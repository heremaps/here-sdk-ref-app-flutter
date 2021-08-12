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
import 'package:here_sdk/navigation.dart' as Navigation;

import '../common/ui_style.dart';

/// A widget that displays the current speed.
class NavigationSpeed extends StatelessWidget {
  static const double _kSpeedWidgetHeight = 135;
  static const double _kSpeedSignBorderWidth = 5;
  static const double _kKMpHinMpS = 3.6;

  /// Current speed.
  final double currentSpeed;

  /// Current speed limit.
  final double? speedLimit;

  /// Current speed warning status.
  final Navigation.SpeedWarningStatus speedWarningStatus;

  /// Constructs a widget.
  NavigationSpeed({
    required this.currentSpeed,
    double? speedLimit,
    required this.speedWarningStatus,
  }) : speedLimit = speedLimit != null && speedLimit > 0 ? speedLimit : null;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: UIStyle.bigButtonHeight + _kSpeedSignBorderWidth * 2,
      height: _kSpeedWidgetHeight,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 2,
              color: colorScheme.background,
              borderRadius: BorderRadius.circular(UIStyle.bigButtonHeight),
              child: Padding(
                padding: EdgeInsets.only(
                  top: UIStyle.contentMarginLarge,
                  bottom: UIStyle.contentMarginLarge,
                ),
                child: Container(
                  width: UIStyle.bigButtonHeight,
                  height: speedLimit != null ? _kSpeedWidgetHeight : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (speedLimit != null) Spacer(),
                      Text(
                        (currentSpeed * _kKMpHinMpS).truncate().toString(),
                        style: TextStyle(
                          fontSize: UIStyle.extraHugeFontSize,
                          color: speedWarningStatus == Navigation.SpeedWarningStatus.speedLimitExceeded
                              ? Colors.red
                              : colorScheme.primary,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.kmhAbbreviationText,
                        style: TextStyle(
                          fontSize: UIStyle.bigFontSize,
                          color: colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (speedLimit != null)
            Align(
              alignment: Alignment.topCenter,
              child: Material(
                elevation: 2,
                color: colorScheme.background,
                borderRadius: BorderRadius.circular(UIStyle.bigButtonHeight),
                child: Container(
                  width: UIStyle.bigButtonHeight + _kSpeedSignBorderWidth * 2,
                  height: UIStyle.bigButtonHeight + _kSpeedSignBorderWidth * 2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: _kSpeedSignBorderWidth,
                    ),
                    borderRadius: BorderRadius.circular(UIStyle.bigButtonHeight),
                  ),
                  child: Center(
                    child: Text(
                      (speedLimit! * _kKMpHinMpS).truncate().toString(),
                      style: TextStyle(
                        fontSize: UIStyle.extraHugeFontSize,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
