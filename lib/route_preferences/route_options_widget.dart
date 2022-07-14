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
import 'package:provider/provider.dart';
import 'numeric_text_field_widget.dart';
import 'enum_string_helper.dart';
import 'preferences_row_title_widget.dart';
import 'preferences_section_title_widget.dart';

import 'dropdown_widget.dart';

import '../common/ui_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/routing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;

import '../common/util.dart' as Util;

/// Routing options widget.
class RouteOptionsWidget extends StatelessWidget {
  static const int _departureYearDelta = 10;
  static const String _alternativesRangeHint = "[0-6]";

  @override
  Widget build(BuildContext context) {
    final RouteOptions routeOptions = context.select((RoutePreferencesModel model) => model.sharedRouteOptions);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PreferencesSectionTitle(title: AppLocalizations.of(context)!.routeOptionsTitle),
        PreferencesRowTitle(title: AppLocalizations.of(context)!.routeAlternativesTitle),
        NumericTextField(
          initialValue: routeOptions.alternatives.toString(),
          isInteger: true,
          hintText: _alternativesRangeHint,
          onChanged: (text) => context.read<RoutePreferencesModel>().sharedRouteOptions = RouteOptions(
            routeOptions.optimizationMode,
            int.tryParse(text) ?? 0,
            routeOptions.departureTime,
          ),
        ),
        PreferencesRowTitle(title: AppLocalizations.of(context)!.departureTimeTitle),
        Container(
          decoration: UIStyle.roundedRectDecoration(),
          child: InkWell(
            onTap: () async {
              DateTime? newDate = await (Platform.isIOS ? _selectDateTimeCupertino(context) : _selectDateTime(context));
              if (newDate != null)
                context.read<RoutePreferencesModel>().sharedRouteOptions =
                    RouteOptions(routeOptions.optimizationMode, routeOptions.alternatives, newDate);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: UIStyle.contentMarginMedium),
                    child: Text(Util.stringFromDateTime(context, routeOptions.departureTime))),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: routeOptions.departureTime != null,
                  child: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: UIStyle.optionsBorderColor,
                    ),
                    onPressed: () => context.read<RoutePreferencesModel>().sharedRouteOptions = RouteOptions(
                      routeOptions.optimizationMode,
                      routeOptions.alternatives,
                      null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        PreferencesRowTitle(title: AppLocalizations.of(context)!.optimizationModeTitle),
        Container(
          decoration: UIStyle.roundedRectDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownWidget(
              data: EnumStringHelper.routeOptimizationModeMap(context),
              selectedValue: routeOptions.optimizationMode.index,
              onChanged: (mode) => context.read<RoutePreferencesModel>().sharedRouteOptions = RouteOptions(
                OptimizationMode.values[mode],
                routeOptions.alternatives,
                routeOptions.departureTime,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _selectDateTime(BuildContext context) async {
    final DateTime? date = await _selectDate(context);
    if (date == null) return null;

    final TimeOfDay? time = await _selectTime(context);
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - _departureYearDelta),
      lastDate: DateTime(now.year + _departureYearDelta),
    );
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
  }

  Future<DateTime?> _selectDateTimeCupertino(BuildContext context) async {
    DateTime? result = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (context) {
        DateTime selectedDateTime = DateTime.now();
        return Container(
          height: UIStyle.cupertinoPickerHeight,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(UIStyle.contentMarginMedium),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectDateTimeTitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: UIStyle.mediumFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: CupertinoDatePicker(onDateTimeChanged: (DateTime dateTime) => selectedDateTime = dateTime),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CupertinoButton(
                      child: Text(
                        AppLocalizations.of(context)!.cancelTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: Text(
                        AppLocalizations.of(context)!.doneTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(selectedDateTime),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    if (result == null) return null;

    return DateTime(result.year, result.month, result.day, result.hour, result.minute);
  }
}
