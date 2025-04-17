/*
 * Copyright (C) 2020-2025 HERE Europe B.V.
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
import 'package:provider/provider.dart';

import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import 'positioning_engine.dart';

typedef LocationEngineStatusCallback = void Function(LocationEngineStatus status);
typedef LocationUpdatedCallback = void Function(Location location);

/// Mixin that implements logic for positioning. It manages the current location marker and provides location updates.
mixin Positioning {
  static const double initDistanceToEarth = 8000; // meters
  static final GeoCoordinates initPosition = GeoCoordinates(52.530932, 13.384915);

  late HereMapController _hereMapController;
  PositioningEngine? _positioningEngine;

  LocationUpdatedCallback? _onLocationUpdatedCallback;
  StreamSubscription? _locationUpdatesSubscription;

  MapPolygon? _locationAccuracyCircle;
  MapMarker? _locationMarker;
  bool _locationMarkerVisible = false;
  Location? _lastKnownLocation;

  bool enableMapUpdate = true;

  /// Gets last known location.
  Location? get lastKnownLocation => _positioningEngine?.lastKnownLocation ?? _lastKnownLocation;

  /// Gets the state of the location engine.
  bool get isLocationEngineStarted => _positioningEngine?.isLocationEngineStarted ?? false;

  /// Gets the state of the current location marker.
  bool get locationVisible => _locationMarkerVisible;

  /// Sets the state of the current location marker.
  set locationVisible(bool visible) {
    if (_locationMarker != null) {
      if (visible) {
        _hereMapController.mapScene.addMapMarker(_locationMarker!);
        _hereMapController.mapScene.addMapPolygon(_locationAccuracyCircle!);
      } else {
        _hereMapController.mapScene.removeMapMarker(_locationMarker!);
        _hereMapController.mapScene.removeMapPolygon(_locationAccuracyCircle!);
      }
      _locationMarkerVisible = visible;
    }
  }

  void _removeMarkers() {
    if (_locationMarker != null) {
      _hereMapController.mapScene.removeMapMarker(_locationMarker!);
    }
    if (_locationAccuracyCircle != null) {
      _hereMapController.mapScene.removeMapPolygon(_locationAccuracyCircle!);
    }
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
    _initMapLocation();

    _locationUpdatesSubscription = _positioningEngine!.getLocationUpdates.listen(_onLocationUpdated);
  }

  /// Stops positioning.
  void stopPositioning() {
    _locationUpdatesSubscription?.cancel();
    _removeMarkers();
  }

  void _initMapLocation() {
    final Location? lastKnownLocation = _positioningEngine!.lastKnownLocation;
    if (lastKnownLocation != null) {
      final double accuracy =
          (lastKnownLocation.horizontalAccuracyInMeters != null) ? lastKnownLocation.horizontalAccuracyInMeters! : 0;

      // Show the obtained last known location on a map.
      _addMyLocationToMap(geoCoordinates: lastKnownLocation.coordinates, accuracyRadiusInMeters: accuracy);
      // Update the map viewport to be centered on the location.
      if (enableMapUpdate) {
        _hereMapController.camera.lookAtPointWithMeasure(
          lastKnownLocation.coordinates,
          MapMeasure(MapMeasureKind.distanceInMeters, initDistanceToEarth),
        );
      }
    } else {
      // No last known location available, show a pre-defined location.
      _addMyLocationToMap(geoCoordinates: initPosition);
      // Update the map viewport to be centered on the location.
      if (enableMapUpdate) {
        _hereMapController.camera.lookAtPointWithMeasure(
          initPosition,
          MapMeasure(MapMeasureKind.distanceInMeters, initDistanceToEarth),
        );
      }
    }
  }

  void _addMyLocationToMap({
    required GeoCoordinates geoCoordinates,
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
    _hereMapController.mapScene.addMapPolygon(_locationAccuracyCircle!);
    _hereMapController.mapScene.addMapMarker(_locationMarker!);
    _locationMarkerVisible = true;
  }

  GeoPolygon _createGeometry(GeoCoordinates geoCoordinates, double accuracyRadiusInMeters) {
    GeoCircle geoCircle = GeoCircle(geoCoordinates, accuracyRadiusInMeters);
    GeoPolygon geoPolygon = GeoPolygon.withGeoCircle(geoCircle);
    return geoPolygon;
  }

  void _onLocationUpdated(Location location) {
    _lastKnownLocation = location;
    final double accuracy = (location.horizontalAccuracyInMeters != null) ? location.horizontalAccuracyInMeters! : 0.0;
    _locationAccuracyCircle?.geometry = _createGeometry(location.coordinates, accuracy);
    _locationMarker?.coordinates = location.coordinates;

    // Update the map viewport to be centered on the location.
    if (enableMapUpdate) {
      _hereMapController.camera.lookAtPoint(location.coordinates);
    }

    _onLocationUpdatedCallback?.call(location);
  }
}
