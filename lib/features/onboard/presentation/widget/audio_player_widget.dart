import 'dart:ui';

import 'package:eightclub/core/extensions/build_extension.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class AudioPlayerWidget extends StatelessWidget {
  final PlayerController playerController;
  final RecorderController recorderController;
  final VoidCallback onPlayPause;
  final VoidCallback onDelete;
  final String? filePath;
  final int duration;
  final bool isKeyboardOpen;

  const AudioPlayerWidget({
    super.key,
    required this.playerController,
    required this.recorderController,
    required this.onPlayPause,
    required this.onDelete,
    this.filePath,
    this.duration = 0,
    this.isKeyboardOpen = false,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = playerController.playerState.isPlaying;

    // Simplified compact version when keyboard is open
    if (isKeyboardOpen) {
      return _buildCompactPlayer(context, isPlaying);
    }

    // Full version when keyboard is closed
    return _buildFullPlayer(context, isPlaying);
  }

  Widget _buildCompactPlayer(BuildContext context, bool isPlaying) {
    final Color edgeColor = context.colorScheme.surface.withAlpha(120);
    final Color centerColor = context.colorScheme.onSurface.withAlpha(40);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          child: Row(
            children: [
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  'Audio Recorded • ${_formatDuration(duration)}',
                  style: context.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),

              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: context.colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullPlayer(BuildContext context, bool isPlaying) {
    final Color edgeColor = context.colorScheme.surface.withAlpha(120);
    final Color centerColor = context.colorScheme.onSurface.withAlpha(40);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Audio Recorded',
                          style: context.textTheme.bodyLarge,
                        ),
                        TextSpan(
                          text: ' • ${_formatDuration(duration)}',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(100),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete_outline_outlined,
                      color: context.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  GestureDetector(
                    onTap: onPlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: AudioFileWaveforms(
                      size: Size(context.width - 160, 50),
                      playerController: playerController,
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: PlayerWaveStyle(
                        liveWaveColor: context.colorScheme.onSurface,
                        fixedWaveColor: context.colorScheme.onSurface,
                        showSeekLine: true,
                        spacing: 6,
                        waveCap: StrokeCap.round,
                        waveThickness: 3.0,
                        scaleFactor: 100,
                      ),
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
}
