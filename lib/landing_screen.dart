/*
 * Copyright (C) 2020-2021 HERE Europe B.V.
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/consent.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/search.dart';

import 'common/place_actions_popup.dart';
import 'common/reset_location_button.dart';
import 'positioning/no_location_warning_widget.dart';
import 'positioning/positioning.dart';
import 'routing/routing_screen.dart';
import 'routing/waypoint_info.dart';
import 'search/search_popup.dart';
import 'common/ui_style.dart';
import 'common/util.dart' as Util;

/// The home screen of the application.
class LandingScreen extends StatefulWidget {
  static const String navRoute = "/";

  LandingScreen({Key key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with WidgetsBindingObserver, Positioning {
  bool _mapInitSuccess = false;
  HereMapController _hereMapController;
  GlobalKey _hereMapKey = GlobalKey();
  OverlayEntry _locationWarningOverlay;

  MapMarker _routeFromMarker;
  Place _routeFromPlace;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (userConsentState == ConsentUserReply.notHandled) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => requestUserConsent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hereMapController?.release();
    _routeFromMarker?.release();
    _routeFromPlace?.release();
    releaseLocationEngine();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // this callback will be called after the user consent screen is closed
      // rebuild layout with a new key for the map widget
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userConsentState == ConsentUserReply.requesting || userConsentState == ConsentUserReply.notHandled) {
      // don't show the map until asking the user for consent
      return Scaffold();
    }

    return Scaffold(
      body: Stack(
        children: [
          HereMap(
            key: _hereMapKey,
            onMapCreated: _onMapCreated,
          ),
          if (Platform.isAndroid) _buildMenuButton(),
        ],
      ),
      floatingActionButton: _mapInitSuccess ? _buildFAB(context) : null,
      drawer: Platform.isAndroid ? _buildDrawer(context) : null,
      extendBodyBehindAppBar: true,
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController?.release();
    _hereMapController = hereMapController;

    hereMapController.mapScene.loadSceneFromConfigurationFile('preview.normal.day.json', (MapError error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      hereMapController.camera.lookAtPointWithDistance(Positioning.initPosition, Positioning.initDistanceToEarth);
      hereMapController.setWatermarkPosition(WatermarkPlacement.bottomLeft, 0);
      _addGestureListeners();

      initLocationEngine(
        hereMapController: hereMapController,
        onLocationEngineStatus: (status) => _checkLocationStatus(status),
      );

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
            color: colorScheme.background,
            borderRadius: BorderRadius.circular(UIStyle.popupsBorderRadius),
            elevation: 2,
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                child: Icon(
                  Icons.menu,
                  color: colorScheme.primary,
                ),
              ),
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUserConsentItems(BuildContext context) {
    if (userConsentState == null) {
      return [];
    }

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context);

    return [
      if (userConsentState != ConsentUserReply.granted)
        ListTile(
          title: Text(
            appLocalizations.userConsentDescription,
            style: TextStyle(
              color: colorScheme.onSecondary,
            ),
          ),
        ),
      ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.privacy_tip,
              color: userConsentState == ConsentUserReply.granted
                  ? UIStyle.acceptedConsentColor
                  : UIStyle.revokedConsentColor,
            ),
          ],
        ),
        title: Text(
          appLocalizations.userConsentTitle,
          style: TextStyle(
            color: colorScheme.onPrimary,
          ),
        ),
        subtitle: userConsentState == ConsentUserReply.granted
            ? Text(
                appLocalizations.consentGranted,
                style: TextStyle(
                  color: UIStyle.acceptedConsentColor,
                ),
              )
            : Text(
                appLocalizations.consentDenied,
                style: TextStyle(
                  color: UIStyle.revokedConsentColor,
                ),
              ),
        trailing: Icon(
          Icons.arrow_forward,
          color: colorScheme.onPrimary,
        ),
        onTap: () {
          Navigator.of(context).pop();
          _mapInitSuccess = false;
          // force-recreating the map view next time to avoid rendering issues
          _hereMapKey = GlobalKey();
          requestUserConsent();
        },
      ),
    ];
  }

  Widget _buildDrawer(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Drawer(
      child: Ink(
        color: colorScheme.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: UIStyle.drawerHeaderHeight,
              child: DrawerHeader(
                padding: EdgeInsets.all(UIStyle.contentMarginHuge),
                decoration: BoxDecoration(
                  color: colorScheme.onSecondary,
                ),
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: SvgPicture.asset("assets/app_logo.svg"),
                    ),
                    SizedBox(
                      width: UIStyle.contentMarginMedium,
                    ),
                    Expanded(
                      child: Text(
                        appLocalizations.appTitleHeader,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ..._buildUserConsentItems(context),
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
    _hereMapController.gestures.panListener =
        PanListener.fromLambdas(lambda_onPan: (state, origin, translation, velocity) {
      if (enableMapUpdate) {
        setState(() => enableMapUpdate = false);
      }
    });

    _hereMapController.gestures.tapListener = TapListener.fromLambdas(lambda_onTap: (point) {
      if (_hereMapController.widgetPins.isEmpty) {
        _removeRouteFromMarker();
      }
      _dismissWayPointPopup();
    });

    _hereMapController.gestures.longPressListener = LongPressListener.fromLambdas(lambda_onLongPress: (state, point) {
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
    GeoCoordinates coordinates = _hereMapController.viewToGeoCoordinates(point);

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
          color: UIStyle.addWayPointPopupForegroundColor,
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
      _hereMapController.mapScene.addMapMarker(_routeFromMarker);
      if (!isLocationEngineStarted) {
        locationVisible = false;
      }
    } else {
      _routeFromMarker.coordinates = coordinates;
    }
  }

  void _removeRouteFromMarker() {
    if (_routeFromMarker != null) {
      _hereMapController.mapScene.removeMapMarker(_routeFromMarker);
      _routeFromMarker.release();
      _routeFromMarker = null;
      _routeFromPlace?.release();
      _routeFromPlace = null;
      locationVisible = true;
    }
  }

  void _resetCurrentPosition() {
    GeoCoordinates coordinates = lastKnownLocation != null ? lastKnownLocation.coordinates : Positioning.initPosition;

    _hereMapController.camera.lookAtPointWithOrientationAndDistance(
        coordinates, MapCameraOrientationUpdate.withDefaults(), Positioning.initDistanceToEarth);

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

    if (_locationWarningOverlay == null) {
      _locationWarningOverlay = OverlayEntry(
        builder: (context) => NoLocationWarning(
          onPressed: () => _dismissLocationWarningPopup(),
        ),
      );

      Overlay.of(context).insert(_locationWarningOverlay);
    }
  }

  void _onSearch(BuildContext context) async {
    GeoCoordinates currentPosition = _hereMapController.camera.state.targetCoordinates;

    final result = await showSearchPopup(
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
        lastKnownLocation != null ? lastKnownLocation.coordinates : Positioning.initPosition;

    await Navigator.of(context).pushNamed(
      RoutingScreen.navRoute,
      arguments: [
        currentPosition,
        _routeFromMarker != null
            ? _routeFromPlace != null
                ? WayPointInfo.withPlace(
                    place: _routeFromPlace,
                    originalCoordinates: _routeFromMarker.coordinates,
                  )
                : WayPointInfo.withCoordinates(
                    coordinates: _routeFromMarker.coordinates,
                  )
            : WayPointInfo(
                coordinates: currentPosition,
              ),
        destination,
      ],
    );

    _routeFromPlace = null;
    _removeRouteFromMarker();
  }
}
