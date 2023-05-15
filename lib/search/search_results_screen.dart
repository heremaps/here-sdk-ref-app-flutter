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
import 'package:here_sdk/search.dart';
import 'package:provider/provider.dart';

import '../common/custom_map_style_settings.dart';
import "../common/draggable_popup_here_logo_helper.dart";
import '../common/reset_location_button.dart';
import '../positioning/positioning.dart';
import '../common/ui_style.dart';
import '../common/util.dart' as Util;
import 'place_details_popup.dart';

/// Search results screen widget.
class SearchResultsScreen extends StatefulWidget {
  static const String navRoute = "/search/results";

  /// Original query string.
  final String queryString;

  /// Resulting list of places.
  final List<Place> places;

  /// Current position.
  final GeoCoordinates currentPosition;

  /// Creates a widget.
  SearchResultsScreen({
    Key? key,
    required this.queryString,
    required this.places,
    required this.currentPosition,
  }) : super(key: key);

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> with TickerProviderStateMixin, Positioning {
  static const double _kZoomDistanceToEarth = 1000; // meters
  static const double _kTapRadius = 3; // pixels
  static const double _kPlaceCardHeight = 80;

  final GlobalKey _bottomBarKey = GlobalKey();
  final GlobalKey _hereMapKey = GlobalKey();

  late HereMapController _hereMapController;

  late MapImage _smallMarkerImage;
  late MapImage _bigMarkerImage;
  late List<MapMarker> _markers;
  late TabController _tabController;
  int _selectedIndex = -1;

  @override
  void initState() {
    _tabController = TabController(
      length: widget.places.length,
      vsync: this,
    );
    _tabController.addListener(() => _updateSelectedPlace());
    enableMapUpdate = false;
    super.initState();
  }

  @override
  void dispose() {
    stopPositioning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: widget.places.length,
        child: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop(_hereMapController.camera.state.targetCoordinates);
            return false;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: HereMap(
              key: _hereMapKey,
              onMapCreated: _onMapCreated,
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context),
            extendBodyBehindAppBar: true,
            floatingActionButton: enableMapUpdate
                ? null
                : ResetLocationButton(
                    onPressed: _resetCurrentPosition,
                  ),
          ),
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
        Anchor2D.withHorizontalAndVertical(0, 1),
        Point2D(
          -hereMapController.watermarkSize.width / 2,
          -hereMapController.watermarkSize.height / 2,
        ),
      );

      hereMapController.camera.lookAtPointWithGeoOrientationAndMeasure(
        widget.currentPosition,
        GeoOrientationUpdate(double.nan, double.nan),
        MapMeasure(MapMeasureKind.distance, Positioning.initDistanceToEarth),
      );
      _addPanListener();
      _createResultsMarkers();
      _setTapGestureHandler();

