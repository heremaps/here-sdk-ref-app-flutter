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

import 'package:RefApp/common/extensions/geo_box_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as Routing;
import 'package:provider/provider.dart';

import '../common/custom_map_style_settings.dart';
import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import '../navigation/navigation_screen.dart';
import 'route_info_widget.dart';
import 'waypoints_controller.dart';

/// Route details mode screen widget.
class RouteDetailsScreen extends StatefulWidget {
  /// Constructs a widget.
  RouteDetailsScreen({
    Key? key,
    required this.route,
    required this.wayPointsController,
  }) : super(key: key);

  static const String navRoute = "/routes/details";

  /// The route.
  final Routing.Route route;

  /// [WayPointsController] that contains way points for the route.
  final WayPointsController wayPointsController;

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  static const double _kBottomSheetHeaderSize = 75;
  static const double _kTapRadius = 5;
  static const double _kZoomDistanceToManeuver = 500;
  static const double _principalPointYFactor = 0.5;
  static const double _minBottomSheetExtent = 0.25;
  static const double _maxBottomSheetExtent = 0.75;
  static const double _initBottomSheetExtent = 0.25;
  static const double _paddingFactor = 0.2;

  final GlobalKey _bottomSheetKey = GlobalKey();
  final GlobalKey _mapKey = GlobalKey();
  final GlobalKey _scaffoldKey = GlobalKey();

  late HereMapController _hereMapController;
  late MapPolyline _mapRoute;
  List<MapMarker> _maneuverMarkers = [];
  List<Routing.Maneuver> _maneuvers = [];
  bool _hasBeenZoomedToManeuver = false;
  bool _maneuversSheetIsExpanded = false;
  Size? _mapSize;
  double? _mapHeight;

  @override
  void initState() {
    super.initState();
    widget.route.sections.forEach((section) {
      section.maneuvers.forEach((maneuver) => _maneuvers.add(maneuver));
    });
  }

  int get _markerSize => (_hereMapController.pixelScale * UIStyle.maneuverMarkerSize).round();

  void _onMapSceneLoaded(MapError? error) {
    if (error != null) {
      debugPrint('ERROR :: Map scene not loaded. MapError: ${error.toString()}');
      return;
    }
    final deviceHeight = MediaQuery.of(context).size.height;
    _addRouteToMap();
    _updatePrincipalPoint(bottomPanelHeight: deviceHeight * _minBottomSheetExtent);
    _updateWatermarkPosition(margin: _minBottomSheetExtent);
    // Implementing the tap listener to enable zooming into the selected maneuver.
    _setTapGestureHandler();
  }

  void _setTapGestureHandler() {
    _hereMapController.gestures.tapListener = TapListener(_pickMapMarker);
  }

  void _pickMapMarker(Point2D touchPoint) {
    _hereMapController.pickMapItems(touchPoint, _kTapRadius, (pickMapItemsResult) {
      List<MapMarker>? mapMarkersList = pickMapItemsResult?.markers;
      if (mapMarkersList == null || mapMarkersList.length == 0) {
        print("No map markers found.");
        return;
      }

      int index = _maneuverMarkers.indexOf(mapMarkersList.first);
      if (index >= 0) {
        _zoomToManeuver(index);
      }
    });
  }

  /// Update the camera to focus on the provided route and adjust the camera view
  /// to fit within the available space.
  void _updateCamera({required double bottomPanelHeight}) {
    final BuildContext? mapContext = _mapKey.currentContext;
    if (mapContext != null && mapContext.size != null) {
      final Size2D _mapRect = Size2D(mapContext.size!.width, mapContext.size!.height);
      _hereMapController.camera.lookAtAreaWithGeoOrientationAndViewRectangle(
        widget.route.boundingBox.expandedByPercentage(_paddingFactor),
        GeoOrientationUpdate(null, null),
        Rectangle2D(
          Point2D(0, _markerSize.toDouble()) * _hereMapController.pixelScale,
          Size2D(_mapRect.width, _mapRect.height - _markerSize - bottomPanelHeight) * _hereMapController.pixelScale,
        ),
      );
    }
  }

  void _updatePrincipalPoint({required double bottomPanelHeight}) {
    _mapSize = (context.findRenderObject() as RenderBox?)?.size;
    if (mounted && _mapSize != null) {
      final Point2D principalPoint = Point2D(
        _hereMapController.pixelScale * _mapSize!.width / 2,
        _hereMapController.pixelScale * ((_mapSize!.height - bottomPanelHeight)) * _principalPointYFactor,
      );
      _hereMapController.camera.principalPoint = principalPoint;
    }
  }

  void _updateWatermarkPosition({required double margin}) {
    _hereMapController.setWatermarkLocation(
      Anchor2D.withHorizontalAndVertical(1, 1 - margin),
      Point2D(0, -_hereMapController.watermarkSize.height / 2),
    );
  }

