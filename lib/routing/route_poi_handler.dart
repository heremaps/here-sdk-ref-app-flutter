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
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.threading.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as Routing;
import 'package:here_sdk/search.dart';

import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import '../search/search_engine_proxy.dart';
import 'poi_svg_helper.dart';
import 'waypoints_controller.dart';

typedef GetTextForPoiMarkerCallback = String Function(Place);

/// A class that searches for POI along a route, creates and keeps map markers for resulting POIs.
class RoutePoiHandler {
  static const int _kGeoCorridorRadius = 20;
  static const int _kMaxSearchSuggestion = 100;

  static final Map<String, PoiIconType> _categoryPoiTypes = {
    PlaceCategory.eatAndDrink: PoiIconType.eatAndDrink,
    PlaceCategory.businessAndServicesFuelingStation: PoiIconType.fueling,
    PlaceCategory.businessAndServicesAtm: PoiIconType.atm,
  };

  final SearchOptions _searchOptions = SearchOptions()
    ..languageCode = LanguageCode.enUs
    ..maxItems = _kMaxSearchSuggestion;

  /// [HereMapController] of the map.
  final HereMapController hereMapController;

  /// Way points controller.
  final WayPointsController wayPointsController;

  /// Called to get a localized string describing a place.
  final GetTextForPoiMarkerCallback? onGetText;

  /// If true, offline routing engine should be used.
  final bool offline;

  List<String> _categories = [];
  Map<Routing.Route, List<Place>> _placesForRoutes = {};
  Map<MapMarker, Place> _markers = {};
  late SearchEngineProxy _searchEngine;
  TaskHandle? _poiSearchTask;

  /// Constructs a [RoutePoiHandler] object.
  RoutePoiHandler({
    required this.hereMapController,
    required this.wayPointsController,
    this.onGetText,
    required this.offline,
  }) {
    _searchEngine = SearchEngineProxy(offline: offline);
  }

  /// Releases resources.
  void release() {
    _stopCurrentSearch();
  }

  void _stopCurrentSearch() {
    _poiSearchTask?.cancel();
    _poiSearchTask = null;
  }

  void _clearMarkers() {
    _markers.keys.forEach((marker) {
      hereMapController.mapScene.removeMapMarker(marker);
    });
    _markers.clear();
  }

  /// Sets the desired categories of places to search.
  set categories(List<String> categories) {
    if (ListEquality().equals(categories, _categories)) {
      return;
    }

    _categories = List.from(categories);
    clearPlaces();
  }

  /// Returns true if the [mapMarker] is a POI marker.
  bool isPoiMarker(MapMarker mapMarker) => _markers.containsKey(mapMarker);

  /// Returns [Place] of the [marker].
  Place getPlaceFromMarker(MapMarker marker) => _markers[marker]!;

  /// Removes all found places.
  void clearPlaces() {
    _placesForRoutes.clear();
  }

  /// Searches POI for the [route].
  void updatePoiForRoute(Routing.Route route) async {
    _clearMarkers();
    _stopCurrentSearch();

    if (_placesForRoutes.containsKey(route)) {
      _addMarkersForPlaces(_placesForRoutes[route]!);
    } else {
      if (_categories.isEmpty) {
        return;
      }

      int nestedSearchLimit = 3;
      List<Place>? places = await _searchForVertices(route.geometry.vertices, nestedSearchLimit);
      print('Total results: ${places?.length}');
      if (places?.isNotEmpty ?? false) {
        _placesForRoutes[route] = places!;
        _addMarkersForPlaces(places);
      }
    }
  }

  Future<List<Place>?> _searchForVertices(List<GeoCoordinates> vertices, int nestedCount) async {
    if (nestedCount < 0) {
      print('Nested search limit exeeded!');
      return null;
    }
    List<PlaceCategory> categories = _categories.map((categoryId) => PlaceCategory(categoryId)).toList();
    CategoryQuery categoryQuery = CategoryQuery.withCategoriesInArea(
      categories,
      CategoryQueryArea.withCorridor(GeoCorridor(vertices, _kGeoCorridorRadius)),
    );
    SearchError? searchError;
    List<Place>? searchedPlaces = await _searchPois(categoryQuery).onError((SearchError? error, stackTrace) {
      searchError = error;
      return null;
    });

    List<Place> places = [];
    if (searchError == SearchError.polylineTooLong) {
      print('Search failed. Error: ${searchError.toString()}, splitting vertices to search again...');
      final List<GeoCoordinates> split1 = vertices.sublist(0, vertices.length ~/ 2);
      final List<GeoCoordinates> split2 = vertices.sublist(vertices.length ~/ 2);
      for (List<GeoCoordinates> coordinates in [split1, split2]) {
        List<Place>? nestedPlaces = await _searchForVertices(coordinates, nestedCount - 1);
        if (nestedPlaces != null) {
          places.addAll(nestedPlaces);
        }
      }
    } else if (searchError != null) {
      print('Search failed. Error: ${searchError.toString()}');
    } else if (searchedPlaces != null) {
      places.addAll(searchedPlaces);
    }
    return places;
  }

  Future<List<Place>?> _searchPois(CategoryQuery categoryQuery) {
    final Completer<List<Place>?> completer = new Completer();
    _poiSearchTask = _searchEngine.searchByCategory(categoryQuery, _searchOptions, (error, places) {
      if (error != null) {
        return completer.completeError(error);
      }
      return completer.complete(places);
    });
    return completer.future;
  }

  List<Place> _filterPlaces(List<Place> places) {
    final Set<String> wayPointsPlacesIds =
        wayPointsController.value.where((wp) => wp.place != null).map((wp) => wp.place!.id).toSet();
    return places.whereNot((place) => wayPointsPlacesIds.contains(place.id)).toList();
  }

  void _addMarkersForPlaces(List<Place> places) {
    int markerSize = (hereMapController.pixelScale * UIStyle.poiMarkerSize).round();

    _filterPlaces(places).forEach((place) {
      SvgInfo svgInfo = PoiSVGHelper.getPoiSvgForCategoryAndText(
        type: _findPoiTypeForCategories(place.details.categories),
        text: onGetText?.call(place),
      );

      MapImage mapImage = MapImage.withImageDataImageFormatWidthAndHeight(Uint8List.fromList(svgInfo.svg.codeUnits),
          ImageFormat.svg, (svgInfo.width * (markerSize / svgInfo.height)).truncate(), markerSize);

      MapMarker mapMarker = Util.createMarkerWithImage(
        place.geoCoordinates!,
        mapImage,
        drawOrder: UIStyle.searchMarkerDrawOrder,
        anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
      );

      hereMapController.mapScene.addMapMarker(mapMarker);
      _markers[mapMarker] = place;
    });
  }

  PoiIconType? _findPoiTypeForCategoryId(String categoryId) {
    PoiIconType? result = _categoryPoiTypes[categoryId];
    if (result != null) {
      return result;
    }

    int index = categoryId.lastIndexOf('-');
    if (index < 0) {
      return null;
    }

    return _findPoiTypeForCategoryId(categoryId.substring(0, index));
  }

  PoiIconType _findPoiTypeForCategories(List<PlaceCategory> categories) {
    for (int i = 0; i < categories.length; ++i) {
      PoiIconType? result = _findPoiTypeForCategoryId(categories[i].id);
      if (result != null) {
        return result;
      }
    }

    return PoiIconType.unknown;
  }
}
