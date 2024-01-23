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

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Helper class for maneuver notifications.
class FileUtility {
  static const String _maneuverDarkImagesDir = "assets/maneuvers/dark/png/";
  static const String _maneuverLightImagesDir = "assets/maneuvers/light/png/";
  static const String _sceneDirectory = 'scenes';

  static Future _createDirsIfNotExist(String docsDirectory, String imagesDirectory) async {
    final Directory maneuversDirectory = Directory("$docsDirectory/$imagesDirectory");
    if (!(await maneuversDirectory.exists())) {
      await maneuversDirectory.create(recursive: true);
    }
  }

  /// Saves an image of the maneuver at [imagePath] to the device's document folder for use in notifications.
  static Future<String> saveManeuverImageFromBundle(String imagePath) async {
    final Directory docsDirectory = await getApplicationDocumentsDirectory();

    await _createDirsIfNotExist(docsDirectory.path, _maneuverDarkImagesDir);
    await _createDirsIfNotExist(docsDirectory.path, _maneuverLightImagesDir);

    final String filePath = '${docsDirectory.path}/$imagePath';

    final File file = File(filePath);
    if (!(await file.exists())) {
      final imageData = await rootBundle.load(imagePath);
      final bytes = imageData.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    }
    return filePath;
  }

  static Future<Directory> _scenesDirectory() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return await Directory('${directory.path}/$_sceneDirectory');
  }

  /// Deletes the scenes directory and all its files if exists.
  static Future<void> deleteScenesDirectory() async {
    try {
      final Directory directory = await _scenesDirectory();
      // delete any files which we saved in the past.
      if (await directory.exists()) {
        directory.deleteSync(recursive: true);
      }
    } catch (e) {
      print('Failed to delete the directory and its files: ${e.toString()}');
    }
  }

  /// Creates and returns a local copy of the given file at scenes directory.
  static Future<File?> createLocalSceneFile(String filePath) async {
    try {
      final Directory scenesDirectory = await _scenesDirectory();
      await deleteScenesDirectory();
      final Directory newDirectory = await scenesDirectory.create();
      final File file = File('${newDirectory.path}/${filePath.split('/').last}');
      // Write the file
      return file.writeAsBytes(File(filePath).readAsBytesSync());
    } catch (e) {
      print('Failed to create a local copy of given file');
      return null;
    }
  }
}
