import 'dart:ui';

import 'package:eightclub/core/constants/app_image.dart';
import 'package:eightclub/core/extensions/build_extension.dart';
import 'package:eightclub/core/constants/app_colors.dart';
import 'package:eightclub/core/widgets/custom_text_feild.dart';
import 'package:eightclub/core/widgets/elevatedNextButton.dart';
import 'package:eightclub/core/widgets/wave_background.dart';
import 'package:eightclub/core/widgets/wave_progress_indicator.dart';
import 'package:eightclub/features/onboard/presentation/widget/app_bar_blur_widget.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final TextEditingController _textController = TextEditingController();
  bool isVideoSelected = false;
  bool isAudioSelected = false;
  // Recorder instance and state
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordFilePath;

  @override
  void dispose() {
    _textController.dispose();

    if (_isRecording) {
      _recorder.stop();
    }
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    // Detect keyboard
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    final adaptiveMaxLines = isKeyboardOpen ? 6 : 14;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),
      body: Stack(
        children: [
          WaveBackground(
            child: Column(
              children: [
                SizedBox(height: context.height * 0.12 + 40),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: isKeyboardOpen ? 20 : 0,
                      top: isKeyboardOpen ? 0 : 80,
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
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
                          Text(
                            'Tell us about your intent and what motivates you to create experiences.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.text3Color,
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Adaptive TextField
                          CustomTextFeild(
                            controller: _textController,
                            maxLines: adaptiveMaxLines,
                            hintText: '/ Start typing here',
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  height: isKeyboardOpen ? null : 120,
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: MediaQuery.of(context).padding.bottom + 10,
                    top: 10,
                  ),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      _videoAudioSelector(context),
                      const SizedBox(width: 40),
                      Expanded(
                        child: Elevatednextbutton(
                          onTap: () {},
                          isEnabled: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: context.height * 0.001,
            left: 19,
            right: 19,
            child: IgnorePointer(child: _appBarBottomOverlay(context)),
          ),
        ],
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
              iconPath: AppImage.micIcon,
              context: context,
              onTap: () => _onAudioTap(),
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
              iconPath: AppImage.videoIcon,
              context: context,
              onTap: () {
                setState(() {
                  isVideoSelected = !isVideoSelected;
                  if (isVideoSelected) {
                    isAudioSelected = false;
                  }
                });
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
    required String iconPath,
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
        child: Image.asset(
          iconPath,
          color: isSelected
              ? (_isRecording ? Colors.redAccent : Colors.white)
              : Colors.white.withAlpha(180),
        ),
      ),
    );
  }

  Future<void> _onAudioTap() async {
    try {
      if (!isAudioSelected) {
        // user is trying to select audio -> start recording
        final hasPermission = await _recorder.hasPermission();
        if (!hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
          return;
        }

        final dir = await getTemporaryDirectory();
        final filePath =
            '${dir.path}/onboard_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          RecordConfig(androidConfig: AndroidRecordConfig()),
          path: dir.path,
        );
        setState(() {
          isAudioSelected = true;
          isVideoSelected = false;
          _isRecording = true;
          _recordFilePath = filePath;
        });
      } else {
        // stop recording
        final path = await _recorder.stop();
        setState(() {
          // keep isAudioSelected state toggled off
          isAudioSelected = false;
          _isRecording = false;
        });

        final savedPath = path ?? _recordFilePath;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording saved: ${savedPath ?? 'unknown'}')),
        );
      }
    } catch (e) {
      // If any error occurs, ensure UI is consistent
      setState(() {
        isAudioSelected = false;
        _isRecording = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Recording error: $e')));
    }
  }

  Container _appBarBottomOverlay(BuildContext context) {
    return Container(
      height: 30,
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.symmetric(vertical: context.height * 0.12),
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
      flexibleSpace: AppBarBlurWidget(),
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
}
