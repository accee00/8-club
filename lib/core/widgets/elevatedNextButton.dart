// ignore_for_file: deprecated_member_use

import 'package:eightclub/core/constants/app_image.dart';
import 'package:eightclub/core/extensions/build_extension.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class Elevatednextbutton extends StatelessWidget {
  const Elevatednextbutton({super.key, this.onTap, this.isEnabled = false});

  final VoidCallback? onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Darker base color when enabled
          color: isEnabled
              ? const Color(0xFF2A2A2A)
              : context.colorScheme.surface.withAlpha(240),
          gradient: isEnabled
              ? LinearGradient(
                  colors: [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2D2D2D),
                    const Color(0xFF252525), // Medium
                    const Color(0xFF1C1C1C), // Darker at bottom
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    context.colorScheme.surface.withAlpha(255),
                    context.colorScheme.surface.withAlpha(200),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          boxShadow: isEnabled
              ? [
                  // Inner shadow effect - top left
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                    spreadRadius: -1,
                  ),
                  // Inner shadow effect - bottom right
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(-1, -1),
                    blurRadius: 4,
                    spreadRadius: -1,
                  ),
                  // Subtle outer glow
                  BoxShadow(
                    color: Colors.white.withOpacity(0.03),
                    offset: const Offset(0, 1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: context.colorScheme.onSurface.withAlpha(6),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: context.colorScheme.surface.withAlpha(17),
                    offset: const Offset(5, 5),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
          border: GradientBoxBorder(
            width: 1.5,
            gradient: LinearGradient(
              colors: isEnabled
                  ? [
                      const Color(0xFF4A4A4A), // Lighter gray at top-left
                      const Color(0xFF2A2A2A), // Medium gray
                      const Color(0xFF1A1A1A), // Darker gray at bottom-right
                    ]
                  : [
                      context.colorScheme.onSurface.withAlpha(20),
                      context.colorScheme.onSurface.withAlpha(15),
                      context.colorScheme.onSurface.withAlpha(4),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Next',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: isEnabled
                      ? Colors.white.withOpacity(0.95)
                      : context.colorScheme.onSurface.withAlpha(100),
                  fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                AppImage.arrowRightIcon,
                color: isEnabled
                    ? Colors.white.withOpacity(0.95)
                    : context.colorScheme.onSurface.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
