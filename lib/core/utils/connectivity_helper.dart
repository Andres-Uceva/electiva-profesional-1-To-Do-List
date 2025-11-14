import 'package:connectivity_plus/connectivity_plus.dart';

/// Helper para verificar la conectividad de red
class ConnectivityHelper {
  final Connectivity _connectivity;

  ConnectivityHelper({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Verifica si hay conexión a internet
  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Stream que notifica cambios en la conectividad
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }
}