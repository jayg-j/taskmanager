import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, TaskRepository? repository})
      : _repository = repository;

  final TaskRepository? _repository;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskRepository _repository;
  final _titleController = TextEditingController();

  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? TaskRepository();
    _loadTasks(showFullScreenLoader: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks({bool showFullScreenLoader = false}) async {
    if (showFullScreenLoader) {
      setState(() => _isLoading = true);
    }
    try {
      final tasks = await _repository.getAllTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } on DatabaseException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Could not load tasks: ${e.toString()}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Could not load tasks: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _validateTitle(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'Enter a task title';
    }
    return null;
  }

  Future<void> _addTask() async {
    final validationError = _validateTitle(_titleController.text);
    if (validationError != null) {
      _showMessage(validationError);
      return;
    }

    final title = _titleController.text.trim();
    try {
      await _repository.insertTask(title);
      _titleController.clear();
      await _loadTasks();
      if (!mounted) return;
      _showMessage('Task added');
    } on DatabaseException catch (e) {
      if (!mounted) return;
      _showMessage('Could not add task: ${e.toString()}');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not add task: $e');
    }
  }

  Future<void> _toggleCompleted(Task task, bool? completed) async {
    if (completed == null) return;
    try {
      await _repository.updateCompletion(task.id, completed);
      await _loadTasks();
    } on DatabaseException catch (e) {
      if (!mounted) return;
      _showMessage('Could not update task: ${e.toString()}');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not update task: $e');
    }
  }

  Future<bool> _confirmDelete(Task task) async {
    try {
      await _repository.deleteTask(task.id);
      await _loadTasks();
      if (!mounted) return false;
      _showMessage('Task deleted');
      return true;
    } on DatabaseException catch (e) {
      if (!mounted) return false;
      _showMessage('Could not delete task: ${e.toString()}');
      return false;
    } catch (e) {
      if (!mounted) return false;
      _showMessage('Could not delete task: $e');
      return false;
    }
  }

  Future<void> _removeTask(Task task) async {
    await _confirmDelete(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'New task',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(child: Text('No tasks yet. Add one above.'))
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Theme.of(context).colorScheme.error,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) => _confirmDelete(task),
                            child: CheckboxListTile(
                              value: task.isCompleted,
                              onChanged: (value) =>
                                  _toggleCompleted(task, value),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete',
                                onPressed: () => _removeTask(task),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
