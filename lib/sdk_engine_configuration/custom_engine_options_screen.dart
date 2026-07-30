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

import 'package:flutter/material.dart';
import 'package:here_sdk/core.engine.dart' show EngineBaseURL, SDKOptions, SDKNativeEngine, AuthenticationMode;
import 'package:here_sdk_reference_application_flutter/common/application_preferences.dart';
import 'package:here_sdk_reference_application_flutter/common/error_toast.dart';
import 'package:here_sdk_reference_application_flutter/common/gradient_elevated_button.dart';
import 'package:here_sdk_reference_application_flutter/common/hds_icons/hds_assets_paths.dart';
import 'package:here_sdk_reference_application_flutter/common/hds_icons/hds_icon_widget.dart';
import 'package:here_sdk_reference_application_flutter/common/ui_style.dart';
import 'package:here_sdk_reference_application_flutter/common/util.dart';
import 'package:here_sdk_reference_application_flutter/download_maps/map_loader_controller.dart';
import 'package:here_sdk_reference_application_flutter/environment.dart';
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';
import 'package:here_sdk_reference_application_flutter/main.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/dropdown_widget.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/enum_string_helper.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/preferences_row_title_widget.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/preferences_section_title_widget.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/custom_engine_options_data.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/sdk_engine_utils.dart';
import 'package:provider/provider.dart';

const EdgeInsets _commonPadding = EdgeInsets.symmetric(
  vertical: UIStyle.contentMarginExtraLarge,
  horizontal: UIStyle.contentMarginLarge,
);

class CustomEngineOptionsScreen extends StatefulWidget {
  const CustomEngineOptionsScreen({super.key});

  static const String navRoute = "/custom_engine_options_screen";

  @override
  State<CustomEngineOptionsScreen> createState() => _CustomEngineOptionsScreenState();
}

