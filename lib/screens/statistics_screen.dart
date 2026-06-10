import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categories.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class StatisticsPanel extends ConsumerWidget {
  const StatisticsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesNotifierProvider).valueOrNull;
    if (state == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final notes = state.notes;
    final categoryCounts = <String, int>{};

    for (final note in notes) {
      categoryCounts[note.category] = (categoryCounts[note.category] ?? 0) + 1;
    }

    final pinned = notes.where((n) => n.isPinned).length;
    final withChecklist = notes.where((n) => n.hasChecklist).length;
    final avgWords = notes.isEmpty
        ? 0
        : (state.totalWords / notes.length).round();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      sliver: SliverList.list(
        children: [
          Text('Statistik', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Ringkasan produktivitas catatan Anda',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth < 500
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _OverviewTile(
                    width: tileWidth,
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Total catatan',
                    value: '${notes.length}',
                    color: AppTheme.teal,
                  ),
                  _OverviewTile(
                    width: tileWidth,
                    icon: Icons.format_align_left_rounded,
                    label: 'Total kata',
                    value: '${state.totalWords}',
                    color: AppTheme.plum,
                  ),
                  _OverviewTile(
                    width: tileWidth,
                    icon: Icons.push_pin_rounded,
                    label: 'Dipin',
                    value: '$pinned',
                    color: AppTheme.coral,
                  ),
                  _OverviewTile(
                    width: tileWidth,
                    icon: Icons.checklist_rounded,
                    label: 'Dengan checklist',
                    value: '$withChecklist',
                    color: AppTheme.gold,
                  ),
                  _OverviewTile(
                    width: tileWidth,
                    icon: Icons.speed_rounded,
                    label: 'Rata-rata kata',
                    value: '$avgWords',
                    color: const Color(0xFF4D6C8B),
                  ),
                  _OverviewTile(
                    width: tileWidth,
                    icon: Icons.task_alt_rounded,
                    label: 'Tugas selesai',
                    value: '${state.completedTasks}/${state.totalTasks}',
                    color: AppTheme.teal,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Per kategori', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...Category.allCategories
              .where((c) => c.id != 'all')
              .map((category) {
            final count = categoryCounts[category.id] ?? 0;
            final fraction = notes.isEmpty ? 0.0 : count / notes.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(category.icon, size: 18, color: category.accent),
                        const SizedBox(width: 8),
                        Text(category.name,
                            style: theme.textTheme.labelLarge),
                        const Spacer(),
                        Text(
                          '$count',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: category.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        backgroundColor: category.accent.withAlpha(30),
                        valueColor:
                            AlwaysStoppedAnimation(category.accent),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _OverviewTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
