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

import 'package:RefApp/common/extensions/truck_specification_extensions.dart';
import 'package:RefApp/route_preferences/preferences_section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk/routing.dart';
import 'package:here_sdk/transport.dart' as Transport;
import 'package:provider/provider.dart';

import '../common/ui_style.dart';
import 'numeric_text_field_widget.dart';
import 'preferences_row_title_widget.dart';
import 'route_preferences_model.dart';

/// Truck specifications screen widget.
class TruckSpecificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TruckOptions _truckOptions = context.select((RoutePreferencesModel model) => model.truckOptions);
    Transport.TruckSpecifications _specs = _truckOptions.truckSpecifications;
    Transport.WeightPerAxleGroup _weightPerAxleGroup = _specs.weightPerAxleGroup ?? Transport.WeightPerAxleGroup();
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.truckSpecificationsTitle),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          color: UIStyle.preferencesBackgroundColor,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(UIStyle.contentMarginMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PreferencesRowTitle(title: localizations.truckWidthRowTitle),
                    NumericTextField(
                      initialValue: _specs.widthInCentimeters == null ? "" : _specs.widthInCentimeters.toString(),
                      hintText: localizations.truckWidthHint,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(widthInCentimeters: text),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.truckHeightRowTitle),
                    NumericTextField(
                      initialValue: _specs.heightInCentimeters == null ? "" : _specs.heightInCentimeters.toString(),
                      hintText: localizations.truckHeightHint,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(heightInCentimeters: text),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.truckLengthRowTitle),
                    NumericTextField(
                      initialValue: _specs.lengthInCentimeters == null ? "" : _specs.lengthInCentimeters.toString(),
                      hintText: localizations.truckLengthtHint,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(lengthInCentimeters: text),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.truckAxleCountRowTitle),
                    NumericTextField(
                      initialValue: _specs.axleCount == null ? "" : _specs.axleCount.toString(),
                      hintText: localizations.truckAxlesCountHint,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(axleCount: text),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.truckWeightPerAxleRowTitle),
                    NumericTextField(
                      initialValue:
                          _specs.weightPerAxleInKilograms == null ? "" : _specs.weightPerAxleInKilograms.toString(),
                      hintText: localizations.truckAxleWeightHint,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(weightPerAxleInKilograms: text),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.truckGrossWeightRowTitle),
                    NumericTextField(
                      initialValue:
                          _specs.grossWeightInKilograms == null ? "" : _specs.grossWeightInKilograms.toString(),
                      hintText: localizations.truckTotalWeightHint,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(grossWeightInKilograms: text),
                        );
                      },
                    ),
                    PreferencesSectionTitle(title: AppLocalizations.of(context)!.weightPerAxleGroup),
                    PreferencesRowTitle(title: localizations.singleAxleGroup),
                    NumericTextField(
                      initialValue: _specs.weightPerAxleGroup?.singleAxleGroupInKilograms == null
                          ? ""
                          : _specs.weightPerAxleGroup!.singleAxleGroupInKilograms.toString(),
                      hintText: localizations.weightInKg,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(
                            weightPerAxleGroup: _weightPerAxleGroup.copyWeightPerAxleGroupWith(
                              singleAxleGroupInKilograms: text,
                            ),
                          ),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.tandemAxleGroup),
                    NumericTextField(
                      initialValue: _specs.weightPerAxleGroup?.tandemAxleGroupInKilograms == null
                          ? ""
                          : _specs.weightPerAxleGroup!.tandemAxleGroupInKilograms.toString(),
                      hintText: localizations.weightInKg,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(
                            weightPerAxleGroup: _weightPerAxleGroup.copyWeightPerAxleGroupWith(
                              tandemAxleGroupInKilograms: text,
                            ),
                          ),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.tripleAxleGroup),
                    NumericTextField(
                      initialValue: _specs.weightPerAxleGroup?.tripleAxleGroupInKilograms == null
                          ? ""
                          : _specs.weightPerAxleGroup!.tripleAxleGroupInKilograms.toString(),
                      hintText: localizations.weightInKg,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(
                            weightPerAxleGroup: _weightPerAxleGroup.copyWeightPerAxleGroupWith(
                              tripleAxleGroupInKilograms: text,
                            ),
                          ),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.quadAxleGroup),
                    NumericTextField(
                      initialValue: _specs.weightPerAxleGroup?.quadAxleGroupInKilograms == null
                          ? ""
                          : _specs.weightPerAxleGroup!.quadAxleGroupInKilograms.toString(),
                      hintText: localizations.weightInKg,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(
                            weightPerAxleGroup: _weightPerAxleGroup.copyWeightPerAxleGroupWith(
                              quadAxleGroupInKilograms: text,
                            ),
                          ),
                        );
                      },
                    ),
                    PreferencesRowTitle(title: localizations.quintAxleGroup),
                    NumericTextField(
                      initialValue: _specs.weightPerAxleGroup?.quintAxleGroupInKilograms == null
                          ? ""
                          : _specs.weightPerAxleGroup!.quintAxleGroupInKilograms.toString(),
                      hintText: localizations.weightInKg,
                      isInteger: true,
                      onChanged: (text) {
                        context.read<RoutePreferencesModel>().truckOptions = _truckOptions.copyTruckOptionsWith(
                          truckSpecifications: _specs.copyTruckSpecificationsWith(
                            weightPerAxleGroup: _weightPerAxleGroup.copyWeightPerAxleGroupWith(
                              quintAxleGroupInKilograms: text,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
