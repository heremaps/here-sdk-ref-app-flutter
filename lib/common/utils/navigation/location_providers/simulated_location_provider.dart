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

import 'package:RefApp/common/extensions/location_listener_extension.dart';
import 'package:RefApp/common/utils/navigation/location_provider_interface.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/navigation.dart';
import 'package:here_sdk/routing.dart';

class SimulatedLocationProvider extends LocationProviderInterface implements LocationListener {
  SimulatedLocationProvider.withRoute(Route route, LocationSimulatorOptions options) {
    _simulator = LocationSimulator.withRoute(route, options);
    _simulator.listener = this;
  }

  late LocationSimulator _simulator;
  final List<LocationListener> _listeners = <LocationListener>[];
  LocationEngine? _locationEngine;

  void pause() => _simulator.pause();

  void resume() => _simulator.resume();

  @override
  void start() {
    // Start location engine to allow background mode under iOS
    _locationEngine = LocationEngine()
      ..setBackgroundLocationAllowed(true)
      ..setBackgroundLocationIndicatorVisible(true)
      ..setPauseLocationUpdatesAutomatically(true)
      ..startWithLocationAccuracy(LocationAccuracy.bestAvailable);
    _simulator.start();
  }

  @override
  void stop() {
    _simulator.stop();
    _locationEngine?.setBackgroundLocationAllowed(false);
    _locationEngine?.setBackgroundLocationIndicatorVisible(false);
    _locationEngine?.setPauseLocationUpdatesAutomatically(false);
  }

  @override
  void addListener(LocationListener listener) => _listeners.add(listener);

  @override
  void removeListener(LocationListener listener) => _listeners.remove(listener);

  @override
  void removeListeners() => _listeners.clear();

  @override
  void onLocationUpdated(Location location) => _listeners.notifyOnLocationUpdated(location);
}
