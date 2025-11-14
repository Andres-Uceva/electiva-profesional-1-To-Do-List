import 'package:sqflite/sqflite.dart';
import '../models/task_local_model.dart';
import 'database_helper.dart';

/// Data source para operaciones locales de tareas en SQLite
class TaskLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TaskLocalDataSource(this._databaseHelper);

  /// Obtiene todas las tareas (sin las eliminadas)
  Future<List<TaskLocalModel>> getAllTasks() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'deleted = ?',
      whereArgs: [0],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => TaskLocalModel.fromMap(map)).toList();
  }

  /// Obtiene una tarea por ID
  Future<TaskLocalModel?> getTaskById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ? AND deleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return TaskLocalModel.fromMap(maps.first);
  }

  /// Inserta una nueva tarea
  Future<void> insertTask(TaskLocalModel task) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza una tarea existente
  Future<void> updateTask(TaskLocalModel task) async {
    final db = await _databaseHelper.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Marca una tarea como eliminada (soft delete)
  Future<void> deleteTask(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'tasks',
      {
        'deleted': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina físicamente una tarea (hard delete)
  Future<void> hardDeleteTask(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Inserta o actualiza múltiples tareas (para sincronización)
  Future<void> upsertTasks(List<TaskLocalModel> tasks) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (final task in tasks) {
      batch.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Limpia todas las tareas
  Future<void> clearAllTasks() async {
    final db = await _databaseHelper.database;
    await db.delete('tasks');
  }
}