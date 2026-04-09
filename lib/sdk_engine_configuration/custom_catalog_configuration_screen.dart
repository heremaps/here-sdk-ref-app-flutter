/*
 * Copyright (C) 2025-2026 HERE Europe B.V.
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
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk_reference_application_flutter/common/application_preferences.dart';
import 'package:here_sdk_reference_application_flutter/common/error_toast.dart';
import 'package:here_sdk_reference_application_flutter/common/gradient_elevated_button.dart';
import 'package:here_sdk_reference_application_flutter/common/hds_icons/hds_assets_paths.dart';
import 'package:here_sdk_reference_application_flutter/common/hds_icons/hds_icon_widget.dart';
import 'package:here_sdk_reference_application_flutter/common/ui_style.dart';
import 'package:here_sdk_reference_application_flutter/download_maps/map_loader_controller.dart';
import 'package:here_sdk_reference_application_flutter/environment.dart';
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';
import 'package:here_sdk_reference_application_flutter/main.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/preferences_row_title_widget.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/catalog_configuration_data.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/sdk_engine_utils.dart';
import 'package:provider/provider.dart';

const EdgeInsets _commonPadding = const EdgeInsets.symmetric(
  vertical: UIStyle.contentMarginMedium,
  horizontal: UIStyle.contentMarginLarge,
);

class CustomCatalogConfigurationScreen extends StatefulWidget {
  const CustomCatalogConfigurationScreen({super.key});

  static const String navRoute = "/custom_catalog_configuration_screen";

  @override
  State<CustomCatalogConfigurationScreen> createState() => _CustomCatalogConfigurationScreenState();
}

class _CustomCatalogConfigurationScreenState extends State<CustomCatalogConfigurationScreen> {
  bool _showProgressIndicator = false;
  late List<CatalogConfigurationData> _catalogConfigurations;
  final TextEditingController _catalogHrnController = TextEditingController();
  final TextEditingController _catalogVersionHintController = TextEditingController();
  final TextEditingController _catalogPatchHrnController = TextEditingController();
  final TextEditingController _catalogExpirationTimeController = TextEditingController();
  bool _ignoreCachedData = false;
  bool _catalogAllowDownload = true;
  bool _isCatalogHrnAddButtonEnabled = false;
  bool _isEngineCreated = false;
  bool _hasAttemptedRecovery = false;

  @override
  void initState() {
    super.initState();
    _catalogConfigurations =
        context.read<AppPreferences>().loadSdkOptionsCatalogConfiguration() ?? <CatalogConfigurationData>[];
  }

  @override
  void dispose() {
    _catalogHrnController.dispose();
    _catalogVersionHintController.dispose();
    _catalogPatchHrnController.dispose();
    _catalogExpirationTimeController.dispose();
    super.dispose();
  }

  void _toggleCatalogHrnAddButtonState() {
    setState(() => _isCatalogHrnAddButtonEnabled = _catalogHrnController.text.trim().isNotEmpty);
  }

  void _resetInputFields() {
    _catalogHrnController.clear();
    _catalogVersionHintController.clear();
    _catalogPatchHrnController.clear();
    _catalogExpirationTimeController.clear();
    setState(() {
      _ignoreCachedData = false;
      _catalogAllowDownload = true;
      _isCatalogHrnAddButtonEnabled = false;
    });
  }

  void _onClearAllConfigurations() {
    _recreateEngineWithCatalogs(_catalogConfigurations..clear());
  }

  void _onDeleteConfiguration(CatalogConfigurationData configurationData) {
    _recreateEngineWithCatalogs(_catalogConfigurations.toList()..remove(configurationData));
  }

  void _onAddCatalogConfig() async {
    final String? patchHrn = _catalogPatchHrnController.text.trim().isEmpty
        ? null
        : _catalogPatchHrnController.text.trim();
    CatalogConfigurationData configurationData = CatalogConfigurationData(
      _catalogHrnController.text.trim(),
      int.tryParse(_catalogVersionHintController.text.trim()),
      _catalogAllowDownload,
      _ignoreCachedData,
      int.tryParse(_catalogExpirationTimeController.text.trim()),
      patchHrn,
    );
    if (_catalogConfigurations.contains(configurationData)) {
      _showErrorMessage(AppLocalizations.of(context)!.catalogErrorMessage);
    } else {
      _hasAttemptedRecovery = false; // Reset recovery attempt flag for new addition
      _recreateEngineWithCatalogs(_catalogConfigurations.toList()..add(configurationData));
    }
  }

  /// Recreates the SDK engine with the provided catalog configurations.
  /// Shows a progress indicator during the process.
  /// On success, updates the engine and re-initializes the MapLoaderController.
  /// On failure, it resets the engine and shows an error.
  void _recreateEngineWithCatalogs(
    List<CatalogConfigurationData> catalogConfigurations, {
    SDKOptions? sdkOptions,
  }) async {
    _setProgressIndicator(true);
    try {
      SDKOptions options = sdkOptions ?? SDKNativeEngine.sharedInstance!.options;
      options.catalogConfigurations = catalogConfigurations.toSdkCatalogConfigurations();

      await createSDKNativeEngine(
        sdkOptions: options,
        onSuccess: () => _onSuccess(catalogConfigurations),
        onFailure: _handleEngineRecreationFailure,
      );
    } catch (e) {
      print('Engine re-creation attempt failed with exception: $e');
      _navigateToInitErrorScreen();
    }
  }

  /// Handles successful SDK engine recreation: re-initializes map loader, updates UI and saves configurations.
  Future<void> _onSuccess(List<CatalogConfigurationData> catalogConfigurations) async {
    if (mounted) {
      await context.read<MapLoaderController>().restartMapLoader();
    }
    _setProgressIndicator(false);
    _resetInputFields();
    setState(() {
      if (!_isEngineCreated) {
        _isEngineCreated = true;
      }
      _catalogConfigurations = catalogConfigurations;
      _saveCatalogConfigurations(_catalogConfigurations);
    });
    return;
  }

  /// Handles SDK engine recreation failure.
  /// Shows an error message and attempts to recover only once by recreating the engine
  /// with the last known valid catalog configurations and fresh authentication.
  /// If recovery fails again, navigates to InitErrorScreen and removes all previous routes.
  void _handleEngineRecreationFailure(String? errorMsg) {
    _showErrorMessage(errorMsg);
    // Only attempt recovery once
    if (!_hasAttemptedRecovery) {
      _hasAttemptedRecovery = true; // Mark that recovery has been attempted

      // Attempt to recover by recreating the SDK engine with previous configurations
      try {
        _recreateEngineWithCatalogs(
          sdkOptions: SDKOptions.withAuthenticationMode(
            AuthenticationMode.withKeySecret(Environment.accessKeyId, Environment.accessKeySecret),
          ),
          _catalogConfigurations.toList(),
        );
      } catch (e) {
        print('Recovery attempt failed: $e');
        _navigateToInitErrorScreen();
      }
    } else {
      // If recovery already attempted and failed, show only the InitErrorScreen
      _navigateToInitErrorScreen();
    }
  }

  void _showErrorMessage(String? message) {
    if (mounted && message != null) {
      ErrorToaster.makeToast(context, message);
    }
  }

  void _setProgressIndicator(bool value) {
    setState(() => _showProgressIndicator = value);
  }

  void _saveCatalogConfigurations(List<CatalogConfigurationData>? configurations) {
    context.read<AppPreferences>().saveSdkOptionsCatalogConfiguration(configurations);
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
              title: Text(localized.catalogConfiguration),
              leading: IconButton(
                highlightColor: UIStyle.foregroundInactive,
                onPressed: () => Navigator.maybePop(context),
                icon: const HdsIconWidget.medium(HdsAssetsPaths.arrowLeftIcon),
                iconSize: UIStyle.sizeAppBarIcon,
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: _commonPadding,
                    child: Column(
                      children: <Widget>[
                        PreferencesRowTitle(title: localized.hrnTitle),
                        Container(
                          decoration: UIStyle.roundedRectDecoration(),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: localized.hrnAsStringHint,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                            ),
                            controller: _catalogHrnController,
                            onChanged: (_) => _toggleCatalogHrnAddButtonState(),
                          ),
                        ),
                        PreferencesRowTitle(title: localized.version),
                        Container(
                          decoration: UIStyle.roundedRectDecoration(),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: localized.versionHintAsLong,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                            ),
                            controller: _catalogVersionHintController,
                            keyboardType: const TextInputType.numberWithOptions(signed: true),
                          ),
                        ),
                        PreferencesRowTitle(title: localized.patchHrn),
                        Container(
                          decoration: UIStyle.roundedRectDecoration(),
                          child: TextFormField(
                            controller: _catalogPatchHrnController,
                            decoration: InputDecoration(
                              hintText: localized.patchHrnHint,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                            ),
                          ),
                        ),
                        PreferencesRowTitle(title: localized.cacheExpirationPeriod),
                        Container(
                          decoration: UIStyle.roundedRectDecoration(),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: localized.cacheExpirationPeriodHint,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: UIStyle.contentMarginMedium),
                            ),
                            controller: _catalogExpirationTimeController,
                            keyboardType: const TextInputType.numberWithOptions(signed: true),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PreferencesRowTitle(title: localized.ignoreCachedData),
                            Switch.adaptive(
                              value: _ignoreCachedData,
                              onChanged: (value) => setState(() => _ignoreCachedData = value),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PreferencesRowTitle(title: localized.allowDownload),
                            Switch.adaptive(
                              value: _catalogAllowDownload,
                              onChanged: (value) => setState(() => _catalogAllowDownload = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: _commonPadding,
                    child: Row(
                      children: [
                        Spacer(),
                        GradientElevatedButton(
                          title: Text(localized.addCatalogConfiguration),
                          onPressed: _isCatalogHrnAddButtonEnabled
                              ? _onAddCatalogConfig
                              : () => _showErrorMessage(localized.catalogHrnErrorMessage),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  if (_catalogConfigurations.isNotEmpty)
                    Container(
                      color: Theme.of(context).dividerColor,
                      child: Padding(
                        padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(localized.addedConfigurations),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero, // removes padding
                                minimumSize: Size.zero, // removes min size constraints
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // reduces hit area
                                foregroundColor: Theme.of(context).colorScheme.secondary, // link color
                              ),
                              child: Text(
                                localized.clearAll,
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                              onPressed: () => _onClearAllConfigurations(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _catalogConfigurations.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CatalogConfigurationData catalogConfiguration = _catalogConfigurations[index];
                      return ListTile(
                        title: Text(catalogConfiguration.title(localized)),
                        subtitle: Text(
                          catalogConfiguration.description(localized),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                        ),
                        trailing: InkWell(
                          onTap: () => _onDeleteConfiguration(catalogConfiguration),
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
