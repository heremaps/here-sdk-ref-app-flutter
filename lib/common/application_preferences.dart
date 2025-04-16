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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A class that implements application preferences.
class AppPreferences extends ChangeNotifier {
  static final _kAppOfflineParam = "use_app_offline";
  static final _kShowTrafficLayersParam = "show_traffic_layers";

  /// Key to track if the HERE Privacy Notice dialog was shown on first launch.
  static final String _kIsHerePrivacyDialogShown = 'is_here_privacy_dialog_shown';

  SharedPreferences? _sharedPreferences;

  AppPreferences() {
    _initializePreferences();
  }

  void _initializePreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    notifyListeners();
  }

  /// If true, app should use offline services.
  bool get useAppOffline {
    return _sharedPreferences?.getBool(_kAppOfflineParam) ?? false;
  }

  /// Setter for [useAppOffline] property.
  void set useAppOffline(bool value) {
    _sharedPreferences?.setBool(_kAppOfflineParam, value);
    notifyListeners();
  }

  /// If true, app should show traffic flow and traffic incidents layers.
  bool get showTrafficLayers {
    return _sharedPreferences?.getBool(_kShowTrafficLayersParam) ?? true;
  }

  /// Setter for [showTrafficLayers] property.
  void set showTrafficLayers(bool value) {
    _sharedPreferences?.setBool(_kShowTrafficLayersParam, value);
    notifyListeners();
  }

  /// Returns true if HERE Privacy Notice was shown.
  bool get isHerePrivacyDialogShown => _sharedPreferences?.getBool(_kIsHerePrivacyDialogShown) ?? false;

  /// Sets the HERE Privacy Notice shown flag and notifies listeners on change.
  void set isHerePrivacyDialogShown(bool value) {
    final current = _sharedPreferences?.getBool(_kIsHerePrivacyDialogShown) ?? false;
    if (current != value) {
      _sharedPreferences?.setBool(_kIsHerePrivacyDialogShown, value);
      notifyListeners();
    }
  }
}
