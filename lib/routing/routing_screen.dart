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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as Routing;
import 'package:here_sdk/search.dart';
import 'package:provider/provider.dart';

import '../common/custom_map_style_settings.dart';
import '../common/reset_location_button.dart';
import '../navigation/navigation_screen.dart';
import '../positioning/positioning.dart';
import 'route_details_screen.dart';
import '../route_preferences/route_preferences_screen.dart';
import '../route_preferences/route_preferences_model.dart';
import '../route_preferences/transport_modes_widget.dart';
import '../search/place_details_popup.dart';
import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import 'route_info_widget.dart';
import 'route_poi_handler.dart';
import 'route_poi_options_button.dart';
import 'route_waypoints_widget.dart';
import '../common/place_actions_popup.dart';
import '../common/application_preferences.dart';
import 'waypoint_info.dart';
import 'waypoints_controller.dart';

/// Routing mode screen widget.
class RoutingScreen extends StatefulWidget {
  static const String navRoute = "/routing";

  /// Coordinates of the current position.
  final GeoCoordinates currentPosition;

  /// Departure point.
  final WayPointInfo departure;

  /// Destination point.
  final WayPointInfo destination;

  /// Creates a widget.
  RoutingScreen({
    Key? key,
    required this.currentPosition,
    required this.departure,
    required this.destination,
  }) : super(key: key);

  @override
  _RoutingScreenState createState() => _RoutingScreenState();
}

class _RoutingScreenState extends State<RoutingScreen> with TickerProviderStateMixin, Positioning {
  static const double _kTapRadius = 30; // pixels
  static const double _kRouteCardHeight = 85;

  final GlobalKey _bottomBarKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _hereMapKey = GlobalKey();

  late HereMapController _hereMapController;
  bool _mapInitSuccess = false;
  List<Routing.Route> _routes = [];
  List<MapPolyline> _mapRoutes = [];

  Set<String> _poiCategories = {};
  late RoutePoiHandler _routePoiHandler;

  late Routing.RoutingInterface _routingEngine;

  late TabController _routesTabController;
  GlobalKey _tabBarViewKey = GlobalKey();
  int _selectedRouteIndex = 0;
  bool _routingInProgress = false;

  late TabController _transportModesTabController;
  late List<TransportModes> _transportModes;
  late WayPointsController _wayPointsController;

  @override
  void initState() {
    super.initState();

    AppPreferences appPreferences = Provider.of<AppPreferences>(context, listen: false);
    _routingEngine = appPreferences.useAppOffline ? Routing.OfflineRoutingEngine() : Routing.RoutingEngine();

    _routesTabController = TabController(
      length: _routes.length,
      vsync: this,
    );

    _transportModes = appPreferences.useAppOffline ? [TransportModes.car, TransportModes.truck] : TransportModes.values;
    _transportModesTabController = TabController(
      length: _transportModes.length,
      vsync: this,
    );
    _transportModesTabController.addListener(() {
      if (!_transportModesTabController.indexIsChanging) {
        _beginRouting();
      }
    });

    enableMapUpdate = false;

    _wayPointsController = WayPointsController(
      wayPoints: [
        widget.departure,
        widget.destination,
      ],
      currentLocation: widget.currentPosition,
    );
    _wayPointsController.addListener(() => _beginRouting());
  }

  @override
  void dispose() {
    _routePoiHandler.release();
    _transportModesTabController.dispose();
    _routesTabController.dispose();
    stopPositioning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            body: Stack(
              children: [
                HereMap(
                  key: _hereMapKey,
                  onMapCreated: _onMapCreated,
                ),
                if (!Provider.of<AppPreferences>(context, listen: false).useAppOffline) _buildTrafficButton(context),
              ],
            ),
            extendBodyBehindAppBar: true,
            bottomNavigationBar: _mapInitSuccess ? _buildBottomNavigationBar(context) : null,
            floatingActionButton: enableMapUpdate && _mapInitSuccess
                ? null
                : ResetLocationButton(
                    onPressed: _resetCurrentPosition,
                  ),
          ),
          if (_routingInProgress)
            Container(
              color: Colors.white54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      );

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;

    CustomMapStyleSettings customMapStyleSettings = Provider.of<CustomMapStyleSettings>(context, listen: false);

