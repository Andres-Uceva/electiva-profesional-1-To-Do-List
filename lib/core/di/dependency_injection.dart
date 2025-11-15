import 'package:http/http.dart' as http;
import 'package:to_do_list_app/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/database/database_helper.dart';
import '../../data/local/database/task_local_data_source.dart';
import '../../data/local/database/queue_operation_local_data_source.dart';
import '../../data/remote/api/api_client.dart';
import '../../data/remote/api/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../core/utils/connectivity_helper.dart';

/// Clase para configurar la inyección de dependencias
class DependencyInjection {
  static DatabaseHelper? _databaseHelper;
  static TaskLocalDataSource? _taskLocalDataSource;
  static QueueOperationLocalDataSource? _queueOperationLocalDataSource;
  static ApiClient? _apiClient;
  static TaskRemoteDataSource? _taskRemoteDataSource;
  static ConnectivityHelper? _connectivityHelper;
  static TaskRepository? _taskRepository;

  /// Inicializa todas las dependencias
  static Future<void> init() async {
    // Database
    _databaseHelper = DatabaseHelper.instance;

    // Local Data Sources
    _taskLocalDataSource = TaskLocalDataSource(_databaseHelper!);
    _queueOperationLocalDataSource = QueueOperationLocalDataSource(_databaseHelper!);

    // Remote Data Sources
    _apiClient = ApiClient(client: http.Client());
    _taskRemoteDataSource = TaskRemoteDataSource(_apiClient!);

    // Utils
    _connectivityHelper = ConnectivityHelper();

    // Repository
    _taskRepository = TaskRepositoryImpl(
      localDataSource: _taskLocalDataSource!,
      remoteDataSource: _taskRemoteDataSource!,
      queueDataSource: _queueOperationLocalDataSource!,
      connectivityHelper: _connectivityHelper!,
      uuid: const Uuid(),
    );
  }

  // Getters para acceder a las dependencias
  static TaskRepository get taskRepository {
    if (_taskRepository == null) {
      throw Exception('DependencyInjection no ha sido inicializado. Llama a init() primero.');
    }
    return _taskRepository!;
  }

  static ConnectivityHelper get connectivityHelper {
    if (_connectivityHelper == null) {
      throw Exception('DependencyInjection no ha sido inicializado. Llama a init() primero.');
    }
    return _connectivityHelper!;
  }

  /// Limpia todas las dependencias (útil para testing)
  static void reset() {
    _apiClient?.dispose();
    _databaseHelper = null;
    _taskLocalDataSource = null;
    _queueOperationLocalDataSource = null;
    _apiClient = null;
    _taskRemoteDataSource = null;
    _connectivityHelper = null;
    _taskRepository = null;
  }
}