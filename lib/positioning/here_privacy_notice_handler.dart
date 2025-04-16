/*
 * Copyright (C) 2025 HERE Europe B.V.
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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/application_preferences.dart';
import '../common/gradient_elevated_button.dart';
import '../common/ui_style.dart';

// HERE Privacy Notice Url
const String _herePrivacyNoticeUrl = 'https://legal.here.com/here-network-positioning-via-sdk';

const EdgeInsets _commonPadding = const EdgeInsets.symmetric(
  vertical: UIStyle.contentMarginLarge,
  horizontal: UIStyle.contentMarginLarge,
);

/// A screen that shows the HERE Privacy Notice, typically from Settings,
/// to inform users about data handling and ensure privacy compliance.
class HerePrivacyNoticeScreen extends StatelessWidget {
  HerePrivacyNoticeScreen({super.key});
  static const String navRoute = "/here_privacy_notice_screen";

  @override
  Widget build(BuildContext context) {
    AppLocalizations localized = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localized.privacyNotice)),
      body: Padding(
        padding: _commonPadding,
        child: Column(
          children: <Widget>[
            Text(localized.privacyNoticePlaceholder, style: TextStyle(fontSize: UIStyle.bigFontSize)),
            HerePrivacyNoticeWidget(),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget that shows the HERE Privacy Notice with a link to more details.
class HerePrivacyNoticeWidget extends StatelessWidget {
  const HerePrivacyNoticeWidget({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localized = AppLocalizations.of(context)!;
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: UIStyle.bigFontSize),
        children: [
          TextSpan(text: localized.herePrivacyNotice),
          TextSpan(
            text: _herePrivacyNoticeUrl,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => _launchURL(_herePrivacyNoticeUrl),
          ),
        ],
      ),
    );
  }
}

/// A dialog that displays the HERE Privacy Notice during app startup as part of the FTU (First-Time Use) flow.
class HerePrivacyDialog extends StatelessWidget {
  const HerePrivacyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localized = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        scrollable: true,
        title: Text(localized.welcome, textAlign: TextAlign.center),
        content: Column(children: <Widget>[Text(localized.welcomeMessage), HerePrivacyNoticeWidget()]),
        actions: [
          GradientElevatedButton(
            title: Text(localized.continueTitle),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
        contentPadding: _commonPadding,
        actionsPadding: _commonPadding,
        insetPadding: _commonPadding,
      ),
    );
  }
}

/// Shows the HERE Privacy Dialog, typically during app startup as part of the FTU flow.
Future<void> showHerePrivacyDialog(BuildContext context) async {
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return const HerePrivacyDialog();
    },
  );
  if (accepted == true) {
    Provider.of<AppPreferences>(context, listen: false).isHerePrivacyDialogShown = true;
  }
}
