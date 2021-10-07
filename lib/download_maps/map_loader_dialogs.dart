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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk/maploader.dart';

import '../common/gradient_elevated_button.dart';
import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import 'map_loader_controller.dart';

/// Shows confirmation dialog and then cancels download a [Region].
extension CancelDownloadExtension on MapLoaderController {
  void cancelDownloadWithConfirmation(BuildContext context, Region region) async {
    this.pauseDownload(region.regionId);

    if (await _askForCancelMapLoading(context, region.name)) {
      this.cancelDownload(region.regionId);
    } else {
      this.resumeDownload(region.regionId);
    }
  }
}

/// Creates a confirmation dialog to cancel map loading.
Future<bool> _askForCancelMapLoading(BuildContext context, String regionName) async {
  AppLocalizations appLocalizations = AppLocalizations.of(context)!;

  bool? result = await showDialog<bool>(
    context: context,
    builder: (context) => SimpleDialog(
      titlePadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      contentPadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      insetPadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      title: Text(
        Util.formatString(appLocalizations.stopMapDownloadDialogTitle, [regionName]),
        textAlign: TextAlign.center,
      ),
      children: [
        Row(
          children: [
            Spacer(),
            GradientElevatedButton(
              title: Text(appLocalizations.stopMapDownloadButtonTitle),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            Spacer(),
          ],
        ),
        Util.buildDialogCancelButton(context),
      ],
    ),
  );

  return result ?? false;
}

/// Creates a map updates unavailable dialog.
void showMapUpdatesUnavailableDialog(BuildContext context) async {
  AppLocalizations appLocalizations = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      titlePadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      contentPadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      insetPadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      title: Text(
        appLocalizations.mapUpdateUnavailableDialogTitle,
        textAlign: TextAlign.center,
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: UIStyle.contentMarginExtraLarge,
          ),
          child: Text(
            appLocalizations.mapUpdateUnavailableDialogMessage,
            style: TextStyle(
              fontSize: UIStyle.bigFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Util.buildDialogCancelButton(context),
      ],
    ),
  );
}

/// Creates a map updates available dialog.
Future<bool> showMapUpdatesAvailableDialog(BuildContext context) async {
  AppLocalizations appLocalizations = AppLocalizations.of(context)!;

  bool? result = await showDialog<bool>(
    context: context,
    builder: (context) => SimpleDialog(
      titlePadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      contentPadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      insetPadding: const EdgeInsets.all(UIStyle.contentMarginExtraLarge),
      title: Text(
        appLocalizations.mapUpdateAvailableDialogTitle,
        textAlign: TextAlign.center,
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: UIStyle.contentMarginExtraLarge,
          ),
          child: Text(
            appLocalizations.mapUpdateAvailableDialogMessage,
            style: TextStyle(
              fontSize: UIStyle.bigFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Spacer(),
            GradientElevatedButton(
              title: Text(appLocalizations.updateButtonTitle),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            Spacer(),
          ],
        ),
        Util.buildDialogCancelButton(context),
      ],
    ),
  );

  return result ?? false;
}
