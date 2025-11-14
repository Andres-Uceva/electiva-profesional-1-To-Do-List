import 'package:to_do_list_app/domain/entities/task.dart';

/// Modelo que representa una tarea desde la API REST
class TaskRemoteModel {
  final String id;
  final String title;
  final bool completed;
  final String updatedAt;

  TaskRemoteModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.updatedAt,
  });

  /// Convierte JSON de la API a TaskRemoteModel
  factory TaskRemoteModel.fromJson(Map<String, dynamic> json) {
    return TaskRemoteModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      completed: json['completed'] as bool,
      updatedAt: json['updatedAt'] as String,
    );
  }

  /// Convierte TaskRemoteModel a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'updatedAt': updatedAt,
    };
  }

  /// Convierte TaskRemoteModel a entidad de dominio
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      completed: completed,
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Crea TaskRemoteModel desde una entidad de dominio
  factory TaskRemoteModel.fromEntity(Task task) {
    return TaskRemoteModel(
      id: task.id,
      title: task.title,
      completed: task.completed,
      updatedAt: task.updatedAt.toIso8601String(),
    );
  }
}