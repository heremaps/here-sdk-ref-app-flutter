/*
 * Copyright (C) 2020-2023 HERE Europe B.V.
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
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'application_preferences.dart';
import 'custom_map_style_settings.dart';
import 'gradient_elevated_button.dart';
import 'ui_style.dart';

/// Version of the Application
const String applicationVersion = "1.6.0";

const String _placeholderPattern = '(\{\{([a-zA-Z0-9]+)\}\})';

/// Returns a formatted string constructed from a [template] and a list of [replacements].
String formatString(String template, List replacements) {
  final regExp = RegExp(_placeholderPattern);
  assert(
      regExp.allMatches(template).length == replacements.length, "Template and Replacements length are incompatible");

  for (final replacement in replacements) {
    template = template.replaceFirst(regExp, replacement.toString());
  }

  return template;
}

/// Returns localized [distance] string in meters.
String makeDistanceString(BuildContext context, int? distance) {
  if (distance == null) {
    return "";
  } else if (distance < 1000) {
    return "$distance ${AppLocalizations.of(context)!.meterAbbreviationText} ";
  } else if (distance < 10000) {
    return "${(distance / 1000.0).toStringAsFixed(1)} ${AppLocalizations.of(context)!.kilometerAbbreviationText} ";
  } else {
    return "${(distance / 1000).truncate()} ${AppLocalizations.of(context)!.kilometerAbbreviationText} ";
  }
}

/// Returns localized storage [size] string in bytes.
String makeStorageSizeString(BuildContext context, int size) {
  if (size < 1024) {
    return "$size ${AppLocalizations.of(context)!.byteAbbreviationText}";
  } else if (size < 1048576) {
    return "${size / 1024} ${AppLocalizations.of(context)!.kilobyteAbbreviationText}";
  } else if (size < 1073741824) {
    return "${(size / 1048576.0).toStringAsFixed(2)} ${AppLocalizations.of(context)!.megabyteAbbreviationText}";
  } else {
    return "${(size / 1073741824).toStringAsFixed(2)} ${AppLocalizations.of(context)!.gigabyteAbbreviationText}";
  }
}

/// An extension for lists that allows swapping of two elements at indices [index1], [index2].
extension ListSwap<T> on List<T> {
  List<T> swap(int index1, int index2) {
    final length = this.length;
    RangeError.checkValidIndex(index1, this, "index1", length);
    RangeError.checkValidIndex(index2, this, "index2", length);
    if (index1 != index2) {
      final tmp1 = this[index1];
      this[index1] = this[index2];
      this[index2] = tmp1;
    }

    return this;
  }
}

/// Creates [MapMarker] in [coordinates] using an image at [imagePath], with [width], [height], [drawOrder]
/// and [anchor].
MapMarker createMarkerWithImagePath(
  GeoCoordinates coordinates,
  String imagePath,
  int width,
  int height, {
  int? drawOrder,
  Anchor2D? anchor,
}) {
  MapImage mapImage = MapImage.withFilePathAndWidthAndHeight(imagePath, width, height);
  MapMarker mapMarker = createMarkerWithImage(coordinates, mapImage, drawOrder: drawOrder, anchor: anchor);
  return mapMarker;
}

/// Creates [MapMarker] in [coordinates] using an [image], [drawOrder] and [anchor].
MapMarker createMarkerWithImage(
  GeoCoordinates coordinates,
  MapImage image, {
  int? drawOrder,
  Anchor2D? anchor,
}) {
  MapMarker mapMarker = MapMarker(coordinates, image);
  if (drawOrder != null) {
    mapMarker.drawOrder = drawOrder;
  }
  if (anchor != null) {
    mapMarker.anchor = anchor;
  }

  return mapMarker;
}

/// Returns the localized [dateTime] string.
String stringFromDateTime(BuildContext context, DateTime? dateTime) {
  if (dateTime == null) return "";

  return DateFormat(AppLocalizations.of(context)!.dateTimeFormat).format(dateTime);
}

/// An extension for the [HereMapController].
extension LogicalCoords on HereMapController {
  /// Zooms map area specified by [geoBox] into [viewPort] with [margin].
  void zoomGeoBoxToLogicalViewPort({
    required GeoBox geoBox,
    required Rect viewPort,
    double margin = UIStyle.contentMarginExtraHuge,
  }) {
    this.camera.lookAtAreaWithGeoOrientationAndViewRectangle(
        geoBox,
        GeoOrientationUpdate(double.nan, double.nan),
        Rectangle2D(
            Point2D(viewPort.left + margin, viewPort.top + margin) * this.pixelScale,
            Size2D(
              (viewPort.width - margin * 2) * this.pixelScale,
              (viewPort.height - margin * 2) * this.pixelScale,
            )));
  }

  /// Zooms map area specified by [geoBox] into entire map area.
  void zoomToLogicalViewPort({
    required GeoBox geoBox,
    required BuildContext context,
  }) {
    final RenderBox box = context.findRenderObject() as RenderBox;

    zoomGeoBoxToLogicalViewPort(
      geoBox: geoBox,
      viewPort: Rect.fromLTRB(0, MediaQuery.of(context).padding.top, box.size.width, box.size.height)
          .deflate(UIStyle.locationMarkerSize.toDouble()),
    );
  }
}

/// An extension for the [GeoCoordinates].
extension GeoCoordinatesExtensions on GeoCoordinates {
  /// Returns formatted string.
  String toPrettyString({int fractionDigits = 5}) => "${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}";
}

/// An extension for the [Point2D].
extension Point2DExtensions on Point2D {
  /// Returns [Point2D], each of whose fields is multiplied by [factor].
  Point2D operator *(double factor) => Point2D(x * factor, y * factor);

  /// Returns [Point2D], each of whose fields is divided by [factor].
  Point2D operator /(double factor) => Point2D(x / factor, y / factor);
}

/// An extension for the [Size2D].
extension Size2DExtensions on Size2D {
  Size2D operator *(double factor) => Size2D(width * factor, height * factor);
}

/// Utility function that shows [SnackBar] with [errorMessage]
void displayErrorSnackBar(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
    content: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.all(UIStyle.contentMarginMedium),
          child: Icon(Icons.error),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(UIStyle.contentMarginMedium),
            child: Text(
              errorMessage,
              style: TextStyle(fontSize: UIStyle.hugeFontSize),
            ),
          ),
        ),
      ],
    ),
  ));
}

/// Utility function that builds cancel button for application dialogs
Widget buildDialogCancelButton(BuildContext context) => SimpleDialogOption(
      child: Padding(
        padding: EdgeInsets.all(UIStyle.contentMarginLarge),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.cancelTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: UIStyle.bigFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ),
      onPressed: () => Navigator.of(context).pop(false),
    );

/// Creates a common confirmation dialog.
Future<bool> showCommonConfirmationDialog({
  required BuildContext context,
  String? title,
  String? message,
  String? actionTitle,
  Color? actionTextColor,
  Color? actionBackgroundColor,
}) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (context) => SimpleDialog(
      titlePadding: const EdgeInsets.symmetric(
        vertical: UIStyle.contentMarginLarge,
        horizontal: UIStyle.contentMarginExtraLarge,
      ),
      title: title != null
          ? Text(
              title,
              textAlign: TextAlign.center,
            )
          : null,
      children: [
        if (message != null)
          Padding(
            padding: EdgeInsets.only(
              left: UIStyle.contentMarginExtraLarge,
              right: UIStyle.contentMarginExtraLarge,
              bottom: UIStyle.contentMarginExtraLarge,
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: UIStyle.bigFontSize,
              ),
            ),
          ),
        if (actionTitle != null)
          Row(
            children: [
              Spacer(),
              GradientElevatedButton(
                title: Text(
                  actionTitle,
                  style: TextStyle(
                    color: actionTextColor,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                primaryColor: actionBackgroundColor ?? UIStyle.buttonPrimaryColor,
                secondaryColor: actionBackgroundColor ?? UIStyle.buttonSecondaryColor,
              ),
              Spacer(),
            ],
          ),
        buildDialogCancelButton(context),
      ],
    ),
  );

  return result ?? false;
}

/// Sets traffic layers visibility on the map according to option saved in preferences (or hides them if app is in
/// offline mode).
void setTrafficLayersVisibilityOnMap(BuildContext context, HereMapController hereMapController) {
  AppPreferences appPreferences = Provider.of<AppPreferences>(context, listen: false);
  bool enableTraffic = appPreferences.useAppOffline ? false : appPreferences.showTrafficLayers;
  if (enableTraffic) {
    hereMapController.mapScene.enableFeatures({
      MapFeatures.trafficFlow: MapFeatureModes.trafficFlowWithFreeFlow,
      MapFeatures.trafficIncidents: MapFeatureModes.trafficIncidentsAll
    });
  } else {
    hereMapController.mapScene.disableFeatures([MapFeatures.trafficFlow, MapFeatures.trafficIncidents]);
  }
}

/// Function loads map scene using custom map style defined in [CustomMapStyleSettings]. [MapScheme.normalDay] style is
/// used if custom map style is not defined.
void loadMapScene(
  CustomMapStyleSettings customMapStyleSettings,
  HereMapController hereMapController,
  MapSceneLoadSceneCallback mapSceneLoadSceneCallback,
) {
  customMapStyleSettings.customMapStyleFilepath != null
      ? hereMapController.mapScene.loadSceneFromConfigurationFile(
          customMapStyleSettings.customMapStyleFilepath!,
          mapSceneLoadSceneCallback,
        )
      : hereMapController.mapScene.loadSceneForMapScheme(
          MapScheme.normalDay,
          mapSceneLoadSceneCallback,
        );
}
