import 'package:hive/hive.dart';
import 'package:task_manager/core/database/hive_service.dart';
import 'package:task_manager/core/models/category_model.dart';

/// Repository for managing categories
class CategoryRepository {
  final HiveService _hiveService = HiveService.instance;

  /// Get categories box
  Box<CategoryModel> get _box => _hiveService.getCategoriesBox();

  // CREATE
  /// Add a new category
  Future<void> addCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  /// Add multiple categories
  Future<void> addCategories(List<CategoryModel> categories) async {
    final Map<String, CategoryModel> categoryMap = {
      for (var category in categories) category.id: category,
    };
    await _box.putAll(categoryMap);
  }

  // READ
  /// Get all categories
  List<CategoryModel> getAllCategories() {
    return _box.values.toList();
  }

  /// Get category by ID
  CategoryModel? getCategoryById(String id) {
    return _box.get(id);
  }

  /// Get category by name
  CategoryModel? getCategoryByName(String name) {
    return _box.values.firstWhere(
      (category) => category.name.toLowerCase() == name.toLowerCase(),
      orElse: () => CategoryModel(
        id: '',
        name: '',
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Get default categories
  List<CategoryModel> getDefaultCategories() {
    return _box.values.where((category) => category.isDefault).toList();
  }

  /// Get custom (non-default) categories
  List<CategoryModel> getCustomCategories() {
    return _box.values.where((category) => !category.isDefault).toList();
  }

  /// Search categories by name
  List<CategoryModel> searchCategories(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((category) => category.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get categories sorted by name
  List<CategoryModel> getCategoriesSortedByName({bool ascending = true}) {
    final categories = _box.values.toList();
    categories.sort((a, b) => ascending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
    return categories;
  }

  // UPDATE
  /// Update a category
  Future<void> updateCategory(CategoryModel category) async {
    category.updatedAt = DateTime.now();
    await _box.put(category.id, category);
  }

  // DELETE
  /// Delete a category by ID (only if not default)
  Future<bool> deleteCategory(String id) async {
    final category = _box.get(id);
    if (category != null && !category.isDefault) {
      await _box.delete(id);
      return true;
    }
    return false;
  }

  /// Delete multiple categories (only non-default)
  Future<void> deleteCategories(List<String> ids) async {
    for (final id in ids) {
      await deleteCategory(id);
    }
  }

  /// Delete all custom categories
  Future<void> deleteAllCustomCategories() async {
    final customIds = _box.values
        .where((category) => !category.isDefault)
        .map((e) => e.id)
        .toList();
    await _box.deleteAll(customIds);
  }

  // STATISTICS
  /// Get total category count
  int getTotalCount() {
    return _box.length;
  }

  /// Get custom category count
  int getCustomCount() {
    return _box.values.where((category) => !category.isDefault).length;
  }

  /// Get default category count
  int getDefaultCount() {
    return _box.values.where((category) => category.isDefault).length;
  }

  // STREAM/WATCH
  /// Watch all categories for real-time updates
  Stream<List<CategoryModel>> watchAllCategories() {
    return _box.watch().map((_) => getAllCategories());
  }

  /// Watch a specific category
  Stream<CategoryModel?> watchCategory(String id) {
    return _box.watch(key: id).map((_) => getCategoryById(id));
  }

  // INITIALIZATION
  /// Initialize with default categories if empty
  Future<void> initializeDefaultCategories() async {
    if (_box.isEmpty) {
      final defaultCategories = [
        CategoryModel(
          id: 'work',
          name: 'Work',
          description: 'Work-related tasks',
          colorIndex: 0,
          icon: '💼',
          createdAt: DateTime.now(),
          isDefault: true,
        ),
        CategoryModel(
          id: 'personal',
          name: 'Personal',
          description: 'Personal tasks',
          colorIndex: 1,
          icon: '👤',
          createdAt: DateTime.now(),
          isDefault: true,
        ),
        CategoryModel(
          id: 'shopping',
          name: 'Shopping',
          description: 'Shopping list',
          colorIndex: 2,
          icon: '🛒',
          createdAt: DateTime.now(),
          isDefault: true,
        ),
        CategoryModel(
          id: 'health',
          name: 'Health',
          description: 'Health and fitness',
          colorIndex: 3,
          icon: '💪',
          createdAt: DateTime.now(),
          isDefault: true,
        ),
        CategoryModel(
          id: 'learning',
          name: 'Learning',
          description: 'Educational tasks',
          colorIndex: 4,
          icon: '📚',
          createdAt: DateTime.now(),
          isDefault: true,
        ),
      ];
      await addCategories(defaultCategories);
    }
  }
}
