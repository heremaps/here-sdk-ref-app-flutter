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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../common/ui_style.dart';
import 'route_progress_widget.dart';

/// A widget that displays the current navigation progress.
class NavigationProgress extends StatelessWidget {
  /// The length of the route.
  final int routeLengthInMeters;
  /// Remaining distance in meters.
  final int remainingDistanceInMeters;
  /// Remaining time in seconds.
  final int remainingDurationInSeconds;

  /// Constructs a widget.
  NavigationProgress({
    Key key,
    @required this.routeLengthInMeters,
    @required this.remainingDistanceInMeters,
    @required this.remainingDurationInSeconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context);

    DateTime dt = DateTime.now();
    DateTime dtArrival = dt.add(Duration(seconds: remainingDurationInSeconds));

    int remainingHours = (remainingDurationInSeconds / 3600).truncate();
    int remainingMinutes = ((remainingDurationInSeconds - remainingHours * 3600) / 60).truncate();

    String remainingDistanceUnits = appLocalizations.kilometerAbbreviationText;
    int remainingDistance = (remainingDistanceInMeters / 1000).truncate();
    if (remainingDistance == 0) {
      remainingDistance = remainingDistanceInMeters;
      remainingDistanceUnits = appLocalizations.meterAbbreviationText;
    }

    return BottomAppBar(
      color: colorScheme.background,
      child: Padding(
        padding: EdgeInsets.all(UIStyle.contentMarginMedium),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      DateFormat.Hm().format(dtArrival),
                      style: TextStyle(
                        fontSize: UIStyle.extraHugeFontSize,
                      ),
                    ),
                    Text(
                      appLocalizations.arrivalTitle,
                      style: TextStyle(
                        fontSize: UIStyle.bigFontSize,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: UIStyle.contentMarginHuge,
                ),
                Column(
                  children: [
                    Text(
                      remainingHours.toString(),
                      style: TextStyle(
                        fontSize: UIStyle.extraHugeFontSize,
                      ),
                    ),
                    Text(
                      appLocalizations.hourAbbreviationText,
                      style: TextStyle(
                        fontSize: UIStyle.bigFontSize,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: UIStyle.contentMarginLarge,
                ),
                Column(
                  children: [
                    Text(
                      remainingMinutes.toString(),
                      style: TextStyle(
                        fontSize: UIStyle.extraHugeFontSize,
                      ),
                    ),
                    Text(
                      appLocalizations.minuteAbbreviationText,
                      style: TextStyle(
                        fontSize: UIStyle.bigFontSize,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: UIStyle.contentMarginHuge,
                ),
                Column(
                  children: [
                    Text(
                      remainingDistance.toString(),
                      style: TextStyle(
                        fontSize: UIStyle.extraHugeFontSize,
                      ),
                    ),
                    Text(
                      remainingDistanceUnits.toString(),
                      style: TextStyle(
                        fontSize: UIStyle.bigFontSize,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: RouteProgress(
                  routeLengthInMeters: routeLengthInMeters,
                  remainingDistanceInMeters: remainingDistanceInMeters,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
