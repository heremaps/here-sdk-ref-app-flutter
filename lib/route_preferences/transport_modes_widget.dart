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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/ui_style.dart';

/// Available transport modes currently supported by the Ref App.
/// The HERE SDK supports more transport modes than featured by this application.
enum TransportModes {
  car,
  truck,
  scooter,
  walk,
}

/// Widget for switching between transport modes.
class TransportModesWidget extends StatelessWidget {
  /// This widget's selection and animation state.
  final TabController tabController;

  /// Constructs a widget.
  TransportModesWidget({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      TabBar(controller: tabController, tabs: _buildTransportTabs(context, tabController.index));

  List<Widget> _buildTransportTabs(BuildContext context, int selectedIndex) {
    return List<Widget>.generate(
      TransportModes.values.length,
      (index) => _buildTransportTab(context, index, selectedIndex == index),
    );
  }

  Widget _buildTransportTab(BuildContext context, int index, bool isSelected) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color color = isSelected ? colorScheme.primary : colorScheme.onSecondary;

    return Tab(
      icon: SvgPicture.asset(
        TransportModes.values[index].icon,
        color: color,
        width: UIStyle.bigIconSize,
        height: UIStyle.bigIconSize,
      ),
    );
  }
}

extension _TransportModeIcon on TransportModes {
  String get icon {
    switch (this) {
      case TransportModes.car:
        return "assets/car.svg";
      case TransportModes.truck:
        return "assets/truck.svg";
      case TransportModes.scooter:
        return "assets/scooter.svg";
      case TransportModes.walk:
        return "assets/walk.svg";
    }
  }
}
