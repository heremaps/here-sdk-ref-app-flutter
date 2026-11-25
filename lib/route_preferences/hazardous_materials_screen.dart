/*
 * Copyright (C) 2026 HERE Europe B.V.
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

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:here_sdk/transport.dart' show HazardousMaterial;
import 'package:here_sdk_reference_application_flutter/common/ui_style.dart';
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';
import 'package:here_sdk_reference_application_flutter/route_preferences/enum_string_helper.dart';

class HazardousMaterialsScreen extends StatefulWidget {
  const HazardousMaterialsScreen({super.key, required this.hazardousMaterials});
  final List<HazardousMaterial> hazardousMaterials;

  @override
  State<HazardousMaterialsScreen> createState() => _HazardousMaterialsScreenState();
}

class _HazardousMaterialsScreenState extends State<HazardousMaterialsScreen> {
  late List<HazardousMaterial> _hazardousMaterials;

  @override
  void initState() {
    super.initState();
    _hazardousMaterials = List.from(widget.hazardousMaterials);
  }

  @override
  Widget build(BuildContext context) {
    LinkedHashMap<String, HazardousMaterial> hazardousMaterialsMap = EnumStringHelper.sortedHazardousMaterialsMap(
      context,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _hazardousMaterials);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.hazardousGoodsTitle)),
        body: Container(
          color: UIStyle.preferencesBackgroundColor,
          child: ListView(
            children: hazardousMaterialsMap.keys.map((String key) {
              return CheckboxListTile(
                title: Text(key),
                value: _hazardousMaterials.contains(hazardousMaterialsMap[key]),
                onChanged: (bool? enable) {
                  HazardousMaterial changedFeature = hazardousMaterialsMap[key]!;
                  setState(() {
                    if (enable ?? false) {
                      _hazardousMaterials.add(changedFeature);
                    } else {
                      _hazardousMaterials.remove(changedFeature);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
