import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/models/category_model.dart';
import 'package:task_manager/core/models/tag_model.dart';

/// Reusable Hive Database Service
/// This service can be copied to any Flutter project for local database management
class HiveService {
  static HiveService? _instance;
  static const String _tasksBoxName = 'tasks';
  static const String _categoriesBoxName = 'categories';
  static const String _tagsBoxName = 'tags';

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
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TagModelAdapter());
    }
  }

  /// Open all required boxes
  Future<void> openBoxes() async {
    await Hive.openBox<TaskModel>(_tasksBoxName);
    await Hive.openBox<CategoryModel>(_categoriesBoxName);
    await Hive.openBox<TagModel>(_tagsBoxName);
  }

  /// Get tasks box
  Box<TaskModel> getTasksBox() {
    return Hive.box<TaskModel>(_tasksBoxName);
  }

  /// Get categories box
  Box<CategoryModel> getCategoriesBox() {
    return Hive.box<CategoryModel>(_categoriesBoxName);
  }

  /// Get tags box
  Box<TagModel> getTagsBox() {
    return Hive.box<TagModel>(_tagsBoxName);
  }

  /// Close all boxes
  Future<void> closeBoxes() async {
    await Hive.close();
  }

  /// Clear all data (use with caution)
  Future<void> clearAllData() async {
    final tasksBox = getTasksBox();
    final categoriesBox = getCategoriesBox();
    final tagsBox = getTagsBox();

    await tasksBox.clear();
    await categoriesBox.clear();
    await tagsBox.clear();
  }

  /// Compact box to reduce file size
  Future<void> compact() async {
    final tasksBox = getTasksBox();
    final categoriesBox = getCategoriesBox();
    final tagsBox = getTagsBox();

    await tasksBox.compact();
    await categoriesBox.compact();
    await tagsBox.compact();
  }

  /// Get database path
  String? get path => Hive.box<TaskModel>(_tasksBoxName).path;
}
