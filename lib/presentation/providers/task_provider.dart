import 'package:flutter/foundation.dart';
import 'package:to_do_list_app/domain/repositories/task_repository.dart';
import '../../domain/entities/task.dart';

/// Provider para manejar el estado de las tareas
class TaskProvider with ChangeNotifier {
  final TaskRepository _repository;

  TaskProvider({required TaskRepository repository})
      : _repository = repository;

  // Estado
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  TaskFilter _currentFilter = TaskFilter.all;

  // Getters
  List<Task> get tasks {
    switch (_currentFilter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.pending:
        return _tasks.where((task) => !task.completed).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.completed).toList();
    }
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskFilter get currentFilter => _currentFilter;
  int get totalTasks => _tasks.length;
  int get pendingTasks => _tasks.where((task) => !task.completed).length;
  int get completedTasks => _tasks.where((task) => task.completed).length;

  /// Carga todas las tareas
  Future<void> loadTasks() async {
    _setLoading(true);
    _clearError();

    try {
      _tasks = await _repository.getTasks();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar las tareas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crea una nueva tarea
  Future<void> createTask(String title) async {
    if (title.trim().isEmpty) {
      _setError('El título no puede estar vacío');
      return;
    }

    _clearError();

    try {
      final newTask = await _repository.createTask(title.trim());
      _tasks.insert(0, newTask); // Agregar al inicio de la lista
      notifyListeners();
    } catch (e) {
      _setError('Error al crear la tarea: $e');
    }
  }

  /// Actualiza una tarea existente
  Future<void> updateTask(Task task) async {
    _clearError();

    try {
      final updatedTask = await _repository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _setError('Error al actualizar la tarea: $e');
    }
  }

  /// Alterna el estado completado de una tarea
  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(completed: !task.completed);
    await updateTask(updatedTask);
  }

  /// Edita el título de una tarea
  Future<void> editTaskTitle(String taskId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _setError('El título no puede estar vacío');
      return;
    }

    final task = _tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(title: newTitle.trim());
    await updateTask(updatedTask);
  }

  /// Elimina una tarea
  Future<void> deleteTask(String taskId) async {
    _clearError();

    try {
      await _repository.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar la tarea: $e');
    }
  }

  /// Cambia el filtro actual
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Sincroniza las operaciones pendientes
  Future<void> syncPendingOperations() async {
    try {
      await _repository.syncPendingOperations();
      // Recargar tareas después de sincronizar
      await loadTasks();
    } catch (e) {
      _setError('Error al sincronizar: $e');
    }
  }

  // Métodos privados para manejar estado interno
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

/// Enum para los filtros de tareas
enum TaskFilter {
  all,
  pending,
  completed,
}