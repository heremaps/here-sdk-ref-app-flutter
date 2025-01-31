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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

/// A widget that controls position of the HERE logo on the map.
/// It observes the state and position of the child draggable sheet widget and updates the position of the logo
/// to prevent it from overlapping.
class DraggablePopupHereLogoHelper extends StatefulWidget {
  /// [HereMapController] that contains the logo.
  final HereMapController hereMapController;

  /// [Key] of the map widget.
  final GlobalKey hereMapKey;

  /// Child draggable scrollable sheet widget.
  final DraggableScrollableSheet draggableScrollableSheet;

  /// Should be true if the child sheet is disposable.
  final bool modal;

  /// Constructs a widget.
  DraggablePopupHereLogoHelper({
    Key? key,
    required this.hereMapController,
    required this.hereMapKey,
    required this.draggableScrollableSheet,
    this.modal = false,
  }) : super(key: key);

  @override
  _DraggablePopupHereLogoHelperState createState() => _DraggablePopupHereLogoHelperState();
}

class _DraggablePopupHereLogoHelperState extends State<DraggablePopupHereLogoHelper> {
  bool _processEvents = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) => SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => _updateHereLogoPosition(widget.draggableScrollableSheet.initialChildSize)));
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      child: widget.draggableScrollableSheet,
      onNotification: (notification) {
        // The modal sheet is going to close, so don't touch the logo
        if (widget.modal && notification.minExtent == notification.extent) {
          _processEvents = false;
        }

        _updateHereLogoPosition(notification.extent);
        return false;
      },
    );
  }

  void _updateHereLogoPosition(double extent) {
    if (widget.hereMapKey.currentContext == null || !_processEvents) {
      return;
    }

    final double height = MediaQuery.of(context).size.height;
    final double popupHeight = height * extent;
    final RenderBox box = widget.hereMapKey.currentContext!.findRenderObject() as RenderBox;
    final double margin = (popupHeight - (height - box.paintBounds.bottom)) * widget.hereMapController.pixelScale;

    if (margin >= 0) {
      widget.hereMapController.setWatermarkLocation(
        Anchor2D.withHorizontalAndVertical(0.5, 1),
        Point2D(0, -(widget.hereMapController.watermarkSize.height / 2) - margin.truncate()),
      );
    } else {
      widget.hereMapController.setWatermarkLocation(
        Anchor2D.withHorizontalAndVertical(0, 1),
        Point2D(
          -widget.hereMapController.watermarkSize.width / 2,
          -widget.hereMapController.watermarkSize.height / 2,
        ),
      );
    }
  }
}
