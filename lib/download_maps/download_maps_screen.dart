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
import 'package:here_sdk/maploader.dart';
import 'package:here_sdk_reference_application_flutter/common/extensions/error_handling/map_loader_error_extension.dart';
import 'package:here_sdk_reference_application_flutter/common/extensions/region_extensions.dart';
import 'package:provider/provider.dart';

import '../common/error_toast.dart';
import '../common/gradient_elevated_button.dart';
import '../common/ui_style.dart';
import 'map_loader_controller.dart';
import 'map_loader_dialogs.dart';
import 'map_region_tile_widget.dart';
import 'map_regions_list_screen.dart';
import 'map_update_progress_widget.dart';
import 'storage_space_widget.dart';

enum MenuActionType { clearAppCache, clearPersistentMapStorage }

/// Download maps screen widget.
class DownloadMapsScreen extends StatefulWidget {
  static const String navRoute = "/download_maps";

  DownloadMapsScreen({Key? key}) : super(key: key);

  @override
  _DownloadMapsScreenState createState() => _DownloadMapsScreenState();
}

class _DownloadMapsScreenState extends State<DownloadMapsScreen> {
  static const double _kDownloadedMapMenuTitleHeight = 80;
  late StreamSubscription<MapLoaderError> _errorStreamSubscription;
  bool _isRegionsSearchInProgress = false;

  @override
  void initState() {
    super.initState();
    MapLoaderController controller = Provider.of<MapLoaderController>(context, listen: false);
    _errorStreamSubscription = controller.getMapUpdateErrors.listen((MapLoaderError error) {
      print('Map downloading failed. Error: ${error.toString()}');
      if (mounted) {
        ErrorToaster.makeToast(context, error.errorMessage(AppLocalizations.of(context)!));
      }
    });

    _checkMapUpdate(controller);
  }

