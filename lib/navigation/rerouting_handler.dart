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

import 'dart:async';

import '../route_preferences/route_preferences_model.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/navigation.dart' as Navigation;
import 'package:here_sdk/routing.dart' as Routing;

typedef ReroutingCallback = void Function(Routing.Route? newRoute);

/// Helper class that monitors the deviation from the current route and performs route recalculation if necessary.
/// [Routing.RoutingEngine] is used to calculate a new route. Calculation of a new route starts when the deviation from
/// the current route exceeds [_kMaxRouteDeviation] meters for [_kMaxRouteDeviationTime] seconds.
class ReroutingHandler implements Navigation.RouteDeviationListener, Navigation.MilestoneReachedListener {
  /// The maximum deviation distance in meters.
  static const int _kMaxRouteDeviation = 20;

  /// The maximum duration of deviation from the route in seconds.
  static const int _kMaxRouteDeviationTime = 5;

  /// [Navigation.VisualNavigator] that runs navigation.
  final Navigation.VisualNavigator visualNavigator;

  /// List of way points.
  List<Routing.Waypoint> _wayPoints;

  /// Routing preferences.
  final RoutePreferencesModel preferences;

  /// Called when route calculations is started.
  final VoidCallback onBeginRerouting;

  /// Called when route calculations is finished.
  final ReroutingCallback onNewRoute;

  Routing.RoutingEngine _routingEngine = Routing.RoutingEngine();
  bool _reroutingInProgress = false;
  Timer? _reroutingTimer;
  int _passedWayPointIndex = 0;

  /// Constructs a [ReroutingHandler] object.
  ReroutingHandler({
    required this.visualNavigator,
    required List<Routing.Waypoint> wayPoints,
    required this.preferences,
    required this.onBeginRerouting,
    required this.onNewRoute,
  }) : _wayPoints = wayPoints;

  /// Called by [Navigator] whenever route deviation has been observed.
  @override
  onRouteDeviation(Navigation.RouteDeviation routeDeviation) {
    Routing.Route? route = visualNavigator.route;
    if (route == null || _reroutingInProgress) {
      return;
    }

    // Get current geographic coordinates.
    Navigation.MapMatchedLocation? currentMapMatchedLocation = routeDeviation.currentLocation.mapMatchedLocation;
    GeoCoordinates currentGeoCoordinates = currentMapMatchedLocation == null
        ? routeDeviation.currentLocation.originalLocation.coordinates
        : currentMapMatchedLocation.coordinates;
    double? heading = currentMapMatchedLocation?.bearingInDegrees;

    // Get last geographic coordinates on route.
    GeoCoordinates lastGeoCoordinatesOnRoute;
    if (routeDeviation.lastLocationOnRoute != null) {
      Navigation.MapMatchedLocation? lastMapMatchedLocationOnRoute =
          routeDeviation.lastLocationOnRoute!.mapMatchedLocation;
      lastGeoCoordinatesOnRoute = lastMapMatchedLocationOnRoute == null
          ? routeDeviation.lastLocationOnRoute!.originalLocation.coordinates
          : lastMapMatchedLocationOnRoute.coordinates;
    } else {
      print('User was never following the route. So, we take the start of the route instead.');
      lastGeoCoordinatesOnRoute = route.sections.first.departurePlace.originalCoordinates!;
    }

    int distanceInMeters = currentGeoCoordinates.distanceTo(lastGeoCoordinatesOnRoute).truncate();
    if (distanceInMeters > _kMaxRouteDeviation) {
      _reroutingTimer ??= Timer(
          Duration(seconds: _kMaxRouteDeviationTime), () => _beginRerouting(currentGeoCoordinates, route, heading));
    } else {
      _reroutingTimer?.cancel();
      _reroutingTimer = null;
    }
  }

  /// Releases resources.
  @override
  void release() {
    _reroutingTimer?.cancel();
  }

  void _beginRerouting(GeoCoordinates currentPosition, Routing.Route oldRoute, double? heading) {
    print("Begin rerouting...");
    _reroutingInProgress = true;
    _reroutingTimer = null;
    onBeginRerouting();

    List<Routing.Waypoint> newWayPoints = [
      Routing.Waypoint.withDefaults(currentPosition)..headingInDegrees = heading,
      ..._wayPoints.sublist(_passedWayPointIndex + 1)
    ];

    switch (oldRoute.transportMode) {
      case Routing.TransportMode.car:
        _routingEngine.calculateCarRoute(
            newWayPoints, preferences.carOptions, (error, routes) => _onReroutingEnd(error, routes, newWayPoints));
        break;

      case Routing.TransportMode.truck:
        _routingEngine.calculateTruckRoute(
            newWayPoints, preferences.truckOptions, (error, routes) => _onReroutingEnd(error, routes, newWayPoints));
        break;

      case Routing.TransportMode.scooter:
        _routingEngine.calculateScooterRoute(
            newWayPoints, preferences.scooterOptions, (error, routes) => _onReroutingEnd(error, routes, newWayPoints));
        break;

      case Routing.TransportMode.pedestrian:
        _routingEngine.calculatePedestrianRoute(newWayPoints, preferences.pedestrianOptions,
            (error, routes) => _onReroutingEnd(error, routes, newWayPoints));
        break;

      default:
        assert(false);
    }
  }

  void _onReroutingEnd(Routing.RoutingError? error, List<Routing.Route>? routes, List<Routing.Waypoint> newWayPoints) {
    if (routes == null || routes.isEmpty) {
      if (error != null) {
        print('Routing failed. Error: ${error.toString()}');
      }
      onNewRoute(null);
      _reroutingInProgress = false;
      return;
    }

    onNewRoute(routes.first);

    _wayPoints = newWayPoints;
    _passedWayPointIndex = 0;
    _reroutingInProgress = false;
  }

  /// Called by [Navigator] when a milestone has been reached.
  @override
  onMilestoneReached(Navigation.Milestone milestone) {
    if (milestone.waypointIndex != null) {
      _passedWayPointIndex = milestone.waypointIndex!;
    }
  }
}
