import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/api/providers/task_provider.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/repositories/task_repository.dart';
import 'package:task_manager/core/services/auth_service.dart';

/// Data Synchronization Service
///
/// Manages synchronization between local database and server
///
/// Features:
/// - Tracks data version for sync detection
/// - Handles online/offline modes
/// - Syncs tasks when data version changes
/// - Saves to server when authenticated
/// - Falls back to local-only when offline
class SyncService {
  final TaskRepository _taskRepository;
  final TaskProvider _taskProvider;
  final AuthService _authService;

  static const String _dataVersionKey = 'local_data_version';
  static const String _lastSyncTimeKey = 'last_sync_time';

  SyncService(
    this._taskRepository,
    this._taskProvider,
    this._authService,
  );

  // ============================================================================
  // DATA VERSION MANAGEMENT
  // ============================================================================

  /// Get local data version
  Future<int> getLocalDataVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dataVersionKey) ?? 0;
  }

  /// Update local data version
  Future<void> updateLocalDataVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dataVersionKey, version);
    print('🔄 [SyncService] Local data version updated to: $version');
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Update last sync time
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastSyncTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Check if sync is needed
  ///
  /// Compares server data_version with local data_version
  /// Returns true if they differ
  Future<bool> isSyncNeeded() async {
    print('🔄 [SyncService] Checking if sync is needed...');

    if (!_authService.isAuthenticated) {
      print('🔄 [SyncService] User not authenticated - sync not needed');
      return false;
    }

    try {
      final serverVersion = _authService.currentUser?.dataVersion ?? 0;
      final localVersion = await getLocalDataVersion();

      print('🔄 [SyncService] 📊 Version comparison:');
      print('🔄 [SyncService]   Server version: $serverVersion');
      print('🔄 [SyncService]   Local version:  $localVersion');

      final needsSync = serverVersion != localVersion;

      if (needsSync) {
        print('🔄 [SyncService] ⚠️ Versions differ - sync needed!');
      } else {
        print('🔄 [SyncService] ✅ Versions match - no sync needed');
      }

      return needsSync;
    } catch (e) {
      print('🔄 [SyncService] ❌ Error checking sync status: $e');
      return false;
    }
  }

  /// Perform full sync from server
  ///
  /// Fetches all tasks from server and replaces local data
  /// Updates local data version to match server
  Future<void> syncFromServer() async {
    if (!_authService.isAuthenticated) {
      print('🔄 [SyncService] Cannot sync - user not authenticated');
      return;
    }

    try {
      print('🔄 [SyncService] 📥 Starting sync from server...');

      final localBefore = _taskRepository.getTotalCount();
      print('🔄 [SyncService]   Local tasks before sync: $localBefore');

      // Fetch tasks from server
      print('🔄 [SyncService]   Fetching tasks from API...');
      final serverTasks = await _taskProvider.fetchTasks();
      print('🔄 [SyncService]   ✅ Received ${serverTasks.length} tasks from server');

      // Clear local tasks and save server tasks
      print('🔄 [SyncService]   Clearing local database...');
      await _taskRepository.deleteAllTasks();

      if (serverTasks.isNotEmpty) {
        print('🔄 [SyncService]   Saving ${serverTasks.length} tasks to local DB...');
        await _taskRepository.addTasks(serverTasks);
      }

      // Update local data version
      final serverVersion = _authService.currentUser?.dataVersion ?? 0;
      print('🔄 [SyncService]   Updating local version to: $serverVersion');
      await updateLocalDataVersion(serverVersion);
      await _updateLastSyncTime();

      final localAfter = _taskRepository.getTotalCount();
      print('🔄 [SyncService] ✅ Sync completed successfully!');
      print('🔄 [SyncService]   Tasks synced: ${serverTasks.length}');
      print('🔄 [SyncService]   Local tasks after sync: $localAfter');
    } catch (e) {
      print('🔄 [SyncService] ❌ Sync failed: $e');
      rethrow;
    }
  }

  /// Sync on app startup
  ///
  /// Called when app opens to check and sync if needed
  Future<void> syncOnStartup() async {
    print('🔄 [SyncService] === SYNC ON STARTUP ===');

    if (!_authService.isAuthenticated) {
      print('🔄 [SyncService] User not authenticated - using local data only');
      final localTaskCount = _taskRepository.getTotalCount();
      print('🔄 [SyncService] Local tasks: $localTaskCount');
      return;
    }

    try {
      print('🔄 [SyncService] User authenticated - checking if sync needed...');
      final needsSync = await isSyncNeeded();

      if (needsSync) {
        print('🔄 [SyncService] ⚠️ Data versions differ - syncing from server...');
        await syncFromServer();
        final localTaskCount = _taskRepository.getTotalCount();
        print('🔄 [SyncService] ✅ Sync complete - Local tasks: $localTaskCount');
      } else {
        print('🔄 [SyncService] ✅ Data is up to date - no sync needed');
        final localTaskCount = _taskRepository.getTotalCount();
        print('🔄 [SyncService] Local tasks: $localTaskCount');
      }
    } catch (e) {
      print('🔄 [SyncService] ❌ Startup sync failed: $e');
      print('🔄 [SyncService] ⚠️ Continuing with local data');
      // Continue with local data if sync fails
    }

    print('🔄 [SyncService] === SYNC COMPLETE ===');
  }

  // ============================================================================
  // TASK OPERATIONS (WITH SYNC)
  // ============================================================================

  /// Create task (saves to local and server if authenticated)
  ///
  /// Returns the created task
  /// Only syncs to server if user is authenticated
  /// Uses Either pattern for error handling
  Future<TaskModel> createTask(TaskModel task) async {
    // Always save to local first
    await _taskRepository.addTask(task);
    print('✅ [SyncService] Task saved locally: ${task.title}');

    // If authenticated, also save to server
    if (_authService.isAuthenticated) {
      final result = await _taskProvider.createTask(task);

      result.fold(
        // Left: Error occurred
        (error) {
          print('⚠️ [SyncService] Server sync failed - task saved locally only');
          print('⚠️ [SyncService] Error: $error');
          // Task is still saved locally, so we can continue
        },
        // Right: Success
        (serverTask) async {
          // Update local task with server data (might have server-generated fields)
          await _taskRepository.updateTask(serverTask);

          print('✅ [SyncService] Task synced to server: ${task.title}');

          // Refresh auth state to get new data_version
          await _authService.checkAuthStatus();
          final newVersion = _authService.currentUser?.dataVersion ?? 0;
          await updateLocalDataVersion(newVersion);
        },
      );
    } else {
      print('ℹ️ [SyncService] User not authenticated - task saved locally only');
    }

    return task;
  }

  /// Update task (saves to local and server if authenticated)
  Future<TaskModel> updateTask(TaskModel task) async {
    // Always update local first
    await _taskRepository.updateTask(task);
    print('✅ [SyncService] Task updated locally: ${task.title}');

    // If authenticated, also update on server
    if (_authService.isAuthenticated) {
      try {
        final serverTask = await _taskProvider.updateTask(task);

        // Update local task with server response
        await _taskRepository.updateTask(serverTask);

        print('✅ [SyncService] Task synced to server: ${task.title}');

        // Refresh auth state to get new data_version
        await _authService.checkAuthStatus();
        final newVersion = _authService.currentUser?.dataVersion ?? 0;
        await updateLocalDataVersion(newVersion);

        return serverTask;
      } catch (e) {
        print('⚠️ [SyncService] Server sync failed - task updated locally only: $e');
      }
    }

    return task;
  }

  /// Delete task (deletes from local and server if authenticated)
  Future<void> deleteTask(String taskId) async {
    // Always delete from local first
    await _taskRepository.deleteTask(taskId);
    print('✅ [SyncService] Task deleted locally: $taskId');

    // If authenticated, also delete from server
    if (_authService.isAuthenticated) {
      try {
        await _taskProvider.deleteTask(taskId);
        print('✅ [SyncService] Task deleted from server: $taskId');

        // Refresh auth state to get new data_version
        await _authService.checkAuthStatus();
        final newVersion = _authService.currentUser?.dataVersion ?? 0;
        await updateLocalDataVersion(newVersion);
      } catch (e) {
        print('⚠️ [SyncService] Server sync failed - task deleted locally only: $e');
      }
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Force full sync (useful for manual refresh)
  Future<void> forceSyncFromServer() async {
    await syncFromServer();
  }

  /// Get sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    final isAuthenticated = _authService.isAuthenticated;
    final localVersion = await getLocalDataVersion();
    final serverVersion = _authService.currentUser?.dataVersion;
    final lastSync = await getLastSyncTime();
    final needsSync = await isSyncNeeded();

    return {
      'isAuthenticated': isAuthenticated,
      'localVersion': localVersion,
      'serverVersion': serverVersion,
      'lastSync': lastSync?.toIso8601String(),
      'needsSync': needsSync,
    };
  }
}
