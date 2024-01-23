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
import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';

/// This abstract class defines a listener for monitoring device location positioning status changes.
/// Subclasses that implement this class must provide an implementation for the
/// `didDevicePositioningStatusUpdated` method, which will be called when there is a change
/// in the availability of device positioning.
abstract class PositioningStatusListener {
  /// Callback method invoked when the device's positioning status is updated.
  ///
  /// [isPositioningAvailable] - A boolean value indicating whether positioning is available
  /// (true if available, false if not available).
  void didDevicePositioningStatusUpdated({
    required bool isPositioningAvailable,
    required bool hasPermissionsGranted,
  });
}

class DeviceLocationServicesStatusNotifier {
  StreamSubscription<ServiceStatus>? _serviceStatusSteam;
  PositioningStatusListener? _listener;

  /// Starts the location services status listener and will notifies about the status change.
  void start(PositioningStatusListener listener) {
    // Stop the previous status stream, if there is any.
    stop();
    _listener = listener;
    _serviceStatusSteam = Geolocator.getServiceStatusStream().listen(_serviceListener);
  }

  /// Stops the location services status listener and no longer notifies about status change.
  Future<void> stop() async {
    return _serviceStatusSteam?.cancel();
  }

  Future<bool> _hasLocationPermissions() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<bool> canLocateUserPositioning() async {
    return (await _hasLocationPermissions()) && await Geolocator.isLocationServiceEnabled();
  }

  Future<void> _serviceListener(ServiceStatus event) async {
    _listener?.didDevicePositioningStatusUpdated(
      isPositioningAvailable: event == ServiceStatus.enabled,
      hasPermissionsGranted: await _hasLocationPermissions(),
    );
  }

  Future<void> onLocationReceived(Location location) async {
    if (await canLocateUserPositioning()) {
      _listener?.didDevicePositioningStatusUpdated(
        isPositioningAvailable: true,
        hasPermissionsGranted: await _hasLocationPermissions(),
      );
    }
  }
}
