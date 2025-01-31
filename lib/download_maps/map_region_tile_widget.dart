/*
 * Copyright (C) 2020-2025 HERE Europe B.V.
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
import 'package:here_sdk/maploader.dart';

import '../common/ui_style.dart';
import '../common/util.dart' as Util;

/// A widget that represents downloadable map region.
class MapRegionTile extends StatelessWidget {
  /// Map region to display.
  final Region region;

  /// Map region installation state.
  final InstalledRegion? installedRegion;

  /// If true widget acts as tree root element.
  final bool isHeader;

  /// If true widget acts as tree child element.
  final bool isChild;

  /// Leading icon.
  final Icon? icon;

  /// Download progress.
  final int? downloadProgress;

  /// Called when the tile is tapped or otherwise activated.
  final VoidCallback? onTap;

  /// Constructs the widget.
  MapRegionTile({
    Key? key,
    required this.region,
    this.installedRegion = null,
    this.isHeader = false,
    this.isChild = false,
    this.icon = null,
    this.downloadProgress = null,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    bool hasChildren = region.childRegions != null;

    late String subtitle;

    if (hasChildren && !isHeader) {
      subtitle = Util.formatString(appLocalizations.mapRegionChildrenNumberText, [region.childRegions!.length]);
    } else if (isHeader) {
      subtitle = Util.formatString(
        appLocalizations.sizeOfWholeAreaOfRegion,
        [Util.makeStorageSizeString(context, region.sizeOnDiskInBytes)],
      );
    } else {
      subtitle = Util.makeStorageSizeString(context, region.sizeOnDiskInBytes);
    }

    Icon? tileIcon;

    if (downloadProgress != null) {
      if (downloadProgress! >= 0) {
        tileIcon = Icon(
          Icons.close,
          size: UIStyle.smallIconSize,
        );
      }
    } else {
      tileIcon = icon ??
          Icon(
            installedRegion?.status == InstalledRegionStatus.installed
                ? Icons.check_circle
                : hasChildren && !isHeader
                    ? Icons.arrow_forward
                    : Icons.download,
            color: installedRegion?.status == InstalledRegionStatus.installed ? Colors.green : null,
          );
    }

    return ListTile(
      minLeadingWidth: 0,
      visualDensity: VisualDensity(vertical: -4),
      leading: isChild
          ? Container(
              width: UIStyle.contentMarginMedium,
            )
          : null,
      title: Text(
        region.name,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSecondary,
            ),
          ),
          if (downloadProgress == null && installedRegion?.status == InstalledRegionStatus.pending && !hasChildren)
            Text(
              appLocalizations.incompleteDownloadMessage,
              style: TextStyle(
                color: colorScheme.onSecondary,
              ),
            ),
        ],
      ),
      trailing: Container(
        width: UIStyle.bigIconSize,
        height: UIStyle.bigIconSize,
        child: Stack(
          children: [
            if (downloadProgress != null)
              CircularProgressIndicator(
                value: downloadProgress! >= 0 ? downloadProgress! / 100 : null,
                color: colorScheme.secondary,
                backgroundColor: Theme.of(context).dividerColor,
              ),
            Center(
              child: tileIcon,
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
