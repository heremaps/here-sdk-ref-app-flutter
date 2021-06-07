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

import '../common/ui_style.dart';

/// A widget indicating that a rerouting is in progress.
class ReroutingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(UIStyle.contentMarginLarge),
          child: Container(
            width: UIStyle.bigButtonHeight,
            height: UIStyle.bigButtonHeight,
            child: CircularProgressIndicator(
              backgroundColor: UIStyle.reroutingProgressBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(UIStyle.reroutingProgressColor),
            ),
          ),
        ),
        Expanded(
          child: Text(
            AppLocalizations.of(context).reroutingInProgressText,
            style: TextStyle(
              color: colorScheme.background,
              fontSize: UIStyle.extraHugeFontSize,
            ),
          ),
        ),
      ],
    );
  }
}
