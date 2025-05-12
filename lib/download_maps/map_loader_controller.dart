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
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/maploader.dart';

import 'map_catalog_update_handler.dart';

abstract class _RegionTask {
  final RegionId regionId;

  int get progress;

  set progress(int value);

  _RegionTask({required this.regionId});

  void cancel();

  void pause();

  void resume();
}

class _RegionDownloadTask extends _RegionTask {
  final MapDownloaderTask task;
  int _progress = 0;

  @override
  int get progress => _progress;

  @override
  set progress(int value) => _progress = value;

  _RegionDownloadTask({
    required RegionId regionId,
    required this.task,
  }) : super(
          regionId: regionId,
        );

  @override
  void cancel() {
    _progress = -1;
    task.cancel();
  }

  @override
  void pause() {
    task.pause();
  }

  @override
  void resume() {
    task.resume();
  }
}

class _RegionDeleteTask extends _RegionTask {
  @override
  int get progress => -1;

  @override
  set progress(int value) => null;

  _RegionDeleteTask({
    required RegionId regionId,
  }) : super(
          regionId: regionId,
        );

  @override
  void cancel() {}

  @override
  void pause() {}

  @override
  void resume() {}
}

enum MapUpdateState {
  none,
  progress,
  paused,
  cancelling,
}

/// Data controller that manages offline maps.
class MapLoaderController extends ChangeNotifier implements MapCatalogUpdateListener {
  MapUpdater? _mapUpdater;
  final Completer<MapUpdater> _mapUpdaterCompleter = Completer();

  Future<MapUpdater> get mapUpdater async => await _mapUpdaterCompleter.future;

  MapDownloader? _mapDownloader;
  final Completer<MapDownloader> _mapDownloaderCompleter = Completer();

  Future<MapDownloader> get mapDownloader async => await _mapDownloaderCompleter.future;

  Map<RegionId, _RegionTask> _regionsInProgress = {};

  /// Contains list of RegionId which get paused.
  /// return `List<RegionId>`
  final List<RegionId> _pausedRegionsWhenOffline = <RegionId>[];

  MapUpdateState _mapUpdateState = MapUpdateState.none;
  int? _mapUpdateProgress;
  StreamController<MapLoaderError> _mapUpdateErrors = StreamController.broadcast();
  List<MapCatalogUpdateHandler>? _catalogHandlers;
  MapCatalogUpdateHandler? _currentCatalogHandler;

  /// Default constructor
  MapLoaderController() {
    MapDownloader.fromSdkEngineAsync(SDKNativeEngine.sharedInstance!, (MapDownloader downloader) {
      _mapDownloader = downloader;
      _mapDownloaderCompleter.complete(_mapDownloader);
    });

    MapUpdater.fromSdkEngineAsync(SDKNativeEngine.sharedInstance!, (MapUpdater updater) {
      _mapUpdater = updater;
      _mapUpdaterCompleter.complete(_mapUpdater);
    });
  }

  /// Returns a list of [Region] objects that can be used to download the actual map data in a separate request.
  Future<List<Region>> getDownloadableRegions() async {
    final Completer<List<Region>> completer = Completer();

    (await mapDownloader).getDownloadableRegions((error, regions) {
      if (error != null) {
        completer.completeError(error);
        return;
      }

      completer.complete(regions);
    });

    return completer.future;
  }

  /// Method to get a list of map regions that are currently installed on the device.
  List<InstalledRegion> getInstalledRegions() {
    List<InstalledRegion> installedRegions = [];
    try {
      if (_mapDownloader != null) {
        installedRegions = _mapDownloader!.getInstalledRegions();
        installedRegions.removeWhere((elementToRemove) =>
            elementToRemove.status == InstalledRegionStatus.pending &&
            installedRegions
                .where((element) =>
                    element.status == InstalledRegionStatus.pending && element.regionId == elementToRemove.parentId)
                .isNotEmpty);
      }
    } on MapLoaderExceptionException catch (error) {
      print('Failed to get installed regions: ${error.error.toString()}');
      throw error;
    }
    return installedRegions;
  }

  /// Starts download a [Region].
  void downloadRegion(RegionId region) async {
    if (_regionsInProgress.containsKey(region)) {
      return;
    }

    MapDownloaderTask task = (await mapDownloader).downloadRegions(
        [region],
        DownloadRegionsStatusListener((error, regions) {
          _regionsInProgress.remove(region);
          _pausedRegionsWhenOffline.remove(region);
          notifyListeners();
        }, (id, progress) {
          _regionsInProgress[region]?.progress = progress;
          notifyListeners();
        }, (error) {
          _pausedRegionsWhenOffline.add(region);
          notifyListeners();
        }, () {
          _pausedRegionsWhenOffline.remove(region);
          notifyListeners();
        }));

    _regionsInProgress[region] = _RegionDownloadTask(
      regionId: region,
      task: task,
    );
    notifyListeners();
  }

  /// Pauses download a [Region].
  void pauseDownload(RegionId region) {
    _regionsInProgress[region]?.pause();
    notifyListeners();
  }

  /// Resumes download a [Region].
  void resumeDownload(RegionId region) {
    _regionsInProgress[region]?.resume();
    notifyListeners();
  }

  /// Cancels download a [Region].
  void cancelDownload(RegionId region) {
    _regionsInProgress[region]?.cancel();
    notifyListeners();
  }

  /// Cancels download of all the [Region].
  void cancelDownloads(List<RegionId> regions) {
    final Iterable<RegionId> downloadingRegions = _regionsInProgress.keys.where((e) => regions.contains(e));
    for (final region in downloadingRegions) {
      _regionsInProgress[region]?.cancel();
    }
    notifyListeners();
  }

