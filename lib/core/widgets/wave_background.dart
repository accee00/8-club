import 'package:flutter/material.dart';

class WaveBackground extends StatelessWidget {
  final Widget? child;

  const WaveBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.white.withAlpha(160), Colors.white],
              stops: const [0.0, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: WavePatternPainter(),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double waveWidth = 40;
    const double waveHeight = 20;
    const double spacing = 35;
    const double rotationAngle = -0.2;

    const double minWaveOpacity = 0.002;
    const double maxWaveOpacity = 0.1;

    final double effectiveMinY = 0;
    final double effectiveMaxY = size.height;

    for (double y = -100; y < size.height + 100; y += spacing) {
      final double clampedY = y.clamp(effectiveMinY, effectiveMaxY);
      final double normalizedY =
          (clampedY - effectiveMinY) / (effectiveMaxY - effectiveMinY);
      final double opacityFactor = 1.0 - normalizedY;
      final double currentOpacity =
          minWaveOpacity + (maxWaveOpacity - minWaveOpacity) * opacityFactor;

      final Paint paint = Paint()
        // ignore: deprecated_member_use
        ..color = Colors.white.withOpacity(currentOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      final Path path = Path();
      path.moveTo(-100, y);

      for (double x = -100; x < size.width + 100; x += waveWidth) {
        // Upward slope to peak
        path.relativeLineTo(waveWidth / 2 - 6, -waveHeight);

        // Rounded peak
        path.arcToPoint(
          Offset(x + waveWidth / 2 + 6, y - waveHeight + 2),
          radius: const Radius.circular(10),
          clockwise: true,
        );

        // Downward slope
        path.relativeLineTo(waveWidth / 2 - 6, waveHeight - 2);

        // Rounded trough (smoother)
        path.arcToPoint(
          Offset(x + waveWidth, y),
          radius: const Radius.elliptical(20, 5), // wider and flatter
          clockwise: true,
        );
      }

      canvas.save();
      canvas.rotate(rotationAngle);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
