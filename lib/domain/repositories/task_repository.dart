import 'package:to_do_list_app/domain/entities/task.dart';

/// Contrato que define las operaciones disponibles para las tareas
/// La implementación concreta estará en la capa de datos
abstract class TaskRepository {
  /// Obtiene todas las tareas
  Future<List<Task>> getTasks();

  /// Obtiene una tarea por su ID
  Future<Task?> getTaskById(String id);

  /// Crea una nueva tarea
  Future<Task> createTask(String title);

  /// Actualiza una tarea existente
  Future<Task> updateTask(Task task);

  /// Elimina una tarea
  Future<void> deleteTask(String id);

  /// Sincroniza las tareas pendientes con el servidor
  Future<void> syncPendingOperations();
}