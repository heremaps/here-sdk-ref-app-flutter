/*
 * Copyright (C) 2020-2026 HERE Europe B.V.
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

import 'package:flutter/cupertino.dart';
import 'package:here_sdk/routing.dart';
import 'package:here_sdk/transport.dart'
    show PedestrianSpecification, ScooterSpecification, VehicleSpecification, TransportMode, TransportSpecification;

/// A helper class that contains all of the routing settings.
class RoutePreferencesModel extends ChangeNotifier {
  static final defaultAlternativeRoutes = 1;

  // Keep transport Options readonly to prevent accidental overwriting
  late RouteOptions _sharedRouteOptions;
  late RouteTextOptions _sharedRouteTextOptions;
  late AvoidanceOptions _sharedAvoidanceOptions;
  late PedestrianSpecification _pedestrianSpecification;
  late ScooterSpecification _scooterSpecification;
  late VehicleSpecification _vehicleSpecification;

  /// Sets new routing settings.
  set sharedRouteOptions(RouteOptions value) {
    _sharedRouteOptions = value;
    notifyListeners();
  }

  /// Sets new route text settings.
  set sharedRouteTextOptions(RouteTextOptions value) {
    _sharedRouteTextOptions = value;
    notifyListeners();
  }

  /// Sets new route avoidance settings.
  set sharedAvoidanceOptions(AvoidanceOptions value) {
    _sharedAvoidanceOptions = value;
    notifyListeners();
  }

  set pedestrianSpecification(double walkingSpeed) {
    _pedestrianSpecification.walkingSpeedInMetersPerSecond = walkingSpeed;
    notifyListeners();
  }

  set scooterSpecification(bool allowScooterOnHighway) {
    _scooterSpecification.allowScooterOnHighway = allowScooterOnHighway;
    notifyListeners();
  }

  set vehicleSpecification(VehicleSpecification vehicleSpecification) {
    _vehicleSpecification = vehicleSpecification;
    notifyListeners();
  }

  /// Gets routing settings.
  RouteOptions get sharedRouteOptions => _sharedRouteOptions;

  /// Gets route text settings.
  RouteTextOptions get sharedRouteTextOptions => _sharedRouteTextOptions;

  /// Gets route avoidance settings.
  AvoidanceOptions get sharedAvoidanceOptions => _sharedAvoidanceOptions;

  // Getters for transport options
  PedestrianSpecification get pedestrianSpecification => _pedestrianSpecification;

  ScooterSpecification get scooterSpecification => _scooterSpecification;

  VehicleSpecification get vehicleSpecification => _vehicleSpecification;

  /// Gets routing options for a given transport mode.
  RoutingOptions getRoutingOptions(TransportMode selectedMode) {
    TransportSpecification specification = TransportSpecification();
    specification.transportMode = selectedMode;

    /// Only a subset of HERE SDK transport modes are supported by the Ref App.
    /// If an unsupported mode is requested, an UnimplementedError is thrown.
    switch (selectedMode) {
      case TransportMode.car:
      case TransportMode.truck:
        specification.vehicleSpecification = _vehicleSpecification;
        break;
      case TransportMode.scooter:
        specification.vehicleSpecification = _vehicleSpecification;
        specification.scooterSpecification = _scooterSpecification;
        break;
      case TransportMode.pedestrian:
        specification.pedestrianSpecification = _pedestrianSpecification;
        break;
      default:
        throw UnimplementedError('TransportMode $selectedMode is not supported by the Ref App.');
    }

    return RoutingOptions()..transportSpecification = specification;
  }

  /// Constructs a settings objects with default values.
  RoutePreferencesModel.withDefaults()
    : _pedestrianSpecification = PedestrianSpecification(),
      _scooterSpecification = ScooterSpecification(),
      _vehicleSpecification = VehicleSpecification() {
    _setupSharedOptions();
  }

  _setupSharedOptions() {
    _sharedRouteTextOptions = RouteTextOptions();
    _sharedAvoidanceOptions = AvoidanceOptions();
    _sharedRouteOptions = RouteOptions.withDefaults()..alternatives = defaultAlternativeRoutes;
  }
}
