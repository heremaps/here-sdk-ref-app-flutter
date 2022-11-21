/*
 * Copyright (C) 2020-2022 HERE Europe B.V.
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

/// A Flutter widget that scrolls Widget Text.
class MarqueeWidget extends StatefulWidget {
  static const int _kDefaultAnimationDuration = 3000;
  static const int _kDefaultBackDuration = 1000;
  static const int _kDefaultPauseDuration = 1000;

  /// Child widget.
  final Widget child;

  /// Scroll direction.
  final Axis direction;

  /// Animation duration.
  final Duration animationDuration;

  /// Back animation duration.
  final Duration backDuration;

  /// Pause duration.
  final Duration pauseDuration;

  /// Constructs the widget.
  MarqueeWidget({
    required this.child,
    this.direction: Axis.horizontal,
    this.animationDuration: const Duration(
      milliseconds: _kDefaultAnimationDuration,
    ),
    this.backDuration: const Duration(
      milliseconds: _kDefaultBackDuration,
    ),
    this.pauseDuration: const Duration(
      milliseconds: _kDefaultPauseDuration,
    ),
  });

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback(scroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget.child,
      scrollDirection: widget.direction,
      controller: _scrollController,
    );
  }

  void scroll(_) async {
    while (_scrollController.hasClients) {
      await Future.delayed(widget.pauseDuration);
      if (_scrollController.hasClients)
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.ease,
        );
      await Future.delayed(widget.pauseDuration);
      if (_scrollController.hasClients)
        await _scrollController.animateTo(
          0.0,
          duration: widget.backDuration,
          curve: Curves.easeOut,
        );
    }
  }
}