class _CustomEngineOptionsScreenState extends State<CustomEngineOptionsScreen> {
  bool _isEngineCreated = false;
  bool _showProgressIndicator = false;
  bool _isInputValid = false;
  bool _hasAttemptedRecovery = false;
  late CustomEngineOptionsData _optionsData;
  EngineBaseURL _engineBaseURL = EngineBaseURL.searchEngine;
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _optionsData = CustomEngineOptionsData(customUrls: {});
    _loadOptions();
    _baseUrlController.addListener(_validateInputFields);
    _idController.addListener(_validateInputFields);
    _secretController.addListener(_validateInputFields);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _idController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final options = await context.read<AppPreferences>().loadSdkOptionsCustomEngineOptions();
    if (!mounted) return;
    setState(() => _optionsData = options ?? CustomEngineOptionsData(customUrls: {}));
  }

  void _setProgressIndicator(bool value) {
    setState(() => _showProgressIndicator = value);
  }

  void _validateInputFields() {
    bool newState =
        _baseUrlController.text.trim().isNotEmpty &&
        _idController.text.trim().isNotEmpty &&
        _secretController.text.trim().isNotEmpty;

    if (newState != _isInputValid) {
      setState(() => _isInputValid = newState);
    }
  }

  void _showErrorMessage(String? message) {
    if (mounted && message != null) {
      ErrorToaster.makeToast(context, message);
    }
  }

  void _onDeleteConfiguration(MapEntry<EngineBaseURL, EngineOptionData> entry) {
    final updatedUrls = Map<EngineBaseURL, EngineOptionData>.from(_optionsData.customUrls)..remove(entry.key);
    _recreateEngineWithOptions(CustomEngineOptionsData(customUrls: updatedUrls));
  }

  void _addCustomEngineOption() {
    if (!_isInputValid) {
      return;
    }

    final baseUrl = _baseUrlController.text.trim();

    EngineOptionData engineOptionData = EngineOptionData(
      customBaseUrl: baseUrl,
      id: _idController.text.trim(),
      secret: _secretController.text.trim(),
    );

    CustomEngineOptionsData customEngineOptionData = CustomEngineOptionsData(
      customUrls: _optionsData.customUrls.map(MapEntry<EngineBaseURL, EngineOptionData>.new),
    )..customUrls[_engineBaseURL] = engineOptionData;
    _hasAttemptedRecovery = false; // Reset recovery attempt flag for new addition
    _recreateEngineWithOptions(customEngineOptionData);
  }

  /// Recreates the SDK engine with the provided CustomEngineOption.
  /// Shows a progress indicator during the process.
  /// On success, updates the engine and re-initializes the MapLoaderController.
  /// On failure, it resets the engine and shows an error.
  void _recreateEngineWithOptions(CustomEngineOptionsData customEngineOptionData, {SDKOptions? sdkOptions}) async {
    _setProgressIndicator(true);
    try {
      SDKOptions options = await getSDKOptions(
        sdkOptions: sdkOptions ?? SDKNativeEngine.sharedInstance!.options,
        catalogConfigurations: context.read<AppPreferences>().loadSdkOptionsCatalogConfiguration(),
        customEngineOptions: customEngineOptionData,
      );

      await createSDKNativeEngine(
        sdkOptions: options,
        onSuccess: () => _onSuccess(customEngineOptionData),
        onFailure: _handleEngineRecreationFailure,
      );
    } catch (e) {
      debugPrint('Engine re-creation attempt failed with exception: $e');
      _setProgressIndicator(false);
      _navigateToInitErrorScreen();
    }
  }

  /// Handles successful SDK engine recreation: re-initializes map loader, updates UI and saves configurations.
  Future<void> _onSuccess(CustomEngineOptionsData customEngineOptionData) async {
    if (!mounted) {
      return;
    }
    await context.read<AppPreferences>().saveSdkOptionsCustomEngineOptions(customEngineOptionData);
    await context.read<MapLoaderController>().restartMapLoader();
    _isEngineCreated = true;
    if (!mounted) {
      return;
    }
    _baseUrlController.clear();
    _idController.clear();
    _secretController.clear();
    setState(() {
      _showProgressIndicator = false;
      _optionsData = customEngineOptionData;
      _engineBaseURL = EngineBaseURL.searchEngine;
    });
  }

  /// Handles SDK engine recreation failure.
  /// Shows an error message and attempts to recover only once by recreating the engine
  /// with the last known valid custom EngineOptions and fresh authentication.
  /// If recovery fails again, navigates to InitErrorScreen and removes all previous routes.
  void _handleEngineRecreationFailure(String? errorMsg) {
    _setProgressIndicator(false);
    _showErrorMessage(errorMsg);
    // Only attempt recovery once
    if (!_hasAttemptedRecovery) {
      _hasAttemptedRecovery = true; // Mark that recovery has been attempted

      // Attempt to recover by recreating the SDK engine with previous configurations
      try {
        _recreateEngineWithOptions(
          _optionsData,
          sdkOptions: SDKOptions.withAuthenticationMode(
            AuthenticationMode.withKeySecret(Environment.accessKeyId, Environment.accessKeySecret),
          ),
        );
      } catch (e) {
        debugPrint('Recovery attempt failed: $e');
        _navigateToInitErrorScreen();
      }
    } else {
      // If recovery already attempted and failed, show only the InitErrorScreen
      _navigateToInitErrorScreen();
    }
  }

  /// Navigates to InitErrorScreen and removes all previous routes from the stack.
  /// Call this when recovery from engine recreation fails.
  void _navigateToInitErrorScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const InitErrorScreen()),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localized = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_isEngineCreated);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(localized.customEngineOptions),
              leading: IconButton(
                highlightColor: UIStyle.foregroundInactive,
                onPressed: () => Navigator.maybePop(context),
                icon: const HdsIconWidget.medium(HdsAssetsPaths.arrowLeftIcon),
                iconSize: UIStyle.sizeAppBarIcon,
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: UIStyle.contentMarginMedium,
                  right: UIStyle.contentMarginMedium,
                  bottom: UIStyle.contentMarginHuge,
                ),
                child: Column(
                  children: <Widget>[
                    PreferencesRowTitle(title: localized.engineBaseURL),
                    Container(
                      decoration: UIStyle.roundedRectDecoration(),
                      child: DropdownButtonHideUnderline(
                        child: DropdownWidget(
                          data: EnumStringHelper.engineBaseURLMap(),
                          selectedValue: _engineBaseURL.index,
                          onChanged: (mode) => setState(() => _engineBaseURL = EngineBaseURL.values[mode]),
                        ),
                      ),
                    ),
                    PreferencesSectionTitle(title: localized.engineOptions),
                    PreferencesRowTitle(title: localized.customBaseUrl),
                    Container(
                      decoration: UIStyle.roundedRectDecoration(),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: localized.customBaseUrlHint,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                        ),
                        controller: _baseUrlController,
                      ),
                    ),
                    PreferencesRowTitle(title: localized.accessID),
                    Container(
                      decoration: UIStyle.roundedRectDecoration(),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: localized.accessIDHint,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                        ),
                        controller: _idController,
                      ),
                    ),
                    PreferencesRowTitle(title: localized.accessIDSecret),
                    Container(
                      decoration: UIStyle.roundedRectDecoration(),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: localized.accessIDSecretHint,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                        ),
                        controller: _secretController,
                      ),
                    ),
                    Padding(
                      padding: _commonPadding,
                      child: Row(
                        children: [
                          Spacer(),
                          GradientElevatedButton(
                            title: Text(localized.save),
                            onPressed: _isInputValid
                                ? _addCustomEngineOption
                                : () => _showErrorMessage(localized.customEngineOptionsErrorErrorMessage),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _optionsData.customUrls.length,
                      itemBuilder: (BuildContext context, int index) {
                        final engineOptionData = _optionsData.customUrls.entries.elementAt(index);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(engineOptionData.key.name.camelToCapitalizedWords()),
                          subtitle: Text(
                            "${localized.url}: ${engineOptionData.value.customBaseUrl} \n"
                            "${localized.authentication} - ${localized.id}: ${engineOptionData.value.readableId},"
                            " ${localized.secret}: ${engineOptionData.value.readableSecret}",
                            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                          ),
                          trailing: InkWell(
                            onTap: () => _onDeleteConfiguration(engineOptionData),
                            child: HdsIconWidget.medium(HdsAssetsPaths.substractSolidIcon),
                          ),
                        );
                      },
                    ),
                    const SafeArea(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
          if (_showProgressIndicator)
            Container(
              color: Colors.white54,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
