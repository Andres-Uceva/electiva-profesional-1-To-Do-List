import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/connectivity_provider.dart';
import '../widgets/task_list.dart';
import '../widgets/task_input_dialog.dart';
import '../widgets/connectivity_banner.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          // Botón de sincronización manual
          Consumer<ConnectivityProvider>(
            builder: (context, connectivityProvider, _) {
              if (!connectivityProvider.isConnected) {
                return const SizedBox.shrink();
              }
              
              return IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () async {
                  final taskProvider = context.read<TaskProvider>();
                  await taskProvider.syncPendingOperations();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sincronización completada'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                tooltip: 'Sincronizar',
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterChips(),
        ),
      ),
      body: Column(
        children: [
          // Banner de conectividad
          const ConnectivityBanner(),
          
          // Estadísticas
          _buildStatsBar(),
          
          // Lista de tareas
          const Expanded(child: TaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip(
                context,
                label: 'Todas',
                filter: TaskFilter.all,
                isSelected: taskProvider.currentFilter == TaskFilter.all,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Pendientes',
                filter: TaskFilter.pending,
                isSelected: taskProvider.currentFilter == TaskFilter.pending,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                label: 'Completadas',
                filter: TaskFilter.completed,
                isSelected: taskProvider.currentFilter == TaskFilter.completed,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required TaskFilter filter,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          context.read<TaskProvider>().setFilter(filter);
        }
      },
    );
  }

  Widget _buildStatsBar() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.list,
                label: 'Total',
                value: taskProvider.totalTasks,
              ),
              _buildStatItem(
                context,
                icon: Icons.pending_actions,
                label: 'Pendientes',
                value: taskProvider.pendingTasks,
              ),
              _buildStatItem(
                context,
                icon: Icons.check_circle,
                label: 'Completadas',
                value: taskProvider.completedTasks,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TaskInputDialog(),
    );
  }
}