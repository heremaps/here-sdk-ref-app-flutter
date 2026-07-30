/*
 * Copyright (C) 2020-2026 HERE Europe B.V.
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/maploader.dart';
import 'package:here_sdk/routing.dart' as Routing;
import 'package:here_sdk/search.dart';
import 'package:here_sdk_reference_application_flutter/environment.dart';
import 'package:here_sdk_reference_application_flutter/l10n/generated/app_localizations.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/catalog_configuration_data.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/custom_catalog_configuration_screen.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/custom_engine_options_data.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/custom_engine_options_screen.dart';
import 'package:here_sdk_reference_application_flutter/sdk_engine_configuration/sdk_engine_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/application_preferences.dart';
import 'common/custom_map_style_settings.dart';
import 'common/ui_style.dart';
import 'download_maps/download_maps_screen.dart';
import 'download_maps/map_loader_controller.dart';
import 'download_maps/map_regions_list_screen.dart';
import 'landing_screen.dart';
import 'navigation/navigation_screen.dart';
import 'positioning/here_privacy_notice_handler.dart';
import 'positioning/positioning_engine.dart';
import 'route_preferences/route_preferences_model.dart';
import 'routing/route_details_screen.dart';
import 'routing/routing_screen.dart';
import 'routing/waypoint_info.dart';
import 'routing/waypoints_controller.dart';
import 'search/recent_search_data_model.dart';
import 'search/search_results_screen.dart';

/// The entry point of the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SdkContext.init();

  // Obtain an instance of SharedPreferences for persistent storage.
  final SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

  // Load catalog configurations data from preferences.
  final List<CatalogConfigurationData>? catalogConfigurations =
      AppPreferences.loadSdkOptionsCatalogConfigurationFromPrefs(_sharedPreferences);

  // Load custom engineOptions data from preferences.
  final CustomEngineOptionsData? customEngineOptions =
      await AppPreferences.loadSdkOptionsCustomEngineOptionsFromStorage();

  // Create SDKOptions with authentication, applying catalog configurations and custom engine options if available.
  final SDKOptions sdkOptions = await getSDKOptions(
    sdkOptions: SDKOptions.withAuthenticationMode(
      AuthenticationMode.withKeySecret(Environment.accessKeyId, Environment.accessKeySecret),
    ),
    catalogConfigurations: catalogConfigurations != null && catalogConfigurations.isNotEmpty
        ? catalogConfigurations
        : null,
    customEngineOptions: customEngineOptions?.customUrls.isNotEmpty ?? false ? customEngineOptions : null,
  );

  createSDKNativeEngine(
    sdkOptions: sdkOptions,
    onSuccess: () => runApp(MyApp()),
    onFailure: (_) => runApp(const InitErrorScreen()),
  );
}

/// Application root widget.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    SdkContext.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecentSearchDataModel()),
        ChangeNotifierProvider(create: (context) => RoutePreferencesModel.withDefaults()),
        ChangeNotifierProvider(create: (context) => MapLoaderController()),
        ChangeNotifierProvider(create: (context) => AppPreferences()),
        Provider(create: (context) => PositioningEngine()),
        ChangeNotifierProvider(create: (context) => CustomMapStyleSettings()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale('en', '')],
        theme: UIStyle.lightTheme,
        onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
        onGenerateRoute: (RouteSettings settings) {
          Map<String, WidgetBuilder> routes = {
            LandingScreen.navRoute: (BuildContext context) => LandingScreen(key: LandingScreen.landingScreenKey),
            SearchResultsScreen.navRoute: (BuildContext context) {
              List<dynamic> arguments = settings.arguments as List<dynamic>;
              assert(arguments.length == 4);
              return SearchResultsScreen(
                queryString: arguments[0] as String,
                places: arguments[1] as List<Place>,
                currentPosition: arguments[2] as GeoCoordinates,
                isRecentSearchResult: arguments[3] as bool,
              );
            },
            RoutingScreen.navRoute: (BuildContext context) {
              List<dynamic> arguments = settings.arguments as List<dynamic>;
              assert(arguments.length == 3);
              return RoutingScreen(
                currentPosition: arguments[0] as GeoCoordinates,
                departure: arguments[1] as WayPointInfo,
                destination: arguments[2] as WayPointInfo,
              );
            },
            RouteDetailsScreen.navRoute: (BuildContext context) {
              List<dynamic> arguments = settings.arguments as List<dynamic>;
              assert(arguments.length == 2);
              return RouteDetailsScreen(
                route: arguments[0] as Routing.Route,
                wayPointsController: arguments[1] as WayPointsController,
              );
            },
            NavigationScreen.navRoute: (BuildContext context) {
              List<dynamic> arguments = settings.arguments as List<dynamic>;
              assert(arguments.length == 2);
              return NavigationScreen(
                route: arguments[0] as Routing.Route,
                wayPoints: arguments[1] as List<Routing.Waypoint>,
              );
            },
            DownloadMapsScreen.navRoute: (BuildContext context) {
              return DownloadMapsScreen();
            },
            HerePrivacyNoticeScreen.navRoute: (BuildContext context) => HerePrivacyNoticeScreen(),
            MapRegionsListScreen.navRoute: (BuildContext context) {
              List<dynamic> arguments = settings.arguments as List<dynamic>;
              assert(arguments.length == 1);
              return MapRegionsListScreen(regions: arguments[0] as List<Region>);
            },
            CustomCatalogConfigurationScreen.navRoute: (BuildContext context) => CustomCatalogConfigurationScreen(),
            CustomEngineOptionsScreen.navRoute: (BuildContext context) => CustomEngineOptionsScreen(),
          };

          WidgetBuilder builder = routes[settings.name]!;
          return MaterialPageRoute(builder: (ctx) => builder(ctx), settings: settings);
        },
        initialRoute: LandingScreen.navRoute,
      ),
    );
  }
}

class InitErrorScreen extends StatelessWidget {
  const InitErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(UIStyle.contentMarginExtraHuge),
                child: Text(
                  AppLocalizations.of(context)!.sdkInitFailError,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          );
        },
      ),
      theme: UIStyle.lightTheme,
      localizationsDelegates: [AppLocalizations.delegate],
    );
  }
}
