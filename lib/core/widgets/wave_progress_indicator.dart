import 'package:flutter/material.dart';

class WaveProgressIndicator extends StatelessWidget {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double height;
  final double waveWidth;
  final double waveHeight;

  const WaveProgressIndicator({
    super.key,
    required this.progress,
    this.activeColor = const Color(0xFF5964FF),
    this.inactiveColor = const Color(0xFF404040),
    this.height = 60,
    this.waveWidth = 30,
    this.waveHeight = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: WaveProgressPainter(
          progress: progress.clamp(0.0, 1.0),
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          waveWidth: waveWidth,
          waveHeight: waveHeight,
        ),
        child: Container(),
      ),
    );
  }
}

class WaveProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double waveWidth;
  final double waveHeight;

  WaveProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.waveWidth,
    required this.waveHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double progressWidth = size.width * progress;

    _drawWaves(canvas, size, inactiveColor, 0, size.width);

    if (progress > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, progressWidth, size.height));
      _drawWaves(canvas, size, activeColor, 0, size.width);
      canvas.restore();
    }
  }

  void _drawWaves(
    Canvas canvas,
    Size size,
    Color color,
    double startX,
    double endX,
  ) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path();
    final double centerY = size.height / 2;

    path.moveTo(startX, centerY);

    for (double x = startX; x <= endX; x += waveWidth) {
      // Changed < to <=
      // Upward curve
      path.quadraticBezierTo(
        x + waveWidth * 0.25,
        centerY - waveHeight,
        x + waveWidth * 0.5,
        centerY,
      );

      // Downward curve
      path.quadraticBezierTo(
        x + waveWidth * 0.75,
        centerY + waveHeight,
        x + waveWidth,
        centerY,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
