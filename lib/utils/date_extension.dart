extension DateTimeExtension on DateTime {
  static const List<String> _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _days = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  String get formattedID {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$day ${_months[month]} $year $hour:$minute';
  }

  String get relative {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    if (isToday) return 'Hari ini $hour:$minute';
    if (isYesterday) return 'Kemarin $hour:$minute';

    final now = DateTime.now();
    if (now.difference(this).inDays.abs() > 7) return formattedID;
    return '${_days[weekday % 7]}, $hour:$minute';
  }

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(year, month, day) == today;
  }

  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final today = DateTime(year, month, day);
    return yesterday == today;
  }
}
