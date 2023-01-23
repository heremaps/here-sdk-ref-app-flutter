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
import 'package:here_sdk/search.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A class that represents the recently searched element.
class RecentSearchItem {
  /// Unique id.
  final int id;

  /// Title.
  final String? title;

  /// [Place].
  final Place? place;

  RecentSearchItem(this.id, this.title, this.place);
}

/// Class that implements a storage for the MRU list for the searching for places.
class RecentSearchDataModel extends ChangeNotifier {
  static final _kDbName = "recent_search";
  static final _kTableName = "items";
  static final _kTitleField = "title";
  static final _kPlaceIdField = "place_id";
  static final _kPlaceField = "place";
  static final _kTimeStampField = "timestamp";

  late Database _db;
  late Future<void> _initFuture;

  RecentSearchDataModel() {
    _initFuture = _init();
  }

  Future<void> _init() async {
    final String createTableSQL = "CREATE TABLE $_kTableName("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$_kTitleField TEXT, "
        "$_kPlaceIdField TEXT, "
        "$_kPlaceField TEXT, "
        "$_kTimeStampField DATETIME)";
    final String deleteTableSQL = "DROP TABLE $_kTableName";

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, _kDbName),
      onCreate: (db, version) => db.execute(createTableSQL),
      onUpgrade: (db, oldVersion, newVersion) => db.execute(deleteTableSQL).then((value) => db.execute(createTableSQL)),
      version: 2,
    );

    notifyListeners();
  }

  Future<int> _updateTimeStamp(int id) {
    return _db.update(
      _kTableName,
      {
        _kTimeStampField: DateTime.now().millisecondsSinceEpoch,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Adds [text] to the list of recently searched items.
  Future<void> insertText(String text) async {
    await _initFuture;
    final queryResult = await _db.query(
      _kTableName,
      where: "$_kTitleField = ?",
      whereArgs: [text],
      limit: 1,
    );
    if (queryResult.isNotEmpty) {
      await _updateTimeStamp(queryResult.first["id"] as int);
    } else {
      await _db.insert(
        _kTableName,
        {
          _kTitleField: text,
          _kTimeStampField: DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    notifyListeners();
  }

  /// Adds id of a place to the list of recently searched items.
  Future<void> insertPlace(Place place) async {
    await _initFuture;
    final queryResult = await _db.query(
      _kTableName,
      where: "$_kPlaceIdField = ?",
      whereArgs: [place.id],
      limit: 1,
    );
    if (queryResult.isNotEmpty) {
      await _updateTimeStamp(queryResult.first["id"] as int);
    } else {
      await _db.insert(
        _kTableName,
        {
          _kPlaceIdField: place.id,
          _kPlaceField: place.serializeCompact(),
          _kTimeStampField: DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    notifyListeners();
  }

  /// Removes an element from the list.
  Future<void> delete(int id) async {
    await _initFuture;
    await _db.delete(
      _kTableName,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Returns recently searched items list.
  Future<List<RecentSearchItem>> getData() async {
    await _initFuture;
    List<Map<String, dynamic>> results = await _db.query(_kTableName, orderBy: "$_kTimeStampField DESC");
    return results.map((e) {
      String? placeString = e[_kPlaceField] as String?;
      Place? place = placeString != null ? Place.deserialize(placeString) : null;
      return RecentSearchItem(e["id"] as int, e[_kTitleField] as String?, place);
    }).toList();
  }
}
