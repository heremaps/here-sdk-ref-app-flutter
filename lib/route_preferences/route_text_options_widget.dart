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
import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart';
import 'package:provider/provider.dart';

import '../common/ui_style.dart';
import 'dropdown_widget.dart';
import 'enum_string_helper.dart';
import 'preferences_section_title_widget.dart';
import 'preferences_row_title_widget.dart';
import 'route_preferences_model.dart';

/// Route text options widget.
class RouteTextOptionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RouteTextOptions textOptions = context.select((RoutePreferencesModel model) => model.sharedRouteTextOptions);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PreferencesSectionTitle(title: AppLocalizations.of(context)!.routeTextOptionsTitle),
        PreferencesRowTitle(title: AppLocalizations.of(context)!.textFormatTitle),
        Container(
          decoration: UIStyle.roundedRectDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownWidget(
              data: EnumStringHelper.routeInstructionsFormatMap(context),
              selectedValue: textOptions.instructionFormat.index,
              onChanged: (format) {
                final RouteTextOptions newOptions = RouteTextOptions.withDefaults()
                  ..language = textOptions.language
                  ..instructionFormat = TextFormat.values[format]
                  ..unitSystem = textOptions.unitSystem;
                context.read<RoutePreferencesModel>().sharedRouteTextOptions = newOptions;
              },
            ),
          ),
        ),
        PreferencesRowTitle(title: AppLocalizations.of(context)!.unitSystemTitle),
        Container(
          decoration: UIStyle.roundedRectDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownWidget(
              data: EnumStringHelper.routeUnitSystemMap(context),
              selectedValue: textOptions.unitSystem.index,
              onChanged: (unit) {
                final RouteTextOptions newOptions = RouteTextOptions.withDefaults()
                  ..language = textOptions.language
                  ..instructionFormat = textOptions.instructionFormat
                  ..unitSystem = UnitSystem.values[unit];
                context.read<RoutePreferencesModel>().sharedRouteTextOptions = newOptions;
              },
            ),
          ),
        ),
        PreferencesRowTitle(title: AppLocalizations.of(context)!.languageCodeTitle),
        Container(
          decoration: UIStyle.roundedRectDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownWidget(
              data: EnumStringHelper.routeLanguageMap(context),
              selectedValue: textOptions.language.index,
              onChanged: (language) {
                final RouteTextOptions newOptions = RouteTextOptions.withDefaults()
                  ..language = LanguageCode.values[language]
                  ..instructionFormat = textOptions.instructionFormat
                  ..unitSystem = textOptions.unitSystem;
                context.read<RoutePreferencesModel>().sharedRouteTextOptions = newOptions;
              },
            ),
          ),
        ),
      ],
    );
  }
}
