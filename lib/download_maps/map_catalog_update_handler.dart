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

import 'package:here_sdk/maploader.dart';

abstract class MapCatalogUpdateListener {
  void onCatalogUpdateProgress(RegionId region, int percentage);
  void onCatalogUpdatePause(MapLoaderError? error);
  void onCatalogUpdateComplete(MapLoaderError? error);
  void onCatalogUpdateResume();
}

class MapCatalogUpdateHandler implements CatalogUpdateProgressListener {
  MapCatalogUpdateHandler(this.updater, this.catalog);

  MapUpdater? updater;
  final CatalogUpdateInfo catalog;
  int progress = 0;
  CatalogUpdateTask? _task;
  final List<MapCatalogUpdateListener> _listeners = <MapCatalogUpdateListener>[];

  void start() {
    _task ??= updater?.updateCatalog(catalog, this);
  }

  void pause() {
    _task?.pause();
  }

  void resume() {
    if (_task == null) {
      start();
    } else {
      _task?.resume();
    }
  }

  void cancel() {
    _task?.cancel();
  }

  void addListener(MapCatalogUpdateListener listener) {
    _listeners.add(listener);
  }

  void removeListener(MapCatalogUpdateListener listener) {
    _listeners.remove(listener);
  }

  @override
  void onComplete(MapLoaderError? error) {
    print('Catalog update completed (error=${error?.index})');
    progress = error == null ? 100 : 0;
    _task = null;
    for (final MapCatalogUpdateListener l in _listeners) {
      l.onCatalogUpdateComplete(error);
    }
  }

  @override
  void onPause(MapLoaderError? error) {
    for (final MapCatalogUpdateListener l in _listeners) {
      l.onCatalogUpdatePause(error);
    }
  }

  @override
  void onProgress(RegionId region, int percentage) {
    print('Updating catalog (id: ${region.id}) in $percentage %.');
    progress = percentage;
    for (final MapCatalogUpdateListener l in _listeners) {
      l.onCatalogUpdateProgress(region, percentage);
    }
  }

  @override
  void onResume() {
    for (final MapCatalogUpdateListener l in _listeners) {
      l.onCatalogUpdateResume();
    }
  }
}
