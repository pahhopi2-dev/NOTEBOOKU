import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color accent;
  final Color tint;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.accent,
    required this.tint,
  });

  static const List<Category> allCategories = [
    Category(
      id: 'all',
      name: 'Semua',
      icon: Icons.dashboard_customize_rounded,
      accent: Color(0xFF1F7A70),
      tint: Color(0xFFDFF2EE),
    ),
    Category(
      id: 'personal',
      name: 'Pribadi',
      icon: Icons.person_outline_rounded,
      accent: Color(0xFF7359A6),
      tint: Color(0xFFEDE7F6),
    ),
    Category(
      id: 'work',
      name: 'Kerja',
      icon: Icons.work_outline_rounded,
      accent: Color(0xFF1F7A70),
      tint: Color(0xFFDFF2EE),
    ),
    Category(
      id: 'ideas',
      name: 'Ide',
      icon: Icons.lightbulb_outline_rounded,
      accent: Color(0xFFB98518),
      tint: Color(0xFFFFF2CC),
    ),
    Category(
      id: 'tasks',
      name: 'Tugas',
      icon: Icons.check_circle_outline_rounded,
      accent: Color(0xFFE56B5D),
      tint: Color(0xFFFFE4DF),
    ),
    Category(
      id: 'other',
      name: 'Lainnya',
      icon: Icons.folder_open_rounded,
      accent: Color(0xFF4D6C8B),
      tint: Color(0xFFE2EBF4),
    ),
  ];

  static const List<NoteColor> noteColors = [
    NoteColor(id: 'white', name: 'Paper', color: Color(0xFFFFFFFF)),
    NoteColor(id: 'mint', name: 'Mint', color: Color(0xFFE2F4EB)),
    NoteColor(id: 'sky', name: 'Sky', color: Color(0xFFE0EEF8)),
    NoteColor(id: 'sun', name: 'Sun', color: Color(0xFFFFF0C7)),
    NoteColor(id: 'rose', name: 'Rose', color: Color(0xFFFFE1DA)),
    NoteColor(id: 'lavender', name: 'Lavender', color: Color(0xFFEDE7F6)),
    NoteColor(id: 'stone', name: 'Stone', color: Color(0xFFE9ECE8)),
  ];

  static Category byId(String id) {
    return allCategories.firstWhere(
      (category) => category.id == id,
      orElse: () => allCategories.last,
    );
  }

  static NoteColor colorById(String id) {
    return noteColors.firstWhere(
      (noteColor) => noteColor.id == id,
      orElse: () => noteColors.first,
    );
  }
}

class NoteColor {
  final String id;
  final String name;
  final Color color;

  const NoteColor({required this.id, required this.name, required this.color});
}
