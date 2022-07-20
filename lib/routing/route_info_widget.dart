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
import 'package:here_sdk/routing.dart' as Routing;

import '../common/ui_style.dart';
import '../common/util.dart' as Util;

/// A widget that displays the route length, duration (with traffic delays) and two buttons one for navigation and the
/// other for route details.
class RouteInfo extends StatelessWidget {
  /// The route.
  final Routing.Route route;

  /// Called when the route details button is tapped or otherwise activated.
  final VoidCallback? onRouteDetails;

  /// Called when the navigation button is tapped or otherwise activated.
  final VoidCallback? onNavigation;

  /// Constructs a widget.
  RouteInfo({
    required this.route,
    this.onRouteDetails,
    this.onNavigation,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(UIStyle.contentMarginMedium),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: _buildDurationString(context, route.duration.inSeconds) + " ",
                    style: TextStyle(
                      fontSize: UIStyle.hugeFontSize,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    children: [
                      if (route.trafficDelay.inSeconds > Duration.secondsPerMinute)
                        TextSpan(
                          text: Util.formatString(AppLocalizations.of(context)!.trafficDelayText,
                              [_buildDurationString(context, route.trafficDelay.inSeconds)]),
                          style: TextStyle(
                            fontSize: UIStyle.mediumFontSize,
                            color: UIStyle.trafficWarningColor,
                          ),
                        )
                      else
                        TextSpan(
                          text: AppLocalizations.of(context)!.noTrafficDelaysText,
                          style: TextStyle(
                            fontSize: UIStyle.smallFontSize,
                            color: colorScheme.onSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  height: UIStyle.contentMarginMedium,
                ),
                Text(
                  Util.makeDistanceString(context, route.lengthInMeters),
                  style: TextStyle(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: UIStyle.hugeFontSize,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onRouteDetails != null)
                ClipOval(
                  child: Material(
                    child: Ink(
                      width: UIStyle.smallButtonHeight,
                      height: UIStyle.smallButtonHeight,
                      color: colorScheme.background,
                      child: InkWell(
                        child: Icon(
                          Icons.directions,
                          size: UIStyle.smallIconSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: onRouteDetails,
                      ),
                    ),
                  ),
                ),
              if (onRouteDetails != null && onNavigation != null)
                Container(
                  width: UIStyle.contentMarginMedium,
                ),
              if (onNavigation != null)
                ClipOval(
                  child: Material(
                    child: Ink(
                      width: UIStyle.smallButtonHeight,
                      height: UIStyle.smallButtonHeight,
                      color: colorScheme.background,
                      child: InkWell(
                        child: Icon(
                          Icons.navigation,
                          size: UIStyle.smallIconSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: onNavigation,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  String _buildDurationString(BuildContext context, int durationInSeconds) {
    int minutes = (durationInSeconds / 60).truncate();
    int hours = (minutes / 60).truncate();
    minutes = minutes % 60;

    if (hours == 0) {
      return "$minutes ${AppLocalizations.of(context)!.minuteAbbreviationText}";
    } else {
      String result = "$hours ${AppLocalizations.of(context)!.hourAbbreviationText}";
      if (minutes != 0) {
        result += " $minutes ${AppLocalizations.of(context)!.minuteAbbreviationText}";
      }
      return result;
    }
  }
}
