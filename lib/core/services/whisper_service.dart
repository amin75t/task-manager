import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class WhisperService {
  static WhisperService? _instance;
  Whisper? _whisper;
  bool _isInitialized = false;
  bool _isInitializing = false;

  WhisperService._();

  static WhisperService get instance {
    _instance ??= WhisperService._();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;

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
      _whisper = Whisper(
        model: WhisperModel.small,  // Using small model for better Persian accuracy
        downloadHost:
            "https://huggingface.co/ggerganov/whisper.cpp/resolve/main",
      );

      _isInitialized = true;
      _isInitializing = false;
      return true;
    } catch (e) {
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
