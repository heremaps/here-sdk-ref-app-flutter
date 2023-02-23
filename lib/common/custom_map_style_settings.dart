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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const scene_directory_name = 'scenes';

/// Class used to store custom map style filepath and to inform listeners when filepath changes.
class CustomMapStyleSettings extends ChangeNotifier {
  String? _customMapStyleFilepath;

  /// Creates and returns a local copy of the given file.
  Future<File> createLocalFile(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final scenesDirectory = await Directory('${directory.path}/$scene_directory_name');
    // delete any files which we saved in the past.
    if (await scenesDirectory.exists()) {
      scenesDirectory.deleteSync(recursive: true);
    }
    await scenesDirectory.create();
    final file = File('$scenesDirectory/${filePath.split('/').last}');
    // Write the file
    return file.writeAsBytes(File(filePath).readAsBytesSync());
  }

  /// Getter for custom map style filepath.
  String? get customMapStyleFilepath => _customMapStyleFilepath;

  /// Setter for custom map style filepath.
  void set customMapStyleFilepath(String? newFilepath) {
    if (newFilepath != null) {
      // create a copy to local application directory
      createLocalFile(newFilepath).then((value) {
        _customMapStyleFilepath = value.path;
        notifyListeners();
      }).onError((_, __) {
        _customMapStyleFilepath = newFilepath;
        notifyListeners();
      });
    }
  }

  /// Getter for filename of current custom map style. Empty string is returned when custom map style is not set.
  String get customMapStyleFilename {
    if (_customMapStyleFilepath == null) {
      return '';
    }
    return _customMapStyleFilepath!.split('/').last;
  }
}