  void _addRouteToMap() {
    _mapRoute = MapPolyline(widget.route.geometry, UIStyle.routeLineWidth, UIStyle.selectedRouteColor);
    _mapRoute.outlineColor = UIStyle.selectedRouteBorderColor;
    _mapRoute.outlineWidth = UIStyle.routeOutLineWidth;
    _hereMapController.mapScene.addMapPolyline(_mapRoute);
    MapImage mapImage = MapImage.withFilePathAndWidthAndHeight("assets/maneuver.svg", _markerSize, _markerSize);
    widget.route.sections.forEach((section) {
      section.maneuvers.forEach((maneuver) {
        if (maneuver.action == Routing.ManeuverAction.depart || maneuver.action == Routing.ManeuverAction.arrive) {
          return;
        }
        MapMarker maneuverMarker = Util.createMarkerWithImage(
          maneuver.coordinates,
          mapImage,
          drawOrder: UIStyle.waypointsMarkerDrawOrder,
        );
        _hereMapController.mapScene.addMapMarker(maneuverMarker);
        _maneuverMarkers.add(maneuverMarker);
      });
    });

    widget.wayPointsController.buildMapMarkersForController(_hereMapController);
    _zoomToWholeRoute();
  }

  void _zoomToManeuver(int index) {
    _hereMapController.camera.lookAtPointWithMeasure(
      _maneuvers[index].coordinates,
      MapMeasure(MapMeasureKind.distance, _kZoomDistanceToManeuver),
    );
    setState(() => _hasBeenZoomedToManeuver = true);
  }

  void _zoomToWholeRoute() {
    final BuildContext? context = _mapKey.currentContext;
    if (context != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      _hereMapController.camera.principalPoint =
          Point2D(box.size.width, box.size.height) / 2 * _hereMapController.pixelScale;
      _hereMapController.zoomToLogicalViewPort(geoBox: widget.route.boundingBox, context: context);
    }
  }

  Widget _buildManeuverItem(BuildContext context, int index) {
    return ListTile(
      leading: SvgPicture.asset(_maneuvers[index].action.imagePath),
      title: Text(_maneuvers[index].text),
      onTap: () => _zoomToManeuver(index),
    );
  }

  /// Resets the bottom sheet position to init position
  void _resetIfBottomSheetIsExpanded() {
    if (_maneuversSheetIsExpanded) {
      DraggableScrollableActuator.reset(_bottomSheetKey.currentContext!);
      _hereMapController.setWatermarkLocation(
        Anchor2D.withHorizontalAndVertical(1, 1),
        Point2D(0, -_hereMapController.watermarkSize.height / 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasBeenZoomedToManeuver,
      onPopInvoked: (_) {
        // If the route is currently zoomed in on a maneuver, zoom out to the full route view.
        // Otherwise, go back to the previous screen.
        if (_hasBeenZoomedToManeuver) {
          _resetIfBottomSheetIsExpanded();
          _zoomToWholeRoute();
          setState(() => _hasBeenZoomedToManeuver = false);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomSheet: DraggableScrollableActuator(
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (DraggableScrollableNotification notification) {
              _maneuversSheetIsExpanded = notification.minExtent != notification.extent;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  final deviceHeight = MediaQuery.of(context).size.height;
                  _updateCamera(bottomPanelHeight: deviceHeight * notification.extent);
                  _updatePrincipalPoint(bottomPanelHeight: deviceHeight * notification.extent);
                  _updateWatermarkPosition(margin: notification.extent);
                });
              });
              return true;
            },
            child: DraggableScrollableSheet(
              key: _bottomSheetKey,
              expand: false,
              initialChildSize: _initBottomSheetExtent,
              minChildSize: _minBottomSheetExtent,
              maxChildSize: _maxBottomSheetExtent,
              builder: (BuildContext context, ScrollController scrollController) {
                return SafeArea(
                  child: CustomScrollView(
                    controller: scrollController,
                    semanticChildCount: _maneuvers.length,
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _HeaderBuildDelegate(
                          route: widget.route,
                          controller: widget.wayPointsController,
                          extent: _kBottomSheetHeaderSize,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final int itemIndex = index ~/ 2;
                            return index.isEven ? _buildManeuverItem(context, itemIndex) : Divider(height: 1);
                          },
                          semanticIndexCallback: (Widget widget, int localIndex) {
                            if (localIndex.isEven) {
                              return localIndex ~/ 2;
                            }
                            return null;
                          },
                          childCount: _maneuvers.length * 2 - 1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: _mapHeight ?? 0),
          child: HereMap(
            key: _mapKey,
            onMapCreated: (HereMapController mapController) {
              _hereMapController = mapController;
              CustomMapStyleSettings customMapStyleSettings = Provider.of<CustomMapStyleSettings>(
                context,
                listen: false,
              );
              Util.loadMapScene(customMapStyleSettings, _hereMapController, _onMapSceneLoaded);
            },
          ),
        ),
      ),
    );
  }
}

extension _ManeuverImagePath on Routing.ManeuverAction {
  String get imagePath {
    return "assets/maneuvers/dark/" + toString().split(".").last + ".svg";
  }
}

class _HeaderBuildDelegate extends SliverPersistentHeaderDelegate {
  _HeaderBuildDelegate({
    required this.route,
    required this.controller,
    required this.extent,
  });

  final WayPointsController controller;
  final double extent;
  final Routing.Route route;

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => extent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Material(
        color: Theme.of(context).cardColor,
        elevation: shrinkOffset == 0 ? 0 : 2,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: UIStyle.contentMarginLarge,
                right: UIStyle.contentMarginLarge,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            Expanded(
              child: RouteInfo(
                route: route,
                onNavigation: () => Navigator.of(context).pushNamed(
                  NavigationScreen.navRoute,
                  arguments: [route, controller.value],
                ),
              ),
            ),
          ],
        ),
      );
}
