import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? _recordingPath;
  bool _isInitialized = false;
  bool _isPlayerInitialized = false;

  Future<void> _initialize() async {
    if (!_isInitialized) {
      await _recorder.openRecorder();
      _isInitialized = true;
    }
  }

  Future<void> _initializePlayer() async {
    if (!_isPlayerInitialized) {
      await _player.openPlayer();
      _isPlayerInitialized = true;
    }
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  Future<String?> startRecording() async {
    try {
      // Initialize recorder
      await _initialize();

      // Check permission
      if (!await hasPermission()) {
        final granted = await requestPermission();
        if (!granted) {
          print('Permission denied');
          return null;
        }
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${directory.path}/recording_$timestamp.wav';

      print('Starting recording to: $_recordingPath');

      // Start recording
      await _recorder.startRecorder(
        toFile: _recordingPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );

      print('Recording started successfully');
      return _recordingPath;
    } catch (e) {
      print('Error starting recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      return _recordingPath;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isRecording() async {
    return _recorder.isRecording;
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder.stopRecorder();
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> playAudio(String filePath) async {
    try {
      await _initializePlayer();
      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          print('Playback finished');
        },
      );
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _player.stopPlayer();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _player.pausePlayer();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  Future<void> resumeAudio() async {
    try {
      await _player.resumePlayer();
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  bool isPlaying() {
    return _player.isPlaying;
  }

  bool isPaused() {
    return _player.isPaused;
  }

  void dispose() {
    if (_isInitialized) {
      _recorder.closeRecorder();
      _isInitialized = false;
    }
    if (_isPlayerInitialized) {
      _player.closePlayer();
      _isPlayerInitialized = false;
    }
  }
}
