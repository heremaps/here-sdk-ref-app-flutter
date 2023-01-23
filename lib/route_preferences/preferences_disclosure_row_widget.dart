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

import '../common/ui_style.dart';

/// Widget for preference disclosure row.
class PreferencesDisclosureRowWidget extends StatelessWidget {
  /// Title
  final String title;

  /// Sub-title
  final String? subTitle;

  /// Called when the widget is tapped or otherwise activated.
  final VoidCallback onPressed;

  /// Constructs a widget.
  PreferencesDisclosureRowWidget({
    required this.title,
    required this.onPressed,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(top: UIStyle.contentMarginExtraLarge),
        child: Container(
          decoration: UIStyle.bottomDividerDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: UIStyle.bigFontSize),
                    ),
                    if (subTitle?.isNotEmpty ?? false)
                      Text(
                        subTitle!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                        textAlign: TextAlign.left,
                      )
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_right, color: Theme.of(context).colorScheme.onSecondary),
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
