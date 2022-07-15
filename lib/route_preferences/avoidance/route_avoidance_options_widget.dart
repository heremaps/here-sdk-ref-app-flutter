/*
 * Copyright (C) 2020-2022 HERE Europe B.V.
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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk/routing.dart';
import 'package:provider/provider.dart';

import '../enum_string_helper.dart';
import '../route_preferences_model.dart';
import '../preferences_section_title_widget.dart';
import '../preferences_disclosure_row_widget.dart';
import 'country_avoidance_screen.dart';
import 'road_features_avoidance_screen.dart';

/// Route avoidance options screen widget.
class RouteAvoidanceOptionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AvoidanceOptions avoidanceOptions =
        context.select((RoutePreferencesModel model) => model.sharedAvoidanceOptions);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PreferencesSectionTitle(title: AppLocalizations.of(context)!.avoidanceOptionsTitle),
        PreferencesDisclosureRowWidget(
          title: AppLocalizations.of(context)!.avoidRoadFeaturesTitle,
          subTitle: EnumStringHelper.roadFeatureNamesToString(context, avoidanceOptions.roadFeatures),
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) => RoadFeaturesAvoidanceScreen())),
        ),
        PreferencesDisclosureRowWidget(
          title: AppLocalizations.of(context)!.avoidCountriesTitle,
          subTitle: EnumStringHelper.countryCodeNamesToString(context, avoidanceOptions.countries),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CountryAvoidanceScreen())),
        ),
      ],
    );
  }
}
