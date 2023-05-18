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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/gestures.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as Routing;
import 'package:provider/provider.dart';

import '../common/custom_map_style_settings.dart';
import '../common/draggable_popup_here_logo_helper.dart';
import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import '../navigation/navigation_screen.dart';
import 'route_info_widget.dart';
import 'waypoints_controller.dart';

/// Route details mode screen widget.
class RouteDetailsScreen extends StatefulWidget {
  static const String navRoute = "/routes/details";

  /// The route.
  final Routing.Route route;

  /// [WayPointsController] that contains way points for the route.
  final WayPointsController wayPointsController;

  /// Constructs a widget.
  RouteDetailsScreen({
    Key? key,
    required this.route,
    required this.wayPointsController,
  }) : super(key: key);

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

extension _ManeuverImagePath on Routing.ManeuverAction {
  String get imagePath {
    return "assets/maneuvers/dark/" + toString().split(".").last + ".svg";
  }
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  final GlobalKey _mapKey = GlobalKey();
  final GlobalKey _scaffoldKey = GlobalKey();
  final GlobalKey _bottomSheetKey = GlobalKey();

  static const double _kBottomSheetMinSize = 200;
  static const double _kBottomSheetHeaderSize = 75;
  static const double _kZoomDistanceToManeuver = 500;
  static const double _kTapRadius = 5;

  late HereMapController _hereMapController;
  bool _mapInitSuccess = false;
  late MapPolyline _mapRoute;
  List<MapMarker> _maneuverMarkers = [];
  List<Routing.Maneuver> _maneuvers = [];

  bool _hasBeenZoomedToManeuver = false;
  bool _maneuversSheetIsExpanded = false;

  @override
  void initState() {
    super.initState();
    widget.route.sections.forEach((section) => section.maneuvers.forEach((maneuver) => _maneuvers.add(maneuver)));
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (_hasBeenZoomedToManeuver) {
            if (_maneuversSheetIsExpanded) {
              DraggableScrollableActuator.reset(_bottomSheetKey.currentContext!);
              _hereMapController.setWatermarkLocation(
                Anchor2D.withHorizontalAndVertical(0.5, 1),
                Point2D(0, -_hereMapController.watermarkSize.height / 2),
              );
            }

            _zoomToWholeRoute();
            _hasBeenZoomedToManeuver = false;
            return false;
          }

          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          body: Column(
            children: [
              Expanded(
                child: HereMap(
                  key: _mapKey,
                  options: HereMapOptions.fromColor(Theme.of(context).colorScheme.background),
                  onMapCreated: _onMapCreated,
                ),
              ),
              Container(
                height: _kBottomSheetMinSize,
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          extendBody: true,
          bottomNavigationBar: _mapInitSuccess ? _buildBottomSheet(context) : null,
        ),
      );

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;

    CustomMapStyleSettings customMapStyleSettings = Provider.of<CustomMapStyleSettings>(context, listen: false);

    MapSceneLoadSceneCallback mapSceneLoadSceneCallback = (MapError? error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }

      hereMapController.setWatermarkLocation(
        Anchor2D.withHorizontalAndVertical(0.5, 1),
        Point2D(0, -hereMapController.watermarkSize.height / 2),
      );
      _addRouteToMap();
      _setTapGestureHandler();
      setState(() => _mapInitSuccess = true);
    };

    Util.loadMapScene(customMapStyleSettings, hereMapController, mapSceneLoadSceneCallback);
  }

  void _setTapGestureHandler() {
    _hereMapController.gestures.tapListener = TapListener((Point2D touchPoint) => _pickMapMarker(touchPoint));
  }

  _pickMapMarker(Point2D touchPoint) {
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

  _addRouteToMap() {
    _mapRoute = MapPolyline(widget.route.geometry, UIStyle.routeLineWidth, UIStyle.selectedRouteColor);
    _mapRoute.outlineColor = UIStyle.selectedRouteBorderColor;
    _mapRoute.outlineWidth = UIStyle.routeOutLineWidth;

    _hereMapController.mapScene.addMapPolyline(_mapRoute);

    int markerSize = (_hereMapController.pixelScale * UIStyle.maneuverMarkerSize).round();
    MapImage mapImage = MapImage.withFilePathAndWidthAndHeight("assets/maneuver.svg", markerSize, markerSize);

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

  _zoomToManeuver(int index) {
    _hereMapController.camera.lookAtPointWithMeasure(
      _maneuvers[index].coordinates,
      MapMeasure(MapMeasureKind.distance, _kZoomDistanceToManeuver),
    );
    _hasBeenZoomedToManeuver = true;
  }

  _zoomToWholeRoute() {
    final BuildContext? context = _mapKey.currentContext;
    if (context != null) {
      final RenderBox box = context.findRenderObject() as RenderBox;

      _hereMapController.camera.principalPoint =
          Point2D(box.size.width, box.size.height) / 2 * _hereMapController.pixelScale;
      _hereMapController.zoomToLogicalViewPort(geoBox: widget.route.boundingBox, context: context);
    }
  }

  _updateMapPrincipalPoint() {
    final RenderBox? mapBox = _mapKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox? bottomSheetBox = _bottomSheetKey.currentContext?.findRenderObject() as RenderBox;

    if (mapBox != null && bottomSheetBox != null) {
      _hereMapController.camera.principalPoint =
          Point2D(mapBox.size.width, mapBox.size.height + _kBottomSheetMinSize - bottomSheetBox.size.height) /
              2 *
              _hereMapController.pixelScale;
    }
  }

  Widget _buildManeuverItem(BuildContext context, int index) {
    return ListTile(
      leading: SvgPicture.asset(_maneuvers[index].action.imagePath),
      title: Text(_maneuvers[index].text),
      onTap: () => _zoomToManeuver(index),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    double minSize = _kBottomSheetMinSize / MediaQuery.of(context).size.height;

    return BottomSheet(
      onClosing: () {},
      builder: (context) => NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          _maneuversSheetIsExpanded = notification.minExtent != notification.extent;
          _updateMapPrincipalPoint();
          return true;
        },
        child: DraggableScrollableActuator(
          child: DraggablePopupHereLogoHelper(
            hereMapController: _hereMapController,
            hereMapKey: _mapKey,
            draggableScrollableSheet: DraggableScrollableSheet(
              key: _bottomSheetKey,
              maxChildSize: UIStyle.maxBottomDraggableSheetSize,
              initialChildSize: minSize,
              minChildSize: minSize,
              expand: false,
              builder: (context, controller) => SafeArea(
                child: CustomScrollView(
                  controller: controller,
                  semanticChildCount: _maneuvers.length,
                  slivers: [
                    SliverPersistentHeader(
                      delegate: _HeaderBuildDelegate(
                        route: widget.route,
                        controller: widget.wayPointsController,
                        extent: _kBottomSheetHeaderSize,
                      ),
                      pinned: true,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final int itemIndex = index ~/ 2;
                          return index.isEven
                              ? _buildManeuverItem(context, itemIndex)
                              : Divider(
                                  height: 1,
                                );
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBuildDelegate extends SliverPersistentHeaderDelegate {
  final Routing.Route route;
  final WayPointsController controller;
  final double extent;

  _HeaderBuildDelegate({
    required this.route,
    required this.controller,
    required this.extent,
  });

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

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => extent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
