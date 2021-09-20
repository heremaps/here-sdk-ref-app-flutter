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

import 'ui_style.dart';

/// A widget for the button with gradient background.
class GradientElevatedButton extends StatelessWidget {
  /// Button's title.
  final Widget title;

  /// Called when the button is tapped or otherwise activated.
  final VoidCallback onPressed;

  /// Background primary color.
  final Color primaryColor;

  /// Background secondary color.
  final Color secondaryColor;

  /// Constructs the widget.
  GradientElevatedButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.primaryColor = UIStyle.buttonPrimaryColor,
    this.secondaryColor = UIStyle.buttonSecondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIStyle.bigButtonHeight),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(UIStyle.bigButtonHeight),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: UIStyle.contentMarginExtraLarge,
                horizontal: UIStyle.contentMarginExtraHuge,
              ),
              child: DefaultTextStyle(
                child: title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: UIStyle.hugeFontSize,
                ),
              ),
            ),
          ),
        ),
        onPressed: onPressed,
      );
}
