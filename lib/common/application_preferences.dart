/*
 * Copyright (C) 2020-2026 HERE Europe B.V.
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/catalog_configuration_data.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/custom_engine_options_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A class that implements application preferences.
class AppPreferences extends ChangeNotifier {
  static final _kAppOfflineParam = "use_app_offline";
  static final _kShowTrafficLayersParam = "show_traffic_layers";

  /// Key to track if the HERE Privacy Notice dialog was shown on first launch.
  static final String _kIsHerePrivacyDialogShown = 'is_here_privacy_dialog_shown';

  /// Key used to store and retrieve SDK options catalog configurations in shared preferences.
  static const String _kSdkOptionsCatalogConfigurations = 'sdk_options_catalog_configurations';

  /// Key used to store and retrieve SDK options custom engineOptions in secure storage.
  static const String _kSdkOptionsCustomEngineOptions = 'sdk_options_custom_engine_options';

  SharedPreferences? _sharedPreferences;

  static const FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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

  /// Saves or removes the SDK options catalog configuration in shared preferences.
  /// Returns `true` if successful, otherwise `false`.
  Future<bool> saveSdkOptionsCatalogConfiguration(List<CatalogConfigurationData>? configs) async {
    if (configs != null && configs.isNotEmpty) {
      final String serialized = const JsonEncoder().convert(CatalogConfigurationData.toDynamicListFromList(configs));
      return (await _sharedPreferences?.setString(_kSdkOptionsCatalogConfigurations, serialized)) ?? false;
    }
    return await _sharedPreferences?.remove(_kSdkOptionsCatalogConfigurations) ?? false;
  }

  /// Retrieves the SDK options catalog configuration from shared preferences.
  /// Returns a `List<CatalogConfigurationData>` if the configuration exists, otherwise `null`.
  List<CatalogConfigurationData>? loadSdkOptionsCatalogConfiguration() {
    return loadSdkOptionsCatalogConfigurationFromPrefs(_sharedPreferences!);
  }

  /// Retrieves the SDK options catalog configuration from the provided [SharedPreferences] instance.
  /// Returns a `List<CatalogConfigurationData>` if the configuration exists, otherwise `null`.
  static List<CatalogConfigurationData>? loadSdkOptionsCatalogConfigurationFromPrefs(SharedPreferences prefs) {
    try {
      final String? jsonString = prefs.getString(_kSdkOptionsCatalogConfigurations);
      return CatalogConfigurationData.fromDynamicListToList(jsonString == null ? null : jsonDecode(jsonString));
    } catch (error) {
      debugPrint('Error while fetching CatalogConfiguration $error');
    }
    return null;
  }

  /// Saves or removes the SDK options custom engineOptions in secure storage.
  Future<void> saveSdkOptionsCustomEngineOptions(CustomEngineOptionsData? customEngineOptionsData) async {
    if (customEngineOptionsData != null && customEngineOptionsData.customUrls.isNotEmpty) {
      final String serialized = const JsonEncoder().convert(customEngineOptionsData.toMap());
      await secureStorage.write(key: _kSdkOptionsCustomEngineOptions, value: serialized);
    } else {
      await secureStorage.delete(key: _kSdkOptionsCustomEngineOptions);
    }
  }

  /// Retrieves the SDK options catalog configuration from the secure storage.
  /// Returns a `CustomEngineOptionsData` if the configuration exists, otherwise `null`.
  Future<CustomEngineOptionsData?> loadSdkOptionsCustomEngineOptions() async {
    return loadSdkOptionsCustomEngineOptionsFromStorage();
  }

  /// Retrieves the SDK options catalog configuration from the secure storage.
  /// Returns a `CustomEngineOptionsData` if the configuration exists, otherwise `null`.
  static Future<CustomEngineOptionsData?> loadSdkOptionsCustomEngineOptionsFromStorage() async {
    try {
      final String? jsonString = await secureStorage.read(key: _kSdkOptionsCustomEngineOptions);
      return CustomEngineOptionsData.fromMap(jsonString == null ? null : jsonDecode(jsonString));
    } catch (error) {
      debugPrint('Error while fetching CustomEngineOptions $error');
    }
    return null;
  }
}
