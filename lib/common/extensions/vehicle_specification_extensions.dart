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

import 'package:here_sdk/transport.dart'
    show VehicleSpecification, WeightPerAxleGroup, TruckCategory, TunnelCategory, HazardousMaterial;
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';

int? _parse(String? value, int? fallback) {
  return value != null ? int.tryParse(value) : fallback;
}

extension VehicleSpecificationExtensions on VehicleSpecification {
  VehicleSpecification copyWith({
    String? heightInCentimeters,
    String? widthInCentimeters,
    String? lengthInCentimeters,
    String? axleCount,
    String? trailerCount,
    TruckCategory? Function()? truckCategory,
    bool? isTruckLight,
    String? payloadCapacityInKilograms,
    String? trailerAxleCount,
    String? kingpinToRearAxleDistanceInCentimeters,
    String? emptyWeightInKilograms,
    String? grossWeightInKilograms,
    String? currentWeightInKilograms,
    String? weightPerAxleInKilograms,
    WeightPerAxleGroup? weightPerAxleGroup,
    bool? isCommercial,
    String? Function()? lastCharacterOfLicensePlate,
    String? engineSizeInCubicCentimeters,
    String? tiresCount,
    TunnelCategory? Function()? tunnelCategory,
    List<HazardousMaterial>? hazardousMaterials,
    String? occupancy,
  }) {
    VehicleSpecification specification = VehicleSpecification();
    specification.heightInCentimeters = _parse(heightInCentimeters, this.heightInCentimeters);
    specification.widthInCentimeters = _parse(widthInCentimeters, this.widthInCentimeters);
    specification.lengthInCentimeters = _parse(lengthInCentimeters, this.lengthInCentimeters);
    specification.axleCount = _parse(axleCount, this.axleCount);
    specification.trailerCount = _parse(trailerCount, this.trailerCount);
    specification.payloadCapacityInKilograms = _parse(payloadCapacityInKilograms, this.payloadCapacityInKilograms);
    specification.trailerAxleCount = _parse(trailerAxleCount, this.trailerAxleCount);
    specification.kingpinToRearAxleDistanceInCentimeters = _parse(
      kingpinToRearAxleDistanceInCentimeters,
      this.kingpinToRearAxleDistanceInCentimeters,
    );
    specification.emptyWeightInKilograms = _parse(emptyWeightInKilograms, this.emptyWeightInKilograms);
    specification.grossWeightInKilograms = _parse(grossWeightInKilograms, this.grossWeightInKilograms);
    specification.currentWeightInKilograms = _parse(currentWeightInKilograms, this.currentWeightInKilograms);
    specification.weightPerAxleInKilograms = _parse(weightPerAxleInKilograms, this.weightPerAxleInKilograms);
    specification.engineSizeInCubicCentimeters = _parse(
      engineSizeInCubicCentimeters,
      this.engineSizeInCubicCentimeters,
    );
    specification.tiresCount = _parse(tiresCount, this.tiresCount);
    specification.occupancy = _parse(occupancy, this.occupancy);
    specification.tunnelCategory = tunnelCategory != null ? tunnelCategory() : this.tunnelCategory;
    specification.hazardousMaterials = hazardousMaterials ?? this.hazardousMaterials;
    specification.lastCharacterOfLicensePlate = lastCharacterOfLicensePlate != null
        ? lastCharacterOfLicensePlate()
        : this.lastCharacterOfLicensePlate;
    specification.truckCategory = truckCategory != null ? truckCategory() : this.truckCategory;
    specification.isCommercial = isCommercial ?? this.isCommercial;
    specification.isTruckLight = isTruckLight ?? this.isTruckLight;
    specification.weightPerAxleGroup = weightPerAxleGroup ?? this.weightPerAxleGroup;

    return specification;
  }

  String specificationsString(AppLocalizations localizations) {
    final specs = <String>[];

    void addSpec(String? label, Object? value) {
      if (value != null) {
        specs.add('$label = $value');
      }
    }

    addSpec(localizations.truckHeightRowTitle, heightInCentimeters);
    addSpec(localizations.truckWidthRowTitle, widthInCentimeters);
    addSpec(localizations.truckLengthRowTitle, lengthInCentimeters);
    addSpec(localizations.truckAxleCountRowTitle, axleCount);
    addSpec(localizations.truckCurrentWeightRowTitle, currentWeightInKilograms);
    addSpec(localizations.truckEmptyWeightRowTitle, emptyWeightInKilograms);
    addSpec(localizations.truckEngineSizeRowTitle, engineSizeInCubicCentimeters);
    addSpec(localizations.truckGrossWeightRowTitle, grossWeightInKilograms);
    addSpec(localizations.truckKingpinToRearAxleDistanceRowTitle, kingpinToRearAxleDistanceInCentimeters);
    addSpec(localizations.truckLastCharacterOfLicensePlateRowTitle, lastCharacterOfLicensePlate);
    addSpec(localizations.truckTiresCountRowTitle, tiresCount);
    addSpec(localizations.truckOccupancyRowTitle, occupancy);
    addSpec(localizations.payloadCapacity, payloadCapacityInKilograms);
    addSpec(localizations.truckSpecTrailerAxleCount, trailerAxleCount);
    addSpec(localizations.truckSpecTrailerCount, trailerCount);
    addSpec(localizations.truckWeightPerAxleRowTitle, weightPerAxleInKilograms);

    if (weightPerAxleGroup != null) {
      addSpec(localizations.singleAxleGroup, weightPerAxleGroup!.singleAxleGroupInKilograms);
      addSpec(localizations.tandemAxleGroup, weightPerAxleGroup!.tandemAxleGroupInKilograms);
      addSpec(localizations.tripleAxleGroup, weightPerAxleGroup!.tripleAxleGroupInKilograms);
      addSpec(localizations.quadAxleGroup, weightPerAxleGroup!.quadAxleGroupInKilograms);
      addSpec(localizations.quintAxleGroup, weightPerAxleGroup!.quintAxleGroupInKilograms);
    }

    return specs.join(', ');
  }
}

extension WeightPerAxleGroupUtils on WeightPerAxleGroup {
  WeightPerAxleGroup? copyWith({
    String? singleAxleGroupInKilograms,
    String? tandemAxleGroupInKilograms,
    String? tripleAxleGroupInKilograms,
    String? quadAxleGroupInKilograms,
    String? quintAxleGroupInKilograms,
  }) {
    return WeightPerAxleGroup()
      ..singleAxleGroupInKilograms = _parse(singleAxleGroupInKilograms, this.singleAxleGroupInKilograms)
      ..tandemAxleGroupInKilograms = _parse(tandemAxleGroupInKilograms, this.tandemAxleGroupInKilograms)
      ..tripleAxleGroupInKilograms = _parse(tripleAxleGroupInKilograms, this.tripleAxleGroupInKilograms)
      ..quadAxleGroupInKilograms = _parse(quadAxleGroupInKilograms, this.quadAxleGroupInKilograms)
      ..quintAxleGroupInKilograms = _parse(quintAxleGroupInKilograms, this.quintAxleGroupInKilograms);
  }
}
