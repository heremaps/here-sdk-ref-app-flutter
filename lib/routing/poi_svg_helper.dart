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

import '../common/util.dart' as Util;

const String _atmIcon = '''
<g transform="scale(0.5) translate(6 6.5)">
<path fill-rule="evenodd" clip-rule="evenodd" d="M19.5 10C19.5 4.75329 15.2467 0.5 10 0.5C4.75329 0.5 0.5 4.75329 0.5 10C0.5 15.2467 4.75329 19.5 10 19.5C15.2467 19.5 19.5 15.2467 19.5 10ZM1 10C1 5.02944 5.02944 1 10 1C14.9706 1 19 5.02944 19 10C19 14.9706 14.9706 19 10 19C5.02944 19 1 14.9706 1 10Z" fill="white"/>
<circle cx="10" cy="10" r="9" fill="#45C094"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M19 10C19 5.02944 14.9706 1 10 1C5.02944 1 1 5.02944 1 10C1 14.9706 5.02944 19 10 19C14.9706 19 19 14.9706 19 10ZM2 10C2 5.58172 5.58172 2 10 2C14.4183 2 18 5.58172 18 10C18 14.4183 14.4183 18 10 18C5.58172 18 2 14.4183 2 10Z" fill="#233459" fill-opacity="0.35"/>
<path d="M13.3335 6.66667H6.66683C6.20433 6.66667 5.83766 7.0375 5.83766 7.5L5.8335 12.5C5.8335 12.9625 6.20433 13.3333 6.66683 13.3333H13.3335C13.796 13.3333 14.1668 12.9625 14.1668 12.5V7.5C14.1668 7.0375 13.796 6.66667 13.3335 6.66667ZM13.3335 12.0833C13.3335 12.3125 13.146 12.5 12.9168 12.5H7.0835C6.85433 12.5 6.66683 12.3125 6.66683 12.0833V7.91667C6.66683 7.6875 6.85433 7.5 7.0835 7.5H12.9168C13.146 7.5 13.3335 7.6875 13.3335 7.91667V12.0833ZM10.8335 9.16667C11.0627 9.16667 11.2502 8.97917 11.2502 8.75C11.2502 8.52083 11.0627 8.33333 10.8335 8.33333H10.4168V8.32917C10.4168 8.1 10.2293 7.9125 10.0002 7.9125C9.771 7.9125 9.5835 8.1 9.5835 8.32917V8.33333H9.16683C8.93766 8.33333 8.75016 8.52083 8.75016 8.75V10C8.75016 10.2292 8.93766 10.4167 9.16683 10.4167H10.4168V10.8333H9.16683C8.93766 10.8333 8.75016 11.0208 8.75016 11.25C8.75016 11.4792 8.93766 11.6667 9.16683 11.6667H9.5835C9.5835 11.8958 9.771 12.0833 10.0002 12.0833C10.2293 12.0833 10.4168 11.8958 10.4168 11.6667H10.8335C11.0627 11.6667 11.2502 11.4792 11.2502 11.25V10C11.2502 9.77083 11.0627 9.58333 10.8335 9.58333H9.5835V9.16667H10.8335Z" fill="white"/>
</g>
''';

