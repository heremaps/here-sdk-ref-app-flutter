/*
 * Copyright (C) 2020-2022 HERE Europe B.V.
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

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart';
import 'package:here_sdk/transport.dart' as Transport;

/// Helper class for the routing options strings.
class EnumStringHelper {
  static int noneValueIndex = -1;

  /// Returns the mapping of [TextFormat] values to the corresponding strings.
  static Map<int, String> routeInstructionsFormatMap(BuildContext context) {
    final Map<int, String> result = Map<int, String>();
    for (TextFormat value in TextFormat.values) {
      switch (value) {
        case TextFormat.html:
          result[value.index] = AppLocalizations.of(context)!.textFormatHtml;
          break;
        case TextFormat.plain:
          result[value.index] = AppLocalizations.of(context)!.textFormatPlain;
          break;
        default:
          throw StateError("Invalid enum value $value for TextFormat enum.");
      }
    }
    return result;
  }

  /// Returns the mapping of [OptimizationMode] values to the corresponding strings.
  static Map<int, String> routeOptimizationModeMap(BuildContext context) {
    final Map<int, String> result = Map<int, String>();
    for (OptimizationMode value in OptimizationMode.values) {
      switch (value) {
        case OptimizationMode.fastest:
          result[value.index] = AppLocalizations.of(context)!.fastestRouteTitle;
          break;
        case OptimizationMode.shortest:
          result[value.index] = AppLocalizations.of(context)!.shortestRouteTitle;
          break;
        default:
          throw StateError("Invalid enum value $value for OptimizationMode enum.");
      }
    }
    return result;
  }

  /// Returns the mapping of [UnitSystem] values to the corresponding strings.
  static Map<int, String> routeUnitSystemMap(BuildContext context) {
    final Map<int, String> result = Map<int, String>();
    for (UnitSystem value in UnitSystem.values) {
      switch (value) {
        case UnitSystem.metric:
          result[value.index] = AppLocalizations.of(context)!.unitSystemMetric;
          break;
        case UnitSystem.imperialUk:
          result[value.index] = AppLocalizations.of(context)!.unitSystemImperialUk;
          break;
        case UnitSystem.imperialUs:
          result[value.index] = AppLocalizations.of(context)!.unitSystemImperialUs;
          break;
        default:
          throw StateError("Invalid enum value $value for TextFormat enum.");
      }
    }
    return result;
  }

  // The app currently only supports a few languages for routing.
  // For the whole list please check LanguageCode enum.
  /// Returns the mapping of [LanguageCode] values to the corresponding strings.
  static Map<int, String> routeLanguageMap(BuildContext context) {
    final Map<int, String> result = Map<int, String>();
    for (LanguageCode value in LanguageCode.values) {
      switch (value) {
        case LanguageCode.arSa:
          result[value.index] = AppLocalizations.of(context)!.languageCodeArSa;
          break;
        case LanguageCode.enUs:
          result[value.index] = AppLocalizations.of(context)!.languageCodeEnUs;
          break;
        case LanguageCode.frFr:
          result[value.index] = AppLocalizations.of(context)!.languageCodeFrFr;
          break;
        case LanguageCode.deDe:
          result[value.index] = AppLocalizations.of(context)!.languageCodeDeDe;
          break;
        case LanguageCode.esEs:
          result[value.index] = AppLocalizations.of(context)!.languageCodeEsEs;
          break;
        case LanguageCode.ptPt:
          result[value.index] = AppLocalizations.of(context)!.languageCodePtPt;
          break;
        case LanguageCode.zhCn:
          result[value.index] = AppLocalizations.of(context)!.languageCodeZhCn;
          break;
        case LanguageCode.hiIn:
          result[value.index] = AppLocalizations.of(context)!.languageCodeHiIn;
          break;

        default:
      }
    }
    return result;
  }

  /// Returns the mapping of [Transport.TunnelCategory] values to the corresponding strings.
  static Map<int, String> tunnelCategoryMap(BuildContext context) {
    final Map<int, String> result = Map<int, String>();
    result[noneValueIndex] = AppLocalizations.of(context)!.noneTitle;

    for (Transport.TunnelCategory value in Transport.TunnelCategory.values) {
      switch (value) {
        case Transport.TunnelCategory.b:
          result[value.index] = AppLocalizations.of(context)!.tunnelCategoryB;
          break;
        case Transport.TunnelCategory.c:
          result[value.index] = AppLocalizations.of(context)!.tunnelCategoryC;
          break;
        case Transport.TunnelCategory.d:
          result[value.index] = AppLocalizations.of(context)!.tunnelCategoryD;
          break;
        case Transport.TunnelCategory.e:
          result[value.index] = AppLocalizations.of(context)!.tunnelCategoryE;
          break;
        default:
          throw StateError("Invalid enum value $value for TunnelCategory enum.");
      }
    }
    return result;
  }

  static String roadFeatureNamesToString(BuildContext context, List<RoadFeatures> roadFeatures) {
    List<String> result = <String>[];
    sortedRoadFeaturesMap(context).forEach((key, value) {
      if (roadFeatures.contains(value)) result.add(key);
    });
    return result.join(", ");
  }

  /// Returns the mapping of [RoadFeatures] values to the corresponding strings.
  static LinkedHashMap<String, RoadFeatures> sortedRoadFeaturesMap(BuildContext context) {
    final Map<String, RoadFeatures> result = Map<String, RoadFeatures>();
    AppLocalizations localizations = AppLocalizations.of(context)!;

    for (RoadFeatures value in RoadFeatures.values) {
      switch (value) {
        case RoadFeatures.seasonalClosure:
          result[localizations.seasonalClosure] = value;
          break;
        case RoadFeatures.tollRoad:
          result[localizations.tollRoad] = value;
          break;
        case RoadFeatures.controlledAccessHighway:
          result[localizations.controlledAccessHighway] = value;
          break;
        case RoadFeatures.ferry:
          result[localizations.ferry] = value;
          break;
        case RoadFeatures.carShuttleTrain:
          result[localizations.carShuttleTrain] = value;
          break;
        case RoadFeatures.tunnel:
          result[localizations.tunnel] = value;
          break;
        case RoadFeatures.dirtRoad:
          result[localizations.dirtRoad] = value;
          break;
        case RoadFeatures.uTurns:
        case RoadFeatures.difficultTurns:
          result[localizations.uTurns] = value;
          break;
        default:
          throw StateError("Invalid enum value $value for RoadFeatures enum.");
      }
    }
    return LinkedHashMap.fromIterable(result.keys.toList()..sort(), key: (k) => k, value: (k) => result[k]!);
  }

  /// Returns concatenated string of the all values from the [hazardousMaterials] list.
  static String hazardousMaterialsNamesToString(
    BuildContext context,
    List<Transport.HazardousMaterial> hazardousMaterials,
  ) {
    List<String> result = <String>[];
    sortedHazardousMaterialsMap(context).forEach((key, value) {
      if (hazardousMaterials.contains(value)) result.add(key);
    });
    return result.join(", ");
  }

  /// Returns the mapping of [HazardousMaterial] values to the corresponding strings.
  static LinkedHashMap<String, Transport.HazardousMaterial> sortedHazardousMaterialsMap(BuildContext context) {
    final Map<String, Transport.HazardousMaterial> result = Map<String, Transport.HazardousMaterial>();
    AppLocalizations localizations = AppLocalizations.of(context)!;

    for (Transport.HazardousMaterial value in Transport.HazardousMaterial.values) {
      switch (value) {
        case Transport.HazardousMaterial.explosive:
          result[localizations.hazardousGoodsExplosive] = value;
          break;
        case Transport.HazardousMaterial.gas:
          result[localizations.hazardousGoodsGas] = value;
          break;
        case Transport.HazardousMaterial.flammable:
          result[localizations.hazardousGoodsFlammable] = value;
          break;
        case Transport.HazardousMaterial.combustible:
          result[localizations.hazardousGoodsCombustible] = value;
          break;
        case Transport.HazardousMaterial.organic:
          result[localizations.hazardousGoodsOrganic] = value;
          break;
        case Transport.HazardousMaterial.poison:
          result[localizations.hazardousGoodsPoison] = value;
          break;
        case Transport.HazardousMaterial.radioactive:
          result[localizations.hazardousGoodsRadioactive] = value;
          break;
        case Transport.HazardousMaterial.corrosive:
          result[localizations.hazardousGoodsCorrosive] = value;
          break;
        case Transport.HazardousMaterial.poisonousInhalation:
          result[localizations.hazardousGoodsPoisonousInhalation] = value;
          break;
        case Transport.HazardousMaterial.harmfulToWater:
          result[localizations.hazardousGoodsHarmfulToWater] = value;
          break;
        case Transport.HazardousMaterial.other:
          result[localizations.hazardousGoodsOther] = value;
          break;
        default:
          throw StateError("Invalid enum value $value for HazardousGood enum.");
      }
    }
    return LinkedHashMap.fromIterable(result.keys.toList()..sort(), key: (k) => k, value: (k) => result[k]!);
  }

  /// Returns concatenated string of the all values from the [countryCodes] list.
  static String countryCodeNamesToString(BuildContext context, List<CountryCode> countryCodes) {
    List<String> result = <String>[];
    countryCodesMap(context).forEach((key, value) {
      if (countryCodes.contains(value)) result.add(key);
    });
    return (result..sort()).join(", ");
  }

  /// Returns the mapping of [CountryCode] values to the corresponding strings.
  static Map<String, CountryCode> countryCodesMap(BuildContext context) {
    final Map<String, CountryCode> result = Map<String, CountryCode>();
    AppLocalizations localizations = AppLocalizations.of(context)!;

    // Keep enum order(sorted) as in SDK
    for (CountryCode value in CountryCode.values) {
      switch (value) {
        case CountryCode.abw:
          result[localizations.countryCodeAbw] = value;
          break;
        case CountryCode.afg:
          result[localizations.countryCodeAfg] = value;
          break;
        case CountryCode.ago:
          result[localizations.countryCodeAgo] = value;
          break;
        case CountryCode.aia:
          result[localizations.countryCodeAia] = value;
          break;
        case CountryCode.ala:
          result[localizations.countryCodeAla] = value;
          break;
        case CountryCode.alb:
          result[localizations.countryCodeAlb] = value;
          break;
        case CountryCode.and:
          result[localizations.countryCodeAnd] = value;
          break;
        case CountryCode.are:
          result[localizations.countryCodeAre] = value;
          break;
        case CountryCode.arg:
          result[localizations.countryCodeArg] = value;
          break;
        case CountryCode.arm:
          result[localizations.countryCodeArm] = value;
          break;
        case CountryCode.asm:
          result[localizations.countryCodeAsm] = value;
          break;
        case CountryCode.ata:
          result[localizations.countryCodeAta] = value;
          break;
        case CountryCode.atf:
          result[localizations.countryCodeAtf] = value;
          break;
        case CountryCode.atg:
          result[localizations.countryCodeAtg] = value;
          break;
        case CountryCode.aus:
          result[localizations.countryCodeAus] = value;
          break;
        case CountryCode.aut:
          result[localizations.countryCodeAut] = value;
          break;
        case CountryCode.aze:
          result[localizations.countryCodeAze] = value;
          break;
        case CountryCode.bdi:
          result[localizations.countryCodeBdi] = value;
          break;
        case CountryCode.bel:
          result[localizations.countryCodeBel] = value;
          break;
        case CountryCode.ben:
          result[localizations.countryCodeBen] = value;
          break;
        case CountryCode.bes:
          result[localizations.countryCodeBes] = value;
          break;
        case CountryCode.bfa:
          result[localizations.countryCodeBfa] = value;
          break;
        case CountryCode.bgd:
          result[localizations.countryCodeBgd] = value;
          break;
        case CountryCode.bgr:
          result[localizations.countryCodeBgr] = value;
          break;
        case CountryCode.bhr:
          result[localizations.countryCodeBhr] = value;
          break;
        case CountryCode.bhs:
          result[localizations.countryCodeBhs] = value;
          break;
        case CountryCode.bih:
          result[localizations.countryCodeBih] = value;
          break;
        case CountryCode.blm:
          result[localizations.countryCodeBlm] = value;
          break;
        case CountryCode.blr:
          result[localizations.countryCodeBlr] = value;
          break;
        case CountryCode.blz:
          result[localizations.countryCodeBlz] = value;
          break;
        case CountryCode.bmu:
          result[localizations.countryCodeBmu] = value;
          break;
        case CountryCode.bol:
          result[localizations.countryCodeBol] = value;
          break;
        case CountryCode.bra:
          result[localizations.countryCodeBra] = value;
          break;
        case CountryCode.brb:
          result[localizations.countryCodeBrb] = value;
          break;
        case CountryCode.brn:
          result[localizations.countryCodeBrn] = value;
          break;
        case CountryCode.btn:
          result[localizations.countryCodeBtn] = value;
          break;
        case CountryCode.bvt:
          result[localizations.countryCodeBvt] = value;
          break;
        case CountryCode.bwa:
          result[localizations.countryCodeBwa] = value;
          break;
        case CountryCode.caf:
          result[localizations.countryCodeCaf] = value;
          break;
        case CountryCode.can:
          result[localizations.countryCodeCan] = value;
          break;
        case CountryCode.cck:
          result[localizations.countryCodeCck] = value;
          break;
        case CountryCode.che:
          result[localizations.countryCodeChe] = value;
          break;
        case CountryCode.chl:
          result[localizations.countryCodeChl] = value;
          break;
        case CountryCode.chn:
          result[localizations.countryCodeChn] = value;
          break;
        case CountryCode.civ:
          result[localizations.countryCodeCiv] = value;
          break;
        case CountryCode.cmr:
          result[localizations.countryCodeCmr] = value;
          break;
        case CountryCode.cod:
          result[localizations.countryCodeCod] = value;
          break;
        case CountryCode.cog:
          result[localizations.countryCodeCog] = value;
          break;
        case CountryCode.cok:
          result[localizations.countryCodeCok] = value;
          break;
        case CountryCode.col:
          result[localizations.countryCodeCol] = value;
          break;
        case CountryCode.com:
          result[localizations.countryCodeCom] = value;
          break;
        case CountryCode.cpv:
          result[localizations.countryCodeCpv] = value;
          break;
        case CountryCode.cri:
          result[localizations.countryCodeCri] = value;
          break;
        case CountryCode.cub:
          result[localizations.countryCodeCub] = value;
          break;
        case CountryCode.cuw:
          result[localizations.countryCodeCuw] = value;
          break;
        case CountryCode.cxr:
          result[localizations.countryCodeCxr] = value;
          break;
        case CountryCode.cym:
          result[localizations.countryCodeCym] = value;
          break;
        case CountryCode.cyp:
          result[localizations.countryCodeCyp] = value;
          break;
        case CountryCode.cze:
          result[localizations.countryCodeCze] = value;
          break;
        case CountryCode.deu:
          result[localizations.countryCodeDeu] = value;
          break;
        case CountryCode.dji:
          result[localizations.countryCodeDji] = value;
          break;
        case CountryCode.dma:
          result[localizations.countryCodeDma] = value;
          break;
        case CountryCode.dnk:
          result[localizations.countryCodeDnk] = value;
          break;
        case CountryCode.dom:
          result[localizations.countryCodeDom] = value;
          break;
        case CountryCode.dza:
          result[localizations.countryCodeDza] = value;
          break;
        case CountryCode.ecu:
          result[localizations.countryCodeEcu] = value;
          break;
        case CountryCode.egy:
          result[localizations.countryCodeEgy] = value;
          break;
        case CountryCode.eri:
          result[localizations.countryCodeEri] = value;
          break;
        case CountryCode.esh:
          result[localizations.countryCodeEsh] = value;
          break;
        case CountryCode.esp:
          result[localizations.countryCodeEsp] = value;
          break;
        case CountryCode.est:
          result[localizations.countryCodeEst] = value;
          break;
        case CountryCode.eth:
          result[localizations.countryCodeEth] = value;
          break;
        case CountryCode.fin:
          result[localizations.countryCodeFin] = value;
          break;
        case CountryCode.fji:
          result[localizations.countryCodeFji] = value;
          break;
        case CountryCode.flk:
          result[localizations.countryCodeFlk] = value;
          break;
        case CountryCode.fra:
          result[localizations.countryCodeFra] = value;
          break;
        case CountryCode.fro:
          result[localizations.countryCodeFro] = value;
          break;
        case CountryCode.fsm:
          result[localizations.countryCodeFsm] = value;
          break;
        case CountryCode.gab:
          result[localizations.countryCodeGab] = value;
          break;
        case CountryCode.gbr:
          result[localizations.countryCodeGbr] = value;
          break;
        case CountryCode.geo:
          result[localizations.countryCodeGeo] = value;
          break;
        case CountryCode.ggy:
          result[localizations.countryCodeGgy] = value;
          break;
        case CountryCode.gha:
          result[localizations.countryCodeGha] = value;
          break;
        case CountryCode.gib:
          result[localizations.countryCodeGib] = value;
          break;
        case CountryCode.gin:
          result[localizations.countryCodeGin] = value;
          break;
        case CountryCode.glp:
          result[localizations.countryCodeGlp] = value;
          break;
        case CountryCode.gmb:
          result[localizations.countryCodeGmb] = value;
          break;
        case CountryCode.gnb:
          result[localizations.countryCodeGnb] = value;
          break;
        case CountryCode.gnq:
          result[localizations.countryCodeGnq] = value;
          break;
        case CountryCode.grc:
          result[localizations.countryCodeGrc] = value;
          break;
        case CountryCode.grd:
          result[localizations.countryCodeGrd] = value;
          break;
        case CountryCode.grl:
          result[localizations.countryCodeGrl] = value;
          break;
        case CountryCode.gtm:
          result[localizations.countryCodeGtm] = value;
          break;
        case CountryCode.guf:
          result[localizations.countryCodeGuf] = value;
          break;
        case CountryCode.gum:
          result[localizations.countryCodeGum] = value;
          break;
        case CountryCode.guy:
          result[localizations.countryCodeGuy] = value;
          break;
        case CountryCode.hkg:
          result[localizations.countryCodeHkg] = value;
          break;
        case CountryCode.hmd:
          result[localizations.countryCodeHmd] = value;
          break;
        case CountryCode.hnd:
          result[localizations.countryCodeHnd] = value;
          break;
        case CountryCode.hrv:
          result[localizations.countryCodeHrv] = value;
          break;
        case CountryCode.hti:
          result[localizations.countryCodeHti] = value;
          break;
        case CountryCode.hun:
          result[localizations.countryCodeHun] = value;
          break;
        case CountryCode.idn:
          result[localizations.countryCodeIdn] = value;
          break;
        case CountryCode.imn:
          result[localizations.countryCodeImn] = value;
          break;
        case CountryCode.ind:
          result[localizations.countryCodeInd] = value;
          break;
        case CountryCode.iot:
          result[localizations.countryCodeIot] = value;
          break;
        case CountryCode.irl:
          result[localizations.countryCodeIrl] = value;
          break;
        case CountryCode.irn:
          result[localizations.countryCodeIrn] = value;
          break;
        case CountryCode.irq:
          result[localizations.countryCodeIrq] = value;
          break;
        case CountryCode.isl:
          result[localizations.countryCodeIsl] = value;
          break;
        case CountryCode.isr:
          result[localizations.countryCodeIsr] = value;
          break;
        case CountryCode.ita:
          result[localizations.countryCodeIta] = value;
          break;
        case CountryCode.jam:
          result[localizations.countryCodeJam] = value;
          break;
        case CountryCode.jey:
          result[localizations.countryCodeJey] = value;
          break;
        case CountryCode.jor:
          result[localizations.countryCodeJor] = value;
          break;
        case CountryCode.jpn:
          result[localizations.countryCodeJpn] = value;
          break;
        case CountryCode.kaz:
          result[localizations.countryCodeKaz] = value;
          break;
        case CountryCode.ken:
          result[localizations.countryCodeKen] = value;
          break;
        case CountryCode.kgz:
          result[localizations.countryCodeKgz] = value;
          break;
        case CountryCode.khm:
          result[localizations.countryCodeKhm] = value;
          break;
        case CountryCode.kir:
          result[localizations.countryCodeKir] = value;
          break;
        case CountryCode.kna:
          result[localizations.countryCodeKna] = value;
          break;
        case CountryCode.kor:
          result[localizations.countryCodeKor] = value;
          break;
        case CountryCode.kwt:
          result[localizations.countryCodeKwt] = value;
          break;
        case CountryCode.lao:
          result[localizations.countryCodeLao] = value;
          break;
        case CountryCode.lbn:
          result[localizations.countryCodeLbn] = value;
          break;
        case CountryCode.lbr:
          result[localizations.countryCodeLbr] = value;
          break;
        case CountryCode.lby:
          result[localizations.countryCodeLby] = value;
          break;
        case CountryCode.lca:
          result[localizations.countryCodeLca] = value;
          break;
        case CountryCode.lie:
          result[localizations.countryCodeLie] = value;
          break;
        case CountryCode.lka:
          result[localizations.countryCodeLka] = value;
          break;
        case CountryCode.lso:
          result[localizations.countryCodeLso] = value;
          break;
        case CountryCode.ltu:
          result[localizations.countryCodeLtu] = value;
          break;
        case CountryCode.lux:
          result[localizations.countryCodeLux] = value;
          break;
        case CountryCode.lva:
          result[localizations.countryCodeLva] = value;
          break;
        case CountryCode.mac:
          result[localizations.countryCodeMac] = value;
          break;
        case CountryCode.maf:
          result[localizations.countryCodeMaf] = value;
          break;
        case CountryCode.mar:
          result[localizations.countryCodeMar] = value;
          break;
        case CountryCode.mco:
          result[localizations.countryCodeMco] = value;
          break;
        case CountryCode.mda:
          result[localizations.countryCodeMda] = value;
          break;
        case CountryCode.mdg:
          result[localizations.countryCodeMdg] = value;
          break;
        case CountryCode.mdv:
          result[localizations.countryCodeMdv] = value;
          break;
        case CountryCode.mex:
          result[localizations.countryCodeMex] = value;
          break;
        case CountryCode.mhl:
          result[localizations.countryCodeMhl] = value;
          break;
        case CountryCode.mkd:
          result[localizations.countryCodeMkd] = value;
          break;
        case CountryCode.mli:
          result[localizations.countryCodeMli] = value;
          break;
        case CountryCode.mlt:
          result[localizations.countryCodeMlt] = value;
          break;
        case CountryCode.mmr:
          result[localizations.countryCodeMmr] = value;
          break;
        case CountryCode.mne:
          result[localizations.countryCodeMne] = value;
          break;
        case CountryCode.mng:
          result[localizations.countryCodeMng] = value;
          break;
        case CountryCode.mnp:
          result[localizations.countryCodeMnp] = value;
          break;
        case CountryCode.moz:
          result[localizations.countryCodeMoz] = value;
          break;
        case CountryCode.mrt:
          result[localizations.countryCodeMrt] = value;
          break;
        case CountryCode.msr:
          result[localizations.countryCodeMsr] = value;
          break;
        case CountryCode.mtq:
          result[localizations.countryCodeMtq] = value;
          break;
        case CountryCode.mus:
          result[localizations.countryCodeMus] = value;
          break;
        case CountryCode.mwi:
          result[localizations.countryCodeMwi] = value;
          break;
        case CountryCode.mys:
          result[localizations.countryCodeMys] = value;
          break;
        case CountryCode.myt:
          result[localizations.countryCodeMyt] = value;
          break;
        case CountryCode.nam:
          result[localizations.countryCodeNam] = value;
          break;
        case CountryCode.ncl:
          result[localizations.countryCodeNcl] = value;
          break;
        case CountryCode.ner:
          result[localizations.countryCodeNer] = value;
          break;
        case CountryCode.nfk:
          result[localizations.countryCodeNfk] = value;
          break;
        case CountryCode.nga:
          result[localizations.countryCodeNga] = value;
          break;
        case CountryCode.nic:
          result[localizations.countryCodeNic] = value;
          break;
        case CountryCode.niu:
          result[localizations.countryCodeNiu] = value;
          break;
        case CountryCode.nld:
          result[localizations.countryCodeNld] = value;
          break;
        case CountryCode.nor:
          result[localizations.countryCodeNor] = value;
          break;
        case CountryCode.npl:
          result[localizations.countryCodeNpl] = value;
          break;
        case CountryCode.nru:
          result[localizations.countryCodeNru] = value;
          break;
        case CountryCode.nzl:
          result[localizations.countryCodeNzl] = value;
          break;
        case CountryCode.omn:
          result[localizations.countryCodeOmn] = value;
          break;
        case CountryCode.pak:
          result[localizations.countryCodePak] = value;
          break;
        case CountryCode.pan:
          result[localizations.countryCodePan] = value;
          break;
        case CountryCode.pcn:
          result[localizations.countryCodePcn] = value;
          break;
        case CountryCode.per:
          result[localizations.countryCodePer] = value;
          break;
        case CountryCode.phl:
          result[localizations.countryCodePhl] = value;
          break;
        case CountryCode.plw:
          result[localizations.countryCodePlw] = value;
          break;
        case CountryCode.png:
          result[localizations.countryCodePng] = value;
          break;
        case CountryCode.pol:
          result[localizations.countryCodePol] = value;
          break;
        case CountryCode.pri:
          result[localizations.countryCodePri] = value;
          break;
        case CountryCode.prk:
          result[localizations.countryCodePrk] = value;
          break;
        case CountryCode.prt:
          result[localizations.countryCodePrt] = value;
          break;
        case CountryCode.pry:
          result[localizations.countryCodePry] = value;
          break;
        case CountryCode.pse:
          result[localizations.countryCodePse] = value;
          break;
        case CountryCode.pyf:
          result[localizations.countryCodePyf] = value;
          break;
        case CountryCode.qat:
          result[localizations.countryCodeQat] = value;
          break;
        case CountryCode.reu:
          result[localizations.countryCodeReu] = value;
          break;
        case CountryCode.rou:
          result[localizations.countryCodeRou] = value;
          break;
        case CountryCode.rus:
          result[localizations.countryCodeRus] = value;
          break;
        case CountryCode.rwa:
          result[localizations.countryCodeRwa] = value;
          break;
        case CountryCode.sau:
          result[localizations.countryCodeSau] = value;
          break;
        case CountryCode.sdn:
          result[localizations.countryCodeSdn] = value;
          break;
        case CountryCode.sen:
          result[localizations.countryCodeSen] = value;
          break;
        case CountryCode.sgp:
          result[localizations.countryCodeSgp] = value;
          break;
        case CountryCode.sgs:
          result[localizations.countryCodeSgs] = value;
          break;
        case CountryCode.shn:
          result[localizations.countryCodeShn] = value;
          break;
        case CountryCode.sjm:
          result[localizations.countryCodeSjm] = value;
          break;
        case CountryCode.slb:
          result[localizations.countryCodeSlb] = value;
          break;
        case CountryCode.sle:
          result[localizations.countryCodeSle] = value;
          break;
        case CountryCode.slv:
          result[localizations.countryCodeSlv] = value;
          break;
        case CountryCode.smr:
          result[localizations.countryCodeSmr] = value;
          break;
        case CountryCode.som:
          result[localizations.countryCodeSom] = value;
          break;
        case CountryCode.spm:
          result[localizations.countryCodeSpm] = value;
          break;
        case CountryCode.srb:
          result[localizations.countryCodeSrb] = value;
          break;
        case CountryCode.ssd:
          result[localizations.countryCodeSsd] = value;
          break;
        case CountryCode.stp:
          result[localizations.countryCodeStp] = value;
          break;
        case CountryCode.sur:
          result[localizations.countryCodeSur] = value;
          break;
        case CountryCode.svk:
          result[localizations.countryCodeSvk] = value;
          break;
        case CountryCode.svn:
          result[localizations.countryCodeSvn] = value;
          break;
        case CountryCode.swe:
          result[localizations.countryCodeSwe] = value;
          break;
        case CountryCode.swz:
          result[localizations.countryCodeSwz] = value;
          break;
        case CountryCode.sxm:
          result[localizations.countryCodeSxm] = value;
          break;
        case CountryCode.syc:
          result[localizations.countryCodeSyc] = value;
          break;
        case CountryCode.syr:
          result[localizations.countryCodeSyr] = value;
          break;
        case CountryCode.tca:
          result[localizations.countryCodeTca] = value;
          break;
        case CountryCode.tcd:
          result[localizations.countryCodeTcd] = value;
          break;
        case CountryCode.tgo:
          result[localizations.countryCodeTgo] = value;
          break;
        case CountryCode.tha:
          result[localizations.countryCodeTha] = value;
          break;
        case CountryCode.tjk:
          result[localizations.countryCodeTjk] = value;
          break;
        case CountryCode.tkl:
          result[localizations.countryCodeTkl] = value;
          break;
        case CountryCode.tkm:
          result[localizations.countryCodeTkm] = value;
          break;
        case CountryCode.tls:
          result[localizations.countryCodeTls] = value;
          break;
        case CountryCode.ton:
          result[localizations.countryCodeTon] = value;
          break;
        case CountryCode.tto:
          result[localizations.countryCodeTto] = value;
          break;
        case CountryCode.tun:
          result[localizations.countryCodeTun] = value;
          break;
        case CountryCode.tur:
          result[localizations.countryCodeTur] = value;
          break;
        case CountryCode.tuv:
          result[localizations.countryCodeTuv] = value;
          break;
        case CountryCode.twn:
          result[localizations.countryCodeTwn] = value;
          break;
        case CountryCode.tza:
          result[localizations.countryCodeTza] = value;
          break;
        case CountryCode.uga:
          result[localizations.countryCodeUga] = value;
          break;
        case CountryCode.ukr:
          result[localizations.countryCodeUkr] = value;
          break;
        case CountryCode.umi:
          result[localizations.countryCodeUmi] = value;
          break;
        case CountryCode.ury:
          result[localizations.countryCodeUry] = value;
          break;
        case CountryCode.usa:
          result[localizations.countryCodeUsa] = value;
          break;
        case CountryCode.uzb:
          result[localizations.countryCodeUzb] = value;
          break;
        case CountryCode.vat:
          result[localizations.countryCodeVat] = value;
          break;
        case CountryCode.vct:
          result[localizations.countryCodeVct] = value;
          break;
        case CountryCode.ven:
          result[localizations.countryCodeVen] = value;
          break;
        case CountryCode.vgb:
          result[localizations.countryCodeVgb] = value;
          break;
        case CountryCode.vir:
          result[localizations.countryCodeVir] = value;
          break;
        case CountryCode.vnm:
          result[localizations.countryCodeVnm] = value;
          break;
        case CountryCode.vut:
          result[localizations.countryCodeVut] = value;
          break;
        case CountryCode.wlf:
          result[localizations.countryCodeWlf] = value;
          break;
        case CountryCode.wsm:
          result[localizations.countryCodeWsm] = value;
          break;
        case CountryCode.yem:
          result[localizations.countryCodeYem] = value;
          break;
        case CountryCode.zaf:
          result[localizations.countryCodeZaf] = value;
          break;
        case CountryCode.zmb:
          result[localizations.countryCodeZmb] = value;
          break;
        case CountryCode.zwe:
          result[localizations.countryCodeZwe] = value;
          break;
        default:
          throw StateError("Invalid enum value $value for CountryCode enum.");
      }
    }
    return result;
  }
}
