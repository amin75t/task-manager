import 'package:hive/hive.dart';
import 'package:task_manager/core/database/hive_service.dart';
import 'package:task_manager/core/models/task_model.dart';

/// Reusable Task Repository for CRUD operations
/// This repository can be copied to any project using the same TaskModel
class TaskRepository {
  final HiveService _hiveService = HiveService.instance;

  /// Get tasks box
  Box<TaskModel> get _box => _hiveService.getTasksBox();

  // CREATE
  /// Add a new task
  Future<void> addTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  /// Add multiple tasks
  Future<void> addTasks(List<TaskModel> tasks) async {
    final Map<String, TaskModel> taskMap = {
      for (var task in tasks) task.id: task,
    };
    await _box.putAll(taskMap);
  }

  // READ
  /// Get all tasks
  List<TaskModel> getAllTasks() {
    return _box.values.toList();
  }

  /// Get task by ID
  TaskModel? getTaskById(String id) {
    return _box.get(id);
  }

  /// Get completed tasks
  List<TaskModel> getCompletedTasks() {
    return _box.values.where((task) => task.isCompleted).toList();
  }

  /// Get pending tasks
  List<TaskModel> getPendingTasks() {
    return _box.values.where((task) => !task.isCompleted).toList();
  }

  /// Get tasks by priority
  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _box.values.where((task) => task.priority == priority).toList();
  }

  /// Get tasks by category
  List<TaskModel> getTasksByCategory(String category) {
    return _box.values.where((task) => task.category == category).toList();
  }

  /// Get tasks by tag
  List<TaskModel> getTasksByTag(String tag) {
    return _box.values
        .where((task) => task.tags?.contains(tag) ?? false)
        .toList();
  }

  /// Get tasks due today
  List<TaskModel> getTasksDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _box.values
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.isAfter(today) &&
              task.dueDate!.isBefore(tomorrow),
        )
        .toList();
  }

  /// Get overdue tasks
  List<TaskModel> getOverdueTasks() {
    final now = DateTime.now();
    return _box.values
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.isBefore(now) &&
              !task.isCompleted,
        )
        .toList();
  }

  /// Search tasks by title or description
  List<TaskModel> searchTasks(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where(
          (task) =>
              task.title.toLowerCase().contains(lowerQuery) ||
              (task.description?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList();
  }

  /// Get tasks sorted by creation date
  List<TaskModel> getTasksSortedByDate({bool ascending = false}) {
    final tasks = _box.values.toList();
    tasks.sort(
      (a, b) => ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt),
    );
    return tasks;
  }

  /// Get tasks sorted by priority
  List<TaskModel> getTasksSortedByPriority() {
    final tasks = _box.values.toList();
    tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return tasks;
  }

  // UPDATE
  /// Update a task
  Future<void> updateTask(TaskModel task) async {
    task.updatedAt = DateTime.now();
    await _box.put(task.id, task);
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String id) async {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.completedAt = task.isCompleted ? DateTime.now() : null;
      task.updatedAt = DateTime.now();
      await task.save();
    }
  }

  /// Update task priority
  Future<void> updateTaskPriority(String id, TaskPriority priority) async {
    final task = _box.get(id);
    if (task != null) {
      task.priority = priority;
      task.updatedAt = DateTime.now();
      await task.save();
    }
  }

  /// Update task category
  Future<void> updateTaskCategory(String id, String category) async {
    final task = _box.get(id);
    if (task != null) {
      task.category = category;
      task.updatedAt = DateTime.now();
      await task.save();
    }
  }

  /// Add tag to task
  Future<void> addTagToTask(String id, String tag) async {
    final task = _box.get(id);
    if (task != null) {
      task.tags ??= [];
      if (!task.tags!.contains(tag)) {
        task.tags!.add(tag);
        task.updatedAt = DateTime.now();
        await task.save();
      }
    }
  }

  /// Remove tag from task
  Future<void> removeTagFromTask(String id, String tag) async {
    final task = _box.get(id);
    if (task != null && task.tags != null) {
      task.tags!.remove(tag);
      task.updatedAt = DateTime.now();
      await task.save();
    }
  }

  // DELETE
  /// Delete a task by ID
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  /// Delete multiple tasks
  Future<void> deleteTasks(List<String> ids) async {
    await _box.deleteAll(ids);
  }

  /// Delete all completed tasks
  Future<void> deleteCompletedTasks() async {
    final completedIds = _box.values
        .where((task) => task.isCompleted)
        .map((e) => e.id)
        .toList();
    await _box.deleteAll(completedIds);
  }

  /// Delete all tasks
  Future<void> deleteAllTasks() async {
    await _box.clear();
  }

  // STATISTICS
  /// Get total task count
  int getTotalCount() {
    return _box.length;
  }

  /// Get completed task count
  int getCompletedCount() {
    return _box.values.where((task) => task.isCompleted).length;
  }

  /// Get pending task count
  int getPendingCount() {
    return _box.values.where((task) => !task.isCompleted).length;
  }

  /// Get completion percentage
  double getCompletionPercentage() {
    final total = getTotalCount();
    if (total == 0) return 0;
    return (getCompletedCount() / total) * 100;
  }

  /// Get tasks count by priority
  Map<TaskPriority, int> getCountByPriority() {
    return {
      for (var priority in TaskPriority.values)
        priority: _box.values.where((task) => task.priority == priority).length,
    };
  }

  // STREAM/WATCH
  /// Watch all tasks for real-time updates
  Stream<List<TaskModel>> watchAllTasks() {
    return _box.watch().map((_) => getAllTasks());
  }

  /// Watch a specific task
  Stream<TaskModel?> watchTask(String id) {
    return _box.watch(key: id).map((_) => getTaskById(id));
  }
}
