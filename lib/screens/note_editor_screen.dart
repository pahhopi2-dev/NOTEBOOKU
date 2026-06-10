import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/categories.dart';
import '../models/note.dart';
import '../utils/date_extension.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_background.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocus = FocusNode();

  String _category = 'personal';
  String _color = 'white';
  bool _isPinned = false;
  bool _focusMode = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _category = note.category;
      _color = note.color;
      _isPinned = note.isPinned;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi judul atau catatan dulu.')),
      );
      return;
    }

    final now = DateTime.now();
    final base = widget.note ??
        Note(id: const Uuid().v4(), createdAt: now, updatedAt: now);

    Navigator.pop(
      context,
      base.copyWith(
        title: title,
        content: content,
        category: _category,
        color: _color,
        isPinned: _isPinned,
        updatedAt: now,
      ),
    );
  }

  void _insertChecklistItem() => _insertText(
        '${_contentController.text.trim().isEmpty ? '' : '\n'}- [ ] ',
      );

  void _insertTimestamp() =>
      _insertText('\n${DateTime.now().formattedID}\n');

  void _insertDivider() => _insertText('\n---\n');

  void _insertText(String text) {
    final selection = _contentController.selection;
    final current = _contentController.text;
    final start = selection.start < 0 ? current.length : selection.start;
    final end = selection.end < 0 ? current.length : selection.end;
    final next = current.replaceRange(start, end, text);
    final cursor = start + text.length;

    _contentController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: cursor),
    );
    _contentFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(widget.note == null ? 'Catatan baru' : 'Edit catatan'),
        actions: [
          IconButton(
            tooltip: _focusMode ? 'Keluar mode fokus' : 'Mode fokus',
            onPressed: () {
              setState(() => _focusMode = !_focusMode);
              if (_focusMode) _contentFocus.requestFocus();
            },
            icon: Icon(
              _focusMode
                  ? Icons.fullscreen_exit_rounded
                  : Icons.center_focus_strong_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Simpan'),
            ),
          ),
        ],
      ),
      body: GradientBackground(
        showOrbs: !_focusMode,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 920 && !_focusMode;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1060),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _buildEditorPanel(context),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 3,
                                child: _buildOptionsPanel(context),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildEditorPanel(context),
                              if (!_focusMode) ...[
                                const SizedBox(height: 14),
                                _buildOptionsPanel(context),
                              ],
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditorPanel(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_focusMode)
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                hintText: 'Judul catatan',
                prefixIcon: Icon(Icons.title_rounded),
                border: InputBorder.none,
                filled: false,
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
          if (!_focusMode) const SizedBox(height: 12),
          if (!_focusMode)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolbarChip(
                    icon: Icons.check_box_outlined,
                    label: 'Checklist',
                    onPressed: _insertChecklistItem,
                  ),
                  const SizedBox(width: 8),
                  _ToolbarChip(
                    icon: Icons.schedule_rounded,
                    label: 'Waktu',
                    onPressed: _insertTimestamp,
                  ),
                  const SizedBox(width: 8),
                  _ToolbarChip(
                    icon: Icons.horizontal_rule_rounded,
                    label: 'Pemisah',
                    onPressed: _insertDivider,
                  ),
                  const SizedBox(width: 8),
                  _ToolbarChip(
                    icon: _isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    label: _isPinned ? 'Dipin' : 'Pin',
                    onPressed: () => setState(() => _isPinned = !_isPinned),
                    selected: _isPinned,
                  ),
                ],
              ),
            ),
          if (!_focusMode) const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            focusNode: _contentFocus,
            minLines: _focusMode ? 20 : 12,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: _focusMode
                  ? 'Mode fokus — tulis tanpa gangguan...'
                  : 'Tulis ide, catatan rapat, atau daftar tugas...',
              alignLabelWithHint: true,
              border: InputBorder.none,
              filled: false,
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontSize: _focusMode ? 17 : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (!_focusMode) ...[
            const SizedBox(height: 16),
            _StatsRow(
              title: _titleController.text,
              content: _contentController.text,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsPanel(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(icon: Icons.category_outlined, title: 'Kategori'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Category.allCategories
                    .where((c) => c.id != 'all')
                    .map(_buildCategoryChip)
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: Icons.color_lens_outlined,
                title: 'Warna catatan',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: Category.noteColors.map(_buildColorChoice).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          borderRadius: 20,
          padding: EdgeInsets.zero,
          child: SwitchListTile.adaptive(
            value: _isPinned,
            onChanged: (v) => setState(() => _isPinned = v),
            secondary: const Icon(Icons.push_pin_outlined),
            title: const Text('Pin di atas'),
            subtitle: const Text('Catatan penting muncul lebih dahulu.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(Category category) {
    final selected = _category == category.id;
    final theme = Theme.of(context);

    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(
        category.icon,
        size: 16,
        color: selected ? Colors.white : category.accent,
      ),
      label: Text(category.name),
      selectedColor: category.accent,
      backgroundColor: theme.cardColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : category.accent.withAlpha(50),
      ),
      onSelected: (_) => setState(() => _category = category.id),
    );
  }

  Widget _buildColorChoice(NoteColor noteColor) {
    final selected = _color == noteColor.id;
    final theme = Theme.of(context);

    return Tooltip(
      message: noteColor.name,
      child: InkWell(
        onTap: () => setState(() => _color = noteColor.id),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 64,
          height: 44,
          decoration: BoxDecoration(
            color: noteColor.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withAlpha(40),
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(60),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: selected
              ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
              : null,
        ),
      ),
    );
  }
}

class _ToolbarChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  const _ToolbarChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? theme.colorScheme.primary.withAlpha(30)
          : theme.colorScheme.surfaceContainerHighest.withAlpha(80),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String title;
  final String content;

  const _StatsRow({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final note = Note(
      id: 'preview',
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _MiniStat(icon: Icons.text_fields_rounded, value: '${note.wordCount}', label: 'kata'),
          const SizedBox(width: 16),
          _MiniStat(
            icon: Icons.checklist_rounded,
            value: '${note.checklistDone}/${note.checklistTotal}',
            label: 'checklist',
          ),
          const Spacer(),
          Text(
            'Auto-save saat simpan',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '$value $label',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
