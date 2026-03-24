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

import 'package:flutter/material.dart';
import 'package:here_sdk/transport.dart' show TransportMode;
import 'package:here_sdk_reference_application_flutter/common/hds_icons/hds_assets_paths.dart' show HdsAssetsPaths;
import 'package:here_sdk_reference_application_flutter/route_preferences/car_options_screen.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/pedestrian_options_screen.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/scooter_options_screen.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/truck_options_screen.dart';

/// Available transport modes currently supported by the Ref App.
/// The HERE SDK supports more transport modes than featured by this application.
enum SupportedTransportMode { car, truck, scooter, walk }

extension SupportedTransportModeExtension on SupportedTransportMode {
  String get icon {
    switch (this) {
      case SupportedTransportMode.car:
        return HdsAssetsPaths.carDrivingIcon;
      case SupportedTransportMode.truck:
        return HdsAssetsPaths.truck;
      case SupportedTransportMode.scooter:
        return HdsAssetsPaths.scooter;
      case SupportedTransportMode.walk:
        return HdsAssetsPaths.walk;
    }
  }

  TransportMode get mode {
    switch (this) {
      case SupportedTransportMode.car:
        return TransportMode.car;
      case SupportedTransportMode.truck:
        return TransportMode.truck;
      case SupportedTransportMode.scooter:
        return TransportMode.scooter;
      case SupportedTransportMode.walk:
        return TransportMode.pedestrian;
    }
  }

  Widget get getOptionsScreen {
    switch (this) {
      case SupportedTransportMode.car:
        return CarOptionsScreen();
      case SupportedTransportMode.truck:
        return TruckOptionsScreen();
      case SupportedTransportMode.scooter:
        return ScooterOptionsScreen();
      case SupportedTransportMode.walk:
        return PedestrianOptionsScreen();
    }
  }
}
