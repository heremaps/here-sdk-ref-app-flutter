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
class NotificationBody {
  final String title;
  final String body;
  final String imagePath;
  final bool presentSound;

  NotificationBody({
    required this.title,
    required this.body,
    required this.imagePath,
    this.presentSound = true,
  });
}

abstract class NotificationsManager {
  Future<bool?> init();

  Future<void> showNotification(NotificationBody body);

  Future<void> dismissNotification();

  Future<bool?> requestNotificationPermissions();
}
