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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'file_utility.dart';

/// Helper class for maneuver notifications.
class LocalNotificationsHelper {
  static const int _defaultNotificationId = 0;
  static FlutterLocalNotificationsPlugin? _maneuverLocalNotificationsPlugin;
  static const MethodChannel _kAndroidServiceChannel =
      const MethodChannel("com.example.RefApp/foreground_service_channel");
  static const String _kTitleParam = "title";
  static const String _kContentParam = "content";
  static const String _kLargeIconParam = "large_icon";
  static const String _kSoundEnabledParam = "sound_enabled";
  static const String _kAndroidServiceStartCommand = "startService";
  static const String _kAndroidServiceUpdateCommand = "updateService";
  static const String _kAndroidServiceStopCommand = "stopService";

  /// Initializes maneuvers notifications on the device with initial [title], [body] and an image at [imagePath].
  static Future startNotifications(String title, String body, String imagePath) async {
    if (Platform.isIOS) {
      _setupNotificationsIOS();
    } else {
      _setupNotificationsAndroid(title, body, imagePath);
    }
  }

  /// Hides maneuvers notifications on the device.
  static Future stopNotifications() async {
    if (Platform.isAndroid) {
      _stopNotificationsAndroid();
    } else if (Platform.isIOS) {
      _maneuverLocalNotificationsPlugin!.cancel(_defaultNotificationId);
    }
  }

  /// Shows maneuvers notifications on the device with a [title], notification [body], and an image at [imagePath].
  /// The [presentSound] parameter indicates whether the sound will be played.
  static Future showManeuverNotification(String title, String body, String imagePath, bool presentSound) async {
    if (Platform.isIOS) {
      _showManeuverNotificationIOS(title, body, imagePath, presentSound);
    } else {
      _showManeuverNotificationAndroid(title, body, imagePath, presentSound);
    }
  }

  static Future _showManeuverNotificationIOS(String title, String body, String imagePath, bool presentSound) async {
    final String savedImagePath = await FileUtility.saveManeuverImageFromBundle(imagePath);

    final DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
        presentSound: presentSound, attachments: [DarwinNotificationAttachment(savedImagePath)]);

    var platformChannelSpecifics = NotificationDetails(
      iOS: iOSNotificationDetails,
    );
    await _maneuverLocalNotificationsPlugin!.show(_defaultNotificationId, title, body, platformChannelSpecifics);
  }

  static Future _showManeuverNotificationAndroid(String title, String body, String imagePath, bool presentSound) async {
    final String savedImagePath = await FileUtility.saveManeuverImageFromBundle(imagePath);

    await _kAndroidServiceChannel.invokeMethod(_kAndroidServiceUpdateCommand, {
      _kTitleParam: title,
      _kContentParam: body,
      _kLargeIconParam: savedImagePath,
      _kSoundEnabledParam: presentSound,
    });
  }

  static _setupNotificationsIOS() {
    if (_maneuverLocalNotificationsPlugin != null) {
      return;
    }

    _maneuverLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initSettings = InitializationSettings(
      iOS: DarwinInitializationSettings(),
    );

    _maneuverLocalNotificationsPlugin!.initialize(initSettings);
  }

  static Future<bool?> requestPermission() async {
    return FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future _setupNotificationsAndroid(String title, String body, String imagePath) async {
    final String savedImagePath = await FileUtility.saveManeuverImageFromBundle(imagePath);

    await _kAndroidServiceChannel.invokeMethod(_kAndroidServiceStartCommand, {
      _kTitleParam: title,
      _kContentParam: body,
      _kLargeIconParam: savedImagePath,
    });
  }

  static Future _stopNotificationsAndroid() async {
    await _kAndroidServiceChannel.invokeMethod(_kAndroidServiceStopCommand);
  }
}
