/*
 * Copyright (C) 2020-2023 HERE Europe B.V.
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

import 'package:here_sdk/search.dart' show SearchError;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension SearchErrorExtension on SearchError {
  String? errorMessage(AppLocalizations localized) {
    switch (this) {
      case SearchError.operationCancelled:
        return null;

      case SearchError.authenticationFailed:
      case SearchError.forbidden:
        return localized.errorAuthenticationFailed;

      case SearchError.maxItemsOutOfRange:
      case SearchError.polylineTooLong:
      case SearchError.noResultsFound:
      case SearchError.invalidParameter:
      case SearchError.queryTooLong:
      case SearchError.filterTooLong:
        return localized.errorNoResultFound;

      case SearchError.parsingError:
      case SearchError.exceededUsageLimit:
      case SearchError.operationFailed:
        return localized.errorSearchFailed;

      case SearchError.httpError:
      case SearchError.serverUnreachable:
      case SearchError.offline:
      case SearchError.proxyAuthenticationFailed:
      case SearchError.proxyServerUnreachable:
        return localized.errorNetworkIssueOccurred;

      default:
        return localized.errorSearchFailedPleaseTryAgain;
    }
  }
}
