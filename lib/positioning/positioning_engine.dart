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

import 'dart:async';
import 'dart:io';

import 'package:RefApp/common/device_info.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/consent.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/location.dart';
import 'package:permission_handler/permission_handler.dart';

/// Class that implements logic for positioning. It asks for user consent, obtains the necessary permissions,
/// and provides current location updates.
/// The current implementation will only ask for user consent on Android devices.
class PositioningEngine {
  static final ConsentEngine? _consentEngine = Platform.isAndroid ? ConsentEngine() : null;
  static const int _locationServicePeriodicDurationInSeconds = 3;
  static const int _androidApiLevel30 = 30;
  LocationEngine? _locationEngine;

  StreamController<Location> _locationUpdatesController = StreamController.broadcast();
  StreamController<LocationEngineStatus> _locationEngineStatusController = StreamController.broadcast();

  /// Initializes the location engine.
  Future initLocationEngine({required BuildContext context}) async {
    return _initialize(context);
  }

  /// Displays user consent form.
  Future<ConsentUserReply>? requestUserConsent(BuildContext context) => _consentEngine?.requestUserConsent(context);

  /// Gets user consent state.
  ConsentUserReply? get userConsentState => _consentEngine?.userConsentState;

  /// Gets last known location.
  Location? get lastKnownLocation => _locationEngine?.lastKnownLocation;

  /// Gets the state of the location engine.
  bool get isLocationEngineStarted => _locationEngine != null ? _locationEngine!.isStarted : false;

  /// Gets stream with location updates.
  Stream<Location> get getLocationUpdates => _locationUpdatesController.stream;

  /// Gets stream with location engine status updates.
  Stream<LocationEngineStatus> get getLocationEngineStatusUpdates => _locationEngineStatusController.stream;

  /// Returns [true] by check if permission location service status is enabled.
  Future<bool> get _didLocationServicesEnabled => Permission.location.serviceStatus.isEnabled;

  Future<void> _initialize(BuildContext context) async {
    // Check user consent state.
    if (userConsentState == ConsentUserReply.notHandled) {
      await requestUserConsent(context);
    }
    await _createLocationEngineIfPermissionsGranted();
    _checkLocationServicesPeriodically();
  }

  /// Periodically checks location services and permissions
  /// and requests them if not granted.
  void _checkLocationServicesPeriodically() {
    Future.delayed(Duration(seconds: _locationServicePeriodicDurationInSeconds), () {
      _checkLocationServicesStatus().then((value) {
        _checkLocationServicesPeriodically();
      });
    });
  }

  /// Returns [true] if both [Permission.location] and [Permission.locationAlways]
  /// are granted, otherwise returns [false].
  ///
  /// Returns [false] if location services is not enabled.
  Future<bool> _didLocationPermissionsGranted() async {
    if (await _didLocationServicesEnabled) {
      final PermissionStatus locationPermission = await Permission.location.request();
      PermissionStatus locationAlwaysPermission = await Permission.locationAlways.request();
      if (Platform.isAndroid && await getAndroidApiVersion() >= _androidApiLevel30) {
        // Checking background location permission status again because result of request is denied even if user granted
        // this permission (on Android 11). It looks like a permission_handler plugin bug.
        locationAlwaysPermission = await Permission.locationAlways.status;
      }
      return locationPermission == PermissionStatus.granted && locationAlwaysPermission == PermissionStatus.granted;
    } else {
      return false;
    }
  }

  void _createAndInitLocationEngine() {
    _locationEngine = LocationEngine();
    _locationUpdatesController.onCancel = () => _locationEngine!.stop();
    _locationEngine!.addLocationListener(LocationListener((location) => _locationUpdatesController.add(location)));
    _locationEngine!.addLocationStatusListener(LocationStatusListener(
      (status) => _locationEngineStatusController.add(status),
      (features) {},
    ));
    _locationEngine!.startWithLocationAccuracy(LocationAccuracy.bestAvailable);
  }

  /// Creates and initialises the location engine if all required permissions
  /// are granted.
  Future<void> _createLocationEngineIfPermissionsGranted() async {
    if (await _didLocationPermissionsGranted()) {
      // The required permissions have been granted, let's start the location engine
      _createAndInitLocationEngine();
    } else {
      _locationEngineStatusController.add(LocationEngineStatus.missingPermissions);
    }
  }

  Future<void> _checkLocationServicesStatus() async {
    if (await _didLocationServicesEnabled) {
      if (_locationEngine == null) {
        await _createLocationEngineIfPermissionsGranted();
      } else {
        _locationEngine!.startWithLocationAccuracy(LocationAccuracy.bestAvailable);
      }
    } else {
      _locationEngineStatusController.add(LocationEngineStatus.notAllowed);
    }
  }
}