const String _eatAndDrinkIcon = '''
<g transform="scale(0.5) translate(6 6.5)">
<path fill-rule="evenodd" clip-rule="evenodd" d="M19.5 10C19.5 4.75329 15.2467 0.5 10 0.5C4.75329 0.5 0.5 4.75329 0.5 10C0.5 15.2467 4.75329 19.5 10 19.5C15.2467 19.5 19.5 15.2467 19.5 10ZM1 10C1 5.02944 5.02944 1 10 1C14.9706 1 19 5.02944 19 10C19 14.9706 14.9706 19 10 19C5.02944 19 1 14.9706 1 10Z" fill="white"/>
<circle cx="10" cy="10" r="9" fill="#FFA858"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M19 10C19 5.02944 14.9706 1 10 1C5.02944 1 1 5.02944 1 10C1 14.9706 5.02944 19 10 19C14.9706 19 19 14.9706 19 10ZM2 10C2 5.58172 5.58172 2 10 2C14.4183 2 18 5.58172 18 10C18 14.4183 14.4183 18 10 18C5.58172 18 2 14.4183 2 10Z" fill="#233459" fill-opacity="0.35"/>
<path d="M12 7V10C12 10.55 12.45 11 13 11H13.5V14.5C13.5 14.775 13.725 15 14 15C14.275 15 14.5 14.775 14.5 14.5V5.565C14.5 5.24 14.195 5 13.88 5.075C12.8 5.34 12 6.255 12 7ZM9.5 8.5H8.5V5.5C8.5 5.225 8.275 5 8 5C7.725 5 7.5 5.225 7.5 5.5V8.5H6.5V5.5C6.5 5.225 6.275 5 6 5C5.725 5 5.5 5.225 5.5 5.5V8.5C5.5 9.605 6.395 10.5 7.5 10.5V14.5C7.5 14.775 7.725 15 8 15C8.275 15 8.5 14.775 8.5 14.5V10.5C9.605 10.5 10.5 9.605 10.5 8.5V5.5C10.5 5.225 10.275 5 10 5C9.725 5 9.5 5.225 9.5 5.5V8.5Z" fill="white"/>
</g>
''';

const String _fuelingIcon = '''
<g transform="scale(0.5) translate(6 6.5)">
<path fill-rule="evenodd" clip-rule="evenodd" d="M19.5 10C19.5 4.75329 15.2467 0.5 10 0.5C4.75329 0.5 0.5 4.75329 0.5 10C0.5 15.2467 4.75329 19.5 10 19.5C15.2467 19.5 19.5 15.2467 19.5 10ZM1 10C1 5.02944 5.02944 1 10 1C14.9706 1 19 5.02944 19 10C19 14.9706 14.9706 19 10 19C5.02944 19 1 14.9706 1 10Z" fill="white"/>
<circle cx="10" cy="10" r="9" fill="#69C8FF"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M19 10C19 5.02944 14.9706 1 10 1C5.02944 1 1 5.02944 1 10C1 14.9706 5.02944 19 10 19C14.9706 19 19 14.9706 19 10ZM2 10C2 5.58172 5.58172 2 10 2C14.4183 2 18 5.58172 18 10C18 14.4183 14.4183 18 10 18C5.58172 18 2 14.4183 2 10Z" fill="#233459" fill-opacity="0.35"/>
<path d="M13.885 7.615L13.89 7.61L12.295 6.015C12.15 5.87 11.91 5.87 11.765 6.015C11.62 6.16 11.62 6.4 11.765 6.545L12.555 7.335C12.03 7.535 11.675 8.07 11.765 8.69C11.845 9.24 12.315 9.685 12.865 9.745C13.1 9.77 13.305 9.73 13.5 9.645V13.25C13.5 13.525 13.275 13.75 13 13.75C12.725 13.75 12.5 13.525 12.5 13.25V11C12.5 10.45 12.05 10 11.5 10H11V6.5C11 5.95 10.55 5.5 10 5.5H7C6.45 5.5 6 5.95 6 6.5V14C6 14.275 6.225 14.5 6.5 14.5H10.5C10.775 14.5 11 14.275 11 14V10.75H11.75V13.18C11.75 13.835 12.22 14.43 12.87 14.495C13.62 14.57 14.25 13.985 14.25 13.25V8.5C14.25 8.155 14.11 7.84 13.885 7.615ZM10 9H7V7C7 6.725 7.225 6.5 7.5 6.5H9.5C9.775 6.5 10 6.725 10 7V9ZM13 9C12.725 9 12.5 8.775 12.5 8.5C12.5 8.225 12.725 8 13 8C13.275 8 13.5 8.225 13.5 8.5C13.5 8.775 13.275 9 13 9Z" fill="white"/>
</g>
''';

