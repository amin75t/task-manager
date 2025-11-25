import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/core/models/task_model.dart';

/// Reusable Hive Database Service
/// This service can be copied to any Flutter project for local database management
class HiveService {
  static HiveService? _instance;
  static const String _tasksBoxName = 'tasks';

  HiveService._();

  static HiveService get instance {
    _instance ??= HiveService._();
    return _instance!;
  }

  /// Initialize Hive - Call this in main() before runApp()
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
  }

  /// Open all required boxes
  Future<void> openBoxes() async {
    await Hive.openBox<TaskModel>(_tasksBoxName);
  }

  /// Get tasks box
  Box<TaskModel> getTasksBox() {
    return Hive.box<TaskModel>(_tasksBoxName);
  }

  /// Close all boxes
  Future<void> closeBoxes() async {
    await Hive.close();
  }

  /// Clear all data (use with caution)
  Future<void> clearAllData() async {
    final tasksBox = getTasksBox();
    await tasksBox.clear();
  }

  /// Compact box to reduce file size
  Future<void> compact() async {
    final tasksBox = getTasksBox();
    await tasksBox.compact();
  }

  /// Get database path
  String? get path => Hive.box<TaskModel>(_tasksBoxName).path;
}
