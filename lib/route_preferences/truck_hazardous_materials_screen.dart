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

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:here_sdk/routing.dart';
import 'package:here_sdk/transport.dart' as Transport;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/ui_style.dart';
import 'enum_string_helper.dart';
import 'route_preferences_model.dart';

/// Truck hazardous goods preferences screen widget.
class TruckHazardousMaterialsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TruckOptions truckOptions = context.select((RoutePreferencesModel model) => model.truckOptions);
    LinkedHashMap<String, Transport.HazardousMaterial> hazardousMaterialsMap =
        EnumStringHelper.sortedHazardousMaterialsMap(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hazardousGoodsTitle),
      ),
      body: Container(
        color: UIStyle.preferencesBackgroundColor,
        child: ListView(
          children: hazardousMaterialsMap.keys.map((String key) {
            return CheckboxListTile(
              title: Text(key),
              value: truckOptions.hazardousMaterials.contains(hazardousMaterialsMap[key]),
              onChanged: (bool? enable) {
                Transport.HazardousMaterial changedFeature = hazardousMaterialsMap[key]!;
                List<Transport.HazardousMaterial> updatedFeatures = List.from(truckOptions.hazardousMaterials);
                if (enable ?? false) {
                  updatedFeatures.add(changedFeature);
                } else {
                  updatedFeatures.remove(changedFeature);
                }

                final TruckOptions newTruckOptions = TruckOptions()
                  ..routeOptions = truckOptions.routeOptions
                  ..textOptions = truckOptions.textOptions
                  ..avoidanceOptions = truckOptions.avoidanceOptions
                  ..truckSpecifications = truckOptions.truckSpecifications
                  ..linkTunnelCategory = truckOptions.linkTunnelCategory
                  ..hazardousMaterials = updatedFeatures;
                context.read<RoutePreferencesModel>().truckOptions = newTruckOptions;
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
