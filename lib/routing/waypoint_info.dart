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

import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart' as Routing;
import 'package:here_sdk/search.dart';

import '../common/util.dart' as Util;

/// Source type for a waypoint.
enum WayPointInfoSourceType {
  /// Current position.
  CurrentPosition,

  /// Arbitrary coordinates.
  Coordinates,

  /// A [Place].
  Place,
}

/// Helper class that contains additional information about waypoint.
class WayPointInfo extends Routing.Waypoint {
  /// Place of the waypoint.
  final Place? place;

  /// Source type.
  final WayPointInfoSourceType sourceType;

  String get title => place?.title ?? coordinates.toPrettyString();

  WayPointInfo({
    required GeoCoordinates coordinates,
  })  : place = null,
        sourceType = WayPointInfoSourceType.CurrentPosition,
        super.withDefaults(coordinates);

  WayPointInfo.withCoordinates({
    required GeoCoordinates coordinates,
  })  : place = null,
        sourceType = WayPointInfoSourceType.Coordinates,
        super.withDefaults(coordinates);

  WayPointInfo.withPlace({
    required this.place,
    GeoCoordinates? originalCoordinates = null,
  })  : sourceType = WayPointInfoSourceType.Place,
        super.withDefaults(originalCoordinates ?? place!.geoCoordinates!);
}
