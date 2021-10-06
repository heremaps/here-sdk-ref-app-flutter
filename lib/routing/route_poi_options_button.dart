/*
 * Copyright (C) 2020-2021 HERE Europe B.V.
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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/search.dart';

import '../common/ui_style.dart';
import 'route_poi_options_item.dart';

class _PoiSettingInfo {
  final String categoryId;
  final String imageEnabled;
  final String imageDisabled;
  final IconData icon;

  _PoiSettingInfo({
    required this.categoryId,
    required this.imageEnabled,
    required this.imageDisabled,
    required this.icon,
  });

  String getTitle(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    if (categoryId == PlaceCategory.eatAndDrink) {
      return appLocalizations.eatAndDrinkTitle;
    } else if (categoryId == PlaceCategory.businessAndServicesFuelingStation) {
      return appLocalizations.fuelingStationsTitle;
    } else if (categoryId == PlaceCategory.businessAndServicesAtm) {
      return appLocalizations.atmTitle;
    }

    return "";
  }
}

final List<_PoiSettingInfo> _poiSettings = [
  _PoiSettingInfo(
    categoryId: PlaceCategory.eatAndDrink,
    imageEnabled: "assets/eat_and_drink_icon.svg",
    imageDisabled: "assets/eat_and_drink_icon_disabled.svg",
    icon: Icons.restaurant_rounded,
  ),
  _PoiSettingInfo(
    categoryId: PlaceCategory.businessAndServicesFuelingStation,
    imageEnabled: "assets/fueling_station_icon.svg",
    imageDisabled: "assets/fueling_station_icon_disabled.svg",
    icon: Icons.local_gas_station_rounded,
  ),
  _PoiSettingInfo(
    categoryId: PlaceCategory.businessAndServicesAtm,
    imageEnabled: "assets/atm_icon.svg",
    imageDisabled: "assets/atm_icon_disabled.svg",
    icon: Icons.local_atm,
  ),
];

/// A widget that displays the POI categories enabled for search.
class RoutePoiOptionsButton extends StatelessWidget {
  /// Set of categories currently enabled.
  final Set<String> categoryIds;

  /// Called when the set of categories is changed.
  final ValueChanged<Set<String>> onChanged;

  /// Constructs a widget.
  RoutePoiOptionsButton({
    this.categoryIds = const {},
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.only(
          left: UIStyle.contentMarginMedium,
          top: UIStyle.contentMarginMedium,
          bottom: UIStyle.contentMarginMedium,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _poiSettings
              .map((poiInfo) => Padding(
                    padding: EdgeInsets.only(
                      right: UIStyle.contentMarginMedium,
                    ),
                    child: SvgPicture.asset(
                        categoryIds.contains(poiInfo.categoryId) ? poiInfo.imageEnabled : poiInfo.imageDisabled),
                  ))
              .toList(),
        ),
      ),
      onTap: () => _showPoiEnableMenu(context),
    );
  }

  void _showPoiEnableMenu(BuildContext context) async {
    Set<String> categories = Set<String>.from(categoryIds);
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIStyle.popupsBorderRadius),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              leading: null,
              automaticallyImplyLeading: false,
              primary: false,
              centerTitle: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UIStyle.popupsBorderRadius),
                  topRight: Radius.circular(UIStyle.popupsBorderRadius),
                ),
              ),
              backgroundColor: colorScheme.background,
              title: Text(AppLocalizations.of(context)!.poiSettingsTitle),
              actions: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            ..._poiSettings
                .map((poiInfo) => RoutePoiOptionsItem(
                      value: categories.contains(poiInfo.categoryId),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            poiInfo.icon,
                            color: colorScheme.primary,
                          ),
                          Container(
                            width: UIStyle.contentMarginLarge,
                          ),
                          Text(poiInfo.getTitle(context)),
                        ],
                      ),
                      onChanged: (value) =>
                          value ? categories.add(poiInfo.categoryId) : categories.remove(poiInfo.categoryId),
                    ))
                .toList()
          ],
        ),
      ),
    );

    if (!SetEquality().equals(categories, categoryIds)) {
      onChanged(categories);
    }
  }
}