    MapSceneLoadSceneCallback mapSceneLoadSceneCallback = (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      Util.setTrafficLayersVisibilityOnMap(context, hereMapController);

      hereMapController.setWatermarkLocation(
        Anchor2D.withHorizontalAndVertical(0, 1),
        Point2D(
          -hereMapController.watermarkSize.width / 2,
          -hereMapController.watermarkSize.height / 2,
        ),
      );

      hereMapController.camera.lookAtPointWithGeoOrientationAndMeasure(
        widget.currentPosition,
        GeoOrientationUpdate(double.nan, double.nan),
        MapMeasure(MapMeasureKind.distance, Positioning.initDistanceToEarth),
      );
      _routePoiHandler = RoutePoiHandler(
        hereMapController: hereMapController,
        wayPointsController: _wayPointsController,
        onGetText: (place) => Util.makeDistanceString(context, place.distanceInMeters),
        offline: Provider.of<AppPreferences>(context, listen: false).useAppOffline,
      );

      initPositioning(
        context: context,
        hereMapController: hereMapController,
        onLocationUpdated: (location) => _wayPointsController.currentLocation = location.coordinates,
      );

      _addGestureListeners();
      _wayPointsController.mapController = hereMapController;
      _mapInitSuccess = true;
      _beginRouting();
    };

