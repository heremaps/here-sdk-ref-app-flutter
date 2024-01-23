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
import 'package:here_sdk/core.threading.dart';
import 'package:here_sdk/search.dart';

/// Proxy class for search engines
class SearchEngineProxy {
  final bool offline;
  late SearchEngine _onlineSearchEngine;
  late OfflineSearchEngine _offlineSearchEngine;

  SearchEngineProxy({this.offline = false}) {
    if (offline) {
      _offlineSearchEngine = OfflineSearchEngine();
    } else {
      _onlineSearchEngine = SearchEngine();
    }
  }

  /// Performs an asynchronous request to search for a [Place] based on its ID and [LanguageCode].
  ///
  /// [query] The id of place to search.
  ///
  /// [languageCode] The preferred language for the search results. When unset or unsupported language is chosen,
  /// results will be returned in their local language.
  ///
  /// [callback] Callback which receives the result on the main thread.
  ///
  /// Returns [TaskHandle]. Handle that will be used to manipulate the execution of the task.
  TaskHandle searchByPlaceIdWithLanguageCode(
      PlaceIdQuery query, LanguageCode? languageCode, PlaceIdSearchCallback callback) {
    if (offline) {
      return _offlineSearchEngine.searchByPlaceIdWithLanguageCode(query, languageCode, callback);
    } else {
      return _onlineSearchEngine.searchByPlaceIdWithLanguageCode(query, languageCode, callback);
    }
  }

  /// Performs an asynchronous request to do a text query search for [Place] instances.
  ///
  /// Optionally, search along a polyline, such as a route, by specifying a [GeoCorridor].
  /// Provides candidate places sorted by relevance.
  ///
  /// [query] Desired free-form text query to search.
  ///
  /// [options] Search options.
  ///
  /// [callback] Callback which receives the result on the main thread.
  ///
  /// Returns [TaskHandle]. Handle that will be used to manipulate the execution of the task.
  TaskHandle searchByText(TextQuery query, SearchOptions options, SearchCallback callback) {
    if (offline) {
      return _offlineSearchEngine.searchByText(query, options, callback);
    } else {
      return _onlineSearchEngine.searchByText(query, options, callback);
    }
  }

  /// Performs an asynchronous request to suggest places for text queries and
  /// returns candidate suggestions sorted by relevance.
  ///
  /// [query] Desired text query to search.
  ///
  /// [options] Search options.
  ///
  /// [callback] Callback which receives the result on the main thread.
  ///
  /// Returns [TaskHandle]. Handle that will be used to manipulate the execution of the task.
  TaskHandle suggest(TextQuery query, SearchOptions options, SuggestCallback callback) {
    if (offline) {
      return _offlineSearchEngine.suggest(query, options, callback);
    } else {
      return _onlineSearchEngine.suggest(query, options, callback);
    }
  }

  /// Performs an asynchronous request to search for places based on given geographic coordinates.
  ///
  /// This is the same process as reverse geocoding, except that more data is returned
  /// than just the [Address] that belongs to given coordinates. Note that coordinates can
  /// belong to more than one [Place] result, but all found places will
  /// share the same coordinates.
  /// Provides candidate places sorted by relevance.
  ///
  /// [coordinates] The coordinates where to search.
  ///
  /// [options] Search options.
  ///
  /// [callback] Callback which receives result on the main thread.
  ///
  /// Returns [TaskHandle]. Handle that will be used to manipulate execution of the task.
  ///
  TaskHandle searchByCoordinates(GeoCoordinates coordinates, SearchOptions options, SearchCallback callback) {
    if (offline) {
      return _offlineSearchEngine.searchByCoordinates(coordinates, options, callback);
    } else {
      return _onlineSearchEngine.searchByCoordinates(coordinates, options, callback);
    }
  }

  /// Performs an asynchronous request to do a category search for [Place] instances.
  ///
  /// A list containing at least one [PlaceCategory] must be provided
  /// as part of the [SearchEngine.searchByCategory.query].
  ///
  /// [query] Query with list of desired categories.
  ///
  /// [options] Search options.
  ///
  /// [callback] Callback which receives the result on the main thread.
  ///
  /// Returns [TaskHandle]. Handle that will be used to manipulate the execution of the task.
  ///
  TaskHandle searchByCategory(CategoryQuery query, SearchOptions options, SearchCallback callback) {
    if (offline) {
      return _offlineSearchEngine.searchByCategory(query, options, callback);
    } else {
      return _onlineSearchEngine.searchByCategory(query, options, callback);
    }
  }
}
