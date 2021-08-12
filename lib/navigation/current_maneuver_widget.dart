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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/routing.dart' as Routing;

import '../common/ui_style.dart';
import '../common/util.dart' as Util;

extension _ManeuverImagePath on Routing.ManeuverAction {
  String get imagePath {
    return "assets/maneuvers/light/" + toString().split(".").last + ".svg";
  }
}

/// A widget that displays the current navigation maneuver.
class CurrentManeuver extends StatelessWidget {
  /// The maneuver action.
  final Routing.ManeuverAction action;

  /// Distance to the maneuver.
  final int distance;

  /// Instruction for the maneuver.
  final String text;

  /// Constructs a widget.
  CurrentManeuver({
    required this.action,
    required this.distance,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(UIStyle.contentMarginLarge),
          child: SvgPicture.asset(
            action.imagePath,
            width: UIStyle.bigButtonHeight,
            height: UIStyle.bigButtonHeight,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Util.makeDistanceString(context, distance),
                style: TextStyle(
                  color: colorScheme.background,
                  fontSize: UIStyle.extraHugeFontSize,
                ),
              ),
              Container(
                height: UIStyle.contentMarginSmall,
              ),
              Text(
                text,
                maxLines: 2,
                style: TextStyle(
                  color: colorScheme.background,
                  fontSize: UIStyle.bigFontSize,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
