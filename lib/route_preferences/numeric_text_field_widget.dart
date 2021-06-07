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

import '../common/ui_style.dart';

/// A widget that allows to enter numeric values.
class NumericTextField extends StatelessWidget {
  /// Initial value.
  final String initialValue;
  /// Hint text.
  final String hintText;
  /// True if the input value is to be interpreted as an integer, otherwise it is decimal.
  final bool isInteger;
  /// Called when the value is changed.
  final Function onChanged;

  /// Constructs a widget.
  NumericTextField({Key key, this.isInteger, this.initialValue, this.hintText, @required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: UIStyle.roundedRectDecoration(),
      child: TextFormField(
        initialValue: initialValue ?? "",
        keyboardType: isInteger ? TextInputType.number : TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hintText ?? "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