  @override
  void dispose() {
    _errorStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<MapLoaderController>(
        builder: (context, controller, child) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(AppLocalizations.of(context)!.downloadMapsTitle),
            actions: [
              PopupMenuButton(
                icon: Icon(Icons.menu),
                onSelected: _menuActionHandler,
                itemBuilder: (_) {
                  return [
                    PopupMenuItem(
                      child: Text(AppLocalizations.of(context)!.clearPrefetchedCache),
                      value: MenuActionType.clearAppCache,
                    ),
                    PopupMenuItem(
                      child: Text(AppLocalizations.of(context)!.clearPersistentMapStorage),
                      value: MenuActionType.clearPersistentMapStorage,
                    ),
                  ];
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              FutureBuilder(
                future: Provider.of<MapLoaderController>(context, listen: false).getDownloadableRegions(),
                builder: (context, snapshot) {
                  return ListView(
                    children: [
                      StorageSpace(),
                      if (controller.mapUpdateState != MapUpdateState.none) MapUpdateProgress(),
                      ..._buildInstalledMapsList(context, snapshot.data),
                      _buildDownloadButton(context),
                    ],
                  );
                },
              ),
              if (_isRegionsSearchInProgress)
                Container(
                  color: Colors.white54,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      );

  Region? _findInstalledRegionByID(List<Region> regions, RegionId regionId) {
    for (Region region in regions) {
      if (region.regionId == regionId) {
        return region;
      }
      if (region.childRegions != null) {
        Region? foundRegion = _findInstalledRegionByID(region.childRegions!, regionId);
        if (foundRegion != null) {
          return foundRegion;
        }
      }
    }

    return null;
  }

  List<Widget> _buildInstalledMapsList(BuildContext context, List<Region>? regions) {
    if (regions == null) {
      return [
        SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        )
      ];
    }

    List<Widget> result = [];
    MapLoaderController controller = Provider.of<MapLoaderController>(context, listen: false);
    try {
      List<InstalledRegion> installedRegions = controller.getInstalledRegions();

      installedRegions.forEach((element) {
        Region region = _findInstalledRegionByID(regions, element.regionId)!;
        int? progress = controller.getDownloadProgress(element.regionId);

        // When true, disables tap action and hides trailing icon.
        final bool hideTrailingAndDisableTap = controller.isAnyDownloadInProgress() && progress == null;
        MapRegionTile tile = MapRegionTile(
          region: region,
          installedRegion: element,
          downloadProgress: progress,
          onTap: () => progress != null
              ? controller.cancelDownloadWithConfirmation(
                  context, region,
                  //  If the canceled tile is a Parent/Header tile,
                  //  we can utilize [childRegionIds] to cancel all associated child region downloads.
                  //  Alternatively, if the canceled tile is a child tile with its own children,
                  //  we pass their region IDs to cancel the respective downloads for those children as well.
                  region.childRegions.regionIds(),
                )
              : hideTrailingAndDisableTap
                  ? null
                  : _displayDownloadedMapMenu(context, controller, region, element),
          icon: Icon(Icons.menu),
          hideTrailingIcon: hideTrailingAndDisableTap,
        );

        result.add(tile);
        result.add(Divider());
      });
    } on MapLoaderExceptionException catch (error) {
      // Ignoring the 'operationCancelled' error when displaying it to the user, but logging it to the console.
      if (error.error != MapLoaderError.operationCancelled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ErrorToaster.makeToast(context, error.error.errorMessage(AppLocalizations.of(context)!));
          }
        });
      }
    }

    if (result.isNotEmpty && controller.mapUpdateState == MapUpdateState.none) {
      result.insert(0, _buildDownloadedMapsHeader(context, controller));
    }

    return result;
  }

  void _displayDownloadedMapMenu(
    BuildContext context,
    MapLoaderController controller,
    Region region,
    InstalledRegion installedRegion,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(UIStyle.popupsBorderRadius)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              toolbarHeight: _kDownloadedMapMenuTitleHeight,
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
              backgroundColor: colorScheme.surface,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    region.name,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    height: UIStyle.contentMarginMedium,
                  ),
                  Text(
                    appLocalizations.downloadedMapOptionsTitle,
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            if (installedRegion.status == InstalledRegionStatus.pending) ...[
              ListTile(
                leading: Icon(Icons.download),
                title: Text(appLocalizations.retryDownloadMapOptionTitle),
                onTap: () {
                  controller.downloadRegion(region.regionId);
                  Navigator.of(context).pop();
                },
              ),
              Divider(),
            ],
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: Text(
                appLocalizations.deleteMapOptionTitle,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                await controller.deleteRegion(region.regionId);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) => Row(
        children: [
          Spacer(),
          GradientElevatedButton(
            title: Text(AppLocalizations.of(context)!.downloadMapsButtonTitle),
            onPressed: () => _openMapRegions(context),
          ),
          Spacer(),
        ],
      );

  void _openMapRegions(BuildContext context) async {
    setState(() {
      _isRegionsSearchInProgress = true;
    });
    try {
      MapLoaderController controller = Provider.of<MapLoaderController>(context, listen: false);
      List<Region> regions = await controller.getDownloadableRegions();
      Navigator.of(context).pushNamed(MapRegionsListScreen.navRoute, arguments: [regions]);
    } catch (error) {
      print('Map downloading failed. Error: ${error.toString()}');
      if (mounted) {
        ErrorToaster.makeToast(
          context,
          (error is MapLoaderError) ? error.errorMessage(AppLocalizations.of(context)!) : error.toString(),
        );
      }
    } finally {
      setState(() {
        _isRegionsSearchInProgress = false;
      });
    }
  }

  Widget _buildDownloadedMapsHeader(BuildContext context, MapLoaderController controller) => Container(
        color: Theme.of(context).dividerColor,
        child: Padding(
          padding: EdgeInsets.all(UIStyle.contentMarginMedium),
          child: Text(AppLocalizations.of(context)!.downloadedMapsTitle),
        ),
      );

  void _checkMapUpdate(MapLoaderController controller) async {
    try {
      // Display the "MapUpdate" option only if it has not been initiated before.
      if (controller.mapUpdateState == MapUpdateState.none) {
        bool? isMapUpdateAvailable = await controller.isMapUpdateAvailable();
        if (isMapUpdateAvailable && await showMapUpdatesAvailableDialog(context)) {
          controller.performMapUpdate();
        }
      }
    } on MapLoaderError catch (error) {
      print('Error while checking map update $error');
      // Ignoring the 'operationCancelled' error when displaying it to the user, but logging it to the console.
      if (error != MapLoaderError.operationCancelled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ErrorToaster.makeToast(context, error.errorMessage(AppLocalizations.of(context)!));
          }
        });
      }
    } catch (error) {
      print('Error while checking map update $error');
    }
  }

  void _menuActionHandler(MenuActionType type) async {
    try {
      MapLoaderController controller = Provider.of<MapLoaderController>(context, listen: false);
      if (type == MenuActionType.clearPersistentMapStorage) {
        await controller.clearPersistentMapStorage();
      } else if (type == MenuActionType.clearAppCache) {
        await controller.clearAppCache();
      }
    } catch (error) {
      print('${type.name} failed. Error: ${error.toString()}');
      if (mounted && error != MapLoaderError.operationCancelled) {
        ErrorToaster.makeToast(
          context,
          (error is MapLoaderError) ? error.errorMessage(AppLocalizations.of(context)!) : error.toString(),
        );
      }
    }
  }
}
