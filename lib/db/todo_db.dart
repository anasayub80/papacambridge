import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:studento/model/todo/todo_model.dart';
import 'package:studento/model/todo/task_model.dart';

class TodoDBProvider {
  static Database? _database;

  TodoDBProvider._();
  static final TodoDBProvider db = TodoDBProvider._();

  var todos = [
    Todo(
      "Pythagoreas Theorem Pg 69",
      parent: '1',
    ),
    Todo(
      "Integration by Parts",
      parent: '1',
    ),
    Todo("Trigonometric Diff", parent: '1', isCompleted: 1),
    Todo(
      "Essay Pg 420",
      parent: '2',
    ),
    Todo(
      "Research Tourism",
      parent: '2',
    ),
    Todo(
      "Work Passage",
      parent: '2',
    ),
  ];

  var tasks = [
    Task('Maths',
        id: '1', color: Colors.yellow.value, codePoint: Icons.add.codePoint),
    Task('English',
        id: '2',
        color: Colors.pink.value,
        codePoint: Icons.sort_by_alpha.codePoint),
  ];

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  get _dbPath async {
    String documentsDirectory = await _localPath;
    return p.join(documentsDirectory, "Todo.db");
  }

  Future<bool> dbExists() async {
    return File(await _dbPath).exists();
  }

  initDB() async {
    String path = await _dbPath;
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      print("DBProvider:: onCreate()");
      await db.execute("CREATE TABLE Task ("
          "id TEXT PRIMARY KEY,"
          "name TEXT,"
          "color INTEGER,"
          "code_point INTEGER"
          ")");
      await db.execute("CREATE TABLE Todo ("
          "id TEXT PRIMARY KEY,"
          "name TEXT,"
          "parent TEXT,"
          "completed INTEGER NOT NULL DEFAULT 0"
          ")");
    });
  }

  insertBulkTask(List<Task> tasks) async {
    final db = await database;
    // ignore: avoid_function_literals_in_foreach_calls
    tasks.forEach((it) async {
      var res = await db!.insert("Task", it.toJson());
      print("Task ${it.id} = $res");
    });
  }

  insertBulkTodo(List<Todo> todos) async {
    final db = await database;
    // ignore: avoid_function_literals_in_foreach_calls
    todos.forEach((it) async {
      var res = await db!.insert("Todo", it.toJson());
      print("Todo ${it.id} = $res");
    });
  }

  Future<List<Task>> getAllTask() async {
    final db = await database;
    var result = await db!.query('Task');
    return result.map((it) => Task.fromJson(it)).toList();
  }

  Future<List<Todo>> getAllTodo() async {
    final db = await database;
    var result = await db!.query('Todo');
    return result.map((it) => Todo.fromJson(it)).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return db!
        .update('Todo', todo.toJson(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> removeTodo(Todo todo) async {
    final db = await database;
    return db!.delete('Todo', where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return db!.insert('Todo', todo.toJson());
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return db!.insert('Task', task.toJson());
  }

  Future<void> removeTask(Task task) async {
    final db = await database;
    return db!.transaction<void>((txn) async {
      await txn.delete('Todo', where: 'parent = ?', whereArgs: [task.id]);
      await txn.delete('Task', where: 'id = ?', whereArgs: [task.id]);
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  closeDB() {
    if (_database != null) {
      _database!.close();
    }
  }
}
