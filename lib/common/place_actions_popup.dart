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
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.threading.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/search.dart';
import 'package:provider/provider.dart';

import '../search/search_engine_proxy.dart';
import 'application_preferences.dart';
import 'ui_style.dart';
import 'util.dart' as Util;

typedef PlaceActionCallback = void Function(Place? place);

/// A widget that displays a pop-up window for creating a waypoint from a point on the map.
class PlaceActionsPopup extends StatefulWidget {
  /// Coordinates of the point on the map.
  final GeoCoordinates coordinates;

  /// Map controller.
  final HereMapController hereMapController;

  /// Called when the right button is tapped or otherwise activated.
  final PlaceActionCallback onRightButtonPressed;

  /// Right button icon.
  final Widget rightButtonIcon;

  /// Called when the left button is tapped or otherwise activated.
  final PlaceActionCallback? onLeftButtonPressed;

  /// Left button icon.
  final Widget? leftButtonIcon;

  /// Creates a widget.
  PlaceActionsPopup({
    Key? key,
    required this.hereMapController,
    required this.coordinates,
    required this.onRightButtonPressed,
    this.rightButtonIcon = const Icon(
      Icons.add,
      color: UIStyle.addWayPointPopupForegroundColor,
    ),
    this.onLeftButtonPressed = null,
    this.leftButtonIcon = null,
  })  : assert((onLeftButtonPressed == null) == (leftButtonIcon == null)),
        super(key: key);

  @override
  _PlaceActionsPopupState createState() => _PlaceActionsPopupState();
}

class _PlaceActionsPopupState extends State<PlaceActionsPopup> {
  static const double _kMaxPopupWidth = 150;

  final SearchOptions _searchOptions = SearchOptions()
    ..languageCode = LanguageCode.enUs
    ..maxItems = 1;
  late SearchEngineProxy _searchEngine;
  late TaskHandle _searchTask;
  late String _title;
  Place? _place;
  late MapMarker _mapMarker;

  @override
  void initState() {
    super.initState();
    _searchEngine = SearchEngineProxy(offline: Provider.of<AppPreferences>(context, listen: false).useAppOffline);
    _searchTask = _searchEngine.searchByCoordinates(widget.coordinates, _searchOptions, _onSearchEnd);
    _title = widget.coordinates.toPrettyString();
    int markerSize = (widget.hereMapController.pixelScale * UIStyle.searchMarkerSize * 2).round();
    _mapMarker = Util.createMarkerWithImagePath(
      widget.coordinates,
      "assets/map_marker_wp.svg",
      markerSize,
      markerSize,
      drawOrder: UIStyle.waypointsMarkerDrawOrder,
      anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
    );
    widget.hereMapController.mapScene.addMapMarker(_mapMarker);
  }

  @override
  void dispose() {
    _searchTask.cancel();
    widget.hereMapController.mapScene.removeMapMarker(_mapMarker);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: UIStyle.addWayPointPopupBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(UIStyle.popupsBorderRadius)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onLeftButtonPressed != null)
                  IconButton(
                    icon: widget.leftButtonIcon!,
                    onPressed: () {
                      widget.onLeftButtonPressed!(_place);
                      _place = null;
                    },
                  ),
                Padding(
                  padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _kMaxPopupWidth,
                    ),
                    child: Text(
                      _title,
                      style: TextStyle(
                        color: UIStyle.addWayPointPopupForegroundColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: widget.rightButtonIcon,
                  onPressed: () {
                    widget.onRightButtonPressed(_place);
                    _place = null;
                  },
                ),
              ],
            ),
          ),
          Container(
            height: UIStyle.searchMarkerSize * 2.0 + UIStyle.contentMarginMedium,
          ),
        ],
      );

  void _onSearchEnd(SearchError? error, List<Place>? places) {
    if (error != null) {
      print('Search failed. Error: ${error.toString()}');
    }
    if (places == null || places.isEmpty) {
      return;
    }

    setState(() {
      _place = places.first;
      _title = places.first.address.addressText;
    });
  }
}
