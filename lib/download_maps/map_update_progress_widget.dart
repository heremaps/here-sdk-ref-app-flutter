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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'map_loader_controller.dart';
import '../common/ui_style.dart';

/// A widget that represents the progress of the map update.
class MapUpdateProgress extends StatelessWidget {
  MapUpdateProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<MapLoaderController>(
        builder: (context, controller, child) => Padding(
          padding: EdgeInsets.all(UIStyle.contentMarginHuge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.updatingMapTitle,
                style: TextStyle(fontSize: UIStyle.bigFontSize, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: UIStyle.contentMarginMedium,
                ),
                child: LinearProgressIndicator(
                  value: controller.mapUpdateState != MapUpdateState.cancelling
                      ? controller.mapUpdateProgress! / 100
                      : null,
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary),
                  backgroundColor: Theme.of(context).dividerColor,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  if (controller.mapUpdateState == MapUpdateState.progress)
                    _buildButton(context, Icon(Icons.pause), () => controller.pauseMapUpdate()),
                  if (controller.mapUpdateState == MapUpdateState.paused)
                    _buildButton(context, Icon(Icons.play_arrow), () => controller.resumeMapUpdate()),
                  Container(
                    width: UIStyle.contentMarginMedium,
                  ),
                  if (controller.mapUpdateState != MapUpdateState.cancelling)
                    _buildButton(
                        context,
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        () => controller.cancelMapUpdate()),
                ],
              ),
              Divider(),
            ],
          ),
        ),
      );

  Widget _buildButton(BuildContext context, Widget icon, VoidCallback onTap) => ClipOval(
        child: Material(
          child: Ink(
            width: UIStyle.smallButtonHeight,
            height: UIStyle.smallButtonHeight,
            color: Theme.of(context).dividerColor,
            child: InkWell(
              child: Center(
                child: icon,
              ),
              onTap: onTap,
            ),
          ),
        ),
      );
}
