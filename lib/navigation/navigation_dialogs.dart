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
import 'package:flutter_svg/flutter_svg.dart';

import '../common/ui_style.dart';
import '../common/util.dart' as Util;

/// Creates a dialog for selecting a location source for navigation.
/// There are two options available, simulation and device location.
Future<bool?> askForPositionSource(BuildContext context) async {
  AppLocalizations appLocalizations = AppLocalizations.of(context)!;

  return await showDialog<bool>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(appLocalizations.selectPositioningDialogTitle),
      children: [
        SimpleDialogOption(
          child: ListTile(
            leading: SvgPicture.asset(
              "assets/route.svg",
              color: Theme.of(context).colorScheme.onSecondary,
              width: UIStyle.mediumIconSize,
              height: UIStyle.mediumIconSize,
            ),
            title: Text(appLocalizations.simulatedLocationSourceTitle),
          ),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        SimpleDialogOption(
          child: ListTile(
            leading: Icon(Icons.gps_fixed),
            title: Text(appLocalizations.realLocationSourceTitle),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    ),
  );
}

/// Creates a confirmation dialog to stop navigation.
Future<bool> askForExitFromNavigation(BuildContext context) async {
  AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  return Util.showCommonConfirmationDialog(
    context: context,
    title: appLocalizations.stopNavigationDialogTitle,
    message: appLocalizations.stopNavigationDialogSubtitle,
    actionTitle: appLocalizations.stopNavigationAcceptButtonCaption,
    actionTextColor: UIStyle.stopNavigationButtonIconColor,
    actionBackgroundColor: UIStyle.stopNavigationButtonColor,
  );
}
