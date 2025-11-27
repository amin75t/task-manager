import 'package:hive/hive.dart';
import 'package:task_manager/core/database/hive_service.dart';
import 'package:task_manager/core/models/tag_model.dart';

/// Repository for managing tags
class TagRepository {
  final HiveService _hiveService = HiveService.instance;

  /// Get tags box
  Box<TagModel> get _box => _hiveService.getTagsBox();

  // CREATE
  /// Add a new tag
  Future<void> addTag(TagModel tag) async {
    await _box.put(tag.id, tag);
  }

  /// Add multiple tags
  Future<void> addTags(List<TagModel> tags) async {
    final Map<String, TagModel> tagMap = {
      for (var tag in tags) tag.id: tag,
    };
    await _box.putAll(tagMap);
  }

  // READ
  /// Get all tags
  List<TagModel> getAllTags() {
    return _box.values.toList();
  }

  /// Get tag by ID
  TagModel? getTagById(String id) {
    return _box.get(id);
  }

  /// Get tag by name
  TagModel? getTagByName(String name) {
    return _box.values.firstWhere(
      (tag) => tag.name.toLowerCase() == name.toLowerCase(),
      orElse: () => TagModel(
        id: '',
        name: '',
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Search tags by name
  List<TagModel> searchTags(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((tag) => tag.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get tags sorted by name
  List<TagModel> getTagsSortedByName({bool ascending = true}) {
    final tags = _box.values.toList();
    tags.sort((a, b) =>
        ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    return tags;
  }

  /// Get tags sorted by usage count
  List<TagModel> getTagsSortedByUsage({bool ascending = false}) {
    final tags = _box.values.toList();
    tags.sort((a, b) => ascending
        ? a.usageCount.compareTo(b.usageCount)
        : b.usageCount.compareTo(a.usageCount));
    return tags;
  }

  /// Get popular tags (most used)
  List<TagModel> getPopularTags({int limit = 10}) {
    final tags = getTagsSortedByUsage();
    return tags.take(limit).toList();
  }

  // UPDATE
  /// Update a tag
  Future<void> updateTag(TagModel tag) async {
    tag.updatedAt = DateTime.now();
    await _box.put(tag.id, tag);
  }

  /// Increment tag usage count
  Future<void> incrementUsageCount(String id) async {
    final tag = _box.get(id);
    if (tag != null) {
      tag.usageCount++;
      tag.updatedAt = DateTime.now();
      await tag.save();
    }
  }

  /// Decrement tag usage count
  Future<void> decrementUsageCount(String id) async {
    final tag = _box.get(id);
    if (tag != null && tag.usageCount > 0) {
      tag.usageCount--;
      tag.updatedAt = DateTime.now();
      await tag.save();
    }
  }

  // DELETE
  /// Delete a tag by ID
  Future<void> deleteTag(String id) async {
    await _box.delete(id);
  }

  /// Delete multiple tags
  Future<void> deleteTags(List<String> ids) async {
    await _box.deleteAll(ids);
  }

  /// Delete unused tags (usage count = 0)
  Future<void> deleteUnusedTags() async {
    final unusedIds = _box.values
        .where((tag) => tag.usageCount == 0)
        .map((e) => e.id)
        .toList();
    await _box.deleteAll(unusedIds);
  }

  /// Delete all tags
  Future<void> deleteAllTags() async {
    await _box.clear();
  }

  // STATISTICS
  /// Get total tag count
  int getTotalCount() {
    return _box.length;
  }

  /// Get used tags count (usage count > 0)
  int getUsedCount() {
    return _box.values.where((tag) => tag.usageCount > 0).length;
  }

  /// Get unused tags count (usage count = 0)
  int getUnusedCount() {
    return _box.values.where((tag) => tag.usageCount == 0).length;
  }

  /// Get total usage count across all tags
  int getTotalUsageCount() {
    return _box.values.fold(0, (sum, tag) => sum + tag.usageCount);
  }

  // STREAM/WATCH
  /// Watch all tags for real-time updates
  Stream<List<TagModel>> watchAllTags() {
    return _box.watch().map((_) => getAllTags());
  }

  /// Watch a specific tag
  Stream<TagModel?> watchTag(String id) {
    return _box.watch(key: id).map((_) => getTagById(id));
  }

  // INITIALIZATION
  /// Initialize with default tags if empty
  Future<void> initializeDefaultTags() async {
    if (_box.isEmpty) {
      final defaultTags = [
        TagModel(
          id: 'urgent',
          name: 'urgent',
          description: 'Urgent tasks',
          colorIndex: 0,
          createdAt: DateTime.now(),
        ),
        TagModel(
          id: 'important',
          name: 'important',
          description: 'Important tasks',
          colorIndex: 1,
          createdAt: DateTime.now(),
        ),
        TagModel(
          id: 'meeting',
          name: 'meeting',
          description: 'Meeting-related tasks',
          colorIndex: 2,
          createdAt: DateTime.now(),
        ),
        TagModel(
          id: 'idea',
          name: 'idea',
          description: 'Ideas and brainstorming',
          colorIndex: 3,
          createdAt: DateTime.now(),
        ),
        TagModel(
          id: 'review',
          name: 'review',
          description: 'Tasks requiring review',
          colorIndex: 4,
          createdAt: DateTime.now(),
        ),
      ];
      await addTags(defaultTags);
    }
  }
}
