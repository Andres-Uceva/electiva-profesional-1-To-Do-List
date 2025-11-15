import 'package:flutter/foundation.dart';
import '../../core/utils/connectivity_helper.dart';
import 'dart:async';

/// Provider para manejar el estado de conectividad
class ConnectivityProvider with ChangeNotifier {
  final ConnectivityHelper _connectivityHelper;
  StreamSubscription<bool>? _connectivitySubscription;

  bool _isConnected = true;
  bool _showSyncIndicator = false;

  ConnectivityProvider({required ConnectivityHelper connectivityHelper})
      : _connectivityHelper = connectivityHelper {
    _initConnectivity();
  }

  // Getters
  bool get isConnected => _isConnected;
  bool get showSyncIndicator => _showSyncIndicator;

  /// Inicializa la verificación de conectividad
  Future<void> _initConnectivity() async {
    // Verificar estado inicial
    _isConnected = await _connectivityHelper.hasConnection();
    notifyListeners();

    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivityHelper.onConnectivityChanged.listen(
      (isConnected) {
        final wasDisconnected = !_isConnected;
        _isConnected = isConnected;

        // Si acabamos de reconectar, mostrar indicador de sincronización
        if (wasDisconnected && isConnected) {
          _showSyncIndicator = true;
          notifyListeners();

          // Ocultar el indicador después de 3 segundos
          Future.delayed(const Duration(seconds: 3), () {
            _showSyncIndicator = false;
            notifyListeners();
          });
        } else {
          notifyListeners();
        }
      },
    );
  }

  /// Verifica manualmente la conectividad
  Future<void> checkConnectivity() async {
    _isConnected = await _connectivityHelper.hasConnection();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}