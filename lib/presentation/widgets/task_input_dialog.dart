import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TaskInputDialog extends StatefulWidget {
  const TaskInputDialog({super.key});

  @override
  State<TaskInputDialog> createState() => _TaskInputDialogState();
}

class _TaskInputDialogState extends State<TaskInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Tarea'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Escribe el título de la tarea',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.task_alt),
          ),
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El título no puede estar vacío';
            }
            return null;
          },
          onFieldSubmitted: (_) => _saveTask(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveTask,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<TaskProvider>().createTask(_controller.text);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea creada exitosamente'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la tarea: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}