/*
 * Copyright (C) 2025-2026 HERE Europe B.V.
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

const String emptyValue = '--';

extension NullableUtils on String? {
  static const _visiblePrefixLength = 3;
  static const _maskedSuffix = '...';

  String get unwrapped => isNotNullNorEmpty ? this! : emptyValue;

  bool get isNotNullNorEmpty => this?.isNotEmpty ?? false;

  String get maskedCredential {
    final value = unwrapped;
    if (value.length <= _visiblePrefixLength) {
      return value;
    }
    return '${value.substring(0, _visiblePrefixLength)}$_maskedSuffix';
  }
}
