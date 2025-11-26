import 'package:flutter/material.dart';
import 'package:task_manager/core/services/audio_recorder_service.dart';
import 'package:task_manager/core/services/whisper_service.dart';

class VoiceTaskPage extends StatefulWidget {
  const VoiceTaskPage({super.key});

  @override
  State<VoiceTaskPage> createState() => _VoiceTaskPageState();
}

class _VoiceTaskPageState extends State<VoiceTaskPage> with SingleTickerProviderStateMixin {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final WhisperService _whisperService = WhisperService.instance;

  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isInitializing = false;
  bool _isPlaying = false;
  String _transcription = '';
  String? _recordingPath;

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

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

  Future<void> _togglePlayback() async {
    if (_recordingPath == null) return;

    if (_isPlaying) {
      await _recorderService.stopAudio();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _recorderService.playAudio(_recordingPath!);
      setState(() {
        _isPlaying = true;
      });

      // Auto-stop after playback finishes
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_recorderService.isPlaying()) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
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
    _animationController.dispose();
    _recorderService.dispose();
    super.dispose();
  }

  Widget _buildDownloadingUI() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated brain icon
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Progress indicator
            SizedBox(
              width: 250,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple.shade400,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Title
            Text(
              'Downloading AI Model',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Setting up Whisper Small Model',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Model size info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_download,
                    size: 18,
                    color: Colors.deepPurple.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '~465 MB • First time only',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Additional info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'This happens only once.\nFuture uses will be instant!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                _buildDownloadingUI()
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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.deepPurple.shade200,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: Colors.deepPurple.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Transcribing Audio...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple.shade600,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'AI is processing your voice...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transcription:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (_recordingPath != null)
                              IconButton(
                                onPressed: _togglePlayback,
                                icon: Icon(
                                  _isPlaying ? Icons.stop : Icons.play_arrow,
                                ),
                                color: Colors.deepPurple,
                                tooltip: _isPlaying ? 'Stop' : 'Play recording',
                              ),
                          ],
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
