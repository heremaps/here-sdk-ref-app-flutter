/*
 * Copyright (c) 2018-2023 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 *
 * This software and other materials contain proprietary information
 * controlled by HERE and are protected by applicable copyright legislation.
 * Any use and utilization of this software and other materials and
 * disclosure to any third parties is conditional upon having a separate
 * agreement with HERE for the access, use, utilization or disclosure of this
 * software. In the absence of such agreement, the use of the software is not
 * allowed.
 */

import 'dart:io';

import 'package:RefApp/common/util.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final Battery battery = Battery();
  bool isBatterySaverOn = false;
  if (Platform.isAndroid) {
    isBatterySaverOn = await battery.isInBatterySaveMode;
  }
  return isBatterySaverOn;
}
