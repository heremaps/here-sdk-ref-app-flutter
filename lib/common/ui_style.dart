/*
 * Copyright (C) 2020-2024 HERE Europe B.V.
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

/// Helper class that contains all definitions of colors, fonts, sizes and other UI parameters that are used in
/// the application.
class UIStyle {
  static const Color buttonPrimaryColor = Color(0xFF6B9CFF); // Primary button color
  static const Color buttonSecondaryColor = Color(0xFF65EBE2); // Secondary button color
  static const Color accuracyCircleColor = Color(0x550BC7C2);
  static const Color selectedListTileColor = Color(0xFFF5F5F5);
  static const Color acceptedConsentColor = Color(0xFF80E3C1);
  static const Color revokedConsentColor = Color(0xFFFF0000);
  static const Color trafficWarningColor = Color(0xFFFA9D00);
  static const Color currentPositionColor = Color(0xFF0BC7C2);

  static const Color stopNavigationButtonColor = Color(0xFFFB0425);
  static const Color stopNavigationButtonIconColor = Color(0xFFFFFFFF);
  static const Color reroutingProgressBackgroundColor = Color(0xFFC4C4C4);
  static const Color reroutingProgressColor = Color(0xFFFFFFFF);

  static const Color optionsBorderColor = Color(0x5500123E);
  static const Color tabBarBackgroundColor = Color(0xFFF9FAFC);
  static const Color preferencesBackgroundColor = Color(0xFFFFFFFF);

  static const Color noLocationWarningBackgroundColor = Color(0xCC000A19);
  static const Color noLocationWarningColor = Color(0xFFFFFFFF);

  static const Color loadCustomStyleResultPopupBackgroundColor = Color(0xCC000A19);
  static const Color loadCustomStyleResultPopupTextColor = Color(0xFFFFFFFF);

  static const Color errorMessageTextColor = Color(0xFFFFFFFF);

  static const Color routeColor = Color(0xFF929FB2);
  static const Color routeBorderColor = Color(0xFF6F7F90);
  static const Color selectedRouteColor = Color(0xFF126EF8);
  static const Color selectedRouteBorderColor = Color(0xFF195BB9);
  static const Color addWayPointPopupBackgroundColor = Color(0xFF333B47);
  static const Color addWayPointPopupForegroundColor = Color(0xFFFFFFFF);
  static const Color removeWayPointBackgroundColor = Color(0xFFFB0425);
  static const Color removeWayPointIconColor = Color(0xFFFFFFFF);
  static const double routeLineWidth = 20;
  static const double routeOutLineWidth = 5;

  static const int locationMarkerSize = 30; // logical pixels
  static const int searchMarkerSize = 30; // logical pixels
  static const int poiMarkerSize = 45; // logical pixels
  static const int maneuverMarkerSize = 15; // logical pixels

  static const double contentMarginExtraSmall = 2;
  static const double contentMarginSmall = 4;
  static const double contentMarginMedium = 8;
  static const double contentMarginLarge = 12;
  static const double contentMarginExtraLarge = 16;
  static const double contentMarginHuge = 20;
  static const double contentMarginExtraHuge = 24;

  static const double extraHugeFontSize = 30;
  static const double hugeFontSize = 20;
  static const double bigFontSize = 16;
  static const double mediumFontSize = 14;
  static const double smallFontSize = 10;

  static const double bigButtonHeight = 56;
  static const double mediumButtonHeight = 48;
  static const double smallButtonHeight = 40;

  static const double bigIconSize = 24;
  static const double mediumIconSize = 20;
  static const double smallIconSize = 16;

  static const double drawerLogoSize = 96;

  static const double optionsRectBorderRadius = 2;
  static const double optionsRectBorderWidth = 1;
  static const double popupsBorderRadius = 10;

  static const double maxBottomDraggableSheetSize = 0.8;

  static const double cupertinoPickerHeight = 250;

  static const int searchMarkerDrawOrder = 5;
  static const int waypointsMarkerDrawOrder = 10;

  // private UI constants
  static const double _defaultFontSize = 16;
  static const double _defaultHeadingFontSize = 18;
  static const double _dialogHeadingFontSize = 20;

  // HERE colors
  static const Color _lightBackground = Color.fromARGB(0xff, 0xf5, 0xf5, 0xf5);
  static const Color _lightAccent = Color.fromARGB(0xff, 0x12, 0x6e, 0xf8);
  static const Color _lightAccentSecondary = Color.fromARGB(0xff, 0x2c, 0x48, 0xa1);
  static const Color _lightForeground = Color.fromARGB(0xff, 0x27, 0x2d, 0x37);
  static const Color _lightForegroundSecondary = Color.fromARGB(0xff, 0x6f, 0x73, 0x7a);
  static const Color _lightForegroundHint = Color.fromARGB(0xff, 0xb7, 0xb9, 0xbc);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: _lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackground,
      foregroundColor: _lightForeground,
      iconTheme: IconThemeData(
        color: _lightAccent,
      ),
    ),
    iconTheme: const IconThemeData(
      color: _lightAccent,
    ),
    textTheme: _lightTextTheme,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _lightAccent,
      selectionColor: _lightAccent,
      selectionHandleColor: _lightAccent,
    ),
    inputDecorationTheme: _lightInputDecorationTheme,
    hintColor: _lightForegroundHint,
    highlightColor: _lightAccentSecondary,
    colorScheme: const ColorScheme.light(
      primary: _lightForeground,
      secondary: _lightAccent,
      secondaryContainer: _lightAccentSecondary,
      onPrimary: _lightBackground,
      onSecondary: _lightForegroundSecondary,
      surface: _lightBackground,
    ).copyWith(surface: _lightBackground),
  );

  static const TextStyle _lightBodyTextStyle = TextStyle(
    fontSize: _defaultFontSize,
    color: _lightForeground,
  );
  static const TextStyle _lightLabelTextStyle = TextStyle(
    color: _lightForeground,
  );
  static const TextStyle _lightButtonTextStyle = TextStyle(
    color: _lightBackground,
  );
  static const TextStyle _lightHeading = TextStyle(
    color: _lightForeground,
    fontWeight: FontWeight.bold,
    fontSize: _defaultHeadingFontSize,
  );
  static const TextStyle _lightHeadlinePrimary = TextStyle(
    color: _lightForeground,
    fontWeight: FontWeight.bold,
    fontSize: _dialogHeadingFontSize,
  );
  static const TextStyle _lightHintTextStyle = TextStyle(
    color: _lightForegroundHint,
  );
  static const TextStyle _lightSecondaryTextStyle = TextStyle(
    color: _lightForeground,
  );

  static const TextTheme _lightTextTheme = TextTheme(
    bodyLarge: _lightBodyTextStyle,
    bodyMedium: _lightLabelTextStyle,
    labelLarge: _lightButtonTextStyle,
    headlineSmall: _lightHeading,
    titleLarge: _lightHeadlinePrimary,
    titleMedium: _lightSecondaryTextStyle,
    titleSmall: _lightHintTextStyle,
  );

  static const InputDecorationTheme _lightInputDecorationTheme = InputDecorationTheme(
    filled: false,
    fillColor: Colors.transparent,
    border: UnderlineInputBorder(
        borderSide: BorderSide(
      color: _lightForegroundHint,
    )),
    focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
      color: _lightForegroundHint,
    )),
    hintStyle: TextStyle(
      color: _lightForegroundHint,
    ),
  );

  /// Creates text style for the options section text.
  static TextStyle optionsSectionStyle(BuildContext context) {
    return TextStyle(
      fontSize: bigFontSize,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  /// Creates rounded rect shape decoration.
  static ShapeDecoration roundedRectDecoration() => ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: optionsRectBorderWidth,
            style: BorderStyle.solid,
            color: optionsBorderColor,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(optionsRectBorderRadius),
          ),
        ),
      );

  /// Creates bottom divider decoration.
  static BoxDecoration bottomDividerDecoration() => BoxDecoration(
        border: Border(
          bottom: BorderSide(color: optionsBorderColor, width: 1.0),
        ),
      );

  /// Creates top rounded border shape.
  static ShapeBorder topRoundedBorder() => RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(popupsBorderRadius),
          topRight: Radius.circular(popupsBorderRadius),
        ),
      );

  /// Creates bottom rounded border shape.
  static ShapeBorder bottomRoundedBorder() => RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(popupsBorderRadius),
          bottomRight: Radius.circular(popupsBorderRadius),
        ),
      );
}
