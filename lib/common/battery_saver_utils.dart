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

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk_reference_application_flutter/common/util.dart';

const String _methodChannelName = 'com.example.RefApp/foreground_service_channel';
const String _methodChannelMethodName = 'openBatterySaverSettings';
const String _methodChannelMethodArgument = 'battery_saver';

// This flag can be used to show the alert dialog if it is not shown
// otherwise, ignore if it is already shown.
bool _isDialogInView = false;

/// Opens device battery_saver settings
Future<void> openBatterySaverSetting() async {
  const MethodChannel channel = MethodChannel(_methodChannelName);
  await channel.invokeMethod<void>(_methodChannelMethodName, _methodChannelMethodArgument);
}

/// Opens Android device battery_saver settings
Future<void> showBatterySaverWarningDialog(BuildContext context) async {
  if (!_isDialogInView) {
    _isDialogInView = true;
    final AppLocalizations localized = AppLocalizations.of(context)!;
    final bool openSettings = await showCommonConfirmationDialog(
      context: context,
      message: localized.batterySaverWarningText,
      actionTitle: localized.turnOff,
    );
    _isDialogInView = false;
    if (openSettings) {
      openBatterySaverSetting();
    }
  }
}

/// Returns [true] is battery saver is on and Platform is Android
/// otherwise, returns [false].
Future<bool> isBatterySaverOn() async {
  return Platform.isAndroid && await Battery().isInBatterySaveMode;
}
