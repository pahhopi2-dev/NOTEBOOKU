import 'package:hive/hive.dart';

class Note {
  static final RegExp _checkedItem = RegExp(r'^\s*[-*]?\s*\[[xX]\]\s+');
  static final RegExp _checkItem = RegExp(r'^\s*[-*]?\s*\[[ xX]\]\s+');

  final String id;
  String title;
  String content;
  String category;
  String color;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    this.category = 'personal',
    this.color = 'white',
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  String get displayTitle {
    final cleanTitle = title.trim();
    if (cleanTitle.isNotEmpty) return cleanTitle;

    final firstLine = content
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    return firstLine.isEmpty ? 'Catatan tanpa judul' : firstLine;
  }

  String get preview {
    final cleanContent = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleanContent.isEmpty) return 'Belum ada isi catatan.';
    return cleanContent;
  }

  int get wordCount {
    final clean = '$title $content'.trim();
    if (clean.isEmpty) return 0;
    return clean.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  bool get hasChecklist {
    return content.split('\n').any((line) => _checkItem.hasMatch(line));
  }

  int get checklistTotal {
    return content
        .split('\n')
        .where((line) => _checkItem.hasMatch(line))
        .length;
  }

  int get checklistDone {
    return content
        .split('\n')
        .where((line) => _checkedItem.hasMatch(line))
        .length;
  }

  double get checklistProgress {
    final total = checklistTotal;
    if (total == 0) return 0;
    return checklistDone / total;
  }

  bool get isTaskLike => category == 'tasks' || hasChecklist;

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final searchable = '$title $content $category'.toLowerCase();
    return searchable.contains(normalizedQuery);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Note(
      id: (json['id'] ?? now.microsecondsSinceEpoch.toString()).toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      category: (json['category'] ?? 'personal').toString(),
      color: (json['color'] ?? 'white').toString(),
      createdAt: _readDate(json['createdAt']) ?? now,
      updatedAt: _readDate(json['updatedAt']) ?? now,
      isPinned: json['isPinned'] == true,
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    if (value is Map && value['_seconds'] is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000,
      );
    }
    return null;
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    return Note(
      id: reader.readString(),
      title: reader.readString(),
      content: reader.readString(),
      category: reader.readString(),
      color: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isPinned: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeString(obj.category);
    writer.writeString(obj.color);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
    writer.writeBool(obj.isPinned);
  }
}
