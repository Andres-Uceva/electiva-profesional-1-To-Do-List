import 'package:sqflite/sqflite.dart';
import '../models/queue_operation_model.dart';
import 'database_helper.dart';

/// Data source para operaciones de cola de sincronización
class QueueOperationLocalDataSource {
  final DatabaseHelper _databaseHelper;

  QueueOperationLocalDataSource(this._databaseHelper);

  /// Obtiene todas las operaciones pendientes ordenadas por fecha
  Future<List<QueueOperationModel>> getPendingOperations() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'queue_operations',
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => QueueOperationModel.fromMap(map)).toList();
  }

  /// Inserta una nueva operación en la cola
  Future<void> insertOperation(QueueOperationModel operation) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'queue_operations',
      operation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza una operación existente (para incrementar intentos o errores)
  Future<void> updateOperation(QueueOperationModel operation) async {
    final db = await _databaseHelper.database;
    await db.update(
      'queue_operations',
      operation.toMap(),
      where: 'id = ?',
      whereArgs: [operation.id],
    );
  }

  /// Elimina una operación de la cola (después de sincronizar con éxito)
  Future<void> deleteOperation(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'queue_operations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Obtiene el conteo de operaciones pendientes
  Future<int> getPendingOperationsCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM queue_operations',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Limpia todas las operaciones (útil para desarrollo)
  Future<void> clearAllOperations() async {
    final db = await _databaseHelper.database;
    await db.delete('queue_operations');
  }
}