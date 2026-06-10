import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool showOrbs;

  const GradientBackground({
    super.key,
    required this.child,
    this.showOrbs = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppTheme.darkPaper,
                      const Color(0xFF141F1D),
                      AppTheme.darkPaperAlt,
                    ]
                  : [
                      AppTheme.paper,
                      const Color(0xFFF0F5F2),
                      AppTheme.paperAlt,
                    ],
            ),
          ),
        ),
        if (showOrbs) ...[
          Positioned(
            top: -60,
            right: -40,
            child: _BlurOrb(
              size: 220,
              color: AppTheme.teal.withAlpha(isDark ? 35 : 45),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -70,
            child: _BlurOrb(
              size: 260,
              color: AppTheme.plum.withAlpha(isDark ? 28 : 38),
            ),
          ),
          Positioned(
            top: 200,
            left: MediaQuery.sizeOf(context).width * 0.5,
            child: _BlurOrb(
              size: 160,
              color: AppTheme.coral.withAlpha(isDark ? 20 : 30),
            ),
          ),
        ],
        child,
      ],
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
