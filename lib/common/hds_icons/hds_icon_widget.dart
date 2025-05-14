/*
 * Copyright (C) 2025 HERE Europe B.V.
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

import '../ui_style.dart';

/// A widget for displaying icons with customizable size and color properties,
/// using assets specified by [assetPath]
///
/// Example:
/// ```dart
///     HdsIconWidget( pathForIcon, color: Colors.accents )
/// ```

class HdsIconWidget extends StatelessWidget {
  /// Creates an [HdsIconWidget] with default icon size ([UIStyle.bigIconSize]).
  const HdsIconWidget(
    this.assetPath, {
    super.key,
    this.color,
    this.width = UIStyle.bigIconSize,
    this.height = UIStyle.bigIconSize,
    this.ignoreColor = false,
  });

  /// Creates an [HdsIconWidget] with a small icon size ([UIStyle.smallIconSize]).
  const HdsIconWidget.small(
    this.assetPath, {
    super.key,
    this.color,
    this.width = UIStyle.smallIconSize,
    this.height = UIStyle.smallIconSize,
    this.ignoreColor = false,
  });

  /// Creates an [HdsIconWidget] with a medium icon size ([UIStyle.mediumIconSize]).
  const HdsIconWidget.medium(
    this.assetPath, {
    super.key,
    this.color,
    this.width = UIStyle.mediumIconSize,
    this.height = UIStyle.mediumIconSize,
    this.ignoreColor = false,
  });

  /// Creates an [HdsIconWidget] with a large icon size ([UIStyle.largeIconSize]).
  const HdsIconWidget.large(
    this.assetPath, {
    super.key,
    this.color,
    this.width = UIStyle.largeIconSize,
    this.height = UIStyle.largeIconSize,
    this.ignoreColor = false,
  });

  /// Path of the asset file
  final String assetPath;

  /// Color of the icon
  ///
  /// defaults to 'Theme.of(context).colorScheme.primary'
  final Color? color;

  /// Height of the icon
  final double height;

  /// Determines whether to ignore the color setting.
  /// If true, the color is set to null, effectively ignoring any color settings.
  /// If false, the color is applied based on the provided `color` value or falls back
  /// to `Theme.of(context).colorScheme.primary` if `color` is null.
  final bool ignoreColor;

  /// Width of the icon
  final double width;

  bool _isSvg(String filePath) => filePath.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    return _isSvg(assetPath)
        ? SvgPicture.asset(
            assetPath,
            width: width,
            height: height,
            colorFilter: ignoreColor
                ? null
                : ColorFilter.mode(
                    color ?? Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
          )
        : ImageIcon(
            AssetImage(assetPath),
            size: width,
            color: ignoreColor ? null : color ?? Theme.of(context).colorScheme.primary,
          );
  }
}
