/*
 * Copyright (C) 2020-2025 HERE Europe B.V.
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

import 'ui_style.dart';

/// A widget for the reset current location floating button.
class ResetLocationButton extends StatelessWidget {
  /// Called when the button is tapped or otherwise activated.
  final VoidCallback onPressed;

  /// Constructs a widget.
  ResetLocationButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UIStyle.mediumButtonHeight,
      height: UIStyle.mediumButtonHeight,
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Icon(Icons.gps_fixed),
        onPressed: onPressed,
      ),
    );
  }
}
