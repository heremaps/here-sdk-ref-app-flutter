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

import 'dart:io' show Platform;

import 'package:here_sdk/mapview.dart';

import 'device_info.dart' show getAndroidApiVersion;

/// Central configuration for HereMap widget settings.
class MapConfiguration {
  static const int _androidApiLevel13 = 33;

  // Resolved once at startup so map widgets can read a stable value later.
  static NativeViewMode _nativeViewMode = NativeViewMode.hybridComposition;

  static Future<void> init() async {
    if (!Platform.isAndroid) return;

    final int androidApiVersion = await getAndroidApiVersion();

    // Use virtual display on Android 13 and below for better compatibility.
    if (androidApiVersion != -1 && androidApiVersion <= _androidApiLevel13) {
      _nativeViewMode = NativeViewMode.virtualDisplay;
    }
  }

  static NativeViewMode get nativeViewMode => _nativeViewMode;
}
