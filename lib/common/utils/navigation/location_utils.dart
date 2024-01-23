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
import 'package:RefApp/common/utils/navigation/location_provider_interface.dart';
import 'package:RefApp/common/utils/navigation/location_providers/positioning_location_provider.dart';
import 'package:RefApp/common/utils/navigation/location_providers/simulated_location_provider.dart';
import 'package:here_sdk/navigation.dart';
import 'package:here_sdk/routing.dart' as here;

LocationProviderInterface createLocationProvider({
  bool simulated = false,
  LocationSimulatorOptions? simulatorOptions, // needed if simulated == true
  here.Route? route,
}) {
  assert(
    simulated == false || simulatorOptions != null,
    'simulatorOptions are needed if simulated == true',
  );
  assert(
    simulated == false || (simulated && route != null),
    'track or route need to be provided if simulated == true',
  );

  if (simulated && route != null) {
    return SimulatedLocationProvider.withRoute(route, simulatorOptions!);
  } else {
    return PositioningLocationProvider();
  }
}
