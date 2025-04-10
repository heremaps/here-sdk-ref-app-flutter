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

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk_reference_application_flutter/landing_screen.dart';
import 'package:path_provider/path_provider.dart';

import 'ui_style.dart';

/// Helper class for maneuver notifications.
class FileUtility {
  static const String _sceneDirectory = 'scenes';

  static Future _createDirsIfNotExist(String docsDirectory, String imagesDirectory) async {
    final Directory maneuversDirectory = Directory("$docsDirectory/$imagesDirectory");
    if (!(await maneuversDirectory.exists())) {
      await maneuversDirectory.create(recursive: true);
    }
  }

  static Future<String> _createFullPath(String imagePath) async {
    final Directory docsDirectory = await getApplicationDocumentsDirectory();
    final List<String> path = imagePath.split('/');
    final String fileName = path.removeLast();
    final String dirPath = path.join('/');
    await _createDirsIfNotExist(docsDirectory.path, dirPath);
    return '${docsDirectory.path}/$dirPath/$fileName';
  }

  /// Saves an image of the maneuver at [imagePath] to the device's document folder for use in notifications.
  static Future<String> saveManeuverImageFromBundle(String imagePath) async {
    String filePath = await _createFullPath(imagePath);

    final File file = File(filePath);
    if (!(await file.exists())) {
      // File does not exist, write new one
      // Convert SVG to PNG type as notifications do not support SVG
      if (pathIsSvg(filePath)) {
        final Uint8List? bytes = await _svgToPngData(svgAssetPath: imagePath);
        filePath = filePath.replaceAll('.svg', '.png');
        final File svgFile = File(filePath);
        if (bytes != null) {
          await svgFile.writeAsBytes(bytes, flush: true);
        }
      } else {
        // Save PNG image type
        final ByteData imageData = await rootBundle.load(imagePath);
        final Uint8List bytes = imageData.buffer.asUint8List();
        await file.writeAsBytes(bytes, flush: true);
      }
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

  // Checks if the given file path points to an SVG file.
  // Converts the path to lowercase and verifies if it ends with ".svg".
  static bool pathIsSvg(String path) => path.toLowerCase().endsWith('.svg');

  /// Converts an SVG image from an asset file into PNG data.
  /// A `Uint8List` containing the PNG image data, or `null` if the conversion fails.
  static Future<Uint8List?> _svgToPngData({
    required String svgAssetPath,
    int width = UIStyle.notificationIconSize,
    int height = UIStyle.notificationIconSize,
  }) async {
    final String svgString = await rootBundle.loadString(svgAssetPath);
    final BuildContext? context = LandingScreen.landingScreenKey.currentContext;
    if (context == null || !context.mounted) {
      return null;
    }
    final PictureInfo pictureInfo = await vg.loadPicture(
      SvgStringLoader(svgString, colorMapper: _SvgColorMapper(Theme.of(context).colorScheme.primary)),
      context,
    );
    final ui.Image image = await pictureInfo.picture.toImage(width, height);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      debugPrint('Error: Unable to convert SVG to PNG');
    }
    return byteData?.buffer.asUint8List();
  }
}

class _SvgColorMapper implements ColorMapper {
  _SvgColorMapper(this.substituteColor);
  final ui.Color substituteColor;

  @override
  ui.Color substitute(String? id, String elementName, String attributeName, ui.Color color) {
    return substituteColor;
  }
}
