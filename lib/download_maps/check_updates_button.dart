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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk/maploader.dart';
import 'package:provider/provider.dart';

import 'map_loader_controller.dart';
import '../common/ui_style.dart';
import '../common/util.dart' as Util;

typedef MapUpdateStatusCallback = void Function(MapUpdateAvailability? availability);

/// A widget that represents a button to check if a map update is available.
class CheckMapUpdatesButton extends StatefulWidget {
  /// Callback that is called when map update is available.
  final MapUpdateStatusCallback onUpdate;

  CheckMapUpdatesButton({
    Key? key,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _CheckMapUpdatesButtonState createState() => _CheckMapUpdatesButtonState();
}

class _CheckMapUpdatesButtonState extends State<CheckMapUpdatesButton> {
  bool _checkInProgress = false;

  @override
  Widget build(BuildContext context) => Consumer<MapLoaderController>(
        builder: (context, controller, child) =>
            _checkInProgress ? _buildProgressWidget(context) : _buildButtonWidget(context, controller),
      );

  Widget _buildButtonWidget(BuildContext context, MapLoaderController controller) => OutlinedButton.icon(
        icon: Icon(Icons.update),
        label: Text(AppLocalizations.of(context)!.checkForMapUpdateTitle),
        onPressed: () {
          setState(() => _checkInProgress = true);
          controller
              .checkMapUpdate()
              .then((value) => widget.onUpdate.call(value))
              .catchError((error) => Util.displayErrorSnackBar(
                  context,
                  Util.formatString(
                    AppLocalizations.of(context)!.updateMapsErrorText,
                    [error.toString()],
                  )))
              .whenComplete(() => mounted ? setState(() => _checkInProgress = false) : null);
        },
      );

  Widget _buildProgressWidget(BuildContext context) => OutlinedButton.icon(
        icon: Container(
          width: UIStyle.mediumIconSize,
          height: UIStyle.mediumIconSize,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).dividerColor,
          ),
        ),
        label: Text(AppLocalizations.of(context)!.checkForMapUpdateProgressTitle),
        onPressed: null,
      );
}
