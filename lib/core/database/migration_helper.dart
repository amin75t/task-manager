import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/database/hive_service.dart';

/// Migration Helper for Hive Database
///
/// Handles schema version changes and data migration
class MigrationHelper {
  static const String _schemaVersionKey = 'hive_schema_version';
  static const int currentSchemaVersion = 2; // Increment when model changes

  /// Check and migrate if needed
  ///
  /// Call this before opening Hive boxes
  static Future<void> checkAndMigrate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(_schemaVersionKey) ?? 0;

    if (savedVersion < currentSchemaVersion) {
      print('🔄 [Migration] Schema version mismatch');
      print('🔄 [Migration] Saved: $savedVersion, Current: $currentSchemaVersion');
      print('🔄 [Migration] Clearing old data...');

      // Clear all Hive data
      await Hive.deleteBoxFromDisk('tasks');
      await Hive.deleteBoxFromDisk('categories');
      await Hive.deleteBoxFromDisk('tags');

      // Update schema version
      await prefs.setInt(_schemaVersionKey, currentSchemaVersion);

      print('✅ [Migration] Migration complete');
    } else {
      print('✅ [Migration] Schema up to date (v$currentSchemaVersion)');
    }
  }
}
