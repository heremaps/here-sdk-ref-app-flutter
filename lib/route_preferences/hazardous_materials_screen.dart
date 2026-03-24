/*
* Copyright (c) 2026 HERE Global B.V. and its affiliate(s).
* All rights reserved.
*
* This software and other materials contain proprietary information
* controlled by HERE and are protected by applicable copyright legislation.
* Any use and utilization of this software and other materials and
* disclosure to any third parties is conditional upon having a separate
* agreement with HERE for the access, use, utilization or disclosure of this
* software. In the absence of such agreement, the use of the software is not
* allowed.
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
