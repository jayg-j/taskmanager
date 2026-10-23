import 'package:sqflite/sqflite.dart';

import '../data/database_helper.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<Task>> getAllTasks() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      DatabaseHelper.tableTasks,
      orderBy: '${DatabaseHelper.columnId} ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<Task> insertTask(String title) async {
    final db = await _databaseHelper.database;
    final id = await db.insert(
      DatabaseHelper.tableTasks,
      {
        DatabaseHelper.columnTitle: title,
        DatabaseHelper.columnIsCompleted: 0,
      },
    );
    return Task(id: id, title: title, isCompleted: false);
  }

  Future<void> updateCompletion(int id, bool isCompleted) async {
    final db = await _databaseHelper.database;
    final updated = await db.update(
      DatabaseHelper.tableTasks,
      {DatabaseHelper.columnIsCompleted: isCompleted ? 1 : 0},
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
    if (updated == 0) {
      throw DatabaseException('Task not found');
    }
  }

  Future<void> deleteTask(int id) async {
    final db = await _databaseHelper.database;
    final deleted = await db.delete(
      DatabaseHelper.tableTasks,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
    if (deleted == 0) {
      throw DatabaseException('Task not found');
    }
  }
}