      initPositioning(
        context: context,
        hereMapController: hereMapController,
      );
    };

    Util.loadMapScene(customMapStyleSettings, hereMapController, mapSceneLoadSceneCallback);
  }

  void _addPanListener() {
    _hereMapController.gestures.panListener = PanListener((state, origin, translation, velocity) {
      if (enableMapUpdate) {
        setState(() => enableMapUpdate = false);
      }
    });
  }

  void _resetCurrentPosition() {
    GeoCoordinates coordinates = lastKnownLocation != null ? lastKnownLocation!.coordinates : widget.currentPosition;

    _hereMapController.camera.lookAtPointWithGeoOrientationAndMeasure(
      coordinates,
      GeoOrientationUpdate(double.nan, double.nan),
      MapMeasure(MapMeasureKind.distance, Positioning.initDistanceToEarth),
    );
    setState(() => enableMapUpdate = true);
  }

  void _setTapGestureHandler() {
    _hereMapController.gestures.tapListener = TapListener((Point2D touchPoint) => _pickMapMarker(touchPoint));
  }

  void _pickMapMarker(Point2D touchPoint) {
    _hereMapController.pickMapItems(touchPoint, _kTapRadius, (pickMapItemsResult) {
      List<MapMarker>? mapMarkerList = pickMapItemsResult?.markers;
      if (mapMarkerList == null || mapMarkerList.length == 0) {
        print("No map markers found.");
        return;
      }

      int index = _markers.indexOf(mapMarkerList.first);
      _tabController.animateTo(index);
      _showPlaceDetailsPopup(context, widget.places[index]);
    });
  }

  void _updateSelectedPlace() {
    if (_selectedIndex >= 0) {
      _markers[_selectedIndex].image = _smallMarkerImage;
      _markers[_selectedIndex].drawOrder = UIStyle.searchMarkerDrawOrder;
    }

    _markers[_tabController.index].image = _bigMarkerImage;
    _markers[_tabController.index].drawOrder = UIStyle.waypointsMarkerDrawOrder;

    _selectedIndex = _tabController.index;
    _zoomToPlace(_selectedIndex);
    if (enableMapUpdate) {
      setState(() => enableMapUpdate = false);
    }
  }

  void _zoomToPlace(int index) {
    _hereMapController.camera.lookAtPointWithMeasure(
      widget.places[index].geoCoordinates!,
      MapMeasure(MapMeasureKind.distance, _kZoomDistanceToEarth),
    );
  }

  void _createResultsMarkers() {
    assert(widget.places.isNotEmpty);

    int markerSize = (_hereMapController.pixelScale * UIStyle.searchMarkerSize).truncate();
    _smallMarkerImage = MapImage.withFilePathAndWidthAndHeight("assets/map_marker.svg", markerSize, markerSize);
    _bigMarkerImage =
        MapImage.withFilePathAndWidthAndHeight("assets/map_marker_big.svg", markerSize * 2, markerSize * 2);
    _markers = <MapMarker>[];

    for (int i = 0; i < widget.places.length; ++i) {
      MapMarker mapMarker = Util.createMarkerWithImage(
        widget.places[i].geoCoordinates!,
        _smallMarkerImage,
        anchor: Anchor2D.withHorizontalAndVertical(0.5, 1),
      );

      _markers.add(mapMarker);
      _hereMapController.mapScene.addMapMarker(mapMarker);
    }

    _updateSelectedPlace();

    if (widget.places.length == 1) {
      _hereMapController.camera.lookAtPointWithMeasure(
        widget.places.first.geoCoordinates!,
        MapMeasure(MapMeasureKind.distance, Positioning.initDistanceToEarth),
      );
    } else {
      GeoBox? geoBox = GeoBox.containingGeoCoordinates(widget.places.map((e) => e.geoCoordinates!).toList());

      if (geoBox != null && _bottomBarKey.currentContext != null) {
        final RenderBox bottomBarBox = _bottomBarKey.currentContext!.findRenderObject() as RenderBox;
        final double topOffset = MediaQuery.of(context).padding.top;

        _hereMapController.zoomGeoBoxToLogicalViewPort(
            geoBox: geoBox,
            viewPort: Rect.fromLTRB(
                0, topOffset, bottomBarBox.size.width, MediaQuery.of(context).size.height - bottomBarBox.size.height));
      }
    }
  }

  Widget _buildPlacesTabs(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(UIStyle.contentMarginSmall),
      child: Container(
        width: double.infinity,
        height: _kPlaceCardHeight,
        child: TabBarView(
          controller: _tabController,
          children: widget.places
              .map((place) => Card(
                    elevation: 2,
                    key: UniqueKey(),
                    child: _buildPlaceTile(context, place, null),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildNavigationHeader(BuildContext context, bool expanded) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_hereMapController.camera.state.targetCoordinates),
        ),
        Expanded(
          child: Text(
            widget.queryString,
            style: TextStyle(
              fontSize: UIStyle.hugeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (widget.places.length > 1)
          IconButton(
            icon: Icon(
              expanded ? Icons.expand_more : Icons.expand_less,
            ),
            onPressed: expanded ? () => Navigator.of(context).pop() : () => _showResultsList(context),
          ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      key: _bottomBarKey,
      color: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavigationHeader(context, false),
          _buildPlacesTabs(context),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(BuildContext context, Place place, int? index) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(left: UIStyle.contentMarginExtraSmall),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              color: _selectedIndex == index ? colorScheme.secondary : Colors.transparent,
              width: UIStyle.contentMarginExtraSmall),
        ),
      ),
      child: ListTile(
        tileColor: _selectedIndex == index ? UIStyle.selectedListTileColor : null,
        title: Text(
          place.title,
          style: TextStyle(fontSize: UIStyle.hugeFontSize),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(
            top: UIStyle.contentMarginSmall,
            bottom: UIStyle.contentMarginSmall,
          ),
          child: RichText(
            text: TextSpan(
                text: Util.makeDistanceString(context, place.distanceInMeters),
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: UIStyle.bigFontSize,
                ),
                children: [
                  TextSpan(
                    text: place.address.addressText,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: ClipOval(
          child: Material(
            child: Ink(
              width: UIStyle.smallButtonHeight,
              height: UIStyle.smallButtonHeight,
              color: colorScheme.background,
              child: InkWell(
                child: Center(
                  child: SvgPicture.asset(
                    "assets/route.svg",
                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSecondary, BlendMode.srcIn),
                    width: UIStyle.smallIconSize,
                    height: UIStyle.smallIconSize,
                  ),
                ),
                onTap: () {
                  if (index != null) {
                    // close bottom sheet
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context).pop(place);
                },
              ),
            ),
          ),
        ),
        onTap: index != null
            ? () {
                Navigator.of(context).pop();
                _tabController.animateTo(index);
              }
            : () => _showPlaceDetailsPopup(context, place),
      ),
    );
  }

  void _showPlaceDetailsPopup(BuildContext context, Place place) async {
    final PlaceDetailsPopupResult? result = await showPlaceDetailsPopup(
      context: context,
      place: place,
      routeToEnabled: true,
    );
    if (result == PlaceDetailsPopupResult.routeTo) {
      Navigator.of(context).pop(place);
    }
  }

  _showResultsList(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: UIStyle.topRoundedBorder(),
      builder: (context) => DraggablePopupHereLogoHelper(
        hereMapController: _hereMapController,
        hereMapKey: _hereMapKey,
        modal: true,
        draggableScrollableSheet: DraggableScrollableSheet(
          maxChildSize: UIStyle.maxBottomDraggableSheetSize,
          initialChildSize: 0.6,
          expand: false,
          builder: (context, controller) => CustomScrollView(
            semanticChildCount: widget.places.length,
            controller: controller,
            slivers: [
              SliverAppBar(
                leading: Container(),
                shape: UIStyle.topRoundedBorder(),
                leadingWidth: 0,
                backgroundColor: Theme.of(context).colorScheme.background,
                pinned: true,
                titleSpacing: 0,
                title: _buildNavigationHeader(context, true),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final int itemIndex = index ~/ 2;
                    return index.isEven
                        ? _buildPlaceTile(context, widget.places[itemIndex], itemIndex)
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
                  childCount: widget.places.length * 2 - 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    _hereMapController.setWatermarkLocation(
      Anchor2D.withHorizontalAndVertical(0, 1),
      Point2D(
        -_hereMapController.watermarkSize.width / 2,
        -_hereMapController.watermarkSize.height / 2,
      ),
    );
  }
}
