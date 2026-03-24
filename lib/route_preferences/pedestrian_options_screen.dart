/*
 * Copyright (C) 2020-2026 HERE Europe B.V.
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

import 'package:flutter/cupertino.dart';
import 'package:here_sdk/transport.dart' show PedestrianSpecification;
import 'package:here_sdk_reference_application_flutter/common/ui_style.dart' show UIStyle;
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import 'numeric_text_field_widget.dart';
import 'preferences_row_title_widget.dart';
import 'preferences_section_title_widget.dart';
import 'route_options_widget.dart';
import 'route_preferences_model.dart';
import 'route_text_options_widget.dart';

/// Routing settings widget for pedestrian mode.
class PedestrianOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final PedestrianSpecification pedestrianSpecification = context.select(
      (RoutePreferencesModel model) => model.pedestrianSpecification,
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RouteOptionsWidget(),
            RouteTextOptionsWidget(),
            PreferencesSectionTitle(title: localizations.transportSpecification),
            PreferencesRowTitle(title: localizations.pedestrianSpecification, fontSize: UIStyle.bigFontSize),
            PreferencesRowTitle(title: localizations.walkingSpeedUnitTitle),
            NumericTextField(
              initialValue: pedestrianSpecification.walkingSpeedInMetersPerSecond.toString(),
              hintText: localizations.walkingSpeedHint,
              isInteger: false,
              onChanged: (text) {
                context.read<RoutePreferencesModel>().pedestrianSpecification = double.tryParse(text) ?? 0;
              },
            ),
          ],
        ),
      ),
    );
  }
}
