import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class WhisperService {
  static WhisperService? _instance;
  Whisper? _whisper;
  bool _isInitialized = false;
  bool _isInitializing = false;
  String? _modelDir;

  WhisperService._();

  static WhisperService get instance {
    _instance ??= WhisperService._();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;

  /// Check if the Whisper model is already downloaded
  Future<bool> isModelDownloaded() async {
    try {
      // Get the app documents directory (app_flutter on Android)
      final Directory appDir = await getApplicationDocumentsDirectory();

      // The whisper_flutter_new package uses this path structure
      final String modelPath = '${appDir.path}/whisper_models/ggml-small.bin';

      final File modelFile = File(modelPath);
      final bool exists = await modelFile.exists();

      if (exists) {
        // Check if file size is valid (small model is ~466 MB)
        final int fileSize = await modelFile.length();
        final double sizeMB = fileSize / (1024 * 1024);

        print('Model file found at: $modelPath');
        print('Model file size: ${sizeMB.toStringAsFixed(2)} MB');

        // If file is larger than 400 MB, it's complete
        if (fileSize > 400 * 1024 * 1024) {
          print('Model is fully downloaded and ready!');
          return true;
        } else {
          print('Model file exists but appears incomplete (${sizeMB.toStringAsFixed(2)} MB)');
          return false;
        }
      }

      print('Model not found at: $modelPath');
      return false;
    } catch (e) {
      print('Error checking model download status: $e');
      return false;
    }
  }

  /// Get the estimated download size for the current model (in MB)
  int getModelSizeMB() {
    // Based on WhisperModel.small
    // Model sizes: tiny=75MB, base=142MB, small=466MB, medium=1.5GB, large=2.9GB
    return 466;
  }

  /// Debug function to find all .bin files in app directory
  Future<void> findModelFiles() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      print('App Documents Directory: ${appDir.path}');

      // List all files recursively
      await for (var entity in appDir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.bin')) {
          final size = await entity.length();
          print('Found .bin file: ${entity.path} (${(size / (1024 * 1024)).toStringAsFixed(2)} MB)');
        }
      }
    } catch (e) {
      print('Error finding model files: $e');
    }
  }

  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    if (_isInitializing) {
      // Wait for initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _isInitialized;
    }

    _isInitializing = true;

    try {
      // Set up model directory if not already set
      if (_modelDir == null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        _modelDir = '${appDir.path}/whisper_models';

        // Create directory if it doesn't exist
        final modelDirectory = Directory(_modelDir!);
        if (!await modelDirectory.exists()) {
          await modelDirectory.create(recursive: true);
          print('Created model directory: $_modelDir');
        }
      }

      print('Initializing Whisper with model directory: $_modelDir');

      _whisper = Whisper(
        model: WhisperModel.small,  // Using small model for better Persian accuracy
        downloadHost:
            "https://huggingface.co/ggerganov/whisper.cpp/resolve/main",
        modelDir: _modelDir,  // Specify custom model directory
      );

      _isInitialized = true;
      _isInitializing = false;
      print('Whisper initialization complete!');

      // Note: The model will be downloaded on first transcription attempt
      print('Model will be downloaded automatically on first transcription');

      return true;
    } catch (e) {
      print('Whisper initialization failed: $e');
      _isInitializing = false;
      return false;
    }
  }

  Future<String?> transcribe(
    String audioPath, {
    String? language,
    Function(int progress)? onProgress,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return null;
      }
    }

    try {
      // Start simulated progress updates
      bool isCompleted = false;
      if (onProgress != null) {
        _simulateProgress(onProgress, () => isCompleted);
      }

      // Try without language first to let Whisper auto-detect
      final response = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false,
          isNoTimestamps: true,
          splitOnWord: true,
          threads: 4,  // Use multiple threads for faster processing
        ),
      );

      // Mark as completed to stop progress simulation
      isCompleted = true;

      // Extract text from WhisperTranscribeResponse
      return response.text.trim();
    } catch (e) {
      print('Transcription error: $e');
      return null;
    }
  }

  // Simulate progress since the package doesn't provide real progress
  Future<void> _simulateProgress(
    Function(int progress) onProgress,
    bool Function() isCompleted,
  ) async {
    int progress = 0;
    while (progress < 95 && !isCompleted()) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (progress < 30) {
        progress += 5;
      } else if (progress < 60) {
        progress += 3;
      } else if (progress < 90) {
        progress += 2;
      } else {
        progress += 1;
      }
      if (!isCompleted()) {
        onProgress(progress);
      }
    }

    // Wait for completion and set to 100%
    while (!isCompleted()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    onProgress(100);
  }

  void dispose() {
    _whisper = null;
    _isInitialized = false;
    _isInitializing = false;
  }
}
