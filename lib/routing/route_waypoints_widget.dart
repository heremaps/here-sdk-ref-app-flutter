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
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk_reference_application_flutter/common/draggable_popup_here_logo_helper.dart';

import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import '../search/search_popup.dart';
import 'route_waypoints_list.dart';
import 'waypoint_info.dart';
import 'waypoints_controller.dart';

typedef QueryCurrentLocationCallback = GeoCoordinates Function();

/// A widget that displays the route start and destination waypoints.
class RouteWayPoints extends StatefulWidget {
  /// Waypoints controller.
  final WayPointsController controller;

  /// Map controller.
  final HereMapController hereMapController;

  /// Key of the current map.
  final GlobalKey hereMapKey;

  /// Title of the current location.
  final String currentLocationTitle;

  /// Creates a widget.
  RouteWayPoints({
    Key? key,
    required this.controller,
    required this.hereMapController,
    required this.hereMapKey,
    required this.currentLocationTitle,
  }) : super(key: key);

  @override
  _RouteWayPointsState createState() => _RouteWayPointsState();
}

class _RouteWayPointsState extends State<RouteWayPoints> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    bool displayCurrentLocationButton = widget.controller.value.fold(true,
        (previousValue, element) => previousValue && element.sourceType != WayPointInfoSourceType.CurrentPosition);

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWayPointItem(context, 0, displayCurrentLocationButton),
              Divider(
                height: 1,
              ),
              _buildWayPointItem(context, widget.controller.length - 1, displayCurrentLocationButton),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: widget.controller.length > 2
              ? IconButton(
                  padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                  icon: Icon(
                    Icons.list,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => _showWayPointsEditPopup(context),
                )
              : IconButton(
                  padding: EdgeInsets.all(UIStyle.contentMarginMedium),
                  icon: Icon(
                    Icons.swap_vert,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => setState(
                      () => widget.controller.value = widget.controller.value.swap(0, widget.controller.length - 1)),
                ),
        ),
      ],
    );
  }

  Widget _buildWayPointItem(BuildContext context, int index, bool displayCurrentLocationButton) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final WayPointInfo wayPoint = widget.controller[index];
    bool isCurrent = wayPoint.sourceType == WayPointInfoSourceType.CurrentPosition;

    return ListTile(
      dense: true,
      leading: Icon(
        isCurrent ? Icons.gps_fixed : Icons.location_on_rounded,
        color: colorScheme.primary,
        size: UIStyle.mediumIconSize,
      ),
      title: Text(
        isCurrent ? widget.currentLocationTitle : wayPoint.title,
        style: TextStyle(
          fontSize: UIStyle.bigFontSize,
          color: isCurrent ? colorScheme.secondary : colorScheme.primary,
        ),
      ),
      onTap: () async {
        GeoCoordinates currentPosition = widget.controller.currentLocation;
        final result = await showSearchPopup(
          context: context,
          currentPosition: currentPosition,
          hereMapController: widget.hereMapController,
          hereMapKey: widget.hereMapKey,
          currentLocationTitle: displayCurrentLocationButton || isCurrent ? widget.currentLocationTitle : null,
        );
        if (result != null) {
          setState(() {
            SearchResult searchResult = result;
            if (searchResult.place != null) {
              widget.controller[index] = WayPointInfo.withPlace(
                place: searchResult.place,
              );
            } else {
              widget.controller[index] = WayPointInfo(
                coordinates: currentPosition,
              );
            }
          });
        }
      },
    );
  }

  void _showWayPointsEditPopup(BuildContext context) async {
    List<WayPointInfo> wayPoints = widget.controller.value;

    await showModalBottomSheet(
      context: context,
      shape: UIStyle.topRoundedBorder(),
      isScrollControlled: true,
      builder: (context) => DraggablePopupHereLogoHelper(
        hereMapController: widget.hereMapController,
        hereMapKey: widget.hereMapKey,
        modal: true,
        draggableScrollableSheet: DraggableScrollableSheet(
          maxChildSize: UIStyle.maxBottomDraggableSheetSize,
          initialChildSize: 0.5,
          minChildSize: 0.5,
          expand: false,
          builder: (context, controller) => RouteWayPointsList(
            wayPoints: wayPoints,
            controller: controller,
            onChanged: (value) => wayPoints = value,
            currentLocationTitle: widget.currentLocationTitle,
          ),
        ),
      ),
    );

    widget.hereMapController.setWatermarkLocation(
      Anchor2D.withHorizontalAndVertical(0, 1),
      Point2D(
        -widget.hereMapController.watermarkSize.width / 2,
        -widget.hereMapController.watermarkSize.height / 2,
      ),
    );
    widget.controller.value = wayPoints;
  }
}
