/*
 * Copyright (C) 2020-2023 HERE Europe B.V.
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
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart' as Navigation;
import 'package:here_sdk/routing.dart' as Routing;
import 'package:here_sdk/transport.dart' as Transport;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ringtone_player/ringtone_player.dart';
import 'package:wakelock/wakelock.dart';

import '../common/application_preferences.dart';
import '../common/custom_map_style_settings.dart';
import '../common/local_notifications_helper.dart';
import '../common/marquee_widget.dart';
import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import '../landing_screen.dart';
import '../route_preferences/route_preferences_model.dart';
import 'current_maneuver_widget.dart';
import 'maneuver_action_text_helper.dart';
import 'navigation_dialogs.dart' as Dialogs;
import 'navigation_progress_widget.dart';
import 'navigation_speed_widget.dart';
import 'next_maneuver_widget.dart';
import 'rerouting_handler.dart';
import 'rerouting_indicator_widget.dart';

/// Navigation mode screen widget.
class NavigationScreen extends StatefulWidget {
  static const String navRoute = "/navigation";

  /// Initial route for navigation.
  final Routing.Route route;

  /// Waypoints lists of the route.
  final List<Routing.Waypoint> wayPoints;

  /// Constructs a widget.
  NavigationScreen({
    Key? key,
    required this.route,
    required this.wayPoints,
  }) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with WidgetsBindingObserver {
  static const double _kInitDistanceToEarth = 1000; // meters
  static const double _kSpeedFactor = 1.3;
  static const int _kNotificationIntervalInMilliseconds = 500;
  static const double _kDistanceToShowNextManeuver = 500;
  static const double _kTopBarHeight = 100;
  static const double _kBottomBarHeight = 130;
  static const double _kHereLogoOffset = 75;
  static const double _kPrincipalPointOffset = 160;

  // This is example code and not for real use.
  // These values are usually country specific and may vary depending on the navigation segment.
  static const double _kDefaultSpeedLimitOffset = 1;
  static const double _kDefaultSpeedLimitBoundary = 50;

  final GlobalKey _mapKey = GlobalKey();

  late Routing.Route _currentRoute;

  late HereMapController _hereMapController;
  late MapPolyline _mapRoute;
  late MapMarker _startMarker;
  late MapMarker _finishMarker;

  Navigation.LocationSimulator? _locationSimulator;
  LocationEngine? _locationEngine;
  late Navigation.VisualNavigator _visualNavigator;
  bool _navigationStarted = false;

  bool _soundEnabled = true;
  FlutterTts _flutterTts = FlutterTts();

  late int _remainingDistanceInMeters;
  late int _remainingDurationInSeconds;
  int? _currentManeuverIndex;
  int _currentManeuverDistance = 0;
  int? _nextManeuverIndex;
  int _nextManeuverDistance = 0;
  String? _currentStreetName;
  double? _currentSpeedLimit;
  double? _currentSpeed;
  Navigation.SpeedWarningStatus _speedWarningStatus = Navigation.SpeedWarningStatus.speedLimitRestored;

  late ReroutingHandler _reroutingHandler;
  bool _reroutingInProgress = false;

  AppLifecycleState? _appLifecycleState;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _visualNavigator = Navigation.VisualNavigator();
    _remainingDistanceInMeters = widget.route.lengthInMeters;
    _remainingDurationInSeconds = widget.route.duration.inSeconds;
    _currentRoute = widget.route;
    WidgetsBinding.instance.addObserver(this);

    _reroutingHandler = ReroutingHandler(
      visualNavigator: _visualNavigator,
      wayPoints: widget.wayPoints,
      preferences: context.read<RoutePreferencesModel>(),
      onBeginRerouting: () => setState(() => _reroutingInProgress = true),
      onNewRoute: _onNewRoute,
      offline: Provider.of<AppPreferences>(context, listen: false).useAppOffline,
    );
  }

  @override
  void dispose() {
    _reroutingHandler.release();
    _locationSimulator?.stop();
    _flutterTts.stop();
    WidgetsBinding.instance.removeObserver(this);
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? nextManeuverWidget = _reroutingInProgress ? null : _buildNextManeuver(context);
    PreferredSize? topBarWidget = _buildTopBar(context);
    double topOffset = MediaQuery.of(context).padding.top - UIStyle.popupsBorderRadius;

    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: topBarWidget,
        body: Padding(
          padding: EdgeInsets.only(
            top: topBarWidget != null ? _kTopBarHeight + topOffset : 0,
          ),
          child: Stack(
            children: [
              HereMap(
                key: _mapKey,
                options: HereMapOptions.fromColor(Theme.of(context).colorScheme.background),
                onMapCreated: _onMapCreated,
              ),
              if (nextManeuverWidget != null) nextManeuverWidget,
              if (_navigationStarted) _buildNavigationControls(context),
            ],
          ),
        ),
        extendBodyBehindAppBar: true,
        bottomNavigationBar: _navigationStarted
            ? Container(
                height: _kBottomBarHeight,
                child: NavigationProgress(
                  routeLengthInMeters: _currentRoute.lengthInMeters,
                  remainingDistanceInMeters: _remainingDistanceInMeters,
                  remainingDurationInSeconds: _remainingDurationInSeconds,
                ),
              )
            : null,
      ),
      onWillPop: () async {
        if (await Dialogs.askForExitFromNavigation(context)) {
          _stopNavigation();
          return true;
        }
        return false;
      },
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;

    CustomMapStyleSettings customMapStyleSettings = Provider.of<CustomMapStyleSettings>(context, listen: false);

    MapSceneLoadSceneCallback mapSceneLoadSceneCallback = (MapError? error) async {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      hereMapController.camera.lookAtPointWithMeasure(
        _currentRoute.geometry.vertices.first,
        MapMeasure(MapMeasureKind.distance, _kInitDistanceToEarth),
      );

      hereMapController.setWatermarkLocation(
        Anchor2D.withHorizontalAndVertical(0, 1),
        Point2D(
          -hereMapController.watermarkSize.width / 2,
          -hereMapController.watermarkSize.height / 2,
        ),
      );

      Util.setTrafficLayersVisibilityOnMap(context, hereMapController);

      _addRouteToMap();
      bool? result = await Dialogs.askForPositionSource(context);
      if (result == null) {
        // Nothing answered. Go back.
        Navigator.of(context).pop();
        return;
      }

      if (result) {
        _startSimulatedLocations();
      } else {
        _startRealLocations();
      }

      _startNavigation();
      _addGestureListeners();
    };

    Util.loadMapScene(customMapStyleSettings, hereMapController, mapSceneLoadSceneCallback);
  }

  void _addGestureListeners() {
    _hereMapController.gestures.doubleTapListener = DoubleTapListener((origin) => _enableTracking(false));
    _hereMapController.gestures.panListener =
        PanListener((state, origin, translation, velocity) => _enableTracking(false));
    _hereMapController.gestures.pinchRotateListener = PinchRotateListener(
        (state, pinchOrigin, rotationOrigin, twoFingerDistance, rotation) => _enableTracking(false));
    _hereMapController.gestures.twoFingerPanListener =
        TwoFingerPanListener((state, origin, translation, velocity) => _enableTracking(false));
    _hereMapController.gestures.twoFingerTapListener = TwoFingerTapListener((origin) => _enableTracking(false));
  }

  void _enableTracking(bool enable) {
    setState(() {
      _visualNavigator.cameraBehavior = enable ? Navigation.DynamicCameraBehavior() : null;
    });
  }

  void _createMapRoute() {
    _mapRoute = MapPolyline(_currentRoute.geometry, UIStyle.routeLineWidth, UIStyle.selectedRouteColor);
    _mapRoute.outlineColor = UIStyle.selectedRouteBorderColor;
    _mapRoute.outlineWidth = UIStyle.routeOutLineWidth;
    _hereMapController.mapScene.addMapPolyline(_mapRoute);
  }

  void _addRouteToMap() {
    _createMapRoute();

    int markerSize = (_hereMapController.pixelScale * UIStyle.locationMarkerSize).round();
    _startMarker = Util.createMarkerWithImagePath(
      _currentRoute.geometry.vertices.first,
      "assets/position.svg",
      markerSize,
      markerSize,
      drawOrder: UIStyle.waypointsMarkerDrawOrder,
    );
    _hereMapController.mapScene.addMapMarker(_startMarker);

    markerSize = (_hereMapController.pixelScale * UIStyle.searchMarkerSize * 2).round();
    _finishMarker = Util.createMarkerWithImagePath(
      _currentRoute.geometry.vertices.last,
      "assets/map_marker_big.svg",
      markerSize,
      markerSize,
      drawOrder: UIStyle.waypointsMarkerDrawOrder,
      anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
    );
    _hereMapController.mapScene.addMapMarker(_finishMarker);

    _zoomToWholeRoute();
  }

  void _zoomToWholeRoute() {
    final BuildContext? context = _mapKey.currentContext;
    if (context != null) {
      _hereMapController.zoomToLogicalViewPort(geoBox: widget.route.boundingBox, context: context);
    }
  }

  void _startSimulatedLocations() {
    Navigation.LocationSimulatorOptions options = Navigation.LocationSimulatorOptions()
      ..speedFactor = _kSpeedFactor
      ..notificationInterval = Duration(milliseconds: _kNotificationIntervalInMilliseconds);

    _locationSimulator = Navigation.LocationSimulator.withRoute(widget.route, options);
    _locationSimulator!.listener = _visualNavigator;
    _locationSimulator!.start();

    // Start location engine to allow background mode under iOS
    if (Platform.isIOS) {
      _startRealLocations(addListener: false);
    }
  }

  void _startRealLocations({bool addListener = true}) {
    _locationEngine = LocationEngine();
    _locationEngine!.setBackgroundLocationAllowed(true);
    _locationEngine!.setBackgroundLocationIndicatorVisible(true);
    _locationEngine!.setPauseLocationUpdatesAutomatically(true);
    if (addListener) {
      _locationEngine!.addLocationListener(_visualNavigator);
    }
    _locationEngine!.startWithLocationAccuracy(LocationAccuracy.bestAvailable);
  }

  void _startNavigation() {
    _hereMapController.mapScene.removeMapMarker(_startMarker);

    _visualNavigator.startRendering(_hereMapController);
    _visualNavigator.isRouteVisible = false;

    _setupListeners();
    _setupVoiceTextMessages();

    _visualNavigator.route = _currentRoute;

    setState(() {
      _navigationStarted = true;
    });
  }

  void _setupListeners() {
    _visualNavigator.routeProgressListener = Navigation.RouteProgressListener((routeProgress) {
      List<Navigation.SectionProgress> sectionProgressList = routeProgress.sectionProgress;

      int? currentManeuverIndex;
      int currentManeuverDistance = 0;
      int? nextManeuverIndex;
      int nextManeuverDistance = 0;

      List<Navigation.ManeuverProgress> nextManeuverList = routeProgress.maneuverProgress;
      if (nextManeuverList.isNotEmpty) {
        currentManeuverIndex = nextManeuverList.first.maneuverIndex;
        currentManeuverDistance = nextManeuverList.first.remainingDistanceInMeters;

        if (nextManeuverList.length > 1) {
          nextManeuverIndex = nextManeuverList[1].maneuverIndex;
          nextManeuverDistance = nextManeuverList[1].remainingDistanceInMeters;
        }
      }

      setState(() {
        _remainingDistanceInMeters = sectionProgressList.last.remainingDistanceInMeters;
        _remainingDurationInSeconds = sectionProgressList.last.remainingDuration.inSeconds;

        _currentManeuverIndex = currentManeuverIndex;
        _currentManeuverDistance = currentManeuverDistance;
        _nextManeuverIndex = nextManeuverIndex;
        _nextManeuverDistance = nextManeuverDistance;
      });
    });

    _visualNavigator.navigableLocationListener = Navigation.NavigableLocationListener((location) {
      if (_currentSpeed != location.originalLocation.speedInMetersPerSecond) {
        setState(() {
          _currentSpeed = location.originalLocation.speedInMetersPerSecond;
        });
      }
    });

    _visualNavigator.roadTextsListener = Navigation.RoadTextsListener((roadTexts) {
      if (_currentStreetName != roadTexts.names.getDefaultValue()) {
        setState(() => _currentStreetName = roadTexts.names.getDefaultValue());
      }
    });

    if (_currentRoute.requestedTransportMode != Transport.TransportMode.pedestrian) {
      _visualNavigator.speedLimitListener = Navigation.SpeedLimitListener((speedLimit) {
        if (_currentSpeedLimit != speedLimit.speedLimitInMetersPerSecond) {
          setState(() => _currentSpeedLimit = speedLimit.speedLimitInMetersPerSecond);
        }
      });

      final Navigation.SpeedLimitOffset offset = Navigation.SpeedLimitOffset()
        ..lowSpeedOffsetInMetersPerSecond = _kDefaultSpeedLimitOffset
        ..highSpeedOffsetInMetersPerSecond = _kDefaultSpeedLimitOffset
        ..highSpeedBoundaryInMetersPerSecond = _kDefaultSpeedLimitBoundary;
      _visualNavigator.speedWarningOptions = Navigation.SpeedWarningOptions(offset);
      _visualNavigator.speedWarningListener = Navigation.SpeedWarningListener((status) {
        if (status == Navigation.SpeedWarningStatus.speedLimitExceeded && _soundEnabled) {
          RingtonePlayer.play(android: Android.notification, ios: Ios.triTone);
        }
        setState(() => _speedWarningStatus = status);
      });
    }

    _visualNavigator.destinationReachedListener = Navigation.DestinationReachedListener(() {
      _stopNavigation();
      Navigator.of(context).popUntil((route) => route.settings.name == LandingScreen.navRoute);
    });

    _visualNavigator.routeDeviationListener = _reroutingHandler;
    _visualNavigator.milestoneStatusListener = _reroutingHandler;
  }

  void _setupVoiceTextMessages() async {
    await _flutterTts.setLanguage("en-US");

    _visualNavigator.maneuverNotificationListener = Navigation.ManeuverNotificationListener((text) {
      if (_soundEnabled) {
        _flutterTts.speak(text);
      }

      if (_appLifecycleState == AppLifecycleState.paused && _currentManeuverIndex != null) {
        Routing.Maneuver? maneuver = _visualNavigator.getManeuver(_currentManeuverIndex!);

        if (maneuver != null) {
          LocalNotificationsHelper.showManeuverNotification(
            _getRemainingTimeString(),
            text,
            maneuver.action.imagePath,
            !_soundEnabled,
          );
        }
      }
    });
  }

  String _getRemainingTimeString() {
    String arrivalInfo = AppLocalizations.of(context)!.arrivalTimeTitle +
        ": " +
        DateFormat.Hm().format(DateTime.now().add(Duration(seconds: _remainingDurationInSeconds)));
    return arrivalInfo;
  }

  void _stopNavigation() {
    _visualNavigator.route = null;
    _visualNavigator.stopRendering();
    _locationSimulator?.stop();
    _locationEngine?.setBackgroundLocationAllowed(false);
    _locationEngine?.setBackgroundLocationIndicatorVisible(false);
    _locationEngine?.setPauseLocationUpdatesAutomatically(false);
  }

  void _onNewRoute(Routing.Route? newRoute) {
    if (newRoute == null) {
      // rerouting failed
      setState(() => _reroutingInProgress = false);
      return;
    }

    _visualNavigator.route = null;
    _hereMapController.mapScene.removeMapPolyline(_mapRoute);

    _currentRoute = newRoute;
    _remainingDistanceInMeters = _currentRoute.lengthInMeters;
    _remainingDurationInSeconds = _currentRoute.duration.inSeconds;
    _currentManeuverIndex = null;
    _nextManeuverIndex = null;
    _currentManeuverDistance = 0;
    _visualNavigator.route = _currentRoute;
    _createMapRoute();
    _finishMarker.coordinates = newRoute.geometry.vertices.last;

    setState(() => _reroutingInProgress = false);
  }

  PreferredSize? _buildTopBar(BuildContext context) {
    if (!_navigationStarted) {
      return null;
    }

    Widget child;
    if (_reroutingInProgress || _currentManeuverIndex == null) {
      child = ReroutingIndicator();
    } else {
      Routing.Maneuver? maneuver = _visualNavigator.getManeuver(_currentManeuverIndex!);
      if (maneuver == null) {
        return null;
      }

      child = CurrentManeuver(
        action: maneuver.action,
        distance: _currentManeuverDistance,
        text: maneuver.getActionText(context),
      );
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(_kTopBarHeight),
      child: AppBar(
        shape: UIStyle.bottomRoundedBorder(),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        flexibleSpace: SafeArea(
          child: child,
        ),
      ),
    );
  }

  Widget? _buildNextManeuver(BuildContext context) {
    if (_currentManeuverDistance > _kDistanceToShowNextManeuver || _reroutingInProgress) {
      return null;
    }

    Routing.Maneuver? maneuver = _nextManeuverIndex != null ? _visualNavigator.getManeuver(_nextManeuverIndex!) : null;
    if (maneuver == null) {
      return null;
    }

    Routing.ManeuverAction action = maneuver.action;
    String text = maneuver.getActionText(context);

    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        shape: UIStyle.bottomRoundedBorder(),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.only(
            top: UIStyle.popupsBorderRadius,
          ),
          child: NextManeuver(
            action: action,
            distance: _nextManeuverDistance,
            text: text,
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_visualNavigator.cameraBehavior == null)
          Padding(
            padding: EdgeInsets.only(bottom: UIStyle.contentMarginLarge),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(
                Icons.videocam,
              ),
              backgroundColor: Theme.of(context).colorScheme.background,
              onPressed: () {
                _enableTracking(true);
              },
            ),
          ),
        FloatingActionButton(
          heroTag: null,
          child: Icon(
            _soundEnabled ? Icons.volume_up : Icons.volume_off,
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          onPressed: () async {
            await _flutterTts.stop();
            setState(() => _soundEnabled = !_soundEnabled);
          },
        ),
        Container(
          height: UIStyle.contentMarginLarge,
        ),
        FloatingActionButton(
          heroTag: null,
          child: Icon(
            Icons.close,
            color: UIStyle.stopNavigationButtonIconColor,
          ),
          backgroundColor: UIStyle.stopNavigationButtonColor,
          onPressed: () async {
            if (await Dialogs.askForExitFromNavigation(context)) {
              _stopNavigation();
              Navigator.of(context).popUntil((route) => route.settings.name == LandingScreen.navRoute);
            }
          },
        ),
      ],
    );
  }

  void _setupLogoAndPrincipalPointPosition() {
    final int margin = _currentStreetName != null ? (_kHereLogoOffset * _hereMapController.pixelScale).truncate() : 0;

    _hereMapController.setWatermarkLocation(
      Anchor2D.withHorizontalAndVertical(0.5, 1),
      Point2D(
        -_hereMapController.watermarkSize.width / 2,
        -(_hereMapController.watermarkSize.height / 2) - margin,
      ),
    );

    _hereMapController.camera.principalPoint = Point2D(_hereMapController.viewportSize.width / 2,
        _hereMapController.viewportSize.height - _kPrincipalPointOffset * _hereMapController.pixelScale);
  }

  Widget _buildNavigationControls(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    _setupLogoAndPrincipalPointPosition();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(UIStyle.contentMarginLarge, UIStyle.contentMarginLarge, UIStyle.contentMarginLarge,
            UIStyle.contentMarginLarge + UIStyle.popupsBorderRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (_currentSpeed != null)
              NavigationSpeed(
                currentSpeed: _currentSpeed!,
                speedLimit: _currentSpeedLimit,
                speedWarningStatus: _speedWarningStatus,
              ),
            if (_currentStreetName == null) Spacer(),
            if (_currentStreetName != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: UIStyle.contentMarginLarge,
                    right: UIStyle.contentMarginLarge,
                  ),
                  child: Material(
                    elevation: 2,
                    color: colorScheme.background,
                    borderRadius: BorderRadius.circular(UIStyle.bigButtonHeight),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: UIStyle.contentMarginMedium,
                        right: UIStyle.contentMarginMedium,
                      ),
                      child: Container(
                        height: UIStyle.bigButtonHeight,
                        child: Center(
                          child: MarqueeWidget(
                            child: Text(
                              _currentStreetName!,
                              style: TextStyle(
                                fontSize: UIStyle.hugeFontSize,
                                color: colorScheme.onSecondary,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_navigationStarted) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      if (_currentManeuverIndex != null) {
        final Routing.Maneuver? maneuver = _visualNavigator.getManeuver(_currentManeuverIndex!);

        if (maneuver != null) {
          LocalNotificationsHelper.startNotifications(
            _getRemainingTimeString(),
            maneuver.getActionText(context),
            maneuver.action.imagePath,
          );
        }
      }
      _visualNavigator.stopRendering();
    }
    if (state == AppLifecycleState.resumed) {
      LocalNotificationsHelper.stopNotifications();
      SchedulerBinding.instance
          .addPostFrameCallback((timeStamp) => _visualNavigator.startRendering(_hereMapController));
    }
    if (state == AppLifecycleState.detached) {
      LocalNotificationsHelper.stopNotifications();
      _stopNavigation();
      Navigator.of(context).popUntil((route) => route.settings.name == LandingScreen.navRoute);
    }
    _appLifecycleState = state;
  }
}

extension _ManeuverImagePath on Routing.ManeuverAction {
  String get imagePath {
    final String subDir = SchedulerBinding.instance.window.platformBrightness == Brightness.light ? "dark" : "light";
    return "assets/maneuvers/$subDir/png/${toString().split(".").last}.png";
  }
}
