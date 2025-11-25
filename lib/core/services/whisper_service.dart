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
        model: WhisperModel.medium,
        downloadHost: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main",
      );

      _isInitialized = true;
      _isInitializing = false;
      return true;
    } catch (e) {
      _isInitializing = false;
      return false;
    }
  }

  Future<String?> transcribe(String audioPath, {String language = 'fa'}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return null;
      }
    }

    try {
      final response = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false,
          isNoTimestamps: true,
          splitOnWord: true,
          language: language,
        ),
      );

      // Extract text from WhisperTranscribeResponse
      return response.text.trim();
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _whisper = null;
    _isInitialized = false;
    _isInitializing = false;
  }
}
