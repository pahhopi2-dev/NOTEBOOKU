import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'glass_card.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final int animationIndex;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withAlpha(40), accent.withAlpha(15)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * animationIndex),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.15,
          end: 0,
          delay: Duration(milliseconds: 80 * animationIndex),
          curve: Curves.easeOutCubic,
        );
  }
}
