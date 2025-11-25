import 'package:flutter/material.dart';
import 'package:task_manager/core/services/audio_recorder_service.dart';
import 'package:task_manager/core/services/whisper_service.dart';

class VoiceTaskPage extends StatefulWidget {
  const VoiceTaskPage({super.key});

  @override
  State<VoiceTaskPage> createState() => _VoiceTaskPageState();
}

class _VoiceTaskPageState extends State<VoiceTaskPage> {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final WhisperService _whisperService = WhisperService.instance;

  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isInitializing = false;
  String _transcription = '';
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _initializeWhisper();
  }

  Future<void> _initializeWhisper() async {
    if (_whisperService.isInitialized) {
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    await _whisperService.initialize();

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final path = await _recorderService.startRecording();
    if (path != null) {
      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _transcription = '';
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start recording. Please check microphone permissions.'),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorderService.stopRecording();
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      await _transcribeAudio(path);
    }
  }

  Future<void> _transcribeAudio(String audioPath) async {
    setState(() {
      _isTranscribing = true;
    });

    final transcription = await _whisperService.transcribe(audioPath);

    if (mounted) {
      setState(() {
        _isTranscribing = false;
        _transcription = transcription ?? 'Failed to transcribe audio';
      });

      if (transcription == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to transcribe audio. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _createTask() async {
    if (_transcription.isEmpty || _transcription == 'Failed to transcribe audio') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record and transcribe your task first.'),
        ),
      );
      return;
    }

    // TODO: Implement task creation logic with repository
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task created: $_transcription'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _recorderService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Task'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isInitializing)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing Whisper AI...'),
                      SizedBox(height: 8),
                      Text(
                        'This may take a moment on first launch',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else ...[
                const Icon(
                  Icons.mic,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 24),
                Text(
                  _isRecording
                      ? 'Recording...'
                      : _isTranscribing
                          ? 'Transcribing...'
                          : 'Tap to record your task',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: _isTranscribing ? null : _toggleRecording,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.red : Colors.deepPurple,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : Colors.deepPurple)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (_isTranscribing)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (_transcription.isNotEmpty && !_isTranscribing) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transcription:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _transcription,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createTask,
                    icon: const Icon(Icons.check),
                    label: const Text('Create Task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _transcription = '';
                        _recordingPath = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Record Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
