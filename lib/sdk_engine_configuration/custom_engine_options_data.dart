/*
 * Copyright (C) 2026 HERE Europe B.V.
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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:here_sdk/core.engine.dart' show AuthenticationMode, EngineOptions, EngineBaseURL;
import 'package:here_sdk_reference_application_flutter/common/extensions/string_extensions.dart';

const String _urlKey = 'url';
const String _credentialIdKey = 'id';
const String _credentialSecretKey = 'secret';

/// Manages custom engine configuration options for different base URLs.
class CustomEngineOptionsData {
  CustomEngineOptionsData({required this.customUrls});

  factory CustomEngineOptionsData.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return CustomEngineOptionsData(customUrls: {});
    }
    final Map<EngineBaseURL, EngineOptionData> customUrls = {};

    map.forEach((key, value) {
      final EngineBaseURL? baseUrl = EngineBaseURL.values.firstWhereOrNull(
        (element) => element.name.toUpperCase() == key.toString().toUpperCase(),
      );
      final Map<String, dynamic>? optionMap = value as Map<String, dynamic>?;

      if (baseUrl == null || optionMap == null) {
        return;
      }

      customUrls[baseUrl] = EngineOptionData.fromMap(optionMap);
    });

    return CustomEngineOptionsData(customUrls: customUrls);
  }

  final Map<EngineBaseURL, EngineOptionData> customUrls;

  Map<EngineBaseURL, EngineOptions> toEngineOptionsMap() {
    return customUrls.map((key, value) => MapEntry(key, value.engineOptions));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CustomEngineOptionsData &&
            const MapEquality<EngineBaseURL, EngineOptionData>().equals(customUrls, other.customUrls);
  }

  @override
  int get hashCode {
    return const MapEquality<EngineBaseURL, EngineOptionData>().hash(customUrls);
  }

  Map<String, dynamic> toMap() {
    return customUrls.map((key, value) => MapEntry(key.name.toUpperCase(), value.toMap()));
  }
}

/// Stores a custom base URL and optional credentials, retaining only complete, nonempty pairs.
class EngineOptionData {
  EngineOptionData({required this.customBaseUrl, String? id, String? secret})
    : id = (id?.trim().isNotEmpty ?? false) && (secret?.trim().isNotEmpty ?? false) ? id!.trim() : null,
      secret = (id?.trim().isNotEmpty ?? false) && (secret?.trim().isNotEmpty ?? false) ? secret!.trim() : null;

  factory EngineOptionData.fromMap(Map<String, dynamic> map) {
    return EngineOptionData(
      customBaseUrl: map[_urlKey] as String? ?? '',
      id: map[_credentialIdKey] as String?,
      secret: map[_credentialSecretKey] as String?,
    );
  }

  final String customBaseUrl;
  final String? id;
  final String? secret;

  EngineOptions get engineOptions {
    final options = EngineOptions()..customBaseUrl = customBaseUrl;
    if (hasCredentials) {
      options.customAuthenticationMode = authenticationMode;
    }
    return options;
  }

  AuthenticationMode? get authenticationMode {
    if (!hasCredentials) return null;
    try {
      return AuthenticationMode.withKeySecret(id!, secret!);
    } catch (error) {
      debugPrint('Failed to create AuthenticationMode $error');
    }
    return null;
  }

  bool get hasCredentials => id != null && secret != null;

  String get readableId => id.maskedCredential;

  String get readableSecret => secret.maskedCredential;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EngineOptionData && customBaseUrl == other.customBaseUrl && id == other.id && secret == other.secret;
  }

  @override
  int get hashCode {
    return Object.hash(customBaseUrl, id, secret);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _urlKey: customBaseUrl,
      if (hasCredentials) _credentialIdKey: id,
      if (hasCredentials) _credentialSecretKey: secret,
    };
  }
}
