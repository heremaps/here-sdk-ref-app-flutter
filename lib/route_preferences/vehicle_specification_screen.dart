/*
 * Copyright (C) 2026 HERE Europe B.V.
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
import 'package:here_sdk/transport.dart'
    show VehicleSpecification, WeightPerAxleGroup, TruckCategory, TunnelCategory, HazardousMaterial;
import 'package:here_sdk_reference_application_flutter/common/extensions/vehicle_specification_extensions.dart';
import 'package:here_sdk_reference_application_flutter/common/ui_style.dart';
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/dropdown_widget.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/enum_string_helper.dart' show EnumStringHelper;
import 'package:here_sdk_reference_application_flutter/route_preferences/hazardous_materials_screen.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/labeled_numeric_text_field_widget.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/preferences_disclosure_row_widget.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/preferences_row_title_widget.dart'
    show PreferencesRowTitle;
import 'package:here_sdk_reference_application_flutter/route_preferences/preferences_section_title_widget.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/route_preferences_model.dart';
import 'package:provider/provider.dart';

class VehicleSpecificationScreen extends StatelessWidget {
  const VehicleSpecificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    final VehicleSpecification _specification = context.select((RoutePreferencesModel model) {
      return model.vehicleSpecification;
    });
    WeightPerAxleGroup _weightPerAxleGroup = _specification.weightPerAxleGroup ?? WeightPerAxleGroup();

    return Scaffold(
      appBar: AppBar(title: Text(localizations.vehicleSpecification)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          color: UIStyle.preferencesBackgroundColor,
          padding: const EdgeInsets.all(UIStyle.contentMarginMedium),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PreferencesRowTitle(title: localizations.isLightTruck),
                  Switch.adaptive(
                    value: _specification.isTruckLight,
                    onChanged: (value) {
                      context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                        isTruckLight: value,
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PreferencesRowTitle(title: localizations.isCommercial),
                  Switch.adaptive(
                    value: _specification.isCommercial,
                    onChanged: (value) {
                      context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                        isCommercial: value,
                      );
                    },
                  ),
                ],
              ),
              PreferencesDisclosureRowWidget(
                title: localizations.hazardousGoodsTitle,
                subTitle: EnumStringHelper.hazardousMaterialsNamesToString(context, _specification.hazardousMaterials),
                onPressed: () async {
                  final List<HazardousMaterial>? result =
                      await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HazardousMaterialsScreen(hazardousMaterials: _specification.hazardousMaterials);
                              },
                            ),
                          )
                          as List<HazardousMaterial>?;
                  if (context.mounted) {
                    context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                      hazardousMaterials: result ?? <HazardousMaterial>[],
                    );
                  }
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckAxleCountRowTitle,
                initialValue: _specification.axleCount?.toString() ?? "",
                hintText: localizations.truckAxlesCountHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(axleCount: text);
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckCurrentWeightRowTitle,
                initialValue: _specification.currentWeightInKilograms?.toString() ?? "",
                hintText: localizations.weightInKg,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    currentWeightInKilograms: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckEmptyWeightRowTitle,
                initialValue: _specification.emptyWeightInKilograms?.toString() ?? "",
                hintText: localizations.weightInKg,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    emptyWeightInKilograms: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckEngineSizeRowTitle,
                initialValue: _specification.engineSizeInCubicCentimeters?.toString() ?? "",
                hintText: localizations.truckEngineSizeHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    engineSizeInCubicCentimeters: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckGrossWeightRowTitle,
                initialValue: _specification.grossWeightInKilograms?.toString() ?? "",
                hintText: localizations.truckTotalWeightHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    grossWeightInKilograms: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckHeightRowTitle,
                initialValue: _specification.heightInCentimeters?.toString() ?? "",
                hintText: localizations.truckHeightHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    heightInCentimeters: text,
                  );
                },
              ),

              LabeledNumericTextField(
                title: localizations.truckKingpinToRearAxleDistanceRowTitle,
                initialValue: _specification.kingpinToRearAxleDistanceInCentimeters?.toString() ?? "",
                hintText: localizations.truckKingpinToRearAxleDistanceHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    kingpinToRearAxleDistanceInCentimeters: text,
                  );
                },
              ),
              PreferencesRowTitle(title: localizations.truckLastCharacterOfLicensePlateRowTitle),
              Container(
                decoration: UIStyle.roundedRectDecoration(),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: localizations.truckLastCharacterOfLicensePlateHint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                  ),
                  onChanged: (text) {
                    context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                      lastCharacterOfLicensePlate: text.isNotEmpty ? text : null,
                    );
                  },
                ),
              ),
              LabeledNumericTextField(
                title: localizations.truckLengthRowTitle,
                initialValue: _specification.lengthInCentimeters?.toString() ?? "",
                hintText: localizations.truckLengthHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    lengthInCentimeters: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckOccupancyRowTitle,
                initialValue: _specification.occupancy?.toString() ?? "",
                hintText: localizations.truckOccupancyHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(occupancy: text);
                },
              ),
              LabeledNumericTextField(
                title: localizations.payloadCapacity,
                initialValue: _specification.payloadCapacityInKilograms?.toString() ?? "",
                hintText: localizations.payloadCapacityHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    payloadCapacityInKilograms: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckTiresCountRowTitle,
                initialValue: _specification.tiresCount?.toString() ?? "",
                hintText: localizations.truckOccupancyHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    tiresCount: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckSpecTrailerAxleCount,
                initialValue: _specification.trailerAxleCount?.toString() ?? "",
                hintText: localizations.truckSpecTrailerAxleCountHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    trailerAxleCount: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckSpecTrailerCount,
                initialValue: _specification.trailerCount?.toString() ?? "",
                hintText: localizations.truckSpecTrailerCountHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    trailerCount: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckWeightPerAxleRowTitle,
                initialValue: _specification.weightPerAxleInKilograms?.toString() ?? "",
                hintText: localizations.truckAxleWeightHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    weightPerAxleInKilograms: text,
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.truckWidthRowTitle,
                initialValue: _specification.widthInCentimeters?.toString() ?? "",
                hintText: localizations.truckWidthHint,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    widthInCentimeters: text,
                  );
                },
              ),
              PreferencesRowTitle(title: localizations.truckCategoryRowTitle),
              Container(
                decoration: UIStyle.roundedRectDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownWidget(
                    data: EnumStringHelper.truckCategoryDisplayNames(context),
                    selectedValue: _specification.truckCategory?.index,
                    onChanged: (categoryId) {
                      TruckCategory? truckCategory;
                      if (categoryId != EnumStringHelper.noneValueIndex) {
                        truckCategory = TruckCategory.values[categoryId];
                      }
                      context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                        truckCategory: () => truckCategory,
                      );
                    },
                  ),
                ),
              ),
              PreferencesRowTitle(title: localizations.tunnelCategoryTitle),
              Container(
                decoration: UIStyle.roundedRectDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownWidget(
                    data: EnumStringHelper.tunnelCategoryMap(context),
                    selectedValue: _specification.tunnelCategory?.index,
                    onChanged: (categoryId) {
                      TunnelCategory? tunnelCategory;
                      if (categoryId != EnumStringHelper.noneValueIndex) {
                        tunnelCategory = TunnelCategory.values[categoryId];
                      }
                      context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                        tunnelCategory: () => tunnelCategory,
                      );
                    },
                  ),
                ),
              ),
              PreferencesSectionTitle(title: localizations.weightPerAxleGroup),
              LabeledNumericTextField(
                title: localizations.singleAxleGroup,
                initialValue: _specification.weightPerAxleGroup?.singleAxleGroupInKilograms?.toString() ?? "",
                hintText: localizations.weightInKg,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    weightPerAxleGroup: _weightPerAxleGroup.copyWith(singleAxleGroupInKilograms: text),
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.tandemAxleGroup,
                initialValue: _specification.weightPerAxleGroup?.tandemAxleGroupInKilograms?.toString() ?? "",
                hintText: localizations.weightInKg,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    weightPerAxleGroup: _weightPerAxleGroup.copyWith(tandemAxleGroupInKilograms: text),
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.tripleAxleGroup,
                initialValue: _specification.weightPerAxleGroup?.tripleAxleGroupInKilograms?.toString() ?? "",
                hintText: localizations.weightInKg,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    weightPerAxleGroup: _weightPerAxleGroup.copyWith(tripleAxleGroupInKilograms: text),
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.quadAxleGroup,
                initialValue: _specification.weightPerAxleGroup?.quadAxleGroupInKilograms?.toString() ?? "",
                hintText: localizations.weightInKg,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    weightPerAxleGroup: _weightPerAxleGroup.copyWith(quadAxleGroupInKilograms: text),
                  );
                },
              ),
              LabeledNumericTextField(
                title: localizations.quintAxleGroup,
                initialValue: _specification.weightPerAxleGroup?.quintAxleGroupInKilograms?.toString() ?? "",
                hintText: localizations.weightInKg,
                onChanged: (text) {
                  context.read<RoutePreferencesModel>().vehicleSpecification = _specification.copyWith(
                    weightPerAxleGroup: _weightPerAxleGroup.copyWith(quintAxleGroupInKilograms: text),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
