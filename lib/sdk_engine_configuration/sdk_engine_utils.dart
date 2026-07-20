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

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart' show InstantiationException;
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/catalog_configuration_data.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/custom_engine_options_data.dart';

///
/// Creates [SDKNativeEngine] for the [SDKOptions] and returns [onSuccess] callback on success and
/// [onFailure] call on receiveing [InstantiationException]
/// with the error message as String
///
Future<void> createSDKNativeEngine({
  required SDKOptions sdkOptions,
  VoidCallback? onSuccess,
  Function(String)? onFailure,
}) async {
  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
    print('SDKNativeEngine created successfully!');
    onSuccess?.call();
  } on Exception catch (e) {
    final String error = e is InstantiationException ? '${e.error}' : e.toString();
    print('Failed to create SDKNativeEngine: $error');
    onFailure?.call(error);
  }
}

///
/// Returns updated `SDKOptions`.
/// If `sdkOptions` is not provided, the current shared engine options are used.
/// Optional catalog and custom engine settings are applied before returning.
///
Future<SDKOptions> getSDKOptions({
  SDKOptions? sdkOptions,
  List<CatalogConfigurationData>? catalogConfigurations,
  CustomEngineOptionsData? customEngineOptions,
}) async {
  SDKOptions options = sdkOptions ?? SDKNativeEngine.sharedInstance!.options;
  if (catalogConfigurations != null) {
    options.catalogConfigurations = catalogConfigurations.toSdkCatalogConfigurations();
  }

  if (customEngineOptions != null) {
    options.customEngineOptions = customEngineOptions.toEngineOptionsMap();
  }

  return options;
}
