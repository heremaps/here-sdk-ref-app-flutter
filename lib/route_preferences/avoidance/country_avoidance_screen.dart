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

import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart';

import '../enum_string_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../route_preferences_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/ui_style.dart';

/// Country avoidance options screen widget.
class CountryAvoidanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AvoidanceOptions avoidanceOptions =
        context.select((RoutePreferencesModel model) => model.sharedAvoidanceOptions);

    LinkedHashMap<String, CountryCode> countryCodesMap = EnumStringHelper.countryCodesMap(context);
    List<String> sortedCountryNames = countryCodesMap.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).avoidCountriesTitle),
          centerTitle: true,
          backgroundColor: UIStyle.preferencesBackgroundColor,
          textTheme: Theme.of(context).textTheme),
      body: Container(
        color: UIStyle.preferencesBackgroundColor,
        child: ListView.builder(
            itemCount: sortedCountryNames.length,
            itemBuilder: (context, index) {
              CountryCode code = countryCodesMap[sortedCountryNames[index]];
              return CheckboxListTile(
                title: Text(sortedCountryNames[index]),
                value: avoidanceOptions.countries.contains(code),
                onChanged: (bool enable) {
                  List<CountryCode> updatedCountries = List.from(avoidanceOptions.countries);
                  enable ? updatedCountries.add(code) : updatedCountries.remove(code);

                  context.read<RoutePreferencesModel>().sharedAvoidanceOptions = AvoidanceOptions(
                    avoidanceOptions.roadFeatures,
                    updatedCountries,
                    avoidanceOptions.avoidAreas,
                    [],
                  );
                },
              );
            }),
      ),
    );
  }
}
