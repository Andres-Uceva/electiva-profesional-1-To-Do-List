import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import 'package:to_do_list_app/domain/repositories/task_repository.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../core/exceptions/api_exception.dart';
import '../local/database/task_local_data_source.dart';
import '../local/database/queue_operation_local_data_source.dart';
import '../local/models/task_local_model.dart';
import '../local/models/queue_operation_model.dart';
import '../remote/api/task_remote_data_source.dart';
import '../remote/models/task_remote_model.dart';

/// Implementación del repositorio de tareas con estrategia offline-first
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;
  final TaskRemoteDataSource _remoteDataSource;
  final QueueOperationLocalDataSource _queueDataSource;
  final ConnectivityHelper _connectivityHelper;
  final Uuid _uuid;

  TaskRepositoryImpl({
    required TaskLocalDataSource localDataSource,
    required TaskRemoteDataSource remoteDataSource,
    required QueueOperationLocalDataSource queueDataSource,
    required ConnectivityHelper connectivityHelper,
    Uuid? uuid,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _queueDataSource = queueDataSource,
        _connectivityHelper = connectivityHelper,
        _uuid = uuid ?? const Uuid();

  @override
  Future<List<Task>> getTasks() async {
    // Estrategia offline-first: Siempre devolver datos locales primero
    final localTasks = await _localDataSource.getAllTasks();
    final tasks = localTasks.map((model) => model.toEntity()).toList();

    // Si hay conexión, sincronizar en segundo plano
    final hasConnection = await _connectivityHelper.hasConnection();
    if (hasConnection) {
      _syncTasksInBackground();
    }

    return tasks;
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final localTask = await _localDataSource.getTaskById(id);
    return localTask?.toEntity();
  }

  @override
  Future<Task> createTask(String title) async {
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      title: title,
      completed: false,
      updatedAt: now,
    );

    // Guardar localmente primero
    final localModel = TaskLocalModel.fromEntity(task);
    await _localDataSource.insertTask(localModel);

    // Encolar operación para sincronización
    final operation = QueueOperationModel(
      id: _uuid.v4(),
      entity: 'task',
      entityId: task.id,
      operation: 'CREATE',
      payload: jsonEncode(TaskRemoteModel.fromEntity(task).toJson()),
      createdAt: now.millisecondsSinceEpoch,
    );
    await _queueDataSource.insertOperation(operation);

    // Intentar sincronizar si hay conexión
    final hasConnection = await _connectivityHelper.hasConnection();
    if (hasConnection) {
      _syncPendingOperationsInBackground();
    }

    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    // Actualizar localmente primero
    final localModel = TaskLocalModel.fromEntity(updatedTask);
    await _localDataSource.updateTask(localModel);

    // Encolar operación para sincronización
    final operation = QueueOperationModel(
      id: _uuid.v4(),
      entity: 'task',
      entityId: updatedTask.id,
      operation: 'UPDATE',
      payload: jsonEncode(TaskRemoteModel.fromEntity(updatedTask).toJson()),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _queueDataSource.insertOperation(operation);

    // Intentar sincronizar si hay conexión
    final hasConnection = await _connectivityHelper.hasConnection();
    if (hasConnection) {
      _syncPendingOperationsInBackground();
    }

    return updatedTask;
  }

  @override
  Future<void> deleteTask(String id) async {
    // Marcar como eliminado localmente (soft delete)
    await _localDataSource.deleteTask(id);

    // Encolar operación para sincronización
    final operation = QueueOperationModel(
      id: _uuid.v4(),
      entity: 'task',
      entityId: id,
      operation: 'DELETE',
      payload: jsonEncode({'id': id}),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _queueDataSource.insertOperation(operation);

    // Intentar sincronizar si hay conexión
    final hasConnection = await _connectivityHelper.hasConnection();
    if (hasConnection) {
      _syncPendingOperationsInBackground();
    }
  }

  @override
  Future<void> syncPendingOperations() async {
    final hasConnection = await _connectivityHelper.hasConnection();
    if (!hasConnection) {
      throw NetworkException('No hay conexión a internet');
    }

    final pendingOperations = await _queueDataSource.getPendingOperations();

    for (final operation in pendingOperations) {
      try {
        await _processSyncOperation(operation);
        // Si fue exitoso, eliminar de la cola
        await _queueDataSource.deleteOperation(operation.id);
      } catch (e) {
        // Si falla, actualizar el contador de intentos y el error
        final updatedOperation = operation.copyWith(
          attemptCount: operation.attemptCount + 1,
          lastError: e.toString(),
        );
        await _queueDataSource.updateOperation(updatedOperation);

        // Si ha fallado demasiadas veces, podrías eliminarlo o manejarlo de otra forma
        if (updatedOperation.attemptCount >= 5) {
          debugPrint('Operación ${operation.id} ha fallado 5 veces. Revisar.');
        }
      }
    }
  }

  /// Sincroniza las tareas desde el servidor al almacenamiento local
  Future<void> _syncTasksInBackground() async {
    try {
      final remoteTasks = await _remoteDataSource.getAllTasks();
      final localModels =
          remoteTasks.map((task) => TaskLocalModel.fromEntity(task.toEntity())).toList();
      
      await _localDataSource.upsertTasks(localModels);
    } catch (e) {
      // Falló la sincronización en segundo plano, no hacer nada
      debugPrint('Error sincronizando en segundo plano: $e');
    }
  }

  /// Procesa las operaciones pendientes en segundo plano
  Future<void> _syncPendingOperationsInBackground() async {
    try {
      await syncPendingOperations();
    } catch (e) {
      // Falló la sincronización, se reintentará después
      debugPrint('Error sincronizando operaciones pendientes: $e');
    }
  }

  /// Procesa una operación de sincronización individual
  Future<void> _processSyncOperation(QueueOperationModel operation) async {
    final payload = jsonDecode(operation.payload) as Map<String, dynamic>;

    switch (operation.operation) {
      case 'CREATE':
        final taskModel = TaskRemoteModel.fromJson(payload);
        await _remoteDataSource.createTask(taskModel);
        break;

      case 'UPDATE':
        final taskModel = TaskRemoteModel.fromJson(payload);
        await _remoteDataSource.updateTask(taskModel);
        break;

      case 'DELETE':
        await _remoteDataSource.deleteTask(operation.entityId);
        // Después de eliminar exitosamente en el servidor, eliminar localmente también
        await _localDataSource.hardDeleteTask(operation.entityId);
        break;

      default:
        throw Exception('Operación desconocida: ${operation.operation}');
    }
  }
}