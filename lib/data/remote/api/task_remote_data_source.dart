import '../../../core/constants/api_constants.dart';
import '../models/task_remote_model.dart';
import 'api_client.dart';

/// Data source para operaciones remotas de tareas con la API
class TaskRemoteDataSource {
  final ApiClient _apiClient;

  TaskRemoteDataSource(this._apiClient);

  /// Obtiene todas las tareas desde la API
  Future<List<TaskRemoteModel>> getAllTasks() async {
    final response = await _apiClient.get(ApiConstants.tasksEndpoint);
    
    final List<dynamic> tasksJson = response as List<dynamic>;
    return tasksJson
        .map((json) => TaskRemoteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene una tarea específica por ID
  Future<TaskRemoteModel> getTaskById(String id) async {
    final response = await _apiClient.get('${ApiConstants.tasksEndpoint}/$id');
    return TaskRemoteModel.fromJson(response as Map<String, dynamic>);
  }

  /// Crea una nueva tarea en la API
  Future<TaskRemoteModel> createTask(TaskRemoteModel task) async {
    final response = await _apiClient.post(
      ApiConstants.tasksEndpoint,
      task.toJson(),
    );
    return TaskRemoteModel.fromJson(response as Map<String, dynamic>);
  }

  /// Actualiza una tarea existente en la API
  Future<TaskRemoteModel> updateTask(TaskRemoteModel task) async {
    final response = await _apiClient.put(
      '${ApiConstants.tasksEndpoint}/${task.id}',
      task.toJson(),
    );
    return TaskRemoteModel.fromJson(response as Map<String, dynamic>);
  }

  /// Elimina una tarea en la API
  Future<void> deleteTask(String id) async {
    await _apiClient.delete('${ApiConstants.tasksEndpoint}/$id');
  }
}