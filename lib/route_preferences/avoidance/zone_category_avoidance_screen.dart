/*
* Copyright (c) 2026 HERE Global B.V. and its affiliate(s).
* All rights reserved.
*
* This software and other materials contain proprietary information
* controlled by HERE and are protected by applicable copyright legislation.
* Any use and utilization of this software and other materials and
* disclosure to any third parties is conditional upon having a separate
* agreement with HERE for the access, use, utilization or disclosure of this
* software. In the absence of such agreement, the use of the software is not
* allowed.
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
