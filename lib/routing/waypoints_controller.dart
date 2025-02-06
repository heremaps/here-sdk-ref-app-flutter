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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

import '../common/ui_style.dart';
import 'waypoint_info.dart';
import '../common/util.dart' as Util;

/// Helper class that manages routing waypoints. It uses [HereMapController] to display waypoint markers.
class WayPointsController extends ValueNotifier<List<WayPointInfo>> {
  /// Current location.
  GeoCoordinates currentLocation;
  HereMapController? _hereMapController;
  List<MapMarker> _wpMarkers = [];

  /// Creates a [WayPointsController] object.
  WayPointsController({
    required List<WayPointInfo> wayPoints,
    required this.currentLocation,
  }) : super(wayPoints) {
    addListener(() {
      _clearWpMarkers();
      _createWpMarkers();
    });
  }

  /// Sets current [HereMapController].
  set mapController(HereMapController? hereMapController) {
    _clearWpMarkers();
    _hereMapController = hereMapController;
    _createWpMarkers();
  }

  /// Returns waypoints list.
  @override
  List<WayPointInfo> get value => super.value.toList();

  /// Sets waypoints list.
  @override
  set value(List<WayPointInfo> value) {
    if (ListEquality().equals(super.value, value)) {
      return;
    }

    super.value = value;
  }

  /// Gets a waypoint by index [i].
  operator [](int i) => super.value[i];

  /// Sets a waypoint by index [i].
  operator []=(int i, WayPointInfo wp) {
    super.value[i] = wp;
    notifyListeners();
  }

  /// Returns length of the waypoints list.
  int get length => super.value.length;

  /// Adds waypoint to the list.
  void add(WayPointInfo wp) {
    super.value.add(wp);
    notifyListeners();
  }

  /// Adds waypoint [wp] to the list at [index].
  void insert(int index, WayPointInfo wp) {
    super.value.insert(index, wp);
    notifyListeners();
  }

  /// Removes waypoint from the list at [index].
  void removeAt(int index) {
    super.value.removeAt(index);
    notifyListeners();
  }

  void _clearWpMarkers() {
    _wpMarkers.forEach((marker) {
      _hereMapController?.mapScene.removeMapMarker(marker);
    });
    _wpMarkers.clear();
  }

  void _createWpMarkers() {
    _wpMarkers = buildMapMarkersForController(_hereMapController);
  }

  /// Creates [MapMarker] for each waypoint in the list an adds it to the [controller].
  /// Returns a list of created markers.
  List<MapMarker> buildMapMarkersForController(HereMapController? controller) {
    if (controller == null) {
      return [];
    }

    List<MapMarker> markers = [];

    int locationMarkerSize = (controller.pixelScale * UIStyle.locationMarkerSize).truncate();
    int placeBigMarkerSize = (controller.pixelScale * UIStyle.searchMarkerSize).truncate() * 2;

    MapMarker marker = Util.createMarkerWithImagePath(
      super.value[0].coordinates,
      "assets/depart_marker.svg",
      locationMarkerSize,
      locationMarkerSize,
      drawOrder: UIStyle.waypointsMarkerDrawOrder,
    );
    controller.mapScene.addMapMarker(marker);
    markers.add(marker);

    for (int i = 1; i < super.value.length; ++i) {
      marker = Util.createMarkerWithImagePath(
        super.value[i].coordinates,
        "assets/map_marker_big.svg",
        placeBigMarkerSize,
        placeBigMarkerSize,
        drawOrder: UIStyle.waypointsMarkerDrawOrder,
        anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
      );

      controller.mapScene.addMapMarker(marker);
      markers.add(marker);
    }

    return markers;
  }
}
