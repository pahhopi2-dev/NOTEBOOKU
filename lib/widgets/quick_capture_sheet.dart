import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../widgets/glass_card.dart';

class QuickCaptureSheet extends StatefulWidget {
  const QuickCaptureSheet({super.key});

  static Future<Note?> show(BuildContext context) {
    return showModalBottomSheet<Note>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickCaptureSheet(),
    );
  }

  @override
  State<QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends State<QuickCaptureSheet> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now();
    final lines = text.split('\n');
    final title = lines.first.trim();
    final content = lines.length > 1
        ? lines.sublist(1).join('\n').trim()
        : '';

    Navigator.pop(
      context,
      Note(
        id: const Uuid().v4(),
        title: title,
        content: content.isEmpty ? '' : content,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: GlassCard(
        borderRadius: 28,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text('Quick Capture', style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              focusNode: _focus,
              maxLines: 5,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Tulis cepat... baris pertama jadi judul',
                border: InputBorder.none,
              ),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Baris pertama = judul',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
