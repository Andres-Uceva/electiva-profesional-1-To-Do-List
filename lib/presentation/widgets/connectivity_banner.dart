import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        // No mostrar nada si está conectado y no hay sincronización
        if (connectivityProvider.isConnected && 
            !connectivityProvider.showSyncIndicator) {
          return const SizedBox.shrink();
        }

        // Banner de sin conexión
        if (!connectivityProvider.isConnected) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade700,
            child: const Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sin conexión. Los cambios se sincronizarán cuando vuelva la conexión.',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        // Banner de sincronización
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.green.shade700,
          child: const Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conexión restablecida. Sincronizando...',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}