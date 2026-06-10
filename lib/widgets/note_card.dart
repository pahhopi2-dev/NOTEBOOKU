import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/categories.dart';
import '../models/note.dart';
import '../utils/date_extension.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onPin;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final int animationIndex;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onPin,
    this.onFavorite,
    this.isFavorite = false,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = Category.byId(note.category);
    final noteColor = Category.colorById(note.color);
    final cardColor = isDark
        ? Color.alphaBlend(noteColor.color.withAlpha(28), theme.cardColor)
        : noteColor.color;
    final borderColor = isDark
        ? Colors.white.withAlpha(28)
        : category.accent.withAlpha(note.isPinned ? 100 : 28);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: note.isPinned ? 1.5 : 1,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: category.accent.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _CategoryBadge(category: category)),
                    if (onFavorite != null)
                      _IconAction(
                        tooltip: isFavorite ? 'Hapus favorit' : 'Favorit',
                        icon: isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: isFavorite
                            ? const Color(0xFFD4A017)
                            : theme.colorScheme.onSurfaceVariant,
                        onTap: onFavorite,
                      ),
                    _IconAction(
                      tooltip: note.isPinned ? 'Lepas pin' : 'Pin',
                      icon: note.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      color: note.isPinned
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurfaceVariant,
                      onTap: onPin,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  note.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    note.preview,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (note.hasChecklist) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: note.checklistProgress,
                      minHeight: 5,
                      backgroundColor: category.accent.withAlpha(30),
                      valueColor: AlwaysStoppedAnimation(category.accent),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${note.checklistDone}/${note.checklistTotal} selesai',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        note.updatedAt.relative,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${note.wordCount} kata',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 40 * (animationIndex % 8)),
          duration: 350.ms,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          delay: Duration(milliseconds: 40 * (animationIndex % 8)),
          curve: Curves.easeOutCubic,
        );
  }
}

class _IconAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final Category category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          category.tint.withAlpha(140),
          theme.colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: category.accent),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: category.accent,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
