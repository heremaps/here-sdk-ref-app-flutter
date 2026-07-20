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
  CredentialsType _selectedType = CredentialsType.authModeKeySecret;

  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _certFileBlobController = TextEditingController();
  final TextEditingController _clientCertFileBlobController = TextEditingController();
  final TextEditingController _clientKeyFileBlobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _optionsData =
        context.read<AppPreferences>().loadSdkOptionsCustomEngineOptions() ?? CustomEngineOptionsData(customUrls: {});

    _baseUrlController.addListener(_validateInputFields);
    _nameController.addListener(_validateInputFields);
    _idController.addListener(_validateInputFields);
    _secretController.addListener(_validateInputFields);
    _tokenController.addListener(_validateInputFields);
    _certFileBlobController.addListener(_validateInputFields);
    _clientCertFileBlobController.addListener(_validateInputFields);
    _clientKeyFileBlobController.addListener(_validateInputFields);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _nameController.dispose();
    _idController.dispose();
    _secretController.dispose();
    _tokenController.dispose();
    _certFileBlobController.dispose();
    _clientCertFileBlobController.dispose();
    _clientKeyFileBlobController.dispose();
    super.dispose();
  }

  void _setProgressIndicator(bool value) {
    setState(() => _showProgressIndicator = value);
  }

  void _validateInputFields() {
    bool newState = _baseUrlController.text.trim().isNotEmpty && _nameController.text.trim().isNotEmpty;
    switch (_selectedType) {
      case CredentialsType.authModeKeySecret:
        newState = newState && _idController.text.trim().isNotEmpty && _secretController.text.trim().isNotEmpty;

      case CredentialsType.authModeToken:
        newState = newState && _tokenController.text.trim().isNotEmpty;

      case CredentialsType.certificate:
        newState =
            newState &&
            _clientCertFileBlobController.text.trim().isNotEmpty &&
            _clientKeyFileBlobController.text.trim().isNotEmpty;
      case CredentialsType.external:
        // no extra validation needed beyond base fields
        break;
    }
    if (newState != _isInputValid) {
      setState(() => _isInputValid = newState);
    }
  }

  void _clearFields({bool isAuthModeChanges = false}) {
    if (!isAuthModeChanges) {
      setState(() {
        _selectedType = CredentialsType.authModeKeySecret;
        _engineBaseURL = EngineBaseURL.searchEngine;
      });
      _baseUrlController.clear();
      _nameController.clear();
    }
    _idController.clear();
    _secretController.clear();
    _tokenController.clear();
    _certFileBlobController.clear();
    _clientCertFileBlobController.clear();
    _clientKeyFileBlobController.clear();
  }

  void _onAuthModeChanged(CredentialsType newMode) {
    setState(() => _selectedType = newMode);
    _clearFields(isAuthModeChanges: true);
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
    final name = _nameController.text.trim();

    EngineOptionData engineOptionData = switch (_selectedType) {
      CredentialsType.authModeKeySecret => EngineOptionData(
        customBaseUrl: baseUrl,
        credentialName: name,
        type: _selectedType,
        id: _idController.text.trim(),
        secret: _secretController.text.trim(),
      ),

      CredentialsType.authModeToken => EngineOptionData(
        customBaseUrl: baseUrl,
        credentialName: name,
        type: _selectedType,
        token: _tokenController.text.trim(),
      ),

      CredentialsType.certificate => EngineOptionData(
        customBaseUrl: baseUrl,
        credentialName: name,
        type: _selectedType,
        certFileBlob: _certFileBlobController.text.trim().isNotEmpty ? _certFileBlobController.text.trim() : null,
        clientCertFileBlob: _clientCertFileBlobController.text.trim(),
        clientKeyFileBlob: _clientKeyFileBlobController.text.trim(),
      ),

      CredentialsType.external => EngineOptionData(customBaseUrl: baseUrl, credentialName: name, type: _selectedType),
    };

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
    if (mounted) {
      await context.read<MapLoaderController>().restartMapLoader();
    }
    _setProgressIndicator(false);
    _clearFields();
    setState(() {
      if (!_isEngineCreated) {
        _isEngineCreated = true;
      }
      _optionsData = customEngineOptionData;
    });
    _saveCustomEngineOptions(customEngineOptionData);
  }

  void _saveCustomEngineOptions(CustomEngineOptionsData? customEngineOptionData) {
    context.read<AppPreferences>().saveSdkOptionsCustomEngineOptions(customEngineOptionData);
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
                    PreferencesRowTitle(title: localized.authentication),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<CredentialsType>(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return UIStyle.selectedRouteColor;
                            }
                            return UIStyle.segmentedButtonBgColor;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return Colors.black;
                          }),
                          side: WidgetStatePropertyAll(BorderSide.none),
                        ),
                        showSelectedIcon: false,
                        segments: CredentialsType.values.map((type) {
                          return ButtonSegment(value: type, label: Text(type.displayName(localized)));
                        }).toList(),
                        selected: {_selectedType},
                        onSelectionChanged: (selection) => _onAuthModeChanged(selection.first),
                      ),
                    ),
                    PreferencesRowTitle(title: localized.name),
                    Container(
                      decoration: UIStyle.roundedRectDecoration(),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: localized.nameAsString,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                        ),
                        controller: _nameController,
                      ),
                    ),
                    if (_selectedType == CredentialsType.authModeKeySecret) ...[
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
                    ],
                    if (_selectedType == CredentialsType.authModeToken) ...[
                      PreferencesRowTitle(title: localized.accessToken),
                      Container(
                        decoration: UIStyle.roundedRectDecoration(),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: localized.accessTokenHint,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                          ),
                          controller: _tokenController,
                        ),
                      ),
                    ],
                    if (_selectedType == CredentialsType.certificate) ...[
                      PreferencesRowTitle(title: localized.certificateAuthorityFileAsBlob),
                      Container(
                        decoration: UIStyle.roundedRectDecoration(),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: localized.asString,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                          ),
                          controller: _certFileBlobController,
                        ),
                      ),
                      PreferencesRowTitle(title: localized.clientCertificateFileAsBlob),
                      Container(
                        decoration: UIStyle.roundedRectDecoration(),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: localized.clientCertificateFileAsBlobHint,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                          ),
                          controller: _clientCertFileBlobController,
                        ),
                      ),
                      PreferencesRowTitle(title: localized.clientKeyCertificateFileAsBlob),
                      Container(
                        decoration: UIStyle.roundedRectDecoration(),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: localized.asString,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                          ),
                          controller: _clientKeyFileBlobController,
                        ),
                      ),
                    ],
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
                            "${localized.authentication}: ${engineOptionData.value.type.name.camelToCapitalizedWords()}",
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
