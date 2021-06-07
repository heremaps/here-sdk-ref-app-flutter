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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.threading.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/search.dart';
import 'package:provider/provider.dart';

import '../common/dismiss_keyboard_on_scroll.dart';
import '../common/draggable_popup_here_logo_helper.dart';
import 'recent_search_data_model.dart';
import 'search_results_screen.dart';
import '../common/ui_style.dart';
import '../common/util.dart' as Util;

class SearchResult {
  final Place place; // if null the current location should be used

  SearchResult({this.place});

  SearchResult.currentLocation() : place = null;
}

/// Displays a popup window with a text search for a place. The [currentPosition] is used as center of the search area.
Future<SearchResult> showSearchPopup({
  @required BuildContext context,
  @required GeoCoordinates currentPosition,
  @required HereMapController hereMapController,
  @required GlobalKey hereMapKey,
  String currentLocationTitle = null,
}) async {
  return showModalBottomSheet<SearchResult>(
    context: context,
    shape: UIStyle.topRoundedBorder(),
    isScrollControlled: true,
    builder: (context) => DraggablePopupHereLogoHelper(
      hereMapController: hereMapController,
      hereMapKey: hereMapKey,
      modal: true,
      draggableScrollableSheet: DraggableScrollableSheet(
        maxChildSize: UIStyle.maxBottomDraggableSheetSize,
        initialChildSize: UIStyle.maxBottomDraggableSheetSize,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) => _SearchPopup(
          currentPosition: currentPosition,
          controller: controller,
          currentLocationTitle: currentLocationTitle,
        ),
      ),
    ),
  ).then((value) {
    hereMapController.setWatermarkPosition(WatermarkPlacement.bottomLeft, 0);
    return value;
  });
}

class _SearchPopup extends StatefulWidget {
  final GeoCoordinates currentPosition;
  final ScrollController controller;
  final String currentLocationTitle;

  _SearchPopup({
    Key key,
    @required this.currentPosition,
    this.controller,
    this.currentLocationTitle,
  }) : super(key: key);

  @override
  _SearchPopupState createState() => _SearchPopupState();
}

class _SearchPopupState extends State<_SearchPopup> {
  static const int _kMaxSearchSuggestion = 20;
  static const double _kHeaderHeight = 110;
  static const double _kHeaderHeightExt = 140;

  final TextEditingController _dstTextEditCtrl = new TextEditingController();
  final SearchOptions _searchOptions = new SearchOptions(LanguageCode.enUs, _kMaxSearchSuggestion);
  final SearchEngine _searchEngine = SearchEngine();

  GeoCoordinates _lastPosition;
  List<Suggestion> _suggestions;
  List<Place> _suggestionsPlaces = []; // we must free all the places we get from suggestions, so we store them
  List<Place> _searchResults;
  Place _searchResult;
  Map<String, Place> _recentPlaces = {};
  TaskHandle _searchTaskHandle;
  bool _searchInProgress = false;
  SearchError _lastError;

  @override
  void initState() {
    _lastPosition = widget.currentPosition;
    super.initState();
  }

