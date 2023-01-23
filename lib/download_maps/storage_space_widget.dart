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

import 'dart:async';

import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/util.dart' as Util;
import '../common/ui_style.dart';

/// A widget displaying the available space in local storage.
class StorageSpace extends StatefulWidget {
  /// Constructs the widget.
  StorageSpace({
    Key? key,
  }) : super(key: key);

  @override
  _StorageSpaceState createState() => _StorageSpaceState();
}

class _StorageSpaceState extends State<StorageSpace> {
  int _availableSpace = 0;
  int _totalSpace = 0;

  late Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) => _updateDiskSpace());
    _updateDiskSpace();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(UIStyle.contentMarginHuge),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: "${appLocalizations.internalStorageText} (",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: UIStyle.bigFontSize,
                ),
                children: [
                  TextSpan(
                    text: Util.makeStorageSizeString(context, _totalSpace),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ")",
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: UIStyle.contentMarginMedium,
          ),
          if (_totalSpace > 0)
            LinearProgressIndicator(
              value: 1 - _availableSpace / _totalSpace,
              valueColor: AlwaysStoppedAnimation(colorScheme.secondary),
              backgroundColor: Theme.of(context).dividerColor,
            ),
          Container(
            height: UIStyle.contentMarginMedium,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: RichText(
              text: TextSpan(
                text: "${appLocalizations.availableStorageText}: ",
                style: TextStyle(
                  color: colorScheme.onSecondary,
                ),
                children: [
                  TextSpan(
                    text: Util.makeStorageSizeString(context, _availableSpace),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDiskSpace() async {
    double? freeDiskSpace = await DiskSpace.getFreeDiskSpace;
    double? totalDiskSpace = await DiskSpace.getTotalDiskSpace;
    if (mounted) {
      setState(() {
        if (freeDiskSpace != null) {
          _availableSpace = (freeDiskSpace * 1048576).toInt();
        }
        if (totalDiskSpace != null) {
          _totalSpace = (totalDiskSpace * 1048576).toInt();
        }
      });
    }
  }
}
