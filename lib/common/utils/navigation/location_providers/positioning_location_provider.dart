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

import 'package:here_sdk/core.dart';
import 'package:here_sdk/location.dart';

import '../location_provider_interface.dart';

class PositioningLocationProvider extends LocationProviderInterface implements LocationListener {
  PositioningLocationProvider() : _locationEngine = LocationEngine();

  final LocationEngine _locationEngine;
  final List<LocationListener> _listeners = <LocationListener>[];

  @override
  void start() {
    if (_locationEngine.lastKnownLocation != null) {
      onLocationUpdated(_locationEngine.lastKnownLocation!);
    }
    _locationEngine.setBackgroundLocationAllowed(true);
    _locationEngine.setBackgroundLocationIndicatorVisible(true);
    _locationEngine.setPauseLocationUpdatesAutomatically(true);
    _locationEngine
      ..addLocationListener(this)
      ..startWithLocationAccuracy(LocationAccuracy.bestAvailable);
  }

  @override
  void stop() {
    _locationEngine
      ..setBackgroundLocationAllowed(false)
      ..setBackgroundLocationIndicatorVisible(false)
      ..setPauseLocationUpdatesAutomatically(false)
      ..removeLocationListener(this)
      ..stop();
  }

  @override
  void addListener(LocationListener listener) => _listeners.add(listener);

  @override
  void removeListener(LocationListener listener) => _listeners.remove(listener);

  @override
  void removeListeners() => _listeners.clear();

  @override
  void onLocationUpdated(Location location) {
    for (final LocationListener listener in _listeners) {
      listener.onLocationUpdated(location);
    }
  }
}
