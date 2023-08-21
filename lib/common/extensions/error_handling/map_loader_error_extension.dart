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

import 'package:here_sdk/maploader.dart' show MapLoaderError;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension MapLoaderErrorExtension on MapLoaderError {
  String getErrorMessage(AppLocalizations localized) {
    String message;
    switch (this) {
      case MapLoaderError.accessDenied:
      case MapLoaderError.forbidden:
      case MapLoaderError.requestLimitReached:
        message = localized.errorAuthenticationFailed;
        break;

      /* case MapLoaderError.brokenUpdate:
        message = "Update failed, please clear all data";
        break;*/

      case MapLoaderError.invalidArgument:
        message = localized.errorNoResultFound;
        break;

      case MapLoaderError.mapManagerError:
      case MapLoaderError.operationCancelled:
      case MapLoaderError.timeOut:
      case MapLoaderError.unexpectedServerResponse:
        message = localized.errorMapLoaderErrorOccurredPleaseTryAgain;
        break;

      case MapLoaderError.migrationRequired:
      case MapLoaderError.protectedCacheCorrupted:
        message = localized.errorMapLoaderErrorPerformMigration;
        break;

      case MapLoaderError.networkConnectionError:
      case MapLoaderError.offline:
      case MapLoaderError.proxyAuthenticationFailed:
      case MapLoaderError.proxyServerUnreachable:
      case MapLoaderError.serviceUnavailable:
        message = localized.errorNetworkIssueOccurred;
        break;

      default:
        message = localized.errorMapLoaderErrorOccurred;
        break;
    }

    return message;
  }
}
