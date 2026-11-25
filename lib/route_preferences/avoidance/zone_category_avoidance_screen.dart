/*
 * Copyright (C) 2026 HERE Europe B.V.
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

import 'dart:collection' show LinkedHashMap;

import 'package:flutter/material.dart';
import 'package:here_sdk/routing.dart' show AvoidanceOptions, ZoneCategory;
import 'package:here_sdk_reference_application_flutter/common/ui_style.dart';
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/enum_string_helper.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/route_preferences_model.dart';
import 'package:provider/provider.dart';

class ZoneCategoryAvoidanceScreen extends StatelessWidget {
  const ZoneCategoryAvoidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AvoidanceOptions avoidanceOptions = context.select(
      (RoutePreferencesModel model) => model.sharedAvoidanceOptions,
    );

    LinkedHashMap<String, ZoneCategory> zoneCategoriesMap = EnumStringHelper.sortedZoneCategoriesMap(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.avoidZoneCategoriesTitle)),
      body: Container(
        color: UIStyle.preferencesBackgroundColor,
        child: ListView(
          children: zoneCategoriesMap.keys.map((String key) {
            return CheckboxListTile(
              title: Text(key),
              value: avoidanceOptions.zoneCategories.contains(zoneCategoriesMap[key]),
              onChanged: (bool? enable) {
                ZoneCategory? changedCategory = zoneCategoriesMap[key];
                if (changedCategory == null) {
                  return;
                }
                List<ZoneCategory> updatedCategories = List.from(avoidanceOptions.zoneCategories);
                if (enable ?? false) {
                  updatedCategories.add(changedCategory);
                } else {
                  updatedCategories.remove(changedCategory);
                }
                context.read<RoutePreferencesModel>().sharedAvoidanceOptions = AvoidanceOptions()
                  ..roadFeatures = avoidanceOptions.roadFeatures
                  ..countries = avoidanceOptions.countries
                  ..zoneCategories = updatedCategories;
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
