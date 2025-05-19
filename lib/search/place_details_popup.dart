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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/search.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/ui_style.dart';
import '../common/application_preferences.dart';
import '../search/search_engine_proxy.dart';

enum PlaceDetailsPopupResult {
  routeTo,
  addToRoute,
}

/// Displays a pop-up window with detailed info of the [place].
Future<PlaceDetailsPopupResult?> showPlaceDetailsPopup({
  required BuildContext context,
  required Place place,
  bool routeToEnabled = false,
  bool addToRouteEnabled = false,
}) async {
  Future<Place> placeDetailsFuture =
      _getPlaceDetails(place, Provider.of<AppPreferences>(context, listen: false).useAppOffline);

  PlaceDetailsPopupResult? result = await showDialog<PlaceDetailsPopupResult>(
    context: context,
    builder: (context) => FutureBuilder<Place>(
      initialData: place,
      future: placeDetailsFuture,
      builder: (context, snapshot) => _createPopupFromPlace(context, snapshot.data!, routeToEnabled, addToRouteEnabled),
    ),
  );

  return result;
}

Future<Place> _getPlaceDetails(Place place, bool offline) async {
  final SearchEngineProxy _searchEngine = SearchEngineProxy(offline: offline);
  final Completer<Place?> completer = Completer();

  _searchEngine.searchByPlaceIdWithLanguageCode(PlaceIdQuery(place.id), LanguageCode.enUs, (error, place) {
    if (error != null) {
      print('Search failed. Error: ${error.toString()}');
      completer.complete();
    }

    completer.complete(place);
  });

  Place? newPlace = await completer.future;

  if (newPlace == null) {
    newPlace = place;
  }

  return newPlace;
}

Widget _createPopupFromPlace(BuildContext context, Place place, bool routeToEnabled, bool addToRouteEnabled) {
  return SimpleDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(UIStyle.popupsBorderRadius)),
    ),
    titlePadding: EdgeInsets.zero,
    title: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(UIStyle.contentMarginLarge),
                child: Text(
                  place.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: UIStyle.hugeFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            left: UIStyle.contentMarginLarge,
            right: UIStyle.contentMarginLarge,
          ),
          child: Text(
            place.address.addressText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: UIStyle.bigFontSize,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
    children: [
      ...?_buildPhonesList(context, place),
      ...?_buildOpeningHours(place),
      ...?_buildURLsList(context, place),
      if (routeToEnabled || addToRouteEnabled)
        Padding(
          padding: EdgeInsets.only(
            top: UIStyle.contentMarginLarge,
            left: UIStyle.contentMarginLarge,
            right: UIStyle.contentMarginLarge,
          ),
          child: Row(
            children: [
              if (routeToEnabled) ...[
                Spacer(),
                _buildOptionButton(
                  context,
                  SvgPicture.asset(
                    "assets/route.svg",
                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                    width: UIStyle.smallIconSize,
                    height: UIStyle.smallIconSize,
                  ),
                  AppLocalizations.of(context)!.routeToButtonTitle,
                  () => Navigator.of(context).pop(PlaceDetailsPopupResult.routeTo),
                ),
              ],
              if (addToRouteEnabled) ...[
                Spacer(),
                _buildOptionButton(
                  context,
                  Icon(
                    Icons.add_location,
                    color: Theme.of(context).colorScheme.primary,
                    size: UIStyle.smallIconSize,
                  ),
                  AppLocalizations.of(context)!.addToRouteButton,
                  () => Navigator.of(context).pop(PlaceDetailsPopupResult.addToRoute),
                ),
              ],
              Spacer(),
            ],
          ),
        ),
    ],
  );
}

List<Widget>? _buildPhonesList(BuildContext context, Place place) {
  if (place.details.contacts.isEmpty) {
    return null;
  }

  List<ListTile> phoneWidgets = [
    ...place.details.contacts.first.landlinePhones.map((phone) => _buildPhoneTile(Icons.phone, phone.phoneNumber)),
    ...place.details.contacts.first.mobilePhones.map((phone) => _buildPhoneTile(Icons.phone_iphone, phone.phoneNumber)),
  ];

  return _convertToExpansionTile(phoneWidgets);
}

ListTile _buildPhoneTile(IconData icon, String phoneNumber) {
  return _buildInfoTile(icon, phoneNumber, () => launchUrl(Uri.parse("tel:" + phoneNumber)));
}

List<Widget>? _buildOpeningHours(Place place) {
  if (place.details.openingHours.isEmpty) {
    return null;
  }

  List<ListTile> openingHoursWidgets = [];
  place.details.openingHours.forEach((openingHours) =>
      openingHours.text.forEach((hour) => openingHoursWidgets.add(_buildInfoTile(Icons.access_time, hour, null))));

  return _convertToExpansionTile(openingHoursWidgets);
}

List<Widget>? _buildURLsList(BuildContext context, Place place) {
  if (place.details.contacts.isEmpty) {
    return null;
  }

  List<ListTile> urlsWidgets = place.details.contacts.first.websites.map((site) {
    return _buildInfoTile(Icons.language, site.address, () {
      launchUrl(
        Uri.parse(site.address),
        mode: LaunchMode.externalApplication,
      );
    });
  }).toList();

  return _convertToExpansionTile(urlsWidgets);
}

List<Widget>? _convertToExpansionTile(List<ListTile> tiles) {
  if (tiles.isEmpty) {
    return null;
  }

  return [
    ListTileTheme.merge(
      horizontalTitleGap: 0,
      child: tiles.length == 1
          ? tiles.first
          : ExpansionTile(
              leading: tiles.first.leading,
              title: InkWell(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: UIStyle.contentMarginLarge,
                    bottom: UIStyle.contentMarginLarge,
                  ),
                  child: tiles.first.title,
                ),
                onTap: tiles.first.onTap,
              ),
              children: tiles.sublist(1),
            ),
    ),
  ];
}

ListTile _buildInfoTile(IconData icon, String text, VoidCallback? onTap) => ListTile(
      leading: Icon(icon),
      title: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );

Widget _buildOptionButton(BuildContext context, Widget icon, String title, VoidCallback onPressed) =>
    SimpleDialogOption(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(UIStyle.bigButtonHeight),
        child: InkWell(
          borderRadius: BorderRadius.circular(UIStyle.bigButtonHeight),
          onTap: onPressed,
          child: Container(
            height: UIStyle.bigButtonHeight,
            child: Padding(
              padding: EdgeInsets.only(
                left: UIStyle.contentMarginLarge,
                right: UIStyle.contentMarginLarge,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  icon,
                  Container(
                    width: UIStyle.contentMarginMedium,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: UIStyle.bigFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
