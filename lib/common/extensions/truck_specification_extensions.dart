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

import 'package:here_sdk/routing.dart';
import 'package:here_sdk/transport.dart';

extension TruckOptionsUtil on TruckOptions {
  TruckOptions copyTruckOptionsWith({
    required TruckSpecifications truckSpecifications,
  }) {
    return TruckOptions()
      ..routeOptions = routeOptions
      ..textOptions = textOptions
      ..avoidanceOptions = avoidanceOptions
      ..truckSpecifications = truckSpecifications
      ..linkTunnelCategory = linkTunnelCategory
      ..hazardousMaterials = hazardousMaterials;
  }
}

extension TruckSpecificationsUtils on TruckSpecifications {
  TruckSpecifications copyTruckSpecificationsWith({
    String? grossWeightInKilograms,
    String? weightPerAxleInKilograms,
    WeightPerAxleGroup? weightPerAxleGroup,
    String? heightInCentimeters,
    String? widthInCentimeters,
    String? lengthInCentimeters,
    String? axleCount,
  }) {
    return TruckSpecifications(
      grossWeightInKilograms != null ? int.tryParse(grossWeightInKilograms) ?? null : this.grossWeightInKilograms,
      weightPerAxleInKilograms != null ? int.tryParse(weightPerAxleInKilograms) ?? null : this.weightPerAxleInKilograms,
      weightPerAxleGroup ?? this.weightPerAxleGroup,
      heightInCentimeters != null ? int.tryParse(heightInCentimeters) ?? null : this.heightInCentimeters,
      widthInCentimeters != null ? int.tryParse(widthInCentimeters) ?? null : this.widthInCentimeters,
      lengthInCentimeters != null ? int.tryParse(lengthInCentimeters) ?? null : this.lengthInCentimeters,
      axleCount != null ? int.tryParse(axleCount) ?? null : this.axleCount,
    );
  }
}

extension WeightPerAxleGroupUtils on WeightPerAxleGroup {
  WeightPerAxleGroup? copyWeightPerAxleGroupWith({
    String? singleAxleGroupInKilograms,
    String? tandemAxleGroupInKilograms,
    String? tripleAxleGroupInKilograms,
    String? quadAxleGroupInKilograms,
    String? quintAxleGroupInKilograms,
  }) {
    return WeightPerAxleGroup()
      ..singleAxleGroupInKilograms = singleAxleGroupInKilograms != null
          ? int.tryParse(singleAxleGroupInKilograms) ?? null
          : this.singleAxleGroupInKilograms
      ..tandemAxleGroupInKilograms = tandemAxleGroupInKilograms != null
          ? int.tryParse(tandemAxleGroupInKilograms) ?? null
          : this.tandemAxleGroupInKilograms
      ..tripleAxleGroupInKilograms = tripleAxleGroupInKilograms != null
          ? int.tryParse(tripleAxleGroupInKilograms) ?? null
          : this.tripleAxleGroupInKilograms
      ..quadAxleGroupInKilograms = quadAxleGroupInKilograms != null
          ? int.tryParse(quadAxleGroupInKilograms) ?? null
          : this.quadAxleGroupInKilograms
      ..quintAxleGroupInKilograms = quintAxleGroupInKilograms != null
          ? int.tryParse(quintAxleGroupInKilograms) ?? null
          : this.quintAxleGroupInKilograms;
  }
}
