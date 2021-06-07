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

import 'route_preferences/route_preferences_model.dart';
import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'landing_screen.dart';
import 'navigation/navigation_screen.dart';
import 'search/recent_search_data_model.dart';
import 'routing/route_details_screen.dart';
import 'routing/routing_screen.dart';
import 'search/search_results_screen.dart';
import 'common/ui_style.dart';

/// The entry point of the application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SdkContext.init(IsolateOrigin.main);
  runApp(MyApp());
}

/// Application root widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecentSearchDataModel()),
        ChangeNotifierProvider(create: (context) => RoutePreferencesModel.withDefaults()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
        ],
        theme: UIStyle.lightTheme,
        onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle,
        onGenerateRoute: (RouteSettings settings) {
          Map<String, WidgetBuilder> routes = {
            LandingScreen.navRoute: (BuildContext context) => LandingScreen(),
            SearchResultsScreen.navRoute: (BuildContext context) {
              List<Object> arguments = settings.arguments;
              assert(arguments != null && arguments.length == 3);
              return SearchResultsScreen(
                queryString: arguments[0],
                places: arguments[1],
                currentPosition: arguments[2],
              );
            },
            RoutingScreen.navRoute: (BuildContext context) {
              List<Object> arguments = settings.arguments;
              assert(arguments != null && arguments.length == 3);
              return RoutingScreen(
                currentPosition: arguments[0],
                departure: arguments[1],
                destination: arguments[2],
              );
            },
            RouteDetailsScreen.navRoute: (BuildContext context) {
              List<Object> arguments = settings.arguments;
              assert(arguments != null && arguments.length == 2);
              return RouteDetailsScreen(
                route: arguments[0],
                wayPointsController: arguments[1],
              );
            },
            NavigationScreen.navRoute: (BuildContext context) {
              List<Object> arguments = settings.arguments;
              assert(arguments != null && arguments.length == 2);
              return NavigationScreen(
                route: arguments[0],
                wayPoints: arguments[1],
              );
            },
          };

          WidgetBuilder builder = routes[settings.name];
          assert(builder != null);
          return MaterialPageRoute(
            builder: (ctx) => builder(ctx),
            settings: settings,
          );
        },
        initialRoute: LandingScreen.navRoute,
      ),
    );
  }
}
