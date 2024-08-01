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

import 'package:flutter/material.dart';
import 'package:here_sdk_reference_application_flutter/common/ui_style.dart';

const int _toastDurationInMs = 3000;
const double _toastVerticalMargin = 50;
const double _toastBottomMargin = 100;
const double _toastPadding = 10;

class ErrorToaster {
  static OverlayEntry? _toastEntry;
  static Timer? _timer;

  static void makeToast(BuildContext context, String message) {
    _hide();
    _toastEntry = _getOverlayEntry(message);
    _displayToast(
      context,
      entry: _toastEntry,
    );
  }

  static void _hide() {
    _toastEntry?.remove();
    _toastEntry = null;
  }

  static OverlayEntry _getOverlayEntry(String message) {
    return OverlayEntry(
      builder: (BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return _Toast(message);
        },
      ),
    );
  }

  static void _displayToast(BuildContext context, {OverlayEntry? entry}) {
    try {
      _timer?.cancel();
      if (entry != null) {
        Overlay.of(context).insert(entry);
        _timer = Timer(const Duration(milliseconds: _toastDurationInMs), _hide);
      }
    } catch (error) {
      print(error.toString());
    }
  }
}

class _Toast extends StatelessWidget {
  const _Toast(this.message, {Key? key}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.only(
              bottom: _toastBottomMargin,
              left: _toastVerticalMargin,
              right: _toastVerticalMargin,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: const BorderRadius.all(
                  Radius.circular(UIStyle.popupsBorderRadius),
                ),
              ),
              padding: const EdgeInsets.all(_toastPadding),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(UIStyle.contentMarginSmall),
                    child: Icon(
                      Icons.error,
                      color: UIStyle.errorMessageTextColor,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(UIStyle.contentMarginSmall),
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: UIStyle.bigFontSize,
                          color: UIStyle.errorMessageTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
