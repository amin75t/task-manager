import 'package:get_it/get_it.dart';
import 'package:task_manager/core/database/hive_service.dart';
import 'package:task_manager/core/repositories/task_repository.dart';
import 'package:task_manager/core/services/audio_recorder_service.dart';
import 'package:task_manager/core/services/whisper_service.dart';
import 'package:task_manager/core/api/api_client.dart';
import 'package:task_manager/core/api/providers/auth_provider.dart';
import 'package:task_manager/core/services/token_service.dart';
import 'package:task_manager/core/services/auth_service.dart';

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

  // ============================================================================
  // BUSINESS LOGIC SERVICES
  // ============================================================================

  // Auth Service (headless authentication management)
  locator.registerLazySingleton(() => AuthService(
        locator<AuthProvider>(),
        locator<TokenService>(),
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
  await locator<HiveService>().openBoxes();

  // Initialize AuthService eagerly to check auth status on app startup
  // This will call /auth/me endpoint if token exists
  locator<AuthService>();
}
