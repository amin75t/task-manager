import 'package:get_it/get_it.dart';
import 'package:task_manager/core/database/hive_service.dart';
import 'package:task_manager/core/repositories/task_repository.dart';
import 'package:task_manager/core/services/audio_recorder_service.dart';
import 'package:task_manager/core/services/whisper_service.dart';

final locator = GetIt.instance;

/// Service Locator Setup
/// Register all services and repositories here for dependency injection
Future<void> setupLocator() async {
  // Core Services
  locator.registerLazySingleton(() => HiveService.instance);
  locator.registerLazySingleton(() => WhisperService.instance);
  locator.registerFactory(() => AudioRecorderService());

  // Repositories
  locator.registerLazySingleton(() => TaskRepository());

  // Initialize Hive
  await locator<HiveService>().init();
  await locator<HiveService>().openBoxes();
}
