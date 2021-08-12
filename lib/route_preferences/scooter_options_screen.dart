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

import 'avoidance/route_avoidance_options_widget.dart';
import 'route_preferences_model.dart';
import 'package:provider/provider.dart';
import 'preferences_row_title_widget.dart';
import 'preferences_section_title_widget.dart';
import 'package:flutter/material.dart';
import 'route_options_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:here_sdk/routing.dart';
import 'route_text_options_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Routing settings widget for scooter mode.
class ScooterOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ScooterOptions scooterOptions = context.select((RoutePreferencesModel model) => model.scooterOptions);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RouteOptionsWidget(),
          RouteTextOptionsWidget(),
          RouteAvoidanceOptionsWidget(),
          PreferencesSectionTitle(title: AppLocalizations.of(context)!.highwayTitle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PreferencesRowTitle(title: AppLocalizations.of(context)!.allowHighwayTitle),
              Switch.adaptive(
                value: scooterOptions.allowHighway,
                onChanged: (value) => context.read<RoutePreferencesModel>().scooterOptions = ScooterOptions(
                  scooterOptions.routeOptions,
                  scooterOptions.textOptions,
                  scooterOptions.avoidanceOptions,
                  value,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
