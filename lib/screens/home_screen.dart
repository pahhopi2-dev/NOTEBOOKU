import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/categories.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/statistics_screen.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/note_card.dart';
import '../widgets/premium_nav_bar.dart';
import '../widgets/quick_capture_sheet.dart';
import '../widgets/stat_card.dart';
import 'note_editor_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _pageIndex = 0;
  bool _gridMode = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditor([Note? note]) async {
    final updatedNote = await Navigator.of(context).push<Note>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NoteEditorScreen(note: note),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );

    if (!mounted || updatedNote == null) return;
    await ref.read(notesNotifierProvider.notifier).saveNote(updatedNote);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          note == null ? 'Catatan baru disimpan.' : 'Perubahan disimpan.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _quickCapture() async {
    final note = await QuickCaptureSheet.show(context);
    if (!mounted || note == null) return;
    await ref.read(notesNotifierProvider.notifier).saveNote(note);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick capture tersimpan!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    await ref.read(notesNotifierProvider.notifier).deleteNote(note.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${note.displayTitle}" dihapus.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(notesNotifierProvider.notifier).saveNote(note);
          },
        ),
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus semua catatan?'),
        content: const Text(
          'Aksi ini akan menghapus semua data lokal Notebooku.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(notesNotifierProvider.notifier).clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua catatan lokal sudah dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesNotifierProvider);

    return notesAsync.when(
      loading: () => const _LoadingScaffold(),
      error: (error, _) => _ErrorScaffold(
        message: error.toString(),
        onRetry: () => ref.read(notesNotifierProvider.notifier).refresh(),
      ),
      data: (state) => _buildScaffold(context, state),
    );
  }

  Widget _buildScaffold(BuildContext context, NotesState state) {
    final visibleNotes = _visibleNotes(state);
    final theme = Theme.of(context);
    final showFab = _pageIndex < 4;

    return Scaffold(
      extendBody: true,
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (_pageIndex == 4)
                    _buildSettings(context, state)
                  else if (_pageIndex == 3)
                    const StatisticsPanel()
                  else ...[
                    _buildHeader(context, state),
                    if (_pageIndex == 0) _buildRecentSection(context, state),
                    if (_pageIndex < 3) _buildCategoryRail(context, state),
                    _buildControls(context, state, visibleNotes.length),
                    _buildNotesSliver(context, visibleNotes, state),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              if (state.isLoading)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withAlpha(30),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PremiumNavBar(
        selectedIndex: _pageIndex,
        onSelected: (i) => setState(() => _pageIndex = i),
        items: const [
          PremiumNavItem(
            icon: Icons.notes_outlined,
            selectedIcon: Icons.notes_rounded,
            label: 'Notes',
          ),
          PremiumNavItem(
            icon: Icons.check_circle_outline_rounded,
            selectedIcon: Icons.check_circle_rounded,
            label: 'Tugas',
          ),
          PremiumNavItem(
            icon: Icons.star_outline_rounded,
            selectedIcon: Icons.star_rounded,
            label: 'Favorit',
          ),
          PremiumNavItem(
            icon: Icons.bar_chart_rounded,
            selectedIcon: Icons.bar_chart_rounded,
            label: 'Stats',
          ),
          PremiumNavItem(
            icon: Icons.tune_rounded,
            selectedIcon: Icons.tune_rounded,
            label: 'Setelan',
          ),
        ],
      ),
      floatingActionButton: showFab
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'quick',
                  onPressed: _quickCapture,
                  tooltip: 'Quick Capture',
                  child: const Icon(Icons.bolt_rounded),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'new',
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Baru'),
                ),
              ],
            )
          : null,
    );
  }

  SliverToBoxAdapter _buildHeader(BuildContext context, NotesState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: isDark
                              ? [AppTheme.tealLight, AppTheme.coral]
                              : [AppTheme.teal, AppTheme.plum],
                        ).createShader(bounds),
                        child: Text(
                          'Notebooku',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                    ],
                  ),
                ),
                _HeaderButton(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  tooltip: 'Ganti tema',
                  onPressed: () {
                    ref.read(themeNotifierProvider.notifier).cycleTheme();
                  },
                ),
                const SizedBox(width: 8),
                _HeaderButton(
                  icon: Icons.archive_outlined,
                  tooltip: 'Arsip (${state.archivedNotes.length})',
                  onPressed: () => _showArchiveSheet(context, state),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GlassCard(
              borderRadius: 18,
              padding: EdgeInsets.zero,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari judul, isi, atau kategori...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon: state.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(notesNotifierProvider.notifier)
                                .setSearch('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: ref.read(notesNotifierProvider.notifier).setSearch,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = constraints.maxWidth < 680
                    ? (constraints.maxWidth - 10) / 2
                    : (constraints.maxWidth - 30) / 4;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: StatCard(
                        icon: Icons.sticky_note_2_outlined,
                        label: 'Catatan',
                        value: '${state.activeNotes.length}',
                        accent: AppTheme.teal,
                        animationIndex: 0,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: StatCard(
                        icon: Icons.push_pin_outlined,
                        label: 'Dipin',
                        value:
                            '${state.activeNotes.where((n) => n.isPinned).length}',
                        accent: AppTheme.coral,
                        animationIndex: 1,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: StatCard(
                        icon: Icons.task_alt_rounded,
                        label: 'Tugas',
                        value: '${state.completedTasks}/${state.totalTasks}',
                        accent: AppTheme.gold,
                        animationIndex: 2,
                      ),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: StatCard(
                        icon: Icons.star_rounded,
                        label: 'Favorit',
                        value: '${state.favoriteIds.length}',
                        accent: AppTheme.plum,
                        animationIndex: 3,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRecentSection(
    BuildContext context,
    NotesState state,
  ) {
    final recent = state.recentNotes;
    if (recent.isEmpty || state.searchQuery.isNotEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text('Terbaru', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final note = recent[index];
                  final category = Category.byId(note.category);
                  return ActionChip(
                    avatar: Icon(category.icon, size: 16, color: category.accent),
                    label: Text(
                      note.displayTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _openEditor(note),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategoryRail(
    BuildContext context,
    NotesState state,
  ) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: Category.allCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = Category.allCategories[index];
            final selected = state.selectedCategory == category.id;
            final count = category.id == 'all'
                ? state.activeNotes.length
                : state.activeNotes
                    .where((n) => n.category == category.id)
                    .length;

            return FilterChip(
              selected: selected,
              showCheckmark: false,
              avatar: Icon(
                category.icon,
                size: 16,
                color: selected ? Colors.white : category.accent,
              ),
              label: Text('$count'),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: selected ? Colors.white : theme.colorScheme.onSurface,
              ),
              tooltip: category.name,
              selectedColor: category.accent,
              backgroundColor: theme.cardColor,
              side: BorderSide(
                color: selected
                    ? Colors.transparent
                    : category.accent.withAlpha(50),
              ),
              onSelected: (_) {
                ref
                    .read(notesNotifierProvider.notifier)
                    .setCategory(category.id);
              },
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildControls(
    BuildContext context,
    NotesState state,
    int count,
  ) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '${_pageTitle()} · $count',
                  key: ValueKey('$_pageIndex-$count'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            PopupMenuButton<NotesSort>(
              initialValue: state.sort,
              onSelected: ref.read(notesNotifierProvider.notifier).setSort,
              icon: const Icon(Icons.sort_rounded),
              itemBuilder: (_) => const [
                CheckedPopupMenuItem(
                  value: NotesSort.updated,
                  child: Text('Terbaru diubah'),
                ),
                CheckedPopupMenuItem(
                  value: NotesSort.created,
                  child: Text('Terbaru dibuat'),
                ),
                CheckedPopupMenuItem(
                  value: NotesSort.title,
                  child: Text('Judul A-Z'),
                ),
              ],
            ),
            IconButton(
              tooltip: _gridMode ? 'Tampilan list' : 'Tampilan grid',
              onPressed: () => setState(() => _gridMode = !_gridMode),
              icon: Icon(
                _gridMode
                    ? Icons.view_agenda_outlined
                    : Icons.grid_view_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSliver(
    BuildContext context,
    List<Note> visibleNotes,
    NotesState state,
  ) {
    if (visibleNotes.isEmpty) {
      return SliverToBoxAdapter(
        child: _EmptyState(
          title: _emptyTitle(state),
          message: _emptyMessage(state),
          actionLabel: _emptyActionLabel(state),
          actionIcon: state.activeNotes.isEmpty
              ? Icons.add_rounded
              : Icons.filter_alt_off_rounded,
          onAction: () {
            if (state.activeNotes.isEmpty) {
              _openEditor();
            } else {
              _searchController.clear();
              ref.read(notesNotifierProvider.notifier)
                ..setSearch('')
                ..setCategory('all');
            }
          },
          secondaryLabel:
              state.activeNotes.isEmpty ? 'Isi contoh' : null,
          onSecondary: state.activeNotes.isEmpty
              ? () => ref.read(notesNotifierProvider.notifier).seedDemoNotes()
              : null,
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = _columnsFor(width);

        if (!_gridMode || columns == 1) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: visibleNotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 180,
                  child: _buildSlidableNote(visibleNotes[index], state, index),
                );
              },
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSlidableNote(
                visibleNotes[index],
                state,
                index,
              ),
              childCount: visibleNotes.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlidableNote(Note note, NotesState state, int index) {
    final notifier = ref.read(notesNotifierProvider.notifier);
    final isFav = state.isFavorite(note.id);

    return Slidable(
      key: ValueKey(note.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => notifier.togglePin(note),
            backgroundColor: AppTheme.gold,
            foregroundColor: Colors.white,
            icon: note.isPinned
                ? Icons.push_pin_outlined
                : Icons.push_pin_rounded,
            label: note.isPinned ? 'Lepas' : 'Pin',
            borderRadius: BorderRadius.circular(16),
          ),
          SlidableAction(
            onPressed: (_) => notifier.toggleFavorite(note),
            backgroundColor: AppTheme.plum,
            foregroundColor: Colors.white,
            icon: isFav ? Icons.star_outline_rounded : Icons.star_rounded,
            label: isFav ? 'Unfav' : 'Fav',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => notifier.toggleArchive(note),
            backgroundColor: const Color(0xFF4D6C8B),
            foregroundColor: Colors.white,
            icon: Icons.archive_outlined,
            label: 'Arsip',
            borderRadius: BorderRadius.circular(16),
          ),
          SlidableAction(
            onPressed: (_) => _deleteNote(note),
            backgroundColor: const Color(0xFFD84A3A),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Hapus',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: NoteCard(
        note: note,
        animationIndex: index,
        isFavorite: isFav,
        onTap: () => _openEditor(note),
        onPin: () => notifier.togglePin(note),
        onFavorite: () => notifier.toggleFavorite(note),
      ),
    );
  }

  void _showArchiveSheet(BuildContext context, NotesState state) {
    final archived = state.archivedNotes;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.archive_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Arsip', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (archived.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Belum ada catatan di arsip.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(ctx).height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: archived.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final note = archived[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(note.displayTitle),
                          subtitle: Text(note.preview, maxLines: 1),
                          trailing: IconButton(
                            icon: const Icon(Icons.unarchive_rounded),
                            onPressed: () {
                              ref
                                  .read(notesNotifierProvider.notifier)
                                  .toggleArchive(note);
                              Navigator.pop(ctx);
                            },
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            _openEditor(note);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  SliverPadding _buildSettings(BuildContext context, NotesState state) {
    final themeMode = ref.watch(themeNotifierProvider);
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      sliver: SliverList.list(
        children: [
          Text('Setelan', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Personalisasi pengalaman Notebooku',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _SettingsPanel(
            icon: Icons.palette_outlined,
            title: 'Tampilan',
            child: SegmentedButton<AppThemeMode>(
              selected: {themeMode},
              onSelectionChanged: (s) {
                ref.read(themeNotifierProvider.notifier).toggleTheme(s.first);
              },
              segments: const [
                ButtonSegment(
                  value: AppThemeMode.system,
                  icon: Icon(Icons.devices_rounded),
                  label: Text('Sistem'),
                ),
                ButtonSegment(
                  value: AppThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('Terang'),
                ),
                ButtonSegment(
                  value: AppThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Gelap'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.archive_outlined,
            title: 'Arsip',
            child: Row(
              children: [
                Text('${state.archivedNotes.length} catatan diarsipkan'),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: state.archivedNotes.isEmpty
                      ? null
                      : () => _showArchiveSheet(context, state),
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text('Lihat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.cloud_sync_outlined,
            title: 'Fullstack sync',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hive offline-first dengan backend Firebase Functions.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  apiBaseUrl,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.storage_outlined,
            title: 'Data lokal',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: state.notes.isEmpty
                      ? () => ref
                          .read(notesNotifierProvider.notifier)
                          .seedDemoNotes()
                      : null,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Isi contoh'),
                ),
                FilledButton.icon(
                  onPressed: state.notes.isEmpty ? null : _confirmClearAll,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Hapus semua'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsPanel(
            icon: Icons.info_outline_rounded,
            title: 'Tentang',
            child: Text('$appName $appVersion\n$appDescription'),
          ),
        ],
      ),
    );
  }

  List<Note> _visibleNotes(NotesState state) {
    switch (_pageIndex) {
      case 1:
        return state.taskNotes;
      case 2:
        return state.favoriteNotes;
      default:
        return state.filteredNotes;
    }
  }

  String _pageTitle() {
    switch (_pageIndex) {
      case 1:
        return 'Tugas';
      case 2:
        return 'Favorit';
      default:
        return 'Semua catatan';
    }
  }

  String _emptyTitle(NotesState state) {
    if (_pageIndex == 2) return 'Belum ada favorit';
    if (state.activeNotes.isEmpty) return 'Belum ada catatan';
    return 'Tidak ditemukan';
  }

  String _emptyMessage(NotesState state) {
    if (_pageIndex == 2) {
      return 'Geser catatan ke kanan dan tap bintang untuk menambah favorit.';
    }
    if (state.activeNotes.isEmpty) {
      return 'Mulai dari catatan kecil, checklist, atau gunakan Quick Capture.';
    }
    return 'Coba ubah filter kategori atau kata pencarian.';
  }

  String _emptyActionLabel(NotesState state) {
    if (state.activeNotes.isEmpty) return 'Buat catatan';
    return 'Reset filter';
  }

  int _columnsFor(double width) {
    if (!_gridMode) return 1;
    if (width < 520) return 1;
    if (width < 860) return 2;
    if (width < 1180) return 3;
    return 4;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi ☀️';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam 🌙';
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingsPanel({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const _EmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withAlpha(40),
                      theme.colorScheme.secondary.withAlpha(30),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.note_add_outlined,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 20),
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onAction,
                    icon: Icon(actionIcon),
                    label: Text(actionLabel),
                  ),
                  if (secondaryLabel != null && onSecondary != null)
                    OutlinedButton.icon(
                      onPressed: onSecondary,
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: Text(secondaryLabel!),
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

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Memuat Notebooku...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorScaffold({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Gagal memuat data',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
