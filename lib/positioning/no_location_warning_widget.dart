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
import 'package:flutter_svg/flutter_svg.dart';

import '../common/ui_style.dart';

/// A widget that displays a warning that positioning is not available..
class NoLocationWarning extends StatelessWidget {
  static const double _kOverlayPosition = 100;
  static const double _kOverlayHeight = 75;

  /// Called when the close button is tapped or otherwise activated.
  final VoidCallback onPressed;

  /// Constructs a widget.
  NoLocationWarning({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Positioned(
        left: UIStyle.contentMarginMedium,
        right: UIStyle.contentMarginMedium,
        bottom: _kOverlayPosition,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(UIStyle.popupsBorderRadius)),
          ),
          color: UIStyle.noLocationWarningBackgroundColor,
          elevation: 2,
          child: SizedBox(
            height: _kOverlayHeight,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                    child: SvgPicture.asset(
                      "assets/gps.svg",
                      color: UIStyle.noLocationWarningColor,
                      width: UIStyle.bigIconSize,
                      height: UIStyle.bigIconSize,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.noLocationWarning,
                      style: TextStyle(
                        fontSize: UIStyle.bigFontSize,
                        color: UIStyle.noLocationWarningColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: UIStyle.noLocationWarningColor,
                    ),
                    onPressed: onPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
