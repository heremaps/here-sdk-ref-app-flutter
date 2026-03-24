/*
* Copyright (c) 2026 HERE Global B.V. and its affiliate(s).
* All rights reserved.
*
* This software and other materials contain proprietary information
* controlled by HERE and are protected by applicable copyright legislation.
* Any use and utilization of this software and other materials and
* disclosure to any third parties is conditional upon having a separate
* agreement with HERE for the access, use, utilization or disclosure of this
* software. In the absence of such agreement, the use of the software is not
* allowed.
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
