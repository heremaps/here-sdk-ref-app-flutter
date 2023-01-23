/*
 * Copyright (C) 2020-2023 HERE Europe B.V.
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
import 'package:here_sdk/transport.dart' as Transport;
import 'package:provider/provider.dart';

import '../common/ui_style.dart';
import 'avoidance/route_avoidance_options_widget.dart';
import 'dropdown_widget.dart';
import 'enum_string_helper.dart';
import 'preferences_disclosure_row_widget.dart';
import 'preferences_row_title_widget.dart';
import 'preferences_section_title_widget.dart';
import 'route_options_widget.dart';
import 'route_preferences_model.dart';
import 'route_text_options_widget.dart';
import 'truck_hazardous_materials_screen.dart';
import 'truck_specifications_screen.dart';

/// Routing settings widget for truck mode.
class TruckOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TruckOptions truckOptions = context.select((RoutePreferencesModel model) => model.truckOptions);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RouteOptionsWidget(),
            RouteTextOptionsWidget(),
            RouteAvoidanceOptionsWidget(),
            PreferencesSectionTitle(title: AppLocalizations.of(context)!.truckSpecificationsTitle),
            PreferencesDisclosureRowWidget(
              title: AppLocalizations.of(context)!.specificationsTitle,
              subTitle: _truckSpecificationsToString(context, truckOptions.truckSpecifications),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TruckSpecificationsScreen()),
              ),
            ),
            PreferencesDisclosureRowWidget(
              title: AppLocalizations.of(context)!.hazardousGoodsTitle,
              subTitle: EnumStringHelper.hazardousMaterialsNamesToString(context, truckOptions.hazardousMaterials),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TruckHazardousMaterialsScreen()),
              ),
            ),
            PreferencesRowTitle(title: AppLocalizations.of(context)!.tunnelCategoryTitle),
            Container(
              decoration: UIStyle.roundedRectDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownWidget(
                  data: EnumStringHelper.tunnelCategoryMap(context),
                  selectedValue: truckOptions.linkTunnelCategory?.index,
                  onChanged: (category) {
                    Transport.TunnelCategory? tunnelCategory;
                    if (category != EnumStringHelper.noneValueIndex) {
                      tunnelCategory = Transport.TunnelCategory.values[category];
                    }
                    final TruckOptions newOptions = TruckOptions()
                      ..routeOptions = truckOptions.routeOptions
                      ..textOptions = truckOptions.textOptions
                      ..avoidanceOptions = truckOptions.avoidanceOptions
                      ..truckSpecifications = truckOptions.truckSpecifications
                      ..linkTunnelCategory = tunnelCategory
                      ..hazardousMaterials = truckOptions.hazardousMaterials;
                    context.read<RoutePreferencesModel>().truckOptions = newOptions;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truckSpecificationsToString(BuildContext context, Transport.TruckSpecifications specifications) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return <String>[
      if (specifications.widthInCentimeters != null)
        localizations.truckWidthRowTitle + " = " + specifications.widthInCentimeters.toString(),
      if (specifications.heightInCentimeters != null)
        localizations.truckHeightRowTitle + " = " + specifications.heightInCentimeters.toString(),
      if (specifications.lengthInCentimeters != null)
        localizations.truckLengthRowTitle + " = " + specifications.lengthInCentimeters.toString(),
      if (specifications.axleCount != null)
        localizations.truckAxleCountRowTitle + " = " + specifications.axleCount.toString(),
      if (specifications.weightPerAxleInKilograms != null)
        localizations.truckWeightPerAxleRowTitle + " = " + specifications.weightPerAxleInKilograms.toString(),
      if (specifications.grossWeightInKilograms != null)
        localizations.truckGrossWeightRowTitle + " = " + specifications.grossWeightInKilograms.toString()
    ].join(", ");
  }
}
