import 'package:get_it/get_it.dart';
import 'package:task_manager/core/database/hive_service.dart';
import 'package:task_manager/core/database/migration_helper.dart';
import 'package:task_manager/core/repositories/task_repository.dart';
import 'package:task_manager/core/services/audio_recorder_service.dart';
import 'package:task_manager/core/services/whisper_service.dart';
import 'package:task_manager/core/api/api_client.dart';
import 'package:task_manager/core/api/providers/auth_provider.dart';
import 'package:task_manager/core/api/providers/task_provider.dart';
import 'package:task_manager/core/services/token_service.dart';
import 'package:task_manager/core/services/auth_service.dart';
import 'package:task_manager/core/services/sync_service.dart';

final locator = GetIt.instance;

/// Service Locator Setup
/// Register all services and repositories here for dependency injection
Future<void> setupLocator() async {
  // ============================================================================
  // API & NETWORK
  // ============================================================================

  // API Client (Dio-based)
  locator.registerLazySingleton(() => ApiClient());

  // Token Service (for JWT management)
  locator.registerLazySingleton(() => TokenService());

  // ============================================================================
  // API PROVIDERS
  // ============================================================================

  // Auth Provider
  locator.registerLazySingleton(() => AuthProvider(locator<ApiClient>()));

  // Task Provider
  locator.registerLazySingleton(() => TaskProvider(locator<ApiClient>()));

  // ============================================================================
  // BUSINESS LOGIC SERVICES
  // ============================================================================

  // Auth Service (headless authentication management)
  locator.registerLazySingleton(() => AuthService(
        locator<AuthProvider>(),
        locator<TokenService>(),
      ));

  // Sync Service (data synchronization between local and server)
  locator.registerLazySingleton(() => SyncService(
        locator<TaskRepository>(),
        locator<TaskProvider>(),
        locator<AuthService>(),
      ));

  // ============================================================================
  // CORE SERVICES
  // ============================================================================

  locator.registerLazySingleton(() => HiveService.instance);
  locator.registerLazySingleton(() => WhisperService.instance);
  locator.registerFactory(() => AudioRecorderService());

  // ============================================================================
  // REPOSITORIES
  // ============================================================================

  locator.registerLazySingleton(() => TaskRepository());

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  // Initialize Hive
  await locator<HiveService>().init();

  // Check for schema changes and migrate if needed
  await MigrationHelper.checkAndMigrate();

  // Open Hive boxes
  await locator<HiveService>().openBoxes();

  // Initialize AuthService eagerly to check auth status on app startup
  // This will call /auth/me endpoint if token exists
  print('🚀 [Locator] Creating AuthService...');
  final authService = locator<AuthService>();

  // Wait for auth initialization to complete before syncing
  // This ensures we have the correct user data_version
  print('⏳ [Locator] Waiting for auth initialization...');
  await authService.initialized;
  print('✅ [Locator] Auth initialization complete');

  // After auth check, perform data synchronization if needed
  // This compares local and server data versions and syncs if different
  print('🔄 [Locator] Starting initial sync...');
  await _performInitialSync();
  print('✅ [Locator] Initial sync complete');
}

/// Perform initial data synchronization
///
/// Called during app startup after auth initialization
/// Syncs tasks from server if data versions differ
Future<void> _performInitialSync() async {
  try {
    final syncService = locator<SyncService>();
    await syncService.syncOnStartup();
  } catch (e) {
    print('⚠️ [Locator] Initial sync failed: $e');
    // Continue app startup even if sync fails
  }
}
