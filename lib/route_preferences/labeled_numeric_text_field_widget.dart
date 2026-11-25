/*
 * Copyright (C) 2026 HERE Europe B.V.
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
import 'package:here_sdk_reference_application_flutter/route_preferences/numeric_text_field_widget.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/preferences_row_title_widget.dart';

/// A widget that combines a [PreferencesRowTitle] label with a [NumericTextField].
class LabeledNumericTextField extends StatelessWidget {
  final String title;
  final String? initialValue;
  final String? hintText;
  final bool isInteger;
  final ValueChanged<String> onChanged;

  const LabeledNumericTextField({
    super.key,
    required this.title,
    this.initialValue,
    this.hintText,
    this.isInteger = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PreferencesRowTitle(title: title),
        NumericTextField(initialValue: initialValue, hintText: hintText, isInteger: isInteger, onChanged: onChanged),
      ],
    );
  }
}
