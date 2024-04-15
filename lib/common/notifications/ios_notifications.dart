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
import 'package:RefApp/common/file_utility.dart';
import 'package:RefApp/common/notifications/notifications_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const int _defaultNotificationId = 0;

class IosNotificationsManager implements NotificationsManager {
  FlutterLocalNotificationsPlugin? _maneuverLocalNotificationsPlugin;

  @override
  Future<bool?> init() async {
    if (_maneuverLocalNotificationsPlugin == null) {
      _maneuverLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var initSettings = InitializationSettings(
        iOS: DarwinInitializationSettings(),
      );
      await _maneuverLocalNotificationsPlugin!.initialize(initSettings);
    }
    return await requestNotificationPermissions();
  }

  @override
  Future<bool?> requestNotificationPermissions() async {
    return FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions();
  }

  @override
  Future<void> showNotification(NotificationBody body) async {
    late DarwinNotificationDetails iOSNotificationDetails;
    try {
      final String savedImagePath = await FileUtility.saveManeuverImageFromBundle(body.imagePath);
      iOSNotificationDetails = DarwinNotificationDetails(
        presentSound: body.presentSound,
        attachments: [DarwinNotificationAttachment(savedImagePath)],
      );
    } catch (_) {
      iOSNotificationDetails = DarwinNotificationDetails(presentSound: body.presentSound);
    }

    var platformChannelSpecifics = NotificationDetails(
      iOS: iOSNotificationDetails,
    );
    await _maneuverLocalNotificationsPlugin!.show(
      _defaultNotificationId,
      body.title,
      body.body,
      platformChannelSpecifics,
    );
  }

  @override
  Future<void> dismissNotification() async {
    _maneuverLocalNotificationsPlugin!.cancel(_defaultNotificationId);
  }
}
