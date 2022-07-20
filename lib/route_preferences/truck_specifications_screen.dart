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
    final TruckOptions truckOptions = context.select((RoutePreferencesModel model) => model.truckOptions);
    Transport.TruckSpecifications specs = truckOptions.truckSpecifications;
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
                      initialValue: specs.widthInCentimeters == null ? "" : specs.widthInCentimeters.toString(),
                      hintText: localizations.truckWidthHint,
                      isInteger: true,
                      onChanged: (text) => context.read<RoutePreferencesModel>().truckOptions = _truckOptionsFrom(
                        truckOptions,
                        _truckSpecificationsFrom(specs, widthInCentimeters: int.tryParse(text) ?? null),
                      ),
                    ),
                    PreferencesRowTitle(title: localizations.truckHeightRowTitle),
                    NumericTextField(
                      initialValue: specs.heightInCentimeters == null ? "" : specs.heightInCentimeters.toString(),
                      hintText: localizations.truckHeightHint,
                      isInteger: true,
                      onChanged: (text) => context.read<RoutePreferencesModel>().truckOptions = _truckOptionsFrom(
                        truckOptions,
                        _truckSpecificationsFrom(specs, heightInCentimeters: int.tryParse(text) ?? null),
                      ),
                    ),
                    PreferencesRowTitle(title: localizations.truckLengthRowTitle),
                    NumericTextField(
                      initialValue: specs.lengthInCentimeters == null ? "" : specs.lengthInCentimeters.toString(),
                      hintText: localizations.truckLengthtHint,
                      isInteger: true,
                      onChanged: (text) => context.read<RoutePreferencesModel>().truckOptions = _truckOptionsFrom(
                        truckOptions,
                        _truckSpecificationsFrom(specs, lengthInCentimeters: int.tryParse(text) ?? null),
                      ),
                    ),
                    PreferencesRowTitle(title: localizations.truckAxleCountRowTitle),
                    NumericTextField(
                      initialValue: specs.axleCount == null ? "" : specs.axleCount.toString(),
                      hintText: localizations.truckAxlesCountHint,
                      isInteger: true,
                      onChanged: (text) => context.read<RoutePreferencesModel>().truckOptions = _truckOptionsFrom(
                        truckOptions,
                        _truckSpecificationsFrom(specs, axleCount: int.tryParse(text) ?? null),
                      ),
                    ),
                    PreferencesRowTitle(title: localizations.truckWeightPerAxleRowTitle),
                    NumericTextField(
                      initialValue:
                          specs.weightPerAxleInKilograms == null ? "" : specs.weightPerAxleInKilograms.toString(),
                      hintText: localizations.truckAxleWeightHint,
                      isInteger: true,
                      onChanged: (text) => context.read<RoutePreferencesModel>().truckOptions = _truckOptionsFrom(
                        truckOptions,
                        _truckSpecificationsFrom(specs, weightPerAxleInKilograms: int.tryParse(text) ?? null),
                      ),
                    ),
                    PreferencesRowTitle(title: localizations.truckGrossWeightRowTitle),
                    NumericTextField(
                      initialValue: specs.grossWeightInKilograms == null ? "" : specs.grossWeightInKilograms.toString(),
                      hintText: localizations.truckTotalWeightHint,
                      isInteger: true,
                      onChanged: (text) => context.read<RoutePreferencesModel>().truckOptions = _truckOptionsFrom(
                        truckOptions,
                        _truckSpecificationsFrom(specs, grossWeightInKilograms: int.tryParse(text) ?? null),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TruckOptions _truckOptionsFrom(TruckOptions truckOptions, Transport.TruckSpecifications truckSpecifications) {
    final TruckOptions options = TruckOptions.withDefaults()
      ..routeOptions = truckOptions.routeOptions
      ..textOptions = truckOptions.textOptions
      ..avoidanceOptions = truckOptions.avoidanceOptions
      ..truckSpecifications = truckSpecifications
      ..linkTunnelCategory = truckOptions.linkTunnelCategory
      ..hazardousMaterials = truckOptions.hazardousMaterials;
    return options;
  }

  Transport.TruckSpecifications _truckSpecificationsFrom(
    Transport.TruckSpecifications specs, {
    int? grossWeightInKilograms,
    int? weightPerAxleInKilograms,
    int? heightInCentimeters,
    int? widthInCentimeters,
    int? lengthInCentimeters,
    int? axleCount,
  }) {
    return Transport.TruckSpecifications(
      grossWeightInKilograms ?? specs.grossWeightInKilograms,
      weightPerAxleInKilograms ?? specs.weightPerAxleInKilograms,
      heightInCentimeters ?? specs.heightInCentimeters,
      widthInCentimeters ?? specs.widthInCentimeters,
      lengthInCentimeters ?? specs.lengthInCentimeters,
      axleCount ?? specs.axleCount,
    );
  }
}
