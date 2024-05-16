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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reorderables/reorderables.dart';

import '../common/ui_style.dart';
import 'waypoint_info.dart';

/// Widget for displaying and editing the list of waypoints of the route.
class RouteWayPointsList extends StatefulWidget {
  /// A waypoints list.
  final List<WayPointInfo> wayPoints;

  /// Parent scroll controller.
  final ScrollController? controller;

  /// Called when the list of waypoints is changed.
  final ValueChanged<List<WayPointInfo>> onChanged;

  /// Title of the current location.
  final String currentLocationTitle;

  /// Creates a widget.
  RouteWayPointsList({
    Key? key,
    required this.wayPoints,
    this.controller,
    required this.onChanged,
    required this.currentLocationTitle,
  }) : super(key: key);

  @override
  _RouteWayPointsListState createState() => _RouteWayPointsListState();
}

class _RouteWayPointsListState extends State<RouteWayPointsList> {
  late List<WayPointInfo> _wayPoints;

  @override
  void initState() {
    super.initState();
    _wayPoints = widget.wayPoints.toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      slivers: [
        SliverAppBar(
          leading: Container(),
          shape: UIStyle.topRoundedBorder(),
          leadingWidth: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          pinned: true,
          titleSpacing: 0,
          title: _buildHeader(context),
        ),
        ReorderableSliverList(
          delegate: ReorderableSliverChildBuilderDelegate(
            (context, index) {
              if (index.isOdd) {
                return Divider(
                  height: 1,
                );
              }

              return _buildItem(context, index ~/ 2);
            },
            semanticIndexCallback: (Widget widget, int localIndex) {
              if (localIndex.isEven) {
                return localIndex ~/ 2;
              }
              return null;
            },
            childCount: _wayPoints.length * 2 - 1,
          ),
          onReorder: (oldIndex, newIndex) {
            setState(() => _wayPoints.insert(newIndex ~/ 2, _wayPoints.removeAt(oldIndex ~/ 2)));
            widget.onChanged(_wayPoints);
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) => Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.wayPointsListTitle,
              style: TextStyle(
                fontSize: UIStyle.hugeFontSize,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      );

  Widget _buildItem(BuildContext context, int index) {
    WayPointInfo wp = _wayPoints[index];
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    bool isCurrent = wp.sourceType == WayPointInfoSourceType.CurrentPosition;

    Widget itemTile = ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_handle,
            color: colorScheme.primary,
            size: UIStyle.mediumIconSize,
          ),
          Container(
            width: UIStyle.contentMarginLarge,
          ),
          Icon(
            isCurrent ? Icons.gps_fixed : Icons.location_on_rounded,
            color: colorScheme.primary,
            size: UIStyle.mediumIconSize,
          ),
        ],
      ),
      title: Text(
        isCurrent ? widget.currentLocationTitle : wp.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isCurrent ? colorScheme.secondary : colorScheme.primary,
        ),
      ),
    );

    if (_wayPoints.length <= 2) {
      return itemTile;
    }

    List<Widget> dismissBackgroundItems = [
      Container(
        width: UIStyle.contentMarginLarge,
      ),
      Icon(
        Icons.delete,
        color: UIStyle.removeWayPointIconColor,
      ),
      Spacer(),
    ];

    return Dismissible(
      key: ObjectKey(wp),
      background: Container(
        color: UIStyle.removeWayPointBackgroundColor,
        child: Row(
          children: dismissBackgroundItems,
        ),
      ),
      secondaryBackground: Container(
        color: UIStyle.removeWayPointBackgroundColor,
        child: Row(
          children: dismissBackgroundItems.reversed.toList(),
        ),
      ),
      onDismissed: (direction) async {
        setState(() => _wayPoints.removeAt(index));
        widget.onChanged(_wayPoints);
      },
      child: itemTile,
    );
  }
}
