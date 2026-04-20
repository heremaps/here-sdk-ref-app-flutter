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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk_reference_application_flutter/common/ui_style.dart';
import 'package:here_sdk_reference_application_flutter/common/utils/navigation/position_status_listener.dart';
import 'package:here_sdk_reference_application_flutter/common/util.dart' as Util;
import 'package:provider/provider.dart';

import 'positioning_engine.dart';

typedef LocationEngineStatusCallback = void Function(LocationEngineStatus status);
typedef LocationUpdatedCallback = void Function(Location location);

/// Mixin that implements logic for positioning. It manages the current location marker and provides location updates.
mixin Positioning implements PositioningStatusListener {
  static const double initDistanceToEarth = 8000; // meters
  static final GeoCoordinates initPosition = GeoCoordinates(52.530932, 13.384915);

  late HereMapController _hereMapController;
  PositioningEngine? _positioningEngine;
  DeviceLocationServicesStatusNotifier? _locationServicesStatusNotifier;

  LocationUpdatedCallback? _onLocationUpdatedCallback;
  StreamSubscription? _locationUpdatesSubscription;

  LocationIndicator? _locationIndicator; // Used when device location is available (shows bearing).
  MapMarker? _locationMarker; // Used as fallback when device location is unavailable.
  bool _locationMarkerVisible = false;
  Location? _lastKnownLocation;

  bool enableMapUpdate = true;

  // Indicates whether the user location marker should be added to the map,
  // based on location permissions and service status.
  bool shouldAddUserLocationMarker = true;

  /// Gets last known location.
  Location? get lastKnownLocation => _positioningEngine?.lastKnownLocation ?? _lastKnownLocation;

  /// Gets the state of the location engine.
  bool get isLocationEngineStarted => _positioningEngine?.isLocationEngineStarted ?? false;

  /// Gets the state of the current location marker.
  bool get locationVisible => _locationMarkerVisible;

  /// Returns the best available location: positioning engine > cached > default.
  Location get _displayLocation {
    return _positioningEngine?.lastKnownLocation ?? _lastKnownLocation ?? Location.withCoordinates(initPosition);
  }

  /// Sets the state of the current location marker.
  set locationVisible(bool visible) {
    if (_locationIndicator == null && _locationMarker == null) {
      _locationMarkerVisible = visible;
      return;
    }

    if (visible) {
      if (_locationIndicator != null) {
        _locationIndicator!.enable(_hereMapController);
        _locationIndicator!.updateLocation(_displayLocation);
      } else if (_locationMarker != null) {
        _hereMapController.mapScene.addMapMarker(_locationMarker!);
      }
    } else {
      _locationIndicator?.disable();
      if (_locationMarker != null) {
        _hereMapController.mapScene.removeMapMarker(_locationMarker!);
      }
    }

    _locationMarkerVisible = visible;
  }

  /// Removes both the [LocationIndicator] and [MapMarker] from the map and resets visibility.
  void _removeMarkers() {
    _locationIndicator?.disable();
    _locationIndicator = null;
    if (_locationMarker != null) {
      _hereMapController.mapScene.removeMapMarker(_locationMarker!);
      _locationMarker = null;
    }
    _locationMarkerVisible = false;
  }

  /// Initializes positioning. The [hereMapController] is used to display current position marker,
  /// [onLocationUpdated] callbacks is required to get location updates.
  void initPositioning({
    required BuildContext context,
    required HereMapController hereMapController,
    LocationUpdatedCallback? onLocationUpdated,
  }) {
    _hereMapController = hereMapController;
    _onLocationUpdatedCallback = onLocationUpdated;

    _positioningEngine = Provider.of<PositioningEngine>(context, listen: false);
    // Ensure that any previously applied markers are removed before applying a new one,
    // when the app is resumed.
    _removeMarkers();
    _locationServicesStatusNotifier?.stop();
    _locationServicesStatusNotifier = DeviceLocationServicesStatusNotifier()..start(this);
    _initMapLocation();

    _locationUpdatesSubscription = _positioningEngine!.getLocationUpdates.listen(_onLocationUpdated);
  }

  /// Stops positioning.
  void stopPositioning() {
    _locationUpdatesSubscription?.cancel();
    _locationServicesStatusNotifier?.stop();
    _locationServicesStatusNotifier = null;
    _removeMarkers();
  }

  /// Checks current device location availability and places the initial location marker on the map.
  Future<void> _initMapLocation() async {
    final bool canShowBearing = await _locationServicesStatusNotifier!.canLocateUserPositioning();

    final Location? lastKnownLocation = _positioningEngine!.lastKnownLocation;
    if (lastKnownLocation != null) {
      final double accuracy = (lastKnownLocation.horizontalAccuracyInMeters != null)
          ? lastKnownLocation.horizontalAccuracyInMeters!
          : 0;

      // Show the obtained last known location on a map.
      _addMyLocationToMap(
        geoCoordinates: lastKnownLocation.coordinates,
        accuracyRadiusInMeters: accuracy,
        canShowUserLocationMarker: shouldAddUserLocationMarker,
        showLocationWithBearing: canShowBearing,
      );
      // Update the map viewport to be centered on the location.
      if (enableMapUpdate) {
        _hereMapController.camera.lookAtPointWithMeasure(
          lastKnownLocation.coordinates,
          MapMeasure(MapMeasureKind.distanceInMeters, initDistanceToEarth),
        );
      }
    } else {
      // No last known location available, show a pre-defined location.
      _addMyLocationToMap(
        geoCoordinates: initPosition,
        canShowUserLocationMarker: shouldAddUserLocationMarker,
        showLocationWithBearing: canShowBearing,
      );
      // Update the map viewport to be centered on the location.
      if (enableMapUpdate) {
        _hereMapController.camera.lookAtPointWithMeasure(
          initPosition,
          MapMeasure(MapMeasureKind.distanceInMeters, initDistanceToEarth),
        );
      }
    }
  }

  /// Clears any existing marker/indicator and adds the appropriate one based on [showLocationWithBearing].
  /// When true, uses [LocationIndicator] with bearing; when false, uses a static [MapMarker].
  void _addMyLocationToMap({
    required GeoCoordinates geoCoordinates,
    double accuracyRadiusInMeters = 0,
    bool canShowUserLocationMarker = true,
    bool showLocationWithBearing = true,
  }) {
    _locationIndicator?.disable();
    _locationIndicator = null;
    if (_locationMarker != null) {
      _hereMapController.mapScene.removeMapMarker(_locationMarker!);
      _locationMarker = null;
    }

    if (showLocationWithBearing) {
      _locationIndicator = LocationIndicator()
        ..locationIndicatorStyle = LocationIndicatorIndicatorStyle.pedestrian
        ..isAccuracyVisualized = true;
    } else {
      final int markerSize = (UIStyle.locationMarkerSize * _hereMapController.pixelScale).truncate();
      _locationMarker = Util.createMarkerWithImagePath(geoCoordinates, 'assets/position.svg', markerSize, markerSize);
    }

    // Add the location indicator based on the flag [canShowUserLocationMarker].
    locationVisible = canShowUserLocationMarker;
  }

  void _onLocationUpdated(Location location) {
    _lastKnownLocation = location;
    if (_locationMarkerVisible) {
      if (_locationIndicator != null) {
        _locationIndicator!.updateLocation(location);
      } else if (_locationMarker != null) {
        final int markerSize = (UIStyle.locationMarkerSize * _hereMapController.pixelScale).truncate();
        _hereMapController.mapScene.removeMapMarker(_locationMarker!);
        _locationMarker = Util.createMarkerWithImagePath(
          location.coordinates,
          'assets/position.svg',
          markerSize,
          markerSize,
        );
        _hereMapController.mapScene.addMapMarker(_locationMarker!);
      }
    }

    // Update the map viewport to be centered on the location.
    if (enableMapUpdate) {
      _hereMapController.camera.lookAtPoint(location.coordinates);
    }

    _onLocationUpdatedCallback?.call(location);
  }

  /// Called by [DeviceLocationServicesStatusNotifier] when device location services are toggled.
  /// Rebuilds the map marker presentation to match the new availability state.
  @override
  void didDevicePositioningStatusUpdated({required bool isPositioningAvailable, required bool hasPermissionsGranted}) {
    final bool canShowBearing = isPositioningAvailable && hasPermissionsGranted;
    final Location currentLocation = _displayLocation;
    final double accuracy = currentLocation.horizontalAccuracyInMeters ?? 0;

    _addMyLocationToMap(
      geoCoordinates: currentLocation.coordinates,
      accuracyRadiusInMeters: accuracy,
      canShowUserLocationMarker: shouldAddUserLocationMarker,
      showLocationWithBearing: canShowBearing,
    );
  }
}
