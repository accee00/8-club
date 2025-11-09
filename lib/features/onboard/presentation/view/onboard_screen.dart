import 'dart:io';
import 'dart:ui';
import 'package:eightclub/core/extensions/build_extension.dart';
import 'package:eightclub/core/constants/app_colors.dart';
import 'package:eightclub/core/logger/app_logger.dart';
import 'package:eightclub/core/widgets/custom_text_feild.dart';
import 'package:eightclub/core/widgets/elevatedNextButton.dart';
import 'package:eightclub/core/widgets/wave_background.dart';
import 'package:eightclub/core/widgets/wave_progress_indicator.dart';
import 'package:eightclub/features/onboard/presentation/widget/app_bar_blur_widget.dart';
import 'package:eightclub/features/onboard/presentation/widget/audio_player_widget.dart';
import 'package:eightclub/features/onboard/presentation/widget/camera_widget.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final TextEditingController _textController = TextEditingController();
  bool isVideoSelected = false;
  bool isAudioSelected = false;
  bool _showAudioPlayer = false;
  String? recordedFilePath;
  String? recordedVideoPath;
  final RecorderController recorderController = RecorderController();
  final PlayerController playerController = PlayerController();
  VideoPlayerController? _videoController;
  bool _isRecording = false;
  bool _isRecordingCompleted = false;
  bool _isVideoRecordingCompleted = false;
  int _recordingDuration = 0;
  DateTime? _recordingStartTime;
  bool _isPermissionChecking = false;

  @override
  void initState() {
    super.initState();
    recorderController.checkPermission();

    playerController.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {});
      }
    });

    playerController.onCompletion.listen((_) async {
      if (mounted && recordedFilePath != null) {
        try {
          await playerController.preparePlayer(
            path: recordedFilePath!,
            shouldExtractWaveform: true,
            noOfSamples: 100,
          );
          if (mounted) {
            setState(() {});
          }
        } catch (e) {
          logInfo('Error re-preparing player after completion: $e');
        }
      }
    });
  }

  Future<bool> _checkCameraPermissions() async {
    setState(() {
      _isPermissionChecking = true;
    });

    try {
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;

      logInfo('Camera permission status: $cameraStatus');
      logInfo('Microphone permission status: $microphoneStatus');

      if (cameraStatus.isPermanentlyDenied ||
          microphoneStatus.isPermanentlyDenied) {
        if (mounted) {
          await _showPermissionRationaleDialog();
        }
        return false;
      }

      if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.camera,
          Permission.microphone,
        ].request();

        logInfo(
          'Camera permission after request: ${statuses[Permission.camera]}',
        );
        logInfo(
          'Microphone permission after request: ${statuses[Permission.microphone]}',
        );

        final bool bothGranted =
            statuses[Permission.camera]?.isGranted == true &&
            statuses[Permission.microphone]?.isGranted == true;

        if (!bothGranted) {
          return false;
        }
      }

      return true;
    } catch (e) {
      logInfo('Error checking permissions: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isPermissionChecking = false;
        });
      }
    }
  }

  Future<void> _showPermissionRationaleDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'Camera and microphone permissions are required to record videos. '
            'Please enable them in app settings to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openNativeCamera() async {
    final hasPermission = await _checkCameraPermissions();
    if (!hasPermission) {
      setState(() {
        isVideoSelected = false;
      });
      return;
    }

    final String? videoPath = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NativeCameraScreen(
          onVideoRecorded: (path) {
            if (path != null) {
              _handleRecordedVideo(path);
            }
          },
        ),
      ),
    );

    if (videoPath != null) {
      _handleRecordedVideo(videoPath);
    } else {
      setState(() {
        isVideoSelected = false;
      });
    }
  }

  void _handleRecordedVideo(String videoPath) async {
    setState(() {
      recordedVideoPath = videoPath;
      _isVideoRecordingCompleted = true;
    });

    try {
      _videoController = VideoPlayerController.file(File(recordedVideoPath!));
      await _videoController!.initialize();
      setState(() {});
    } catch (e) {
      logInfo('Error initializing video player: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _textController.dispose();
    recorderController.dispose();
    playerController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _startOrStopRecording() async {
    try {
      if (_isRecording) {
        if (recorderController.isRecording) {
          recordedFilePath = await recorderController.stop();
        }

        setState(() {
          _isRecording = false;
          _isRecordingCompleted = recordedFilePath != null;
          isAudioSelected = false;
        });

        if (recordedFilePath != null) {
          final file = File(recordedFilePath!);
          final exists = await file.exists();

          if (exists) {
            try {
              await playerController.preparePlayer(
                path: recordedFilePath!,
                shouldExtractWaveform: true,
                noOfSamples: 100,
              );
              logInfo('Player prepared successfully');
            } catch (e) {
              logInfo('Error preparing player: $e');
            }
          }
        }
      } else {
        if (recorderController.hasPermission) {
          await recorderController.record();

          setState(() {
            _isRecording = true;
            _isRecordingCompleted = false;
            _recordingDuration = 0;
          });

          _startTimer();
        }
      }
    } catch (e) {
      logInfo(e.toString());
    }
  }

  void _startTimer() {
    _recordingStartTime = DateTime.now();

    Future.doWhile(() async {
      if (!_isRecording || !mounted) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration = DateTime.now()
              .difference(_recordingStartTime!)
              .inSeconds;
        });
      }
      return _isRecording;
    });
  }

  Future<void> _togglePlayPause() async {
    if (recordedFilePath == null) return;

    try {
      if (playerController.playerState.isPlaying) {
        await playerController.pausePlayer();
      } else if (playerController.playerState.isPaused) {
        await playerController.startPlayer();
      } else {
        await playerController.preparePlayer(
          path: recordedFilePath!,
          shouldExtractWaveform: true,
          noOfSamples: 100,
        );
        await playerController.startPlayer();
      }

      setState(() {});
    } catch (e) {
      logInfo('Playback error: $e');
      try {
        await playerController.preparePlayer(
          path: recordedFilePath!,
          shouldExtractWaveform: true,
          noOfSamples: 100,
        );
        await playerController.startPlayer();
        if (mounted) {
          setState(() {});
        }
      } catch (retryError) {
        logInfo('Retry playback error: $retryError');
      }
    }
  }

  Future<void> _toggleVideoPlayPause() async {
    if (_videoController == null) return;

    try {
      if (_videoController!.value.isPlaying) {
        await _videoController!.pause();
      } else {
        await _videoController!.play();
      }
      setState(() {});
    } catch (e) {
      logInfo('Video playback error: $e');
    }
  }

  Future<void> _deleteRecording() async {
    try {
      await playerController.stopPlayer();

      if (recordedFilePath != null) {
        final file = File(recordedFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        recordedFilePath = null;
        _isRecordingCompleted = false;
        _showAudioPlayer = false;
      });
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> _deleteVideoRecording() async {
    try {
      if (_videoController != null) {
        await _videoController!.pause();
        _videoController!.dispose();
        _videoController = null;
      }

      if (recordedVideoPath != null) {
        final file = File(recordedVideoPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        recordedVideoPath = null;
        _isVideoRecordingCompleted = false;
      });
    } catch (e) {
      debugPrint('Video delete error: $e');
    }
  }

  void _showVideoPlayerDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface.withAlpha(204),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2A2A2A),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Video',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                        // Video Player
                        if (_videoController != null &&
                            _videoController!.value.isInitialized)
                          Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.4,
                            ),
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        // Controls
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Column(
                            children: [
                              // Progress Bar
                              if (_videoController != null &&
                                  _videoController!.value.isInitialized)
                                VideoProgressIndicator(
                                  _videoController!,
                                  allowScrubbing: true,
                                  colors: VideoProgressColors(
                                    playedColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    backgroundColor: Colors.grey[700]!,
                                    bufferedColor: Colors.grey[500]!,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                              const SizedBox(height: 20),
                              // Play/Pause and Delete buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Play/Pause button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        _videoController != null &&
                                                _videoController!
                                                    .value
                                                    .isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () async {
                                        await _toggleVideoPlayPause();
                                        setDialogState(() {});
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  // Delete button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: context.colorScheme.error
                                          .withAlpha(120),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: context.colorScheme.error,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _deleteVideoRecording();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    final adaptiveMaxLines =
        isKeyboardOpen ||
            _isRecording ||
            _isRecordingCompleted ||
            _isVideoRecordingCompleted
        ? 6
        : 14;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: false,
      appBar: _appBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 0),
            child: _appBarBottomOverlay(context),
          ),
          Expanded(
            child: WaveBackground(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        top: _calculateTopPadding(context, isKeyboardOpen),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('02', style: context.textTheme.labelMedium),
                          const SizedBox(height: 10),
                          Text(
                            'Why do you want to host with us?',
                            style: context.textTheme.displayMedium,
                          ),
                          const SizedBox(height: 10),
                          if (recordedFilePath == null &&
                              recordedVideoPath == null)
                            Text(
                              'Tell us about your intent and what motivates you to create experiences.',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.text3Color,
                              ),
                            )
                          else if ((_isRecordingCompleted &&
                                  !_showAudioPlayer &&
                                  !isKeyboardOpen) ||
                              (_isVideoRecordingCompleted && !isKeyboardOpen) ||
                              (_showAudioPlayer && !isKeyboardOpen))
                            Text(
                              'Tell us about your intent and what motivates you to create experiences.',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.text3Color,
                              ),
                            ),
                          const SizedBox(height: 15),
                          CustomTextFeild(
                            controller: _textController,
                            maxLines: adaptiveMaxLines,
                            hintText: '/ Start typing here',
                          ),
                          const SizedBox(height: 10),

                          if (_isRecording) _buildRecordingWaveform(context),

                          if (_isRecordingCompleted &&
                              !_showAudioPlayer &&
                              recordedFilePath != null &&
                              !isKeyboardOpen)
                            _buildRecordingComplete(context),

                          if (_showAudioPlayer && recordedFilePath != null)
                            AudioPlayerWidget(
                              recorderController: recorderController,
                              playerController: playerController,
                              onPlayPause: _togglePlayPause,
                              onDelete: () {
                                _deleteRecording();
                                setState(() {
                                  _showAudioPlayer = false;
                                });
                              },
                              filePath: recordedFilePath,
                              duration: _recordingDuration,
                              isKeyboardOpen: isKeyboardOpen,
                            ),

                          // Compact Video Widget
                          if (_isVideoRecordingCompleted &&
                              recordedVideoPath != null &&
                              !isKeyboardOpen)
                            _buildCompactVideoWidget(context),

                          if (isVideoSelected &&
                              !_isVideoRecordingCompleted &&
                              !_isPermissionChecking)
                            _buildPermissionDeniedUI(),

                          if (_isPermissionChecking)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: MediaQuery.of(context).padding.bottom + 10,
                      top: 10,
                    ),
                    child: Row(
                      children: [
                        // Use ternary operator for conditional rendering
                        _shouldShowSelector()
                            ? _videoAudioSelector(context)
                            : Container(), // Empty container when selector is hidden
                        _shouldShowSelector()
                            ? const SizedBox(width: 40)
                            : const SizedBox(
                                width: 0,
                              ), // No space when selector is hidden
                        Expanded(
                          child: Elevatednextbutton(
                            onTap: () {},
                            isEnabled:
                                !_shouldShowSelector(), // Enable when selector is hidden
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactVideoWidget(BuildContext context) {
    return GestureDetector(
      onTap: _showVideoPlayerDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colorScheme.onSurface.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey[900],
                child:
                    _videoController != null &&
                        _videoController!.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Audio Recorded',
                          style: context.textTheme.bodyLarge,
                        ),
                        TextSpan(
                          text:
                              ' • ${_formatDuration(_videoController?.value.duration.inSeconds ?? 0)}',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(100),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: context.colorScheme.primary,
                size: 24,
              ),
              onPressed: () => _deleteVideoRecording(),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTopPadding(BuildContext context, bool isKeyboardOpen) {
    // Case 1: Keyboard is open with no recording activity at all
    if (isKeyboardOpen &&
        !_isRecording &&
        !_isRecordingCompleted &&
        !_isVideoRecordingCompleted &&
        recordedFilePath == null &&
        recordedVideoPath == null) {
      return context.height *
          0.09; // Small top padding when only keyboard is open
    }
    // Case 2: Recording in progress (audio or video completed) AND keyboard is open
    else if ((_isRecording || _isVideoRecordingCompleted) && isKeyboardOpen) {
      return context.height *
          0.06; // Minimal padding during recording with keyboard
    }
    // Case 3: Recording in progress (audio or video completed) AND keyboard is closed
    else if ((_isRecording || _isVideoRecordingCompleted) && !isKeyboardOpen) {
      return context.height *
          0.24; // Medium padding for recording UI without keyboard
    }
    // Case 4: Recording completed but not saved yet (before clicking checkmark) AND keyboard is open
    else if ((_isRecordingCompleted || _isVideoRecordingCompleted) &&
        ((recordedFilePath != null && !_showAudioPlayer) ||
            recordedVideoPath != null) &&
        isKeyboardOpen) {
      return context.height *
          0.06; // Minimal padding for completed recording with keyboard
    }
    // Case 5: Recording completed but not saved yet (before clicking checkmark) AND keyboard is closed
    else if ((_isRecordingCompleted || _isVideoRecordingCompleted) &&
        ((recordedFilePath != null && !_showAudioPlayer) ||
            recordedVideoPath != null) &&
        !isKeyboardOpen) {
      return context.height *
          0.24; // Medium padding for completed recording without keyboard
    }
    // Case 6: Audio player is visible AND keyboard is open
    else if (_showAudioPlayer && isKeyboardOpen) {
      return context.height *
          0.06; // Minimal padding when audio player and keyboard are both visible
    }
    // Case 7: Audio player is visible AND keyboard is closed
    else if (_showAudioPlayer) {
      return context.height *
          0.29; // Larger padding for audio player without keyboard
    }
    // Case 8: Keyboard is open (general fallback case for other states)
    else if (isKeyboardOpen) {
      return 10.0; // Fixed small padding when keyboard is open
    }
    // Case 9: Any recording file exists (fallback for when recordings exist)
    else if (recordedFilePath != null || recordedVideoPath != null) {
      return context.height * 0.24; // Medium padding when recordings exist
    }
    // Case 10: Default initial state (no keyboard, no recording activity)
    else {
      return context.height * 0.22; // Default padding for initial state
    }
  }

  Widget _buildRecordingWaveform(BuildContext context) {
    final Color edgeColor = context.colorScheme.surface.withAlpha(120);
    final Color centerColor = context.colorScheme.onSurface.withAlpha(40);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.black,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [edgeColor, centerColor, centerColor, edgeColor],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recording Audio...', style: context.textTheme.titleMedium),
              const SizedBox(height: 28),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: AudioWaveforms(
                      size: Size(context.width - 160, 50),
                      recorderController: recorderController,
                      waveStyle: WaveStyle(
                        showDurationLabel: false,
                        spacing: 6.0,
                        waveColor: Colors.white,
                        extendWaveform: true,
                        showMiddleLine: false,
                        waveCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingComplete(BuildContext context) {
    final Color edgeColor = context.colorScheme.surface.withAlpha(120);
    final Color centerColor = context.colorScheme.onSurface.withAlpha(40);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.black,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [edgeColor, centerColor, centerColor, edgeColor],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recording Complete', style: context.textTheme.titleMedium),
              const SizedBox(height: 28),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAudioPlayer = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: recordedFilePath != null
                        ? AudioFileWaveforms(
                            size: Size(context.width - 160, 50),
                            playerController: playerController,
                            waveformType: WaveformType.fitWidth,
                            playerWaveStyle: PlayerWaveStyle(
                              liveWaveColor: context.colorScheme.onSurface,
                              fixedWaveColor: context.colorScheme.onSurface,
                              showSeekLine: false,
                              spacing: 6,
                              waveCap: StrokeCap.round,
                              waveThickness: 3.0,
                              scaleFactor: 100,
                            ),
                          )
                        : const SizedBox(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _videoAudioSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.onSurface.withAlpha(30)),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildSelectableIcon(
              isSelected: isAudioSelected,
              icon: Icons.mic_none_outlined,
              context: context,
              onTap: () {
                setState(() {
                  isAudioSelected = !isAudioSelected;
                  if (isAudioSelected) {
                    isVideoSelected = false;
                    _startOrStopRecording();
                  } else if (_isRecording) {
                    _startOrStopRecording();
                  }
                });
              },
            ),
            SizedBox(
              height: 38,
              child: VerticalDivider(
                color: context.colorScheme.onSurface.withAlpha(90),
                thickness: 1,
                width: 1,
                indent: 10,
                endIndent: 10,
              ),
            ),
            _buildSelectableIcon(
              isSelected: isVideoSelected,
              icon: Icons.videocam_outlined,
              context: context,
              onTap: () async {
                setState(() {
                  isVideoSelected = !isVideoSelected;
                });

                if (isVideoSelected) {
                  isAudioSelected = false;
                  if (_isRecording) {
                    _startOrStopRecording();
                  }
                  await _openNativeCamera();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableIcon({
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    context.colorScheme.onSurface.withAlpha(5),
                    context.colorScheme.onSurface.withAlpha(60),
                    context.colorScheme.onSurface.withAlpha(5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : context.colorScheme.surface.withAlpha(10),
        ),
        child: Icon(icon, color: context.colorScheme.onSurface, size: 24),
      ),
    );
  }

  Widget _buildPermissionDeniedUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.videocam_off, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            'Camera access required',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _appBarBottomOverlay(BuildContext context) {
    return Container(
      height: 10,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border(
          left: _borderSide(),
          right: _borderSide(),
          bottom: _borderSide(),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Container(color: context.colorScheme.onSurface.withAlpha(20)),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: const AppBarBlurWidget(),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: SizedBox(
        width: context.width * 0.6,
        child: WaveProgressIndicator(
          progress: 0.4,
          activeColor: context.colorScheme.primary,
          inactiveColor: const Color(0xFF404040),
          height: 40,
          waveWidth: 20,
          waveHeight: 5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  BorderSide _borderSide() => BorderSide(
    color: context.colorScheme.onSurface.withAlpha(50),
    strokeAlign: BorderSide.strokeAlignOutside,
    style: BorderStyle.solid,
  );
  bool _shouldShowSelector() {
    return recordedFilePath == null && recordedVideoPath == null ||
        (!_showAudioPlayer);
  }
}