  /// Deleted downloaded [Region].
  Future<void> deleteRegion(RegionId region) async {
    _regionsInProgress[region] = _RegionDeleteTask(
      regionId: region,
    );
    notifyListeners();

    (await mapDownloader).deleteRegions([region], (error, regions) {
      print("delete error ${error}");
      _regionsInProgress.remove(region);
      notifyListeners();
    });
  }

  /// Returns progress of the currently loaded [Region].
  int? getDownloadProgress(RegionId region) {
    return _regionsInProgress[region]?.progress;
  }

  /// Checks if any region download is currently in progress.
  ///
  /// Returns `true` if at least one region has a progress value of 0 or greater,
  bool isAnyDownloadInProgress() => _regionsInProgress.values.any((_RegionTask region) => region.progress >= 0);

  // Handle pending Map Downloads
  void resumePendingMapDownloads() {
    if (_pausedRegionsWhenOffline.isNotEmpty) {
      _pausedRegionsWhenOffline.forEach((RegionId region) => _regionsInProgress[region]?.resume());
      notifyListeners();
    }
  }

  /// Checks for map updates
  Future<bool> isMapUpdateAvailable() async {
    final Completer<List<CatalogUpdateInfo>?> getCatalogs = Completer<List<CatalogUpdateInfo>?>();
    (await mapUpdater).retrieveCatalogsUpdateInfo(
      (MapLoaderError? error, List<CatalogUpdateInfo>? catalogs) {
        if (error != null) {
          getCatalogs.completeError(error);
          return;
        }
        getCatalogs.complete(catalogs);
      },
    );
    final List<CatalogUpdateInfo>? newCatalogs = await getCatalogs.future;
    if (newCatalogs != null && newCatalogs.isNotEmpty && _mapUpdater != null) {
      _catalogHandlers = newCatalogs.map((CatalogUpdateInfo catalog) {
        final MapCatalogUpdateHandler handler = MapCatalogUpdateHandler(_mapUpdater, catalog)..addListener(this);
        return handler;
      }).toList();
    } else {
      _catalogHandlers = null;
    }

    return newCatalogs?.isNotEmpty ?? false;
  }

  /// Clear persisted map data
  Future<void> clearPersistentMapStorage() async {
    await _onCallback(_mapDownloader!.clearPersistentMapStorage);
    notifyListeners();
  }

  /// Clear app cache
  Future<void> clearAppCache() async {
    return _onCallback(SDKCache.fromSdkEngine(SDKNativeEngine.sharedInstance!).clearAppCache);
  }

  Future<void> _onCallback(Function callbackFunction) {
    final Completer<void> completer = Completer<void>();

    void callback(MapLoaderError? error) {
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete();
      }
    }

    callbackFunction(callback);
    return completer.future;
  }

  @override
  void onCatalogUpdateComplete(MapLoaderError? error) {
    if (error != null && error != MapLoaderError.operationCancelled) {
      print("map update error ${error}");
      _mapUpdateErrors.add(error);
    }

    bool checkForNextCatalog = false;
    if (error == null && _currentCatalogHandler != null) {
      _catalogHandlers?.remove(_currentCatalogHandler);
      checkForNextCatalog = true;
    }

    _mapUpdateState = MapUpdateState.none;
    _currentCatalogHandler = null;
    _mapUpdateProgress = null;
    notifyListeners();
    if (checkForNextCatalog && (_catalogHandlers?.isNotEmpty ?? false)) {
      performMapUpdate();
    }
  }

  @override
  void onCatalogUpdatePause(MapLoaderError? error) {
    if (error != null) {
      _mapUpdateErrors.add(error);
    }
    _mapUpdateState = MapUpdateState.paused;
    notifyListeners();
  }

  @override
  void onCatalogUpdateProgress(RegionId region, int percentage) {
    if (_mapUpdateState == MapUpdateState.paused) {
      // Progress callback can be called after a pause.
      return;
    }
    _mapUpdateProgress = percentage;
    _mapUpdateState = MapUpdateState.progress;
    notifyListeners();
  }

  @override
  void onCatalogUpdateResume() {
    _mapUpdateState = MapUpdateState.progress;
    notifyListeners();
  }

  /// Performs map update.
  void performMapUpdate() async {
    if (_catalogHandlers == null || _catalogHandlers!.isEmpty) {
      return;
    }
    if (_currentCatalogHandler != null) {
      _currentCatalogHandler!.cancel();
    }
    _currentCatalogHandler = _catalogHandlers?.first;
    if (_currentCatalogHandler == null) {
      return;
    }
    _mapUpdateState = MapUpdateState.progress;
    _mapUpdateProgress = 0;
    notifyListeners();
    _currentCatalogHandler?.start();
  }

  /// Gets current map updating state.
  MapUpdateState get mapUpdateState => _mapUpdateState;

  /// Gets current map updating progress.
  int? get mapUpdateProgress => _mapUpdateProgress;

  /// Gets stream with errors occurred while map update.
  Stream<MapLoaderError> get getMapUpdateErrors => _mapUpdateErrors.stream;

  /// Pauses map update.
  void pauseMapUpdate() {
    _currentCatalogHandler?.pause();
    _mapUpdateState = MapUpdateState.paused;
    notifyListeners();
  }

  /// Resumes map update.
  void resumeMapUpdate() {
    _mapUpdateState = MapUpdateState.progress;
    _currentCatalogHandler?.resume();
    notifyListeners();
  }

  /// Cancels map update.
  void cancelMapUpdate() {
    _mapUpdateState = MapUpdateState.cancelling;
    notifyListeners();
    _currentCatalogHandler?.cancel();
  }
}
