import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        // Mostrar loading
        if (taskProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Mostrar error
        if (taskProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    taskProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => taskProvider.loadTasks(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Lista vacía
        if (taskProvider.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(taskProvider.currentFilter),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          );
        }

        // Lista de tareas
        return RefreshIndicator(
          onRefresh: () => taskProvider.loadTasks(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return TaskItem(key: ValueKey(task.id), task: task);
            },
          ),
        );
      },
    );
  }

  String _getEmptyMessage(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'No hay tareas. ¡Crea una nueva!';
      case TaskFilter.pending:
        return 'No hay tareas pendientes';
      case TaskFilter.completed:
        return 'No hay tareas completadas';
    }
  }
}