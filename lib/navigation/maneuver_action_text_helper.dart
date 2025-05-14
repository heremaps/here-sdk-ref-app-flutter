/*
 * Copyright (C) 2020-2025 HERE Europe B.V.
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk/routing.dart';

import '../common/hds_icons/hds_assets_paths.dart';
import '../common/util.dart';

String _makeActionString(String text, String template, String? roadName) {
  if (roadName == null || roadName.isEmpty) {
    return text;
  }

  return formatString(template, [roadName]);
}

/// Helper extension class for the [Maneuver] class.
extension ManeuverActionHelper on Maneuver {
  /// Returns the localized text for the navigation maneuver.
  String getActionText(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final String? roadName = roadTexts.names.getDefaultValue();
    final String? nextRoadName = nextRoadTexts.names.getDefaultValue();

    switch (action) {
      case ManeuverAction.arrive:
        return localizations.arriveActionText;
      case ManeuverAction.continueOn:
        return _makeActionString(localizations.continueOnActionText, localizations.continueOnActionRoadText, roadName);
      case ManeuverAction.depart:
        return _makeActionString(localizations.departActionText, localizations.departActionRoadText, roadName);
      case ManeuverAction.leftExit:
        return _makeActionString(
            localizations.leftExitActionText, localizations.leftExitActionNextRoadText, nextRoadName);
      case ManeuverAction.leftFork:
        return _makeActionString(
            localizations.leftForkActionText, localizations.leftForkActionNextRoadText, nextRoadName);
      case ManeuverAction.leftRamp:
        return _makeActionString(
            localizations.leftRampActionText, localizations.leftRampActionNextRoadText, nextRoadName);
      case ManeuverAction.leftRoundaboutEnter:
        return localizations.leftRoundaboutEnterActionText;
      case ManeuverAction.leftRoundaboutExit1:
        return localizations.leftRoundaboutExit1ActionText;
      case ManeuverAction.leftRoundaboutExit10:
        return localizations.leftRoundaboutExit10ActionText;
      case ManeuverAction.leftRoundaboutExit11:
        return localizations.leftRoundaboutExit11ActionText;
      case ManeuverAction.leftRoundaboutExit12:
        return localizations.leftRoundaboutExit12ActionText;
      case ManeuverAction.leftRoundaboutExit2:
        return localizations.leftRoundaboutExit2ActionText;
      case ManeuverAction.leftRoundaboutExit3:
        return localizations.leftRoundaboutExit3ActionText;
      case ManeuverAction.leftRoundaboutExit4:
        return localizations.leftRoundaboutExit4ActionText;
      case ManeuverAction.leftRoundaboutExit5:
        return localizations.leftRoundaboutExit5ActionText;
      case ManeuverAction.leftRoundaboutExit6:
        return localizations.leftRoundaboutExit6ActionText;
      case ManeuverAction.leftRoundaboutExit7:
        return localizations.leftRoundaboutExit7ActionText;
      case ManeuverAction.leftRoundaboutExit8:
        return localizations.leftRoundaboutExit8ActionText;
      case ManeuverAction.leftRoundaboutExit9:
        return localizations.leftRoundaboutExit9ActionText;
      case ManeuverAction.leftRoundaboutPass:
        return localizations.leftRoundaboutPassActionText;
      case ManeuverAction.leftTurn:
        return _makeActionString(
            localizations.leftTurnActionText, localizations.leftTurnActionNextRoadText, nextRoadName);
      case ManeuverAction.leftUTurn:
        return _makeActionString(
            localizations.leftUTurnActionText, localizations.leftUTurnActionNextRoadText, nextRoadName);
      case ManeuverAction.middleFork:
        return _makeActionString(
            localizations.middleForkActionText, localizations.middleForkActionNextRoadText, nextRoadName);
      case ManeuverAction.rightExit:
        return _makeActionString(
            localizations.rightExitActionText, localizations.rightExitActionNextRoadText, nextRoadName);
      case ManeuverAction.rightFork:
        return _makeActionString(
            localizations.rightForkActionText, localizations.rightForkActionNextRoadText, nextRoadName);
      case ManeuverAction.rightRamp:
        return _makeActionString(
            localizations.rightRampActionText, localizations.rightRampActionNextRoadText, nextRoadName);
      case ManeuverAction.rightRoundaboutEnter:
        return localizations.rightRoundaboutEnterActionText;
      case ManeuverAction.rightRoundaboutExit1:
        return localizations.rightRoundaboutExit1ActionText;
      case ManeuverAction.rightRoundaboutExit10:
        return localizations.rightRoundaboutExit10ActionText;
      case ManeuverAction.rightRoundaboutExit11:
        return localizations.rightRoundaboutExit11ActionText;
      case ManeuverAction.rightRoundaboutExit12:
        return localizations.rightRoundaboutExit12ActionText;
      case ManeuverAction.rightRoundaboutExit2:
        return localizations.rightRoundaboutExit2ActionText;
      case ManeuverAction.rightRoundaboutExit3:
        return localizations.rightRoundaboutExit3ActionText;
      case ManeuverAction.rightRoundaboutExit4:
        return localizations.rightRoundaboutExit4ActionText;
      case ManeuverAction.rightRoundaboutExit5:
        return localizations.rightRoundaboutExit5ActionText;
      case ManeuverAction.rightRoundaboutExit6:
        return localizations.rightRoundaboutExit6ActionText;
      case ManeuverAction.rightRoundaboutExit7:
        return localizations.rightRoundaboutExit7ActionText;
      case ManeuverAction.rightRoundaboutExit8:
        return localizations.rightRoundaboutExit8ActionText;
      case ManeuverAction.rightRoundaboutExit9:
        return localizations.rightRoundaboutExit9ActionText;
      case ManeuverAction.rightRoundaboutPass:
        return localizations.rightRoundaboutPassActionText;
      case ManeuverAction.rightTurn:
        return _makeActionString(
            localizations.rightTurnActionText, localizations.rightTurnActionNextRoadText, nextRoadName);
      case ManeuverAction.rightUTurn:
        return _makeActionString(
            localizations.rightUTurnActionText, localizations.rightUTurnActionNextRoadText, nextRoadName);
      case ManeuverAction.sharpLeftTurn:
        return _makeActionString(
            localizations.sharpLeftTurnActionText, localizations.sharpLeftTurnActionNextRoadText, nextRoadName);
      case ManeuverAction.sharpRightTurn:
        return _makeActionString(
            localizations.sharpRightTurnActionText, localizations.sharpRightTurnActionNextRoadText, nextRoadName);
      case ManeuverAction.slightLeftTurn:
        return _makeActionString(
            localizations.slightLeftTurnActionText, localizations.slightLeftTurnActionNextRoadText, nextRoadName);
      case ManeuverAction.slightRightTurn:
        return _makeActionString(
            localizations.slightRightTurnActionText, localizations.slightRightTurnActionNextRoadText, nextRoadName);
      case ManeuverAction.enterHighwayFromLeft:
        return localizations.enterHighwayFromLeftActionText;
      case ManeuverAction.enterHighwayFromRight:
        return localizations.enterHighwayFromRightActionText;
    }
  }
}

extension ManeuverActionExtension on ManeuverAction {
  String get iconPath {
    switch (this) {
      case ManeuverAction.depart:
        return HdsAssetsPaths.departIcon;
      case ManeuverAction.arrive:
        return HdsAssetsPaths.arriveIcon;
      case ManeuverAction.leftUTurn:
        return HdsAssetsPaths.leftUTurnIcon;
      case ManeuverAction.sharpLeftTurn:
        return HdsAssetsPaths.sharpLeftTurnIcon;
      case ManeuverAction.leftTurn:
        return HdsAssetsPaths.leftTurnIcon;
      case ManeuverAction.slightLeftTurn:
        return HdsAssetsPaths.slightLeftTurnIcon;
      case ManeuverAction.continueOn:
        return HdsAssetsPaths.continueOnIcon;
      case ManeuverAction.slightRightTurn:
        return HdsAssetsPaths.slightRightTurnIcon;
      case ManeuverAction.rightTurn:
        return HdsAssetsPaths.rightTurnIcon;
      case ManeuverAction.sharpRightTurn:
        return HdsAssetsPaths.sharpRightTurnIcon;
      case ManeuverAction.rightUTurn:
        return HdsAssetsPaths.rightUTurnIcon;
      case ManeuverAction.leftExit:
        return HdsAssetsPaths.leftExitIcon;
      case ManeuverAction.rightExit:
        return HdsAssetsPaths.rightExitIcon;
      case ManeuverAction.leftRamp:
        return HdsAssetsPaths.leftRampIcon;
      case ManeuverAction.rightRamp:
        return HdsAssetsPaths.rightRampIcon;
      case ManeuverAction.leftFork:
        return HdsAssetsPaths.leftForkIcon;
      case ManeuverAction.middleFork:
        return HdsAssetsPaths.middleForkIcon;
      case ManeuverAction.rightFork:
        return HdsAssetsPaths.rightForkIcon;
      case ManeuverAction.enterHighwayFromLeft:
        return HdsAssetsPaths.enterHighwayFromRightIcon;
      case ManeuverAction.enterHighwayFromRight:
        return HdsAssetsPaths.enterHighwayFromLeftIcon;
      case ManeuverAction.leftRoundaboutEnter:
        return HdsAssetsPaths.leftRoundaboutEnterIcon;
      case ManeuverAction.rightRoundaboutEnter:
        return HdsAssetsPaths.rightRoundaboutEnterIcon;
      case ManeuverAction.leftRoundaboutPass:
        return HdsAssetsPaths.leftRoundaboutPassIcon;
      case ManeuverAction.rightRoundaboutPass:
        return HdsAssetsPaths.rightRoundaboutPassIcon;
      case ManeuverAction.leftRoundaboutExit1:
        return HdsAssetsPaths.leftRoundaboutExit1Icon;
      case ManeuverAction.leftRoundaboutExit2:
        return HdsAssetsPaths.leftRoundaboutExit2Icon;
      case ManeuverAction.leftRoundaboutExit3:
        return HdsAssetsPaths.leftRoundaboutExit3Icon;
      case ManeuverAction.leftRoundaboutExit4:
        return HdsAssetsPaths.leftRoundaboutExit4Icon;
      case ManeuverAction.leftRoundaboutExit5:
        return HdsAssetsPaths.leftRoundaboutExit5Icon;
      case ManeuverAction.leftRoundaboutExit6:
        return HdsAssetsPaths.leftRoundaboutExit6Icon;
      case ManeuverAction.leftRoundaboutExit7:
        return HdsAssetsPaths.leftRoundaboutExit7Icon;
      case ManeuverAction.leftRoundaboutExit8:
        return HdsAssetsPaths.leftRoundaboutExit8Icon;
      case ManeuverAction.leftRoundaboutExit9:
        return HdsAssetsPaths.leftRoundaboutExit9Icon;
      case ManeuverAction.leftRoundaboutExit10:
        return HdsAssetsPaths.leftRoundaboutExit10Icon;
      case ManeuverAction.leftRoundaboutExit11:
        return HdsAssetsPaths.leftRoundaboutExit11Icon;
      case ManeuverAction.leftRoundaboutExit12:
        return HdsAssetsPaths.leftRoundaboutExit12Icon;
      case ManeuverAction.rightRoundaboutExit1:
        return HdsAssetsPaths.rightRoundaboutExit1Icon;
      case ManeuverAction.rightRoundaboutExit2:
        return HdsAssetsPaths.rightRoundaboutExit2Icon;
      case ManeuverAction.rightRoundaboutExit3:
        return HdsAssetsPaths.rightRoundaboutExit3Icon;
      case ManeuverAction.rightRoundaboutExit4:
        return HdsAssetsPaths.rightRoundaboutExit4Icon;
      case ManeuverAction.rightRoundaboutExit5:
        return HdsAssetsPaths.rightRoundaboutExit5Icon;
      case ManeuverAction.rightRoundaboutExit6:
        return HdsAssetsPaths.rightRoundaboutExit6Icon;
      case ManeuverAction.rightRoundaboutExit7:
        return HdsAssetsPaths.rightRoundaboutExit7Icon;
      case ManeuverAction.rightRoundaboutExit8:
        return HdsAssetsPaths.rightRoundaboutExit8Icon;
      case ManeuverAction.rightRoundaboutExit9:
        return HdsAssetsPaths.rightRoundaboutExit9Icon;
      case ManeuverAction.rightRoundaboutExit10:
        return HdsAssetsPaths.rightRoundaboutExit10Icon;
      case ManeuverAction.rightRoundaboutExit11:
        return HdsAssetsPaths.rightRoundaboutExit11Icon;
      case ManeuverAction.rightRoundaboutExit12:
        return HdsAssetsPaths.rightRoundaboutExit12Icon;
    }
  }
}
