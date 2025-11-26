import 'package:flutter/material.dart';
import 'package:task_manager/config/theme/app_colors.dart';
import 'package:task_manager/core/services/audio_recorder_service.dart';
import 'package:task_manager/core/services/whisper_service.dart';
import 'package:task_manager/features/home/presentation/widgets/action_button.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final AudioRecorderService _recorderService = AudioRecorderService();
  final WhisperService _whisperService = WhisperService.instance;

  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isInitializing = false;
  int _transcriptionProgress = 0;
  String _transcription = '';
  String? _recordingPath;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
            content: Text('Failed to start recording'),
            backgroundColor: AppColors.error,
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
      _transcriptionProgress = 0;
    });

    final transcription = await _whisperService.transcribe(
      audioPath,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _transcriptionProgress = progress;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isTranscribing = false;
        _transcriptionProgress = 100;
        _transcription = transcription ?? 'Failed to transcribe audio';
      });

      if (transcription == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to transcribe audio'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recorderService.dispose();
    super.dispose();
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _isTranscribing || _isInitializing ? null : _toggleRecording,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundDark,
                boxShadow: [
                  BoxShadow(
                    color: _isRecording
                        ? AppColors.accent.withOpacity(0.4)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: _isRecording ? 30 : 20,
                    spreadRadius: _isRecording ? 10 : 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRecording ? '' : 'Hi',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRecording ? 'Recording...' : 'Tap to Start',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Audio wave animation
                  if (_isRecording)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 4,
                          height: 20 + (index % 3) * 10,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    )
                  else
                    Icon(
                      Icons.graphic_eq,
                      size: 40,
                      color: AppColors.accent.withOpacity(0.5),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTranscribingOverlay() {
    return Container(
      color: AppColors.backgroundDarker.withOpacity(0.95),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 60,
                color: AppColors.accent,
              ),
              const SizedBox(height: 24),
              const Text(
                'Transcribing Audio...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _transcriptionProgress / 100,
                    backgroundColor: AppColors.accentDark,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                    minHeight: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$_transcriptionProgress%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI is processing your voice...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDarker,
        elevation: 0,

        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textLight,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 70,),
          _buildRecordButton(),
          SizedBox(height: 70,),
          // Bottom action buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButton(
                  iconPath: 'assets/icons/upload.svg',
                  label: 'Upload Audio',
                  onTap: null, // Disabled as per requirements
                ),
                const SizedBox(width: 32),
                ActionButton(
                  iconPath: 'assets/icons/music-library-2.svg',
                  label: 'Records',
                  onTap: null, // Disabled as per requirements
                ),
              ],
            ),
          ),
          // Transcribing overlay
          if (_isTranscribing) _buildTranscribingOverlay(),
          // Result overlay
          if (_transcription.isNotEmpty && !_isTranscribing)
            Container(
              color: AppColors.backgroundDarker.withOpacity(0.95),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transcription Result',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textLight,
                            ),
                            onPressed: () {
                              setState(() {
                                _transcription = '';
                                _recordingPath = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _transcription,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textLight,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Save transcription
                          setState(() {
                            _transcription = '';
                            _recordingPath = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textOnAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _transcription = '';
                            _recordingPath = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Record Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
