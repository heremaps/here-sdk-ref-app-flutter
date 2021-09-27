/*
 * Copyright (C) 2020-2021 HERE Europe B.V.
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

/// Data controller that manages offline maps.
class MapLoaderController extends ChangeNotifier {
  final MapDownloader _mapDownloader;

  Map<RegionId, _RegionTask> _regionsInProgress = {};

  /// Default constructor
  MapLoaderController() : _mapDownloader = MapDownloader.fromSdkEngine(SDKNativeEngine.sharedInstance!);

  /// Returns a list of [Region] objects that can be used to download the actual map data in a separate request.
  Future<List<Region>> getDownloadableRegions() async {
    final Completer<List<Region>> completer = Completer();
    _mapDownloader.getDownloadableRegions((error, regions) {
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
    List<InstalledRegion> installedRegions = _mapDownloader.getInstalledRegions();

    installedRegions.removeWhere((elementToRemove) =>
        elementToRemove.status == InstalledRegionStatus.pending &&
        installedRegions
            .where((element) =>
                element.status == InstalledRegionStatus.pending && element.regionId == elementToRemove.parentId)
            .isNotEmpty);

    return installedRegions;
  }

  /// Starts download a [Region].
  void downloadRegion(RegionId region) {
    if (_regionsInProgress.containsKey(region)) {
      return;
    }

    MapDownloaderTask task = _mapDownloader.downloadRegions(
        [region],
        DownloadRegionsStatusListener((error, regions) {
          _regionsInProgress.remove(region);
          notifyListeners();
        }, (id, progress) {
          _regionsInProgress[region]?.progress = progress;
          notifyListeners();
        }, (error) {
          notifyListeners();
        }, () {
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

  /// Deleted downloaded [Region].
  void deleteRegion(RegionId region) {
    _regionsInProgress[region] = _RegionDeleteTask(
      regionId: region,
    );
    notifyListeners();

    _mapDownloader.deleteRegions([region], (error, regions) {
      print("delete error ${error}");
      _regionsInProgress.remove(region);
      notifyListeners();
    });
  }

  /// Returns progress of the currently loaded [Region].
  int? getDownloadProgress(RegionId region) {
    return _regionsInProgress[region]?.progress;
  }
}
