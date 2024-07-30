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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:here_sdk/maploader.dart';
import 'package:here_sdk_reference_application_flutter/common/extensions/error_handling/map_loader_error_extension.dart';
import 'package:here_sdk_reference_application_flutter/common/extensions/region_extensions.dart';
import 'package:provider/provider.dart';

import 'map_loader_controller.dart';
import 'map_loader_dialogs.dart';
import 'map_region_tile_widget.dart';

class _ParentRegion extends Region {
  _ParentRegion.fromRegion(Region region) : super(region.regionId) {
    name = region.name;
    sizeOnDiskInBytes = region.sizeOnDiskInBytes;
    sizeOnNetworkInBytes = region.sizeOnNetworkInBytes;
    this.childRegions = region.childRegions;
  }
}

/// Map regions list screen widget.
class MapRegionsListScreen extends StatefulWidget {
  static const String navRoute = "/download_maps/regions";

  /// List of regions to display.
  final List<Region> regions;

  MapRegionsListScreen({
    Key? key,
    required this.regions,
  }) : super(key: key);

  @override
  _MapRegionsListScreenState createState() => _MapRegionsListScreenState();
}

class _MapRegionsListScreenState extends State<MapRegionsListScreen> {
  @override
  Widget build(BuildContext context) => Consumer<MapLoaderController>(
        builder: (context, model, child) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(AppLocalizations.of(context)!.downloadMapsTitle),
          ),
          body: _buildRegionsList(context),
        ),
      );

  Widget _buildRegionsList(context) {
    return ListView.separated(
      itemBuilder: _buildRegionTile,
      separatorBuilder: (context, index) => Divider(),
      itemCount: widget.regions.length,
    );
  }

  Widget _buildRegionTile(BuildContext context, int index) {
    Region region = widget.regions[index];
    MapLoaderController controller = Provider.of<MapLoaderController>(
      context,
      listen: false,
    );
    InstalledRegion? installedRegion;
    try {
      installedRegion = controller.getInstalledRegions().where((element) {
        return element.regionId == region.regionId;
      }).firstOrNull;
    } on MapLoaderExceptionException catch (error) {
      print(error.error.errorMessage(AppLocalizations.of(context)!));
    }
    bool hasChildren = region.childRegions != null;
    int? progress = controller.getDownloadProgress(region.regionId);
    bool hasParentRegion = widget.regions.any((element) => element is _ParentRegion);
    return MapRegionTile(
      region: widget.regions[index],
      installedRegion: installedRegion,
      isHeader: region is _ParentRegion,
      isChild: hasParentRegion && region is! _ParentRegion,
      downloadProgress: progress,
      onTap: () => progress != null
          ? _cancelDownload(controller, region)
          : hasChildren && region is! _ParentRegion
              ? _openChildRegions(region)
              : installedRegion?.status != InstalledRegionStatus.installed
                  ? controller.downloadRegion(region.regionId)
                  : null,
    );
  }

  void _cancelDownload(MapLoaderController controller, Region region) {
    controller.cancelDownloadWithConfirmation(
      context,
      region,
      //  If the canceled tile is a Parent/Header tile,
      //  we can utilize [childRegionIds] to cancel all associated child region downloads.
      //  Alternatively, if the canceled tile is a child tile with its own children,
      //  we pass their region IDs to cancel the respective downloads for those children as well.
      region.childRegions.regionIds(),
    );
  }

  void _openChildRegions(Region region) {
    List<Region> regions = [_ParentRegion.fromRegion(region), ...?region.childRegions];

    Navigator.of(context).pushNamed(
      MapRegionsListScreen.navRoute,
      arguments: [regions],
    );
  }
}
