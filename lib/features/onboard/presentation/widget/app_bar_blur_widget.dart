import 'dart:ui';

import 'package:eightclub/core/extensions/build_extension.dart';
import 'package:flutter/material.dart';

class AppBarBlurWidget extends StatelessWidget {
  const AppBarBlurWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const double blurSigma = 11.0;
    final Color edgeColor = context.colorScheme.surface.withAlpha(230);
    final Color centerColor = context.colorScheme.surface.withAlpha(13);

    return ClipRect(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              color: context.colorScheme.onSurface.withAlpha(13),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [centerColor, edgeColor, edgeColor, centerColor],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
