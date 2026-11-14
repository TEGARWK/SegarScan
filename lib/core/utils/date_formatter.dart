/// Helper format tanggal Bahasa Indonesia yang aman dan tanpa dependensi eksternal yang rentan uninitialized locale
class AppDateFormatter {
  AppDateFormatter._();

  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Menghasilkan format: "Jumat, 9 Oktober 2026"
  static String formatFullDate(DateTime date) {
    final dayName = _days[date.weekday - 1];
    final monthName = _months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  /// Menghasilkan format: "9 Oktober 2026, 14:30"
  static String formatDateTime(DateTime date) {
    final monthName = _months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} $monthName ${date.year}, $hour:$minute';
  }

  /// Menghasilkan format: "9 Okt, 14:30"
  static String formatShort(DateTime date) {
    final monthName = _shortMonths[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} $monthName, $hour:$minute';
  }
}
