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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/ui_style.dart';
import 'car_options_screen.dart';
import 'pedestrian_options_screen.dart';
import 'scooter_options_screen.dart';
import 'transport_modes_widget.dart';
import 'truck_options_screen.dart';

/// Routing preferences screen widget.
class RoutePreferencesScreen extends StatefulWidget {
  /// Constructs a widget.
  RoutePreferencesScreen({
    Key? key,
    required this.activeTransportTab,
  }) : super(key: key);

  /// Active transport mode for display.
  final int activeTransportTab;

  @override
  _RoutePreferencesScreenState createState() => _RoutePreferencesScreenState();
}

class _RoutePreferencesScreenState extends State<RoutePreferencesScreen> with TickerProviderStateMixin {
  late TabController _transportModesTabController;

  @override
  void initState() {
    super.initState();
    _transportModesTabController = TabController(length: TransportModes.values.length, vsync: this);
    _transportModesTabController.index = widget.activeTransportTab;
  }

  @override
  void dispose() {
    _transportModesTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.routePreferencesScreenTitle),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(UIStyle.mediumButtonHeight),
              child: Container(
                  color: UIStyle.tabBarBackgroundColor,
                  child: TransportModesWidget(tabController: _transportModesTabController)))),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _transportModesTabController.index);
          return false;
        },
        child: Container(
          color: UIStyle.preferencesBackgroundColor,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: UIStyle.contentMarginMedium,
                  right: UIStyle.contentMarginMedium,
                  bottom: UIStyle.contentMarginHuge),
              child: TabBarView(
                controller: _transportModesTabController,
                children: [CarOptionsScreen(), TruckOptionsScreen(), ScooterOptionsScreen(), PedestrianOptionsScreen()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
