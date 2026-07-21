/*
* Copyright (c) 2026 HERE Global B.V. and its affiliate(s).
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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:here_sdk/core.engine.dart' show AuthenticationMode, EngineOptions, EngineBaseURL;
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';

const String _credentialNameKey = 'name';
const String _urlKey = 'url';
const String _credentialIdKey = 'id';
const String _credentialSecretKey = 'secret';
const String _credentialTypeKey = 'type';
const String _credentialTokenKey = 'token';

enum CredentialsType {
  authModeKeySecret,
  authModeToken,
  external;

  String displayName(AppLocalizations localized) {
    return switch (this) {
      CredentialsType.authModeKeySecret => localized.idAndSecret,
      CredentialsType.authModeToken => localized.token,
      CredentialsType.external => localized.external,
    };
  }
}

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

/// Stores engine configuration data including credentials and custom base URL.
class EngineOptionData {
  EngineOptionData({
    required this.customBaseUrl,
    required this.credentialName,
    this.type = CredentialsType.authModeKeySecret,
    this.id,
    this.secret,
    this.token,
  });

  factory EngineOptionData.fromMap(Map<String, dynamic> map) {
    final String typeData = map[_credentialTypeKey] as String? ?? '';

    final CredentialsType type = CredentialsType.values.firstWhere(
      (CredentialsType rc) => rc.name.toUpperCase() == typeData.toUpperCase(),
      orElse: () => CredentialsType.authModeKeySecret,
    );

    return EngineOptionData(
      customBaseUrl: map[_urlKey] as String? ?? '',
      credentialName: map[_credentialNameKey] as String? ?? '',
      type: type,
      id: map[_credentialIdKey] as String?,
      secret: map[_credentialSecretKey] as String?,
      token: map[_credentialTokenKey] as String?,
    );
  }

  final String customBaseUrl;
  final String credentialName;
  final CredentialsType type;
  final String? id;
  final String? secret;
  final String? token;

  EngineOptions get engineOptions {
    return EngineOptions()
      ..customBaseUrl = customBaseUrl
      ..customAuthenticationMode = authenticationMode;
  }

  AuthenticationMode? get authenticationMode {
    if (!isValid) return null;
    try {
      return switch (type) {
        CredentialsType.authModeToken => AuthenticationMode.withToken(token!),
        CredentialsType.external => AuthenticationMode.withExternal(),
        CredentialsType.authModeKeySecret => AuthenticationMode.withKeySecret(id!, secret!),
      };
    } catch (error) {
      debugPrint('Failed to create AuthenticationMode $error');
    }
    return null;
  }

  bool get isValid {
    if (credentialName.isEmpty) return false;
    return switch (type) {
      CredentialsType.external => true,
      CredentialsType.authModeToken => token?.trim().isNotEmpty ?? false,
      CredentialsType.authModeKeySecret => (id?.trim().isNotEmpty ?? false) && (secret?.trim().isNotEmpty ?? false),
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EngineOptionData &&
            customBaseUrl == other.customBaseUrl &&
            credentialName == other.credentialName &&
            type == other.type &&
            id == other.id &&
            secret == other.secret &&
            token == other.token;
  }

  @override
  int get hashCode {
    return Object.hash(customBaseUrl, credentialName, type, id, secret, token);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _urlKey: customBaseUrl,
      _credentialNameKey: credentialName,
      _credentialTypeKey: type.name.toUpperCase(),
      if (id != null) _credentialIdKey: id,
      if (secret != null) _credentialSecretKey: secret,
      if (token != null) _credentialTokenKey: token,
    };
  }
}
