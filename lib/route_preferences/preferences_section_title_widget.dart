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

import 'package:flutter/cupertino.dart';

import '../common/ui_style.dart';

/// Widget for preference section title.
class PreferencesSectionTitle extends StatelessWidget {
  /// Title
  final String title;

  /// Constructs a widget.
  PreferencesSectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: UIStyle.contentMarginExtraHuge),
        child: Row(children: <Widget>[
          Text(title, style: UIStyle.optionsSectionStyle(context)),
        ]));
  }
}