    Util.loadMapScene(customMapStyleSettings, hereMapController, mapSceneLoadSceneCallback);
  }

  void _addGestureListeners() {
    _hereMapController.gestures.panListener = PanListener((state, origin, translation, velocity) {
      if (enableMapUpdate) {
        setState(() => enableMapUpdate = false);
      }
    });

    _hereMapController.gestures.tapListener = TapListener((Point2D touchPoint) {
      _dismissWayPointPopup();
      _pickMapItem(touchPoint);
    });

    _hereMapController.gestures.longPressListener = LongPressListener((state, point) {
      if (state == GestureState.begin) {
        _showWayPointPopup(point);
      }
    });
  }

  void _resetCurrentPosition() {
    GeoCoordinates coordinates = lastKnownLocation != null ? lastKnownLocation!.coordinates : widget.currentPosition;

    _hereMapController.camera.lookAtPointWithGeoOrientationAndMeasure(
      coordinates,
      GeoOrientationUpdate(double.nan, double.nan),
      MapMeasure(MapMeasureKind.distance, Positioning.initDistanceToEarth),
    );
    setState(() => enableMapUpdate = true);
  }

  void _pickMapItem(Point2D touchPoint) {
    _hereMapController.pickMapItems(touchPoint, _kTapRadius, (pickMapItemsResult) async {
      List<MapMarker>? mapMarkersList = pickMapItemsResult?.markers;
      if (mapMarkersList != null && mapMarkersList.length != 0 && _routePoiHandler.isPoiMarker(mapMarkersList.first)) {
        Place place = _routePoiHandler.getPlaceFromMarker(mapMarkersList.first);

        PlaceDetailsPopupResult? result = await showPlaceDetailsPopup(
          context: context,
          place: place,
          routeToEnabled: true,
          addToRouteEnabled: true,
        );

        if (result == null) {
          return;
        }

        WayPointInfo wp = WayPointInfo.withPlace(
          place: place,
        );

        switch (result) {
          case PlaceDetailsPopupResult.routeTo:
            _wayPointsController.value = [
              WayPointInfo(coordinates: lastKnownLocation?.coordinates ?? widget.currentPosition),
              wp,
            ];
            break;
          case PlaceDetailsPopupResult.addToRoute:
            _wayPointsController.insert(_appropriateIndexToInsertWaypoint(wp), wp);
            break;
        }

        return;
      }

      List<MapPolyline>? mapPolyLinesList = pickMapItemsResult?.polylines;
      if (mapPolyLinesList == null || mapPolyLinesList.length == 0) {
        print("No map poly lines found.");
        return;
      }

      _routesTabController.animateTo(_mapRoutes.indexOf(mapPolyLinesList.first));
    });
  }

  int _appropriateIndexToInsertWaypoint(WayPointInfo wayPointInfo) {
    final List<WayPointInfo> waypoints = _wayPointsController.value;
    final GeoPolyline routeLine = _routes[_selectedRouteIndex].geometry;
    final int indexOnRoute = routeLine.getNearestIndexTo(wayPointInfo.coordinates);

    for (int i = 1; i < waypoints.length - 1; ++i) {
      if (routeLine.getNearestIndexTo(waypoints[i].coordinates) > indexOnRoute) {
        return i;
      }
    }

    return waypoints.length - 1;
  }

  void _dismissWayPointPopup() {
    if (_hereMapController.widgetPins.isNotEmpty) {
      _hereMapController.widgetPins.first.unpin();
    }
  }

  void _showWayPointPopup(Point2D point) {
    _dismissWayPointPopup();
    GeoCoordinates? coordinates = _hereMapController.viewToGeoCoordinates(point);

    if (coordinates == null) {
      return;
    }

    _hereMapController.pinWidget(
      PlaceActionsPopup(
        coordinates: coordinates,
        hereMapController: _hereMapController,
        onRightButtonPressed: (place) {
          _dismissWayPointPopup();
          _wayPointsController.add(place != null
              ? WayPointInfo.withPlace(
                  place: place,
                  originalCoordinates: coordinates,
                )
              : WayPointInfo.withCoordinates(
                  coordinates: coordinates,
                ));
        },
      ),
      coordinates,
      anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
    );
  }

  _clearMapRoutes() {
    _mapRoutes.forEach((route) {
      _hereMapController.mapScene.removeMapPolyline(route);
    });
    _mapRoutes.clear();
  }

  _addRoutesToMap() {
    _clearMapRoutes();

    for (int i = 0; i < _routes.length; ++i) {
      _addRouteToMap(_routes[i], i == _selectedRouteIndex);
    }
  }

  _zoomToRoutes() {
    List<GeoCoordinates> bounds = [];

    for (int i = 0; i < _routes.length; ++i) {
      GeoBox geoBox = _routes[i].boundingBox;
      bounds.add(geoBox.northEastCorner);
      bounds.add(geoBox.southWestCorner);
    }

    if (_bottomBarKey.currentContext != null) {
      final RenderBox bottomBarBox = _bottomBarKey.currentContext!.findRenderObject() as RenderBox;
      final GeoBox? geoBox = GeoBox.containingGeoCoordinates(bounds);

      if (geoBox == null) {
        return;
      }

      _hereMapController.zoomGeoBoxToLogicalViewPort(
        geoBox: geoBox,
        viewPort: Rect.fromLTRB(
          0,
          MediaQuery.of(context).padding.top,
          bottomBarBox.size.width,
          MediaQuery.of(context).size.height - bottomBarBox.size.height,
        ).deflate(UIStyle.locationMarkerSize.toDouble()),
      );
    }

    setState(() => enableMapUpdate = false);
  }

  _addRouteToMap(Routing.Route route, bool selected) {
    MapPolyline routeMapPolyline = MapPolyline(
      route.geometry,
      UIStyle.routeLineWidth,
      selected ? UIStyle.selectedRouteColor : UIStyle.routeColor,
    );
    routeMapPolyline.drawOrder = selected ? 1 : 0;
    routeMapPolyline.outlineColor = selected ? UIStyle.selectedRouteBorderColor : UIStyle.routeBorderColor;
    routeMapPolyline.outlineWidth = UIStyle.routeOutLineWidth;

    _hereMapController.mapScene.addMapPolyline(routeMapPolyline);
    _mapRoutes.add(routeMapPolyline);
  }

  _updateSelectedRoute() {
    _mapRoutes[_selectedRouteIndex].lineColor = UIStyle.routeColor;
    _mapRoutes[_selectedRouteIndex].outlineColor = UIStyle.routeBorderColor;
    _mapRoutes[_selectedRouteIndex].drawOrder = 0;

    _mapRoutes[_routesTabController.index].lineColor = UIStyle.selectedRouteColor;
    _mapRoutes[_routesTabController.index].outlineColor = UIStyle.selectedRouteBorderColor;
    _mapRoutes[_routesTabController.index].drawOrder = 1;

    _selectedRouteIndex = _routesTabController.index;

    _zoomToRoutes();
    _routePoiHandler.updatePoiForRoute(_routes[_selectedRouteIndex]);
  }

  Widget _buildTrafficButton(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppPreferences appPreferences = Provider.of<AppPreferences>(context, listen: false);

    return Align(
      alignment: Alignment.topRight,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(UIStyle.contentMarginLarge),
          child: Material(
            color: colorScheme.background,
            borderRadius: BorderRadius.circular(UIStyle.popupsBorderRadius),
            elevation: 2,
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                child: SvgPicture.asset(
                  appPreferences.showTrafficLayers ? "assets/traffic_off.svg" : "assets/traffic_on.svg",
                  colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                  width: UIStyle.bigIconSize,
                  height: UIStyle.bigIconSize,
                ),
              ),
              onTap: () => setState(() {
                appPreferences.showTrafficLayers = !appPreferences.showTrafficLayers;
                Util.setTrafficLayersVisibilityOnMap(context, _hereMapController);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransportTypeWidget(BuildContext context) => Container(
        color: UIStyle.selectedListTileColor,
        child: TransportModesWidget(
          tabController: _transportModesTabController,
          transportModes: _transportModes,
        ),
      );

  Widget _buildBottomNavigationBar(context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations appLocalization = AppLocalizations.of(context)!;
    AppPreferences appPreferences = Provider.of<AppPreferences>(context, listen: false);

    return BottomAppBar(
      key: _bottomBarKey,
      color: colorScheme.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RouteWayPoints(
                  controller: _wayPointsController,
                  hereMapController: _hereMapController,
                  hereMapKey: _hereMapKey,
                  currentLocationTitle: lastKnownLocation != null
                      ? appLocalization.yourLocationTitle
                      : appLocalization.defaultLocationTitle,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                color: colorScheme.primary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          _buildTransportTypeWidget(context),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              RoutePoiOptionsButton(
                categoryIds: _poiCategories,
                onChanged: (categoryIds) {
                  setState(() => _poiCategories = categoryIds);
                  _routePoiHandler.categories = categoryIds.toList();
                  if (_routes.isNotEmpty) {
                    _routePoiHandler.updatePoiForRoute(_routes[_selectedRouteIndex]);
                  }
                },
              ),
              Spacer(),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.preferencesTitle,
                  style: TextStyle(color: colorScheme.secondary),
                ),
                onPressed: () => _awaitOptionsFromPreferenceScreen(context),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: _kRouteCardHeight,
            child: TabBarView(
              key: _tabBarViewKey,
              controller: _routesTabController,
              children: _routes
                  .map(
                    (route) => Card(
                      elevation: 2,
                      child: RouteInfo(
                        route: route,
                        onRouteDetails: appPreferences.useAppOffline
                            ? null
                            : () => Navigator.of(context).pushNamed(
                                  RouteDetailsScreen.navRoute,
                                  arguments: [_routes[_routesTabController.index], _wayPointsController],
                                ),
                        onNavigation: () => Navigator.of(context).pushNamed(
                          NavigationScreen.navRoute,
                          arguments: [route, _wayPointsController.value],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  _beginRouting() {
    _dismissWayPointPopup();
    setState(() => _routingInProgress = true);
    RoutePreferencesModel preferences = Provider.of<RoutePreferencesModel>(context, listen: false);

    switch (_transportModes[_transportModesTabController.index]) {
      case TransportModes.car:
        _routingEngine.calculateCarRoute(_wayPointsController.value, preferences.carOptions, _onRoutingEnd);
        break;
      case TransportModes.truck:
        _routingEngine.calculateTruckRoute(_wayPointsController.value, preferences.truckOptions, _onRoutingEnd);
        break;
      case TransportModes.scooter:
        _routingEngine.calculateScooterRoute(_wayPointsController.value, preferences.scooterOptions, _onRoutingEnd);
        break;
      case TransportModes.walk:
        _routingEngine.calculatePedestrianRoute(
            _wayPointsController.value, preferences.pedestrianOptions, _onRoutingEnd);
        break;
    }
  }

  _onRoutingEnd(Routing.RoutingError? error, List<Routing.Route>? routes) {
    if (routes == null || routes.isEmpty) {
      if (error != null) {
        setState(() => _routingInProgress = false);
        Util.displayErrorSnackBar(
          _scaffoldKey.currentContext!,
          Util.formatString(AppLocalizations.of(context)!.routingErrorText, [error.toString()]),
        );
      }
      return;
    }

    _routePoiHandler.clearPlaces();
    _selectedRouteIndex = 0;
    _routesTabController.dispose();

    _routes = routes;
    _tabBarViewKey = GlobalKey();
    _routesTabController = TabController(
      length: _routes.length,
      vsync: this,
    );
    _routesTabController.addListener(() => _updateSelectedRoute());

    _addRoutesToMap();

    setState(() => _routingInProgress = false);
    _routePoiHandler.updatePoiForRoute(_routes[_selectedRouteIndex]);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _zoomToRoutes());
  }

  void _awaitOptionsFromPreferenceScreen(BuildContext context) async {
    final activeTransportMode = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoutePreferencesScreen(
            activeTransportMode: _transportModes[_transportModesTabController.index],
          ),
        ));

    setState(() => _transportModesTabController.index = max(_transportModes.indexOf(activeTransportMode), 0));
    _beginRouting();
  }
}
