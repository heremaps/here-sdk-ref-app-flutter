/*
 * Copyright (C) 2020-2025 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/maploader.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/search.dart';
import 'package:here_sdk_reference_application_flutter/common/extensions/error_handling/map_loader_error_extension.dart';
import 'package:here_sdk_reference_application_flutter/common/file_utility.dart';
import 'package:here_sdk_reference_application_flutter/common/hds_icons/hds_assets_paths.dart';
import 'package:here_sdk_reference_application_flutter/routing/routing_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'common/application_preferences.dart';
import 'common/connection_state_monitor.dart';
import 'common/custom_map_style_settings.dart';
import 'common/hds_icons/hds_icon_widget.dart';
import 'common/load_custom_style_result_popup.dart';
import 'common/place_actions_popup.dart';
import 'common/reset_location_button.dart';
import 'common/ui_style.dart';
import 'common/util.dart' as Util;
import 'download_maps/download_maps_screen.dart';
import 'download_maps/map_loader_controller.dart';
import 'positioning/here_privacy_notice_handler.dart';
import 'positioning/no_location_warning_widget.dart';
import 'positioning/positioning.dart';
import 'positioning/positioning_engine.dart';
import 'routing/waypoint_info.dart';
import 'search/search_popup.dart';

/// The home screen of the application.
class LandingScreen extends StatefulWidget {
  static const String navRoute = "/";
  static final GlobalKey<_LandingScreenState> landingScreenKey = GlobalKey();

  LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with Positioning, WidgetsBindingObserver {
  static const int _kLocationWarningDismissPeriod = 5; // seconds
  static const int _kLoadCustomStyleResultPopupDismissPeriod = 5; // seconds

  bool _mapInitSuccess = false;
  bool _didBackPressedAndPositionStopped = false;
  late HereMapController _hereMapController;
  late PositioningEngine _positioningEngine;
  GlobalKey _hereMapKey = GlobalKey();
  OverlayEntry? _locationWarningOverlay;
  OverlayEntry? _loadCustomSceneResultOverlay;
  MapMarker? _routeFromMarker;
  Place? _routeFromPlace;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    stopPositioning();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stops the location engine when app is detached.
    if (state == AppLifecycleState.detached) {
      // This flag helps us to re-init the positioning when app is resumed.
      _didBackPressedAndPositionStopped = true;
      stopPositioning();
    } else if (state == AppLifecycleState.resumed && _didBackPressedAndPositionStopped) {
      _didBackPressedAndPositionStopped = false;
      // Restart the location engine and initiate positioning when the app is resumed.
      _positioningEngine.initLocationEngine(context: context).then((value) {
        initPositioning(context: context, hereMapController: _hereMapController);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final HereMapOptions options = HereMapOptions()..initialBackgroundColor = Theme.of(context).colorScheme.surface;
    options.renderMode = MapRenderMode.texture;
    return ConnectionStateMonitor(
      mapLoaderController: Provider.of<MapLoaderController>(context, listen: false),
      child: Consumer2<AppPreferences, CustomMapStyleSettings>(
        builder: (context, preferences, customStyleSettings, child) => Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              HereMap(
                key: _hereMapKey,
                options: options,
                onMapCreated: _onMapCreated,
              ),
              _buildMenuButton(),
            ],
          ),
          floatingActionButton: _mapInitSuccess ? _buildFAB(context) : null,
          drawer: _buildDrawer(context, preferences),
          extendBodyBehindAppBar: true,
          onDrawerChanged: (isOpened) => _dismissLocationWarningPopup(),
        ),
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;

    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      hereMapController.camera.lookAtPointWithMeasure(
        Positioning.initPosition,
        MapMeasure(MapMeasureKind.distanceInMeters, Positioning.initDistanceToEarth),
      );

      hereMapController.setWatermarkLocation(
        Anchor2D.withHorizontalAndVertical(0, 1),
        Point2D(
          -hereMapController.watermarkSize.width / 2,
          -hereMapController.watermarkSize.height / 2,
        ),
      );

      _addGestureListeners();

      _positioningEngine = Provider.of<PositioningEngine>(context, listen: false);
      _positioningEngine.getLocationEngineStatusUpdates.listen(_checkLocationStatus);
      _positioningEngine.initLocationEngine(context: context).then((value) {
        initPositioning(context: context, hereMapController: hereMapController);
      });

      setState(() {
        _mapInitSuccess = true;
      });
    });
  }

  Widget _buildMenuButton() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.all(UIStyle.contentMarginLarge),
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(UIStyle.popupsBorderRadius),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(UIStyle.popupsBorderRadius),
              child: Padding(
                padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                child: const HdsIconWidget(HdsAssetsPaths.menuSolidIcon),
              ),
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
    );
  }

  void applyCustomStyle(CustomMapStyleSettings customMapStyleSettings, File file) {
    _hereMapController.mapScene.loadSceneFromConfigurationFile(
      file.path,
      (MapError? error) {
        _showLoadCustomSceneResultPopup(error == null);
        if (error != null) {
          print('Custom scene load failed: ${error.toString()}');
        } else {
          customMapStyleSettings.customMapStyleFilepath = file.path;
        }
      },
    );
  }

  Future<void> loadCustomScene(CustomMapStyleSettings customMapStyleSettings) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    final File file = File(result.files.single.path!);
    final File? localFile = await FileUtility.createLocalSceneFile(file.path);
    if (localFile != null) {
      applyCustomStyle(customMapStyleSettings, localFile);
    } else {
      customMapStyleSettings.reset();
      FileUtility.deleteScenesDirectory();
      _showLoadCustomSceneResultPopup(false);
    }
  }

  void resetCustomScene(CustomMapStyleSettings customMapStyleSettings) {
    customMapStyleSettings.reset();
    FileUtility.deleteScenesDirectory();
    _hereMapController.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (MapError? error) {
        if (error != null) {
          print('Map scene not loaded. MapError: ${error.toString()}');
        }
      },
    );
  }

  List<Widget> _buildLoadCustomSceneItem(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    CustomMapStyleSettings customMapStyleSettings = Provider.of<CustomMapStyleSettings>(context, listen: false);
    return [
      ListTile(
        onTap: () => loadCustomScene(customMapStyleSettings),
        trailing: customMapStyleSettings.customMapStyleFilepath != null
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () => resetCustomScene(customMapStyleSettings),
              )
            : null,
        title: Text(
          appLocalizations.loadCustomScene,
          style: TextStyle(color: themeData.colorScheme.onPrimary),
        ),
        subtitle: customMapStyleSettings.customMapStyleFilepath != null
            ? Text(
                customMapStyleSettings.customMapStyleFilename,
                style: TextStyle(color: themeData.hintColor),
              )
            : null,
      ),
    ];
  }

  Widget _buildDrawer(BuildContext context, AppPreferences preferences) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Drawer(
      child: Ink(
        color: colorScheme.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              child: DrawerHeader(
                padding: EdgeInsets.all(UIStyle.contentMarginLarge),
                decoration: BoxDecoration(
                  color: colorScheme.onSecondary,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/app_logo.svg",
                      width: UIStyle.drawerLogoSize,
                      height: UIStyle.drawerLogoSize,
                    ),
                    SizedBox(
                      width: UIStyle.contentMarginMedium,
                    ),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (_, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            String title = Util.formatString(
                              appLocalizations.appTitleHeader,
                              [
                                snapshot.data?.version ?? '',
                                SDKBuildInformation.sdkVersion().versionGeneration,
                                SDKBuildInformation.sdkVersion().versionMajor,
                                SDKBuildInformation.sdkVersion().versionMinor,
                              ],
                            );
                            return Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            );
                          default:
                            return const SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: HdsIconWidget(HdsAssetsPaths.inboxAttentionIcon, color: colorScheme.onPrimary),
              title: Text(appLocalizations.privacyNotice, style: TextStyle(color: colorScheme.onPrimary)),
              trailing: HdsIconWidget(HdsAssetsPaths.chevronRightIcon, color: colorScheme.onPrimary),
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..pushNamed(HerePrivacyNoticeScreen.navRoute);
              },
            ),
            ListTile(
                leading: Icon(
                  Icons.download_rounded,
                  color: colorScheme.onPrimary,
                ),
                title: Text(
                  appLocalizations.downloadMapsTitle,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(context)
                    ..pop()
                    ..pushNamed(DownloadMapsScreen.navRoute);
                }),
            ..._buildLoadCustomSceneItem(context),
            SwitchListTile(
              title: Text(
                appLocalizations.useMapOfflineSwitch,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                ),
              ),
              value: preferences.useAppOffline,
              onChanged: (newValue) async {
                if (newValue) {
                  MapLoaderController controller = Provider.of<MapLoaderController>(context, listen: false);
                  List<InstalledRegion> installedRegions = [];
                  try {
                    installedRegions = controller.getInstalledRegions();
                  } on MapLoaderExceptionException catch (error) {
                    print(error.error.errorMessage(AppLocalizations.of(context)!));
                  }
                  if (installedRegions.isEmpty) {
                    Navigator.of(context).pop();
                    if (!await Util.showCommonConfirmationDialog(
                      context: context,
                      title: appLocalizations.offlineAppMapsDialogTitle,
                      message: appLocalizations.offlineAppMapsDialogMessage,
                      actionTitle: appLocalizations.downloadMapsTitle,
                    )) {
                      return;
                    }
                    Navigator.of(context).pushNamed(DownloadMapsScreen.navRoute);
                  }
                }
                preferences.useAppOffline = newValue;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!enableMapUpdate)
              ResetLocationButton(
                onPressed: _resetCurrentPosition,
              ),
            Container(
              height: UIStyle.contentMarginMedium,
            ),
            FloatingActionButton(
              child: ClipOval(
                child: Ink(
                  width: UIStyle.bigButtonHeight,
                  height: UIStyle.bigButtonHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        UIStyle.buttonPrimaryColor,
                        UIStyle.buttonSecondaryColor,
                      ],
                    ),
                  ),
                  child: Icon(Icons.search),
                ),
              ),
              onPressed: () => _onSearch(context),
            ),
          ],
        ),
      ],
    );
  }

  void _addGestureListeners() {
    _hereMapController.gestures.panListener = PanListener((state, origin, translation, velocity) {
      if (enableMapUpdate) {
        setState(() => enableMapUpdate = false);
      }
    });

    _hereMapController.gestures.tapListener = TapListener((point) {
      if (_hereMapController.widgetPins.isEmpty) {
        _removeRouteFromMarker();
      }
      _dismissWayPointPopup();
    });

    _hereMapController.gestures.longPressListener = LongPressListener((state, point) {
      if (state == GestureState.begin) {
        _showWayPointPopup(point);
      }
    });
  }

  void _dismissWayPointPopup() {
    if (_hereMapController.widgetPins.isNotEmpty) {
      _hereMapController.widgetPins.first.unpin();
    }
  }

  void _showWayPointPopup(Point2D point) {
    _dismissWayPointPopup();
    GeoCoordinates coordinates =
        _hereMapController.viewToGeoCoordinates(point) ?? _hereMapController.camera.state.targetCoordinates;

    _hereMapController.pinWidget(
      PlaceActionsPopup(
        coordinates: coordinates,
        hereMapController: _hereMapController,
        onLeftButtonPressed: (place) {
          _dismissWayPointPopup();
          _routeFromPlace = place;
          _addRouteFromPoint(coordinates);
        },
        leftButtonIcon: SvgPicture.asset(
          "assets/depart_marker.svg",
          width: UIStyle.bigIconSize,
          height: UIStyle.bigIconSize,
        ),
        onRightButtonPressed: (place) {
          _dismissWayPointPopup();
          _showRoutingScreen(place != null
              ? WayPointInfo.withPlace(
                  place: place,
                  originalCoordinates: coordinates,
                )
              : WayPointInfo.withCoordinates(
                  coordinates: coordinates,
                ));
        },
        rightButtonIcon: SvgPicture.asset(
          "assets/route.svg",
          colorFilter: ColorFilter.mode(UIStyle.addWayPointPopupForegroundColor, BlendMode.srcIn),
          width: UIStyle.bigIconSize,
          height: UIStyle.bigIconSize,
        ),
      ),
      coordinates,
      anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
    );
  }

  void _addRouteFromPoint(GeoCoordinates coordinates) {
    if (_routeFromMarker == null) {
      int markerSize = (_hereMapController.pixelScale * UIStyle.searchMarkerSize).round();
      _routeFromMarker = Util.createMarkerWithImagePath(
        coordinates,
        "assets/depart_marker.svg",
        markerSize,
        markerSize,
        drawOrder: UIStyle.waypointsMarkerDrawOrder,
        anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
      );
      _hereMapController.mapScene.addMapMarker(_routeFromMarker!);
      if (!isLocationEngineStarted) {
        locationVisible = false;
      }
    } else {
      _routeFromMarker!.coordinates = coordinates;
    }
  }

  void _removeRouteFromMarker() {
    if (_routeFromMarker != null) {
      _hereMapController.mapScene.removeMapMarker(_routeFromMarker!);
      _routeFromMarker = null;
      _routeFromPlace = null;
      locationVisible = true;
    }
  }

  void _resetCurrentPosition() {
    GeoCoordinates coordinates = lastKnownLocation != null ? lastKnownLocation!.coordinates : Positioning.initPosition;
    _hereMapController.camera.lookAtPointWithGeoOrientationAndMeasure(
      coordinates,
      GeoOrientationUpdate(double.nan, double.nan),
      MapMeasure(MapMeasureKind.distanceInMeters, Positioning.initDistanceToEarth),
    );

    setState(() => enableMapUpdate = true);
  }

  void _dismissLocationWarningPopup() {
    _locationWarningOverlay?.remove();
    _locationWarningOverlay = null;
  }

  void _checkLocationStatus(LocationEngineStatus status) {
    if (status == LocationEngineStatus.engineStarted || status == LocationEngineStatus.alreadyStarted) {
      _dismissLocationWarningPopup();
      return;
    }
    // If we manually stopped the [_positioning], then no need to show the
    // warning dialog.
    if (status == LocationEngineStatus.engineStopped && _didBackPressedAndPositionStopped) {
      _dismissLocationWarningPopup();
      return;
    }

    if (_locationWarningOverlay == null) {
      _locationWarningOverlay = OverlayEntry(
        builder: (context) => NoLocationWarning(onPressed: () => _dismissLocationWarningPopup()),
      );

      Overlay.of(context).insert(_locationWarningOverlay!);
      Timer(Duration(seconds: _kLocationWarningDismissPeriod), _dismissLocationWarningPopup);
    }
  }

  void _showLoadCustomSceneResultPopup(bool result) {
    _dismissLoadCustomSceneResultPopup();

    _loadCustomSceneResultOverlay = OverlayEntry(
      builder: (context) => LoadCustomStyleResultPopup(
        loadCustomStyleResult: result,
        onClosePressed: () => _dismissLoadCustomSceneResultPopup(),
      ),
    );

    Overlay.of(context).insert(_loadCustomSceneResultOverlay!);
    Timer(Duration(seconds: _kLoadCustomStyleResultPopupDismissPeriod), _dismissLoadCustomSceneResultPopup);
  }

  void _dismissLoadCustomSceneResultPopup() {
    _loadCustomSceneResultOverlay?.remove();
    _loadCustomSceneResultOverlay = null;
  }

  void _onSearch(BuildContext context) async {
    GeoCoordinates currentPosition = _hereMapController.camera.state.targetCoordinates;

    final SearchResult? result = await showSearchPopup(
      context: context,
      currentPosition: currentPosition,
      hereMapController: _hereMapController,
      hereMapKey: _hereMapKey,
    );
    if (result != null) {
      SearchResult searchResult = result;
      assert(searchResult.place != null);
      _showRoutingScreen(WayPointInfo.withPlace(
        place: searchResult.place,
      ));
    }
  }

  void _showRoutingScreen(WayPointInfo destination) async {
    final GeoCoordinates currentPosition =
        lastKnownLocation != null ? lastKnownLocation!.coordinates : Positioning.initPosition;

    await Navigator.of(context).pushNamed(
      RoutingScreen.navRoute,
      arguments: [
        currentPosition,
        _routeFromMarker != null
            ? _routeFromPlace != null
                ? WayPointInfo.withPlace(
                    place: _routeFromPlace,
                    originalCoordinates: _routeFromMarker!.coordinates,
                  )
                : WayPointInfo.withCoordinates(
                    coordinates: _routeFromMarker!.coordinates,
                  )
            : WayPointInfo(coordinates: currentPosition),
        destination,
      ],
    );

    _routeFromPlace = null;
    _removeRouteFromMarker();
  }
}
