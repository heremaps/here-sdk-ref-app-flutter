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

import 'route_preferences_model.dart';
import 'package:provider/provider.dart';
import 'enum_string_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart';
import '../common/ui_style.dart';
import 'dropdown_widget.dart';
import 'preferences_section_title_widget.dart';
import 'preferences_row_title_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Route text options widget.
class RouteTextOptionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RouteTextOptions textOptions = context.select((RoutePreferencesModel model) => model.sharedRouteTextOptions);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PreferencesSectionTitle(title: AppLocalizations.of(context).routeTextOptionsTitle),
        PreferencesRowTitle(title: AppLocalizations.of(context).textFormatTitle),
        Container(
          decoration: UIStyle.roundedRectDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownWidget(
              data: EnumStringHelper.routeInstructionsFormatMap(context),
              selectedValue: textOptions.instructionFormat.index,
              onChanged: (format) => context.read<RoutePreferencesModel>().sharedRouteTextOptions = RouteTextOptions(
                textOptions.language,
                TextFormat.values[format],
                textOptions.unitSystem,
              ),
            ),
          ),
        ),
        PreferencesRowTitle(title: AppLocalizations.of(context).unitSystemTitle),
        Container(
          decoration: UIStyle.roundedRectDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownWidget(
              data: EnumStringHelper.routeUnitSystemMap(context),
              selectedValue: textOptions.unitSystem.index,
              onChanged: (unit) => context.read<RoutePreferencesModel>().sharedRouteTextOptions = RouteTextOptions(
                textOptions.language,
                textOptions.instructionFormat,
                UnitSystem.values[unit],
              ),
            ),
          ),
        ),
        PreferencesRowTitle(title: AppLocalizations.of(context).languageCodeTitle),
        Container(
          decoration: UIStyle.roundedRectDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownWidget(
              data: EnumStringHelper.routeLanguageMap(context),
              selectedValue: textOptions.language.index,
              onChanged: (language) => context.read<RoutePreferencesModel>().sharedRouteTextOptions = RouteTextOptions(
                LanguageCode.values[language],
                textOptions.instructionFormat,
                textOptions.unitSystem,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
