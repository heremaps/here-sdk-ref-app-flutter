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

import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk_reference_application_flutter/common/extensions/string_extensions.dart';
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';

const String _hrn = 'hrn';
const String _version = 'version';
const String _allowDownload = 'allowDownload';
const String _ignoreCachedData = 'ignoreCachedData';
const String _cacheExpirationInSec = 'cacheExpirationInSec';
const String _patchHrn = 'patchHrn';

const bool _ignoredCachedDataDefaultValue = false;

class CatalogConfigurationData {
  const CatalogConfigurationData(
    this.hrn,
    this.version,
    this.allowDownload,
    this.ignoreCachedData,
    this.cacheExpirationInSec,
    this.patchHrn,
  );

  factory CatalogConfigurationData.fromMap(Map<String, dynamic> map) {
    final String? hrn = map[_hrn] as String?;
    final int? version = map[_version] as int?;
    final bool allowDownload = map[_allowDownload] as bool? ?? true;
    final bool ignoreCachedData = map[_ignoreCachedData] as bool? ?? false;
    final int? cacheExpiration = map[_cacheExpirationInSec] as int?;
    final String? patchHrn = map[_patchHrn] as String?;

    if (hrn == null) {
      throw Exception('Error in parsing CatalogConfigurationData');
    }

    return CatalogConfigurationData(hrn, version, allowDownload, ignoreCachedData, cacheExpiration, patchHrn);
  }

  CatalogConfigurationData.from(CatalogConfiguration config)
    : hrn = config.catalog.id.hrn,
      version = config.catalog.id.version,
      allowDownload = config.allowDownload,
      ignoreCachedData = _ignoredCachedDataDefaultValue,
      cacheExpirationInSec = config.cacheExpirationPeriod?.inSeconds,
      patchHrn = config.patchHrn;

  final String hrn;
  final int? version;
  final bool allowDownload;
  final bool ignoreCachedData;
  final int? cacheExpirationInSec;
  final String? patchHrn;

  @override
  int get hashCode {
    return hrn.hashCode ^
        version.hashCode ^
        allowDownload.hashCode ^
        ignoreCachedData.hashCode ^
        cacheExpirationInSec.hashCode ^
        patchHrn.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogConfigurationData &&
            hrn == other.hrn &&
            version == other.version &&
            allowDownload == other.allowDownload &&
            ignoreCachedData == other.ignoreCachedData &&
            cacheExpirationInSec == other.cacheExpirationInSec &&
            patchHrn == other.patchHrn;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _hrn: hrn,
      _version: version,
      _allowDownload: allowDownload,
      _ignoreCachedData: ignoreCachedData,
      _cacheExpirationInSec: cacheExpirationInSec,
      _patchHrn: patchHrn,
    };
  }

  static List<CatalogConfigurationData>? fromDynamicListToList(List<dynamic>? list) {
    if (list?.isNotEmpty ?? false) {
      final List<Map<String, dynamic>> listOfMaps = list!.cast<Map<String, dynamic>>();
      return listOfMaps.map(CatalogConfigurationData.fromMap).toList();
    }
    return null;
  }

  static List<dynamic> toDynamicListFromList(List<CatalogConfigurationData> list) {
    return list.map((CatalogConfigurationData catConf) => catConf.toMap()).toList();
  }
}

extension CatalogConfigurationDataDescriptionUtil on CatalogConfigurationData {
  String title(AppLocalizations localized) {
    return '${localized.hrn}: $hrn, ${version == -1 ? localized.latest : version ?? localized.latest}';
  }

  String description(AppLocalizations localized) => '${localized.patchHrn.toUpperCase()}: ${patchHrn.unwrapped}';

  /// Converts this `CatalogConfigurationData` to a `CatalogConfiguration` for SDK usage.
  CatalogConfiguration toSdkCatalogConfiguration() {
    final DesiredCatalog desiredCatalog = DesiredCatalog(
      hrn,
      version != null
          ? CatalogVersionHint.specific(version!)
          : CatalogVersionHint.latestWithIgnoringCachedData(ignoreCachedData),
    );
    final CatalogConfiguration catalogConfig = CatalogConfiguration(desiredCatalog)
      ..allowDownload = allowDownload
      ..cacheExpirationPeriod = cacheExpirationInSec != null ? Duration(seconds: cacheExpirationInSec!) : null
      ..patchHrn = patchHrn;
    return catalogConfig;
  }
}

extension CatalogConfigurationDataListUtil on List<CatalogConfigurationData> {
  List<CatalogConfiguration> toSdkCatalogConfigurations() {
    return map((CatalogConfigurationData c) => c.toSdkCatalogConfiguration()).toList();
  }
}
