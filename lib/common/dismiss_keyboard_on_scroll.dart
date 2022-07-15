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

import 'package:flutter/material.dart';

/// A widget that hides the keyboard when the user scrolls child widget.
class DismissKeyboardOnScroll extends StatelessWidget {
  /// Child widget.
  final Widget child;

  /// Called when the keyboard is dismissed.
  final Function? onDismiss;

  /// Constructs a widget.
  const DismissKeyboardOnScroll({
    Key? key,
    required this.child,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollStartNotification>(
      onNotification: (x) {
        if (x.dragDetails == null) {
          return false;
        }

        FocusScope.of(context).unfocus();
        onDismiss?.call();
        return false;
      },
      child: child,
    );
  }
}
