import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studento/model/class_item.dart';

class ClassDB {
  static final ClassDB _instance = ClassDB.internal();
  factory ClassDB() => _instance;

  final String tableName = "Classes";

  final String columnId = "id";
  final String columnSubject = "subject";
  final String columnStartTime = "startTime";
  final String columnEndTime = "endTime";
  final String columnTeacher = "teacher";
  final String columnWeekDay = "weekDay";
  final String columnLocation = "location";

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await (initDb());
    return _db;
  }

  ClassDB.internal();

  Future initDb() async {
    Directory databasesDirPath = await getApplicationDocumentsDirectory();
    String path = join(databasesDirPath.path, "classes.db");

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableName(id INTEGER PRIMARY KEY, $columnWeekDay INTEGER, $columnSubject TEXT, $columnStartTime TEXT, $columnEndTime TEXT, $columnTeacher TEXT, $columnLocation TEXT)");
    print("Table is created");
  }

  /// Save a class to the database.
  Future<int> saveClass(ClassItem item) async {
    var dbClient = await (db);
    int res = await dbClient!.insert(tableName, item.toMap());
    print(res.toString());
    return res;
  }

  /// Get classes by their weekDay.
  Future<List<ClassItem>?> getClasses({required int weekDay}) async {
    var dbClient = await db;
    var result = await dbClient!.rawQuery(
        "SELECT * FROM $tableName WHERE $columnWeekDay = $weekDay ORDER BY $columnStartTime ASC");

    List x = result.toList();
    List<ClassItem> classes = [];

    if (x.isNotEmpty) {
      for (var c in x) {
        classes.add(ClassItem.fromMap(c));
      }
      return classes;
    }

    return null;
  }

  Future<ClassItem?> getClass(int id) async {
    var dbClient = await (db);
    var result =
        await dbClient!.rawQuery("SELECT * FROM $tableName WHERE id = $id");

    if (result.isEmpty) return null;
    return ClassItem.fromMap(result.first);
  }

  Future<int> deleteClass(int id) async {
    var dbClient = await db;
    return await dbClient!
        .delete(tableName, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<int> updateClass(ClassItem item) async {
    var dbClient = await db;
    return await dbClient!.update(tableName, item.toMap(),
        where: "$columnId = ?", whereArgs: [item.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient!.close();
  }
}
