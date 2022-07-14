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

import '../common/ui_style.dart';

/// A widget that displays the progress on the route as a progress bar.
class RouteProgress extends StatelessWidget {
  /// Length of the route.
  final int routeLengthInMeters;

  /// Remaining distance of the route.
  final int remainingDistanceInMeters;

  /// Constructs a widget.
  RouteProgress({
    Key? key,
    required this.routeLengthInMeters,
    required this.remainingDistanceInMeters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _RoutePainter(
        routeLengthInMeters: routeLengthInMeters,
        remainingDistanceInMeters: remainingDistanceInMeters,
        travelledColor: Theme.of(context).colorScheme.onSecondary,
        remainingColor: Theme.of(context).colorScheme.secondary,
        currentColor: UIStyle.currentPositionColor,
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  static const double _kLineWidth = 5;
  static const double _kPositionSize = 10;

  final int routeLengthInMeters;
  final int remainingDistanceInMeters;
  final Color travelledColor;
  final Color remainingColor;
  final Color currentColor;

  _RoutePainter({
    required this.routeLengthInMeters,
    required this.remainingDistanceInMeters,
    required this.travelledColor,
    required this.remainingColor,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    double currentPosition =
        (routeLengthInMeters - remainingDistanceInMeters) / routeLengthInMeters * (size.width - _kLineWidth * 4) +
            _kLineWidth * 2;

    paint.color = travelledColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = _kLineWidth;

    canvas.drawLine(Offset(_kLineWidth * 2, size.height / 2), Offset(currentPosition, size.height / 2), paint);
    paint.strokeWidth = 1;
    canvas.drawCircle(Offset(_kLineWidth, size.height / 2), _kLineWidth, paint);

    paint.strokeWidth = _kLineWidth;
    paint.color = remainingColor;
    canvas.drawLine(
        Offset(currentPosition, size.height / 2), Offset(size.width - _kLineWidth * 2, size.height / 2), paint);
    paint.strokeWidth = 1;
    canvas.drawCircle(Offset(size.width - _kLineWidth, size.height / 2), _kLineWidth, paint);

    Path currentPositionShape = Path()
      ..moveTo(_kPositionSize, 0)
      ..lineTo(-_kPositionSize, -_kPositionSize)
      ..lineTo(-_kPositionSize / 2, 0)
      ..lineTo(-_kPositionSize, _kPositionSize)
      ..lineTo(_kPositionSize, 0);
    Matrix4 matrix4 = Matrix4.identity();
    matrix4.translate(currentPosition, size.height / 2);
    currentPositionShape = currentPositionShape.transform(matrix4.storage);

    paint.style = PaintingStyle.fill;
    paint.color = currentColor;
    canvas.drawPath(currentPositionShape, paint);
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    canvas.drawPath(currentPositionShape, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
