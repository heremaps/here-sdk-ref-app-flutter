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

import 'package:path_provider/path_provider.dart';

const scene_directory_name = 'scenes';

Future<Directory> _scenesDirectory() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  return await Directory('${directory.path}/$scene_directory_name');
}

Future<void> deleteScenesDirectory() async {
  final Directory directory = await _scenesDirectory();
  // delete any files which we saved in the past.
  if (await directory.exists()) {
    try {
      directory.deleteSync(recursive: true);
    } catch (_) {
      print('Failed to delete the directory and its files');
    }
  }
}

/// Creates and returns a local copy of the given file.
Future<File?> createLocalSceneFile(String filePath) async {
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
