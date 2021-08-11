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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:here_sdk/consent.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/ui_style.dart';
import '../common/util.dart' as Util;

typedef LocationEngineStatusCallback = void Function(LocationEngineStatus status);
typedef LocationUpdatedCallback = void Function(Location location);

/// Mixin that implements logic for positioning. It asks for user consent, obtains the necessary permissions,
/// and provides current location updates to classes that use this mixin.
/// The current implementation will only ask for user consent on Android devices.
mixin Positioning {
  static const double initDistanceToEarth = 8000; // meters
  static final GeoCoordinates initPosition = GeoCoordinates(52.530932, 13.384915);
  static final ConsentEngine _consentEngine = Platform.isAndroid ? ConsentEngine() : null;

  HereMapController _hereMapController;
  LocationEngine _locationEngine;

  LocationEngineStatusCallback _onLocationEngineStatus;
  LocationUpdatedCallback _onLocationUpdatedCallback;

  MapPolygon _locationAccuracyCircle;
  MapMarker _locationMarker;
  bool _locationMarkerVisible = false;

  bool enableMapUpdate = true;

  /// Gets last known location.
  Location get lastKnownLocation => _locationEngine?.lastKnownLocation;

  /// Gets the state of the location engine.
  bool get isLocationEngineStarted => _locationEngine != null ? _locationEngine.isStarted : false;

  /// Gets the state of the current location marker.
  bool get locationVisible => _locationMarkerVisible;

  /// Sets the state of the current location marker.
  set locationVisible(bool visible) {
    if (_hereMapController != null && _locationMarker != null) {
      if (visible) {
        _hereMapController.mapScene.addMapMarker(_locationMarker);
        _hereMapController.mapScene.addMapPolygon(_locationAccuracyCircle);
      } else {
        _hereMapController.mapScene.removeMapMarker(_locationMarker);
        _hereMapController.mapScene.removeMapPolygon(_locationAccuracyCircle);
      }
      _locationMarkerVisible = visible;
    }
  }

  /// Releases resources.
  void releaseLocationEngine() {
    _locationEngine?.release();
    _consentEngine?.release();
  }

  /// Initializes the location engine. The [hereMapController] is used to display current position marker,
  /// [onLocationEngineStatus] and [onLocationUpdated] callbacks are required to get location updates.
  void initLocationEngine({
    @required BuildContext context,
    @required HereMapController hereMapController,
    LocationEngineStatusCallback onLocationEngineStatus,
    LocationUpdatedCallback onLocationUpdated,
  }) async {
    _hereMapController = hereMapController;
    _onLocationEngineStatus = onLocationEngineStatus;
    _onLocationUpdatedCallback = onLocationUpdated;

    await _askPermissions(context);
  }

  /// Displays user consent form.
  Future<ConsentUserReply> requestUserConsent(BuildContext context) => _consentEngine?.requestUserConsent(context);

  /// Gets user consent state.
  ConsentUserReply get userConsentState {
    return _consentEngine?.userConsentState;
  }

  void _askPermissions(BuildContext context) async {
    if (userConsentState == ConsentUserReply.notHandled) {
      await requestUserConsent(context);
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();

    final bool locationEnabled = await Permission.location.serviceStatus.isEnabled;

    if (statuses.containsKey(Permission.location) && statuses[Permission.location].isGranted && locationEnabled) {
      // The required permissions have been granted, let's start the location engine
      await _createAndInitLocationEngine();
      return;
    }

    _addMyLocationToMap(geoCoordinates: initPosition);
    if (_onLocationEngineStatus != null) {
      _onLocationEngineStatus(LocationEngineStatus.missingPermissions);
    }
  }

  void _createAndInitLocationEngine() async {
    releaseLocationEngine();

    _locationEngine = LocationEngine();
    _locationEngine.addLocationListener(LocationListener((location) => _onLocationUpdated(location)));
    _locationEngine.addLocationStatusListener(LocationStatusListener(_onStatusChanged, null));

    LocationEngineStatus status = _locationEngine.startWithLocationAccuracy(LocationAccuracy.bestAvailable);
    if (status != LocationEngineStatus.alreadyStarted && status != LocationEngineStatus.engineStarted) {
      return;
    }

    final Location lastKnownLocation = _locationEngine.lastKnownLocation;
    if (lastKnownLocation != null) {
      final double accuracy =
          (lastKnownLocation.horizontalAccuracyInMeters != null) ? lastKnownLocation.horizontalAccuracyInMeters : 0;

      // Show the obtained last known location on a map.
      _addMyLocationToMap(geoCoordinates: lastKnownLocation.coordinates, accuracyRadiusInMeters: accuracy);
      // Update the map viewport to be centered on the location.
      if (enableMapUpdate) {
        _hereMapController.camera.lookAtPointWithDistance(lastKnownLocation.coordinates, initDistanceToEarth);
      }
    } else {
      // No last known location available, show a pre-defined location.
      _addMyLocationToMap(geoCoordinates: initPosition);
      // Update the map viewport to be centered on the location.
      if (enableMapUpdate) {
        _hereMapController.camera.lookAtPointWithDistance(initPosition, initDistanceToEarth);
      }
    }
  }

  void _addMyLocationToMap({
    GeoCoordinates geoCoordinates,
    double accuracyRadiusInMeters = 0,
  }) {
    int locationMarkerSize = (UIStyle.locationMarkerSize * _hereMapController.pixelScale).truncate();

    // Transparent halo around the current location.
    _locationAccuracyCircle =
        MapPolygon(_createGeometry(geoCoordinates, accuracyRadiusInMeters), UIStyle.accuracyCircleColor);
    // Image on top of the current location.
    _locationMarker = Util.createMarkerWithImagePath(
      geoCoordinates,
      "assets/position.svg",
      locationMarkerSize,
      locationMarkerSize,
    );

    // Add the circle to the map.
    _hereMapController.mapScene.addMapPolygon(_locationAccuracyCircle);
    _hereMapController.mapScene.addMapMarker(_locationMarker);
    _locationMarkerVisible = true;
  }

  GeoPolygon _createGeometry(GeoCoordinates geoCoordinates, double accuracyRadiusInMeters) {
    GeoCircle geoCircle = GeoCircle(geoCoordinates, accuracyRadiusInMeters);
    GeoPolygon geoPolygon = GeoPolygon.withGeoCircle(geoCircle);
    return geoPolygon;
  }

  void _onLocationUpdated(Location location) {
    final double accuracy = (location.horizontalAccuracyInMeters != null) ? location.horizontalAccuracyInMeters : 0.0;
    if (_locationAccuracyCircle != null) {
      _locationAccuracyCircle.geometry = _createGeometry(location.coordinates, accuracy);
    }
    if (_locationMarker != null) {
      _locationMarker.coordinates = location.coordinates;
    }

    // Update the map viewport to be centered on the location.
    if (enableMapUpdate) {
      _hereMapController.camera.lookAtPoint(location.coordinates);
    }

    if (_onLocationUpdatedCallback != null) {
      _onLocationUpdatedCallback(location);
    }
  }

  void _onStatusChanged(LocationEngineStatus status) {
    if (_onLocationEngineStatus != null) {
      _onLocationEngineStatus(status);
    }
  }
}
