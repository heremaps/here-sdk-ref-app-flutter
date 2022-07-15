/*
 * Copyright (C) 2020-2022 HERE Europe B.V.
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
  LocationEngine? _locationEngine;

  StreamController<Location> _locationUpdatesController = StreamController.broadcast();
  StreamController<LocationEngineStatus> _locationEngineStatusController = StreamController.broadcast();

  bool _locationServicesIsEnabled = false;

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

  Future _initialize(BuildContext context) async {
    if (userConsentState == ConsentUserReply.notHandled) {
      await requestUserConsent(context);
    }

    _locationServicesIsEnabled = await Permission.location.serviceStatus.isEnabled;

    if (!await _askPermissions()) {
      _locationEngineStatusController.add(LocationEngineStatus.missingPermissions);
    }

    Timer.periodic(Duration(seconds: 3), (timer) => _checkLocationServicesStatus());
  }

  Future<bool> _askPermissions() async {
    if (_locationServicesIsEnabled) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
      ].request();

      if (statuses.containsKey(Permission.location) && statuses[Permission.location]!.isGranted) {
        // The required permissions have been granted, let's start the location engine
        _createAndInitLocationEngine();
        return true;
      }
    }

    return false;
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

  void _checkLocationServicesStatus() async {
    bool isEnabled = await Permission.location.serviceStatus.isEnabled;
    if (isEnabled == _locationServicesIsEnabled) {
      return;
    }

    _locationServicesIsEnabled = isEnabled;
    if (_locationServicesIsEnabled) {
      if (_locationEngine == null) {
        _askPermissions();
      } else {
        _locationEngine!.startWithLocationAccuracy(LocationAccuracy.bestAvailable);
      }
    } else {
      _locationEngineStatusController.add(LocationEngineStatus.notAllowed);
    }
  }
}
