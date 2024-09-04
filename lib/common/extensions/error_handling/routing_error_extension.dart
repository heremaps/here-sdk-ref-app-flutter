/*
 * Copyright (C) 2020-2024 HERE Europe B.V.
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

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk/routing.dart' as Routing;

extension RoutingErrorExtension on Routing.RoutingError {
  String errorMessage(AppLocalizations localized) {
    String message;
    switch (this) {
      case Routing.RoutingError.internalError:
      case Routing.RoutingError.forbidden:
      case Routing.RoutingError.exceededUsageLimit:
      case Routing.RoutingError.parsingError:
        message = localized.errorRoutingFailed;
        break;

      case Routing.RoutingError.serverUnreachable:
      case Routing.RoutingError.httpError:
      case Routing.RoutingError.timedOut:
      case Routing.RoutingError.offline:
        message = localized.errorNetworkIssueOccurred;
        break;

      case Routing.RoutingError.authenticationFailed:
        message = localized.errorAuthenticationFailed;
        break;

      case Routing.RoutingError.noRouteFound:
      case Routing.RoutingError.invalidParameter:
      case Routing.RoutingError.couldNotMatchDestination:
      case Routing.RoutingError.couldNotMatchOrigin:
      case Routing.RoutingError.routeLengthLimitExceeded:
        message = localized.errorNoResultFound;
        break;

      default:
        message = localized.errorRoutingFailedPleaseTryAgain;
    }
    return '$message ($name)';
  }
}
