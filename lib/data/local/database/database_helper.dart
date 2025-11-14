import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper para manejar la base de datos SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Crea las tablas de la base de datos
  Future<void> _createDB(Database db, int version) async {
    // Tabla de tareas
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabla de cola de operaciones para sincronización
    await db.execute('''
      CREATE TABLE queue_operations (
        id TEXT PRIMARY KEY,
        entity TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        op TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT
      )
    ''');

    // Índices para mejorar el rendimiento
    await db.execute('''
      CREATE INDEX idx_tasks_deleted ON tasks(deleted)
    ''');

    await db.execute('''
      CREATE INDEX idx_queue_created_at ON queue_operations(created_at)
    ''');
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  /// Elimina la base de datos (útil para desarrollo/testing)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}