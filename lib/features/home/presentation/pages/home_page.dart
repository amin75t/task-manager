import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _isPaused = false;
  int _transcriptionProgress = 0;
  String _transcription = '';
  String? _recordingPath;
  int _recordingSeconds = 0;
  bool _isModelDownloaded = false;

  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animationController = controller;

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    _initializeWhisper();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && !_isPaused && mounted) {
        setState(() {
          _recordingSeconds++;
        });
        return true;
      }
      return false;
    });
  }

  String _formatDuration(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours : $minutes : $secs';
  }

  Future<void> _initializeWhisper() async {
    if (_whisperService.isInitialized) {
      return;
    }

    setState(() {
      _isInitializing = true;
    });

    // Check if model is downloaded before initialization
    final isDownloaded = await _whisperService.isModelDownloaded();
    if (mounted) {
      setState(() {
        _isModelDownloaded = isDownloaded;
      });
    }

    // Start initialization (this will download the model if needed)
    final initFuture = _whisperService.initialize();

    // Periodically check download status while initializing
    if (!isDownloaded) {
      _checkDownloadProgress();
    }

    await initFuture;

    // Final check after initialization
    final isDownloadedAfterInit = await _whisperService.isModelDownloaded();

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _isModelDownloaded = isDownloadedAfterInit;
      });
    }
  }

  Future<void> _checkDownloadProgress() async {
    // Check download status every 2 seconds while initializing
    while (_isInitializing && mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_isInitializing || !mounted) break;

      final isDownloaded = await _whisperService.isModelDownloaded();
      if (mounted && _isModelDownloaded != isDownloaded) {
        setState(() {
          _isModelDownloaded = isDownloaded;
        });
      }

      if (isDownloaded) break;
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
        _recordingSeconds = 0;
      });
      _startTimer();
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

  Future<void> _togglePause() async {
    if (_isPaused) {
      await _recorderService.resumeRecording();
      setState(() {
        _isPaused = false;
      });
    } else {
      await _recorderService.pauseRecording();
      setState(() {
        _isPaused = true;
      });
    }
  }

  Future<void> _cancelRecording() async {
    await _recorderService.stopRecording();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordingSeconds = 0;
      _recordingPath = null;
    });
  }

  Future<void> _showStopRecordingDialog() async {
    final shouldTranscribe = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Have you finished recording? Would\nyou like to transcribe it now?',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                // Transcribe Now button
                SizedBox(
                  width: 285,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Transcribe Now',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Not Yet button
                SizedBox(
                  width: 285,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Not Yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldTranscribe == true) {
      await _stopRecording();
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorderService.stopRecording();
    setState(() {
      _isRecording = false;
      _isPaused = false;
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

    // Start checking model download status during transcription
    _checkModelDownloadDuringTranscription();

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

      // Check model status one final time after transcription
      _checkModelStatus();

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

  Future<void> _checkModelDownloadDuringTranscription() async {
    // Check download status every 2 seconds while transcribing
    while (_isTranscribing && mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_isTranscribing || !mounted) break;

      final isDownloaded = await _whisperService.isModelDownloaded();
      if (mounted && _isModelDownloaded != isDownloaded) {
        setState(() {
          _isModelDownloaded = isDownloaded;
        });
      }

      if (isDownloaded) break;
    }
  }

  Future<void> _checkModelStatus() async {
    final isDownloaded = await _whisperService.isModelDownloaded();
    if (mounted && _isModelDownloaded != isDownloaded) {
      setState(() {
        _isModelDownloaded = isDownloaded;
      });
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _recorderService.dispose();
    super.dispose();
  }

  Widget _buildRecordButton() {
    if (_isRecording) {
      return _buildRecordingUI();
    }

    return GestureDetector(
      onTap: _isTranscribing || _isInitializing ? null : _toggleRecording,
      child: AnimatedBuilder(
        animation: _animationController ?? AnimationController(vsync: this),
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hi',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap to Start',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
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

  Widget _buildRecordingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          _isPaused ? 'Paused' : 'Recording...',
          style: TextStyle(
            color: _isPaused ? AppColors.accent : AppColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 60),
        // Animated circular button with concentric circles
        AnimatedBuilder(
          animation: _animationController ?? AnimationController(vsync: this),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing circles
                for (int i = 3; i > 0; i--)
                  Transform.scale(
                    scale: 1.0 + (i * 0.15 * (_pulseAnimation?.value ?? 0.0)),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3 / i),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                // Center button
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: _showStopRecordingDialog,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundDark,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 180),
        // Timer
        Text(
          _formatDuration(_recordingSeconds),
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
      ],
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
              const Icon(Icons.auto_awesome, size: 60, color: AppColors.accent),
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
                style: TextStyle(fontSize: 14, color: AppColors.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isTranscribing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isTranscribing) {
          // Prevent back during transcription
          return;
        }
        if (!didPop && _transcription.isNotEmpty) {
          // Clear transcription on back
          setState(() {
            _transcription = '';
            _recordingPath = null;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDarker,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundDarker,
          elevation: 0,
          leading: _transcription.isNotEmpty && !_isTranscribing
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textLight,
                  ),
                  onPressed: () {
                    setState(() {
                      _transcription = '';
                      _recordingPath = null;
                    });
                  },
                )
              : null,
          centerTitle: false,
          actions: [
            // Model download status button
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isModelDownloaded
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isModelDownloaded
                      ? AppColors.success.withOpacity(0.5)
                      : AppColors.warning.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isModelDownloaded
                        ? Icons.check_circle
                        : Icons.download,
                    color: _isModelDownloaded
                        ? AppColors.success
                        : AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isModelDownloaded ? 'Model Ready' : 'Not Downloaded',
                    style: TextStyle(
                      color: _isModelDownloaded
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12), // Space between model status and settings
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textLight,
              ),
              onPressed: () {
                GoRouter.of(context).push('/settings');
              },
            ),
          ],
        ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_isRecording)
                Expanded(
                  child: Stack(
                    children: [
                      Center(child: _buildRecordButton()),
                      // Pause/Resume button (left)
                      Positioned(
                        left: 40,
                        top: MediaQuery.of(context).size.height * 0.4,
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPaused ? Icons.play_arrow : Icons.pause,
                                color: AppColors.textLight,
                                size: 32,
                              ),
                              onPressed: _togglePause,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isPaused ? 'Resume' : 'Pause',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Cancel button (right)
                      Positioned(
                        right: 40,
                        top: MediaQuery.of(context).size.height * 0.4,
                        child: Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textLight,
                                size: 32,
                              ),
                              onPressed: _cancelRecording,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                const SizedBox(height: 70),
                _buildRecordButton(),
                const SizedBox(height: 70),
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
              ],
            ],
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
      ),
    );
  }
}
