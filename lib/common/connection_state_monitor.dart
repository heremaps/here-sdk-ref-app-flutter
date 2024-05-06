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

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../download_maps/map_loader_controller.dart';

class ConnectionStateMonitor extends StatefulWidget {
  const ConnectionStateMonitor({super.key, required this.child, required this.mapLoaderController});

  final Widget child;
  final MapLoaderController mapLoaderController;

  @override
  State<ConnectionStateMonitor> createState() => _ConnectionStateMonitorState();
}

class _ConnectionStateMonitorState extends State<ConnectionStateMonitor> {
  bool get isConnected => !_status.contains(ConnectivityResult.none);
  List<ConnectivityResult> _status = <ConnectivityResult>[];
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((_) async {
      // Check latest connectivity status on connection change.
      final List<ConnectivityResult> status = await Connectivity().checkConnectivity();
      final bool hasSameConnectionStatus = _status.length == status.length && _status.every(status.contains);
      if (!hasSameConnectionStatus) {
        _status = status;
        if (isConnected) {
          // Check for any pending downloads and resume
          widget.mapLoaderController.resumePendingMapDownloads();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