  @override
  void dispose() {
    _dstTextEditCtrl.dispose();
    _searchEngine.release();
    _clearSuggestions();
    _clearSearchResults();
    _clearRecentPlace();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Consumer<RecentSearchDataModel>(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          _stopCurrentSearch();
          return true;
        },
        child: DismissKeyboardOnScroll(
          child: SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  controller: widget.controller,
                  slivers: [
                    SliverAppBar(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UIStyle.popupsBorderRadius),
                      ),
                      leading: Container(),
                      leadingWidth: 0,
                      backgroundColor: colorScheme.background,
                      pinned: true,
                      primary: false,
                      titleSpacing: UIStyle.contentMarginMedium,
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchHeader(context),
                          Container(
                            height: UIStyle.contentMarginMedium,
                          ),
                          if (widget.currentLocationTitle != null)
                            ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.gps_fixed,
                                color: colorScheme.primary,
                                size: UIStyle.mediumIconSize,
                              ),
                              title: Text(
                                widget.currentLocationTitle,
                                style: TextStyle(
                                  fontSize: UIStyle.bigFontSize,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              onTap: () {
                                _stopCurrentSearch();
                                Navigator.of(context).pop(SearchResult.currentLocation());
                              },
                            ),
                          _buildResultsHeader(context),
                        ],
                      ),
                      toolbarHeight: widget.currentLocationTitle != null ? _kHeaderHeightExt : _kHeaderHeight,
                    ),
                    if (_lastError != null) _buildErrorWidget(context),
                    if (_lastError == null)
                      _suggestions != null ? _buildSuggestionsWidget(context) : _buildRecentSearchWidget(context),
                  ],
                ),
                if (_searchInProgress)
                  Container(
                    color: Colors.white54,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    Color foregroundColor = Theme.of(context).colorScheme.onSecondary;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: foregroundColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: UIStyle.contentMarginLarge,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: AppLocalizations.of(context).searchHint,
                    ),
                    controller: _dstTextEditCtrl,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => _suggestionsForText(value),
                    onSubmitted: (value) => _searchForText(context, value),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  color: foregroundColor,
                  onPressed: () => setState(() {
                    _lastError = null;
                    _dstTextEditCtrl.clear();
                    _clearSuggestions();
                  }),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context).cancelTitle,
            style: TextStyle(
              fontSize: UIStyle.bigFontSize,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsHeader(BuildContext context) {
    return Text(
      _suggestions != null
          ? AppLocalizations.of(context).matchingResultsTitle
          : AppLocalizations.of(context).recentlySearchTitle,
      style: TextStyle(
        fontSize: UIStyle.bigFontSize,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }

  List<TextSpan> _makeHighlightedText(String text, List<IndexRange> highlights) {
    List<TextSpan> result = [];

    if (highlights == null) {
      result.add(TextSpan(
        text: text,
      ));
    } else {
      int lastPosition = 0;

      highlights.forEach((element) {
        result.add(TextSpan(
          text: text.substring(lastPosition, element.start),
        ));
        result.add(TextSpan(
            text: text.substring(element.start, element.end),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )));
        lastPosition = element.end;
      });

      result.add(TextSpan(
        text: text.substring(lastPosition),
      ));
    }

    return result;
  }

  Widget _buildSearchTile(BuildContext context, String title, {Map<HighlightType, List<IndexRange>> highlights}) {
    List<TextSpan> textSpans = _makeHighlightedText(title, (highlights ?? const {})[HighlightType.title]);

    return ListTile(
      leading: Icon(Icons.search),
      title: RichText(
        text: TextSpan(
          text: "\"",
          style: TextStyle(
            fontSize: UIStyle.hugeFontSize,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            ...textSpans,
            TextSpan(
              text: "\"",
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Container(),
      onTap: () => _searchForText(context, title),
    );
  }

  Widget _buildPlaceTile(BuildContext context, Place place, {Map<HighlightType, List<IndexRange>> highlights}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    List<TextSpan> titleTextSpans = _makeHighlightedText(place.title, (highlights ?? const {})[HighlightType.title]);
    List<TextSpan> addressTextSpans =
        _makeHighlightedText(place.address.addressText, (highlights ?? const {})[HighlightType.addressLabel]);

    return ListTile(
      leading: Icon(Icons.location_on_rounded),
      title: RichText(
        text: TextSpan(
          text: "",
          style: TextStyle(
            fontSize: UIStyle.hugeFontSize,
            color: colorScheme.primary,
          ),
          children: titleTextSpans,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(
          top: UIStyle.contentMarginSmall,
          bottom: UIStyle.contentMarginSmall,
        ),
        child: RichText(
          text: TextSpan(
            text: "",
            style: TextStyle(
              color: colorScheme.onSecondary,
              fontSize: UIStyle.bigFontSize,
            ),
            children: [
              TextSpan(
                text: Util.makeDistanceString(context, place.distanceInMeters),
                style: TextStyle(
                  color: colorScheme.secondary,
                ),
              ),
              ...addressTextSpans,
            ],
          ),
          maxLines: 2,
        ),
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
        RecentSearchDataModel model = Provider.of<RecentSearchDataModel>(context, listen: false);
        model.insertPlaceId(place.id);
        _showSearchResults(context, null, [place]);
      },
    );
  }

  Stream<List<RecentSearchPlace>> _recentSearchItemsStream(BuildContext context) async* {
    RecentSearchDataModel model = Provider.of<RecentSearchDataModel>(context, listen: false);
    List<RecentSearchItem> items = await model.getData();
    List<RecentSearchPlace> result = [];

    for (RecentSearchItem item in items) {
      if (item.placeId == null) {
        result.add(RecentSearchPlace(item.title, null));
      } else {
        Place place = _recentPlaces[item.placeId];

        if (place == null) {
          final Completer<Place> completer = Completer();
          // try to find a place by id, if it is not there, then remove it from the list
          TaskHandle taskHandle = _searchEngine
              .searchByPlaceIdWithLanguageCode(PlaceIdQuery(item.placeId), LanguageCode.enUs, (error, place) {
            if (error != null) {
              if (error == SearchError.noResultsFound) {
                model.delete(item.id);
              }
              completer.complete();
            }

            completer.complete(place);
          });

          place = await completer.future;
          taskHandle.release();

          if (place == null) {
            continue;
          }

          _recentPlaces[item.placeId] = place;
        }

        result.add(RecentSearchPlace(item.title, place));
      }

      yield result;
    }
  }

  Widget _buildRecentSearchWidget(BuildContext context) {
    return StreamBuilder<List<RecentSearchPlace>>(
      initialData: [],
      stream: _recentSearchItemsStream(context),
      builder: (context, snapshot) => snapshot.hasData
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index.isOdd) {
                    return Divider(
                      height: 1,
                    );
                  }

                  final RecentSearchPlace item = snapshot.data[index ~/ 2];
                  return item.place != null
                      ? _buildPlaceTile(context, item.place)
                      : _buildSearchTile(context, item.title);
                },
                semanticIndexCallback: (Widget widget, int localIndex) {
                  if (localIndex.isEven) {
                    return localIndex ~/ 2;
                  }
                  return null;
                },
                childCount: snapshot.data.length * 2 - 1,
              ),
            )
          : SliverFillRemaining(),
    );
  }

  Widget _buildSuggestionsWidget(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
            );
          }

          Widget suggestionsWidget;
          Suggestion suggestion = _suggestions[index ~/ 2];
          Place place = suggestion.place;
          Map<HighlightType, List<IndexRange>> highlights = suggestion.getHighlights();

          if (place == null) {
            suggestionsWidget = _buildSearchTile(
              context,
              suggestion.title,
              highlights: highlights,
            );
          } else {
            _suggestionsPlaces.add(place);
            suggestionsWidget = _buildPlaceTile(
              context,
              place,
              highlights: highlights,
            );
          }

          highlights?.forEach((key, value) => value?.forEach((element) => element.release()));

          return suggestionsWidget;
        },
        semanticIndexCallback: (Widget widget, int localIndex) {
          if (localIndex.isEven) {
            return localIndex ~/ 2;
          }
          return null;
        },
        childCount: _suggestions.length * 2 - 1,
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context);

    if (_lastError == SearchError.noResultsFound) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/nothing_found.svg"),
              Text(
                appLocalizations.noResultsFoundText,
                style: TextStyle(
                  fontSize: UIStyle.hugeFontSize,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                appLocalizations.noResultsFoundDescription,
                style: TextStyle(
                  fontSize: UIStyle.bigFontSize,
                  color: colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            Util.formatString(appLocalizations.searchErrorText, [_lastError.toString()]),
            style: TextStyle(
              fontSize: UIStyle.hugeFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      );
    }
  }

  void _clearSuggestions() {
    if (_suggestions != null) {
      _suggestions.forEach((element) => element.release());
      _suggestions = null;
    }
    _suggestionsPlaces.forEach((place) {
      if (place != _searchResult) {
        place.release();
      }
    });
    _suggestionsPlaces.clear();
  }

  void _clearSearchResults() {
    if (_searchResults != null) {
      _searchResults.forEach((place) {
        if (place != _searchResult) {
          place.release();
        }
      });
      _searchResults = null;
    }
  }

  void _clearRecentPlace() {
    _recentPlaces.values.forEach((place) {
      if (place != _searchResult) {
        place.release();
      }
    });
  }

  void _stopCurrentSearch() {
    if (_searchTaskHandle != null) {
      _searchTaskHandle.cancel();
      _searchTaskHandle.release();
      _searchTaskHandle = null;
    }
  }

  void _suggestionsForText(String text) {
    _stopCurrentSearch();

    if (_lastError != null) {
      setState(() {
        _lastError = null;
      });
    }

    if (text.isEmpty) {
      // clear suggestions
      setState(() {
        _clearSuggestions();
      });
    } else {
      // start searching
      _searchTaskHandle =
          _searchEngine.suggest(TextQuery.withAreaCenter(text, _lastPosition), _searchOptions, (error, suggestions) {
        if (error != null) {
          print('Search failed. Error: ${error.toString()}');
        }

        setState(() {
          _clearSuggestions();
          _suggestions = suggestions ?? [];
        });
      });
    }
  }

  void _searchForText(BuildContext context, String text) {
    _stopCurrentSearch();
    FocusScope.of(context).unfocus();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _searchInProgress = true;
    });

    RecentSearchDataModel model = Provider.of<RecentSearchDataModel>(context, listen: false);
    model.insertText(text);

    _searchTaskHandle = _searchEngine.searchByText(TextQuery.withAreaCenter(text, _lastPosition), _searchOptions,
        (error, places) async {
      if (error != null) {
        print('Search failed. Error: ${error.toString()}');
      } else {
        _clearSearchResults();
        _searchResults = places;
        await _showSearchResults(context, text, places);
      }
      setState(() {
        _lastError = error;
        _searchInProgress = false;
      });
    });
  }

  void _showSearchResults(BuildContext context, String queryString, List<Place> places) async {
    final result = await Navigator.of(context).pushNamed(
      SearchResultsScreen.navRoute,
      arguments: [queryString, places, _lastPosition],
    );

    if (result != null) {
      if (result is GeoCoordinates) {
        _lastPosition = result;
      } else if (result is Place) {
        _searchResult = result;
        Navigator.of(context).pop(SearchResult(
          place: _searchResult,
        ));
      } else {
        assert(false);
      }
    }
  }
}
