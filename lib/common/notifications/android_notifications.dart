/*
 * Copyright (C) 2024 HERE Europe B.V.
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

import 'package:flutter/services.dart';
import 'package:here_sdk_reference_application_flutter/common/file_utility.dart';
import 'package:here_sdk_reference_application_flutter/common/notifications/notifications_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class AndroidNotificationsManager implements NotificationsManager {
  static const MethodChannel _kAndroidServiceChannel = const MethodChannel(
    "com.example.RefApp/foreground_service_channel",
  );
  static const String _kTitleParam = "title";
  static const String _kContentParam = "content";
  static const String _kLargeIconParam = "large_icon";
  static const String _kSoundEnabledParam = "sound_enabled";
  static const String _kAndroidServiceStartCommand = "startService";
  static const String _kAndroidServiceStopCommand = "stopService";

  @override
  Future<bool?> init() async {
    return await requestNotificationPermissions();
  }

  @override
  Future<bool?> requestNotificationPermissions() async {
    final PermissionStatus notificationPermission = await Permission.notification.request();
    return notificationPermission.isGranted || notificationPermission.isLimited;
  }

  @override
  Future<void> showNotification(NotificationBody body) async {
    try {
      final String savedImagePath = await FileUtility.saveManeuverImageFromBundle(body.imagePath);
      await _kAndroidServiceChannel.invokeMethod(_kAndroidServiceStartCommand, {
        _kTitleParam: body.title,
        _kContentParam: body.body,
        _kLargeIconParam: savedImagePath,
        _kSoundEnabledParam: body.presentSound,
      });
    } catch (_) {
      await _kAndroidServiceChannel.invokeMethod(_kAndroidServiceStartCommand, {
        _kTitleParam: body.title,
        _kContentParam: body.body,
        _kSoundEnabledParam: body.presentSound,
      });
    }
  }

  @override
  Future<void> dismissNotification() async {
    await _kAndroidServiceChannel.invokeMethod(_kAndroidServiceStopCommand);
  }
}
