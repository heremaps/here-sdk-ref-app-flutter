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
import 'package:here_sdk/maploader.dart';

extension RegionExtensions on List<Region>? {
  List<RegionId>? _getChildRegionIds(Region region) {
    return region.childRegions?.expand<RegionId>((e) {
      if (e.childRegions != null) {
        return [e.regionId, ..._getChildRegionIds(e) ?? <RegionId>[]];
      } else {
        return [e.regionId];
      }
    }).toList();
  }

  List<RegionId> regionIds() {
    if (this != null) {
      return this!.map((e) => [e.regionId, ..._getChildRegionIds(e) ?? <RegionId>[]]).expand((e) => e).toList();
    } else {
      return <RegionId>[];
    }
  }
}
