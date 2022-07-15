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

import 'route_preferences_model.dart';
import 'preferences_row_title_widget.dart';
import 'preferences_section_title_widget.dart';
import 'numeric_text_field_widget.dart';
import 'route_options_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:here_sdk/routing.dart';
import 'route_text_options_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';

/// Routing settings widget for pedestrian mode.
class PedestrianOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PedestrianOptions pedestrianOptions =
        context.select((RoutePreferencesModel model) => model.pedestrianOptions);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RouteOptionsWidget(),
            RouteTextOptionsWidget(),
            PreferencesSectionTitle(title: AppLocalizations.of(context)!.walkSpeedTitle),
            PreferencesRowTitle(title: AppLocalizations.of(context)!.walkSpeedUnitTitle),
            NumericTextField(
              initialValue: pedestrianOptions.walkSpeedInMetersPerSecond.toString(),
              isInteger: false,
              onChanged: (text) => context.read<RoutePreferencesModel>().pedestrianOptions = PedestrianOptions(
                pedestrianOptions.routeOptions,
                pedestrianOptions.textOptions,
                AvoidanceOptions.withDefaults(),
                double.tryParse(text) ?? 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
