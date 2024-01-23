/*
 * Copyright (C) 2020-2024 HERE Europe B.V.
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

/// A helper class that contains all of the routing settings.
class RoutePreferencesModel extends ChangeNotifier {
  static final defaultAlternativeRoutes = 1;

  // Keep transport Options readonly to prevent accidental overwriting
  CarOptions _carOptions;
  TruckOptions _truckOptions;
  ScooterOptions _scooterOptions;
  PedestrianOptions _pedestrianOptions;

  late RouteOptions _sharedRouteOptions;
  late RouteTextOptions _sharedRouteTextOptions;
  late AvoidanceOptions _sharedAvoidanceOptions;

  /// Sets new routing settings for car mode.
  set carOptions(CarOptions value) {
    _carOptions = value;
    notifyListeners();
  }

  /// Sets new routing settings for truck mode.
  set truckOptions(TruckOptions value) {
    _truckOptions = value;
    notifyListeners();
  }

  /// Sets new routing settings for scooter mode.
  set scooterOptions(ScooterOptions value) {
    _scooterOptions = value;
    notifyListeners();
  }

  /// Sets new routing settings for pedestrian mode.
  set pedestrianOptions(PedestrianOptions value) {
    _pedestrianOptions = value;
    notifyListeners();
  }

  /// Sets new routing settings.
  set sharedRouteOptions(RouteOptions value) {
    _sharedRouteOptions = value;
    _carOptions.routeOptions = _truckOptions.routeOptions =
        _scooterOptions.routeOptions = _pedestrianOptions.routeOptions = _sharedRouteOptions;
    notifyListeners();
  }

  /// Sets new route text settings.
  set sharedRouteTextOptions(RouteTextOptions value) {
    _sharedRouteTextOptions = value;
    _carOptions.textOptions = _truckOptions.textOptions =
        _scooterOptions.textOptions = _pedestrianOptions.textOptions = _sharedRouteTextOptions;
    notifyListeners();
  }

  /// Sets new route avoidance settings.
  set sharedAvoidanceOptions(AvoidanceOptions value) {
    _sharedAvoidanceOptions = value;
    _carOptions.avoidanceOptions =
        _truckOptions.avoidanceOptions = _scooterOptions.avoidanceOptions = _sharedAvoidanceOptions;
    notifyListeners();
  }

  /// Gets routing settings for car mode.
  CarOptions get carOptions => _carOptions;

  /// Gets routing settings for truck mode.
  TruckOptions get truckOptions => _truckOptions;

  /// Gets routing settings for scooter mode.
  ScooterOptions get scooterOptions => _scooterOptions;

  /// Gets routing settings for pedestrian mode.
  PedestrianOptions get pedestrianOptions => _pedestrianOptions;

  /// Gets routing settings.
  RouteOptions get sharedRouteOptions => _sharedRouteOptions;

  /// Gets route text settings.
  RouteTextOptions get sharedRouteTextOptions => _sharedRouteTextOptions;

  /// Gets route avoidance settings.
  AvoidanceOptions get sharedAvoidanceOptions => _sharedAvoidanceOptions;

  /// Constructs a settings objects with default values.
  RoutePreferencesModel.withDefaults()
      : _carOptions = CarOptions(),
        _truckOptions = TruckOptions(),
        _scooterOptions = ScooterOptions(),
        _pedestrianOptions = PedestrianOptions() {
    _setupSharedOptions();
  }

  _setupSharedOptions() {
    _sharedRouteTextOptions = RouteTextOptions();
    _sharedAvoidanceOptions = AvoidanceOptions();
    _sharedRouteOptions = RouteOptions.withDefaults();

    _sharedRouteOptions.alternatives = defaultAlternativeRoutes;

    _carOptions.routeOptions = _truckOptions.routeOptions =
        _scooterOptions.routeOptions = _pedestrianOptions.routeOptions = _sharedRouteOptions;

    _carOptions.textOptions = _truckOptions.textOptions =
        _scooterOptions.textOptions = _pedestrianOptions.textOptions = _sharedRouteTextOptions;

    _carOptions.avoidanceOptions =
        _truckOptions.avoidanceOptions = _scooterOptions.avoidanceOptions = _sharedAvoidanceOptions;
  }
}
