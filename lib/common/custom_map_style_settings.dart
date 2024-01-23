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

/// Class used to store custom map style filepath and to inform listeners when filepath changes.
class CustomMapStyleSettings extends ChangeNotifier {
  String? _customMapStyleFilepath;

  /// Getter for custom map style filepath.
  String? get customMapStyleFilepath => _customMapStyleFilepath;

  /// Setter for custom map style filepath.
  void set customMapStyleFilepath(String? newFilepath) {
    if (newFilepath != null) {
      _customMapStyleFilepath = newFilepath;
      notifyListeners();
    }
  }

  /// Getter for filename of current custom map style. Empty string is returned when custom map style is not set.
  String get customMapStyleFilename {
    if (_customMapStyleFilepath == null) {
      return '';
    }
    return _customMapStyleFilepath!.split('/').last;
  }

  void reset() {
    _customMapStyleFilepath = null;
    notifyListeners();
  }
}
