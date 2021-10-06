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

import 'dart:collection';

import 'enum_string_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/routing.dart';
import 'package:provider/provider.dart';
import 'route_preferences_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/ui_style.dart';

/// Truck hazardous goods preferences screen widget.
class TruckHazardousGoodsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TruckOptions truckOptions = context.select((RoutePreferencesModel model) => model.truckOptions);
    LinkedHashMap<String, HazardousGood> hazardousGoodsMap = EnumStringHelper.sortedHazardousGoodsMap(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hazardousGoodsTitle),
      ),
      body: Container(
        color: UIStyle.preferencesBackgroundColor,
        child: ListView(
          children: hazardousGoodsMap.keys.map((String key) {
            return CheckboxListTile(
              title: Text(key),
              value: truckOptions.hazardousGoods.contains(hazardousGoodsMap[key]),
              onChanged: (bool? enable) {
                HazardousGood changedFeature = hazardousGoodsMap[key]!;
                List<HazardousGood> updatedFeatures = List.from(truckOptions.hazardousGoods);
                enable ?? false ? updatedFeatures.add(changedFeature) : updatedFeatures.remove(changedFeature);

                context.read<RoutePreferencesModel>().truckOptions = TruckOptions(
                    truckOptions.routeOptions,
                    truckOptions.textOptions,
                    truckOptions.avoidanceOptions,
                    truckOptions.specifications,
                    truckOptions.tunnelCategory,
                    updatedFeatures);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