const String _unknownIcon = '''
<g transform="scale(0.5) translate(4 4.5)">
<path fill-rule="evenodd" clip-rule="evenodd" d="M19.6465 9.49197C19.6465 4.3293 15.374 0.135498 10.1378 0.135498C4.90466 0.135498 0.646484 4.32636 0.646484 9.49197C0.646484 13.3665 1.50614 15.7662 5.27101 19.528L10.1371 24.3378L15.0229 19.5271C18.7868 15.7662 19.6465 13.3665 19.6465 9.49197ZM1.15033 9.23084C1.29093 4.46031 5.27121 0.635498 10.1378 0.635498C15.0929 0.635498 19.1465 4.60066 19.1465 9.49197L19.1435 10.0881L19.1318 10.5487C19.0455 12.7805 18.4514 15.4752 14.369 19.4705L10.1378 23.6355L5.64482 19.1939C1.63772 15.1731 1.19998 12.4897 1.15229 10.2502L1.14693 9.78766L1.15033 9.23084Z" fill="white"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M10.1378 23.6355L5.92402 19.4705C1.17695 14.8248 1.14648 11.9376 1.14648 9.49197C1.14648 4.60066 5.18273 0.635498 10.1378 0.635498C15.0929 0.635498 19.1465 4.60066 19.1465 9.49197C19.1465 11.9376 19.116 14.8248 14.369 19.4705L10.1378 23.6355Z" fill="#08A8A4"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M19.1465 9.49197C19.1465 4.60066 15.0929 0.635498 10.1378 0.635498C5.18273 0.635498 1.14648 4.60066 1.14648 9.49197C1.14648 11.9376 1.17695 14.8248 5.92402 19.4705L10.1378 23.6355L14.369 19.4705C18.2616 15.661 18.9827 13.034 19.1162 10.8632L19.1318 10.5487L19.1435 10.0881L19.1465 9.49197ZM2.14648 9.49197C2.14648 5.16018 5.72778 1.6355 10.1378 1.6355C14.5517 1.6355 18.1465 5.16403 18.1465 9.49197L18.1448 9.77991C18.1056 13.0059 17.3744 14.9877 14.2467 18.1795L13.6695 18.7558L10.1385 22.2305L6.33178 18.4676C2.86597 15.0072 2.14648 12.9874 2.14648 9.49197Z" fill="#233459" fill-opacity="0.35"/>
</g>
''';

const String _poiTemplate = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {{0}} 24" fill="#0F1621">
<rect x="0.5" y=".5" rx="2" ry="2" width="{{1}}" height="16"/>
<polygon transform="translate({{2}} 0)" points="0,16 5,22 10,16"/>
{{3}}
<text x="16" y="12" font-size="9" fill="#ffffff" stroke-width="0">{{4}}</text>
</svg>
''';

/// Class representing SVG image for a POI.
class SvgInfo {
  final String svg;
  final int width;
  final int height;

  SvgInfo({
    required this.svg,
    required this.width,
    required this.height,
  });
}

enum PoiIconType {
  atm,
  eatAndDrink,
  fueling,
  unknown,
}

/// Helper class that allows to create SVG images for desired POI type and text.
class PoiSVGHelper {
  static const int _iconHeight = 24;
  static const int _minIconSize = 20;
  static const int _charAverageWidth = 4;

  /// returns SVG images for desired POI icon [type] and [text].
  static SvgInfo getPoiSvgForCategoryAndText({
    required PoiIconType type,
    String? text,
  }) {
    int width = text != null ? text.length * _charAverageWidth + _minIconSize : 0;

    String icon;
    switch (type) {
      case PoiIconType.atm:
        icon = _atmIcon;
        break;
      case PoiIconType.eatAndDrink:
        icon = _eatAndDrinkIcon;
        break;
      case PoiIconType.fueling:
        icon = _fuelingIcon;
        break;
      case PoiIconType.unknown:
        icon = _unknownIcon;
        break;
    }

    return SvgInfo(
      svg: Util.formatString(_poiTemplate, [
        width, // view port width
        width - 1, // rectangle width
        width / 2 - 5, // anchor offset
        icon, // icon
        text, // text to display
      ]),
      width: width,
      height: _iconHeight,
    );
  }
}
