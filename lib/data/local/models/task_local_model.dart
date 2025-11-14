import 'package:to_do_list_app/domain/entities/task.dart';

class TaskLocalModel {
  final String id;
  final String title;
  final int completed; // SQLite usa INTEGER para booleanos
  final String updatedAt;
  final int deleted;

  TaskLocalModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.updatedAt,
    this.deleted = 0,
  });

  /// Convierte un Map de SQLite a TaskLocalModel
  factory TaskLocalModel.fromMap(Map<String, dynamic> map) {
    return TaskLocalModel(
      id: map['id'] as String,
      title: map['title'] as String,
      completed: map['completed'] as int,
      updatedAt: map['updated_at'] as String,
      deleted: map['deleted'] as int? ?? 0,
    );
  }

  /// Convierte TaskLocalModel a Map para insertar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'updated_at': updatedAt,
      'deleted': deleted,
    };
  }

  /// Convierte TaskLocalModel a entidad de dominio
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      completed: completed == 1,
      updatedAt: DateTime.parse(updatedAt),
      deleted: deleted == 1,
    );
  }

  /// Crea TaskLocalModel desde una entidad de dominio
  factory TaskLocalModel.fromEntity(Task task) {
    return TaskLocalModel(
      id: task.id,
      title: task.title,
      completed: task.completed ? 1 : 0,
      updatedAt: task.updatedAt.toIso8601String(),
      deleted: task.deleted ? 1 : 0,
    );
  }
}