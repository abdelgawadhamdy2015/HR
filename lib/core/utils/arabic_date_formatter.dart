class ArabicDateFormatter {
  ArabicDateFormatter._();

  static const List<String> months = [
    'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const List<String> weekDaysSatFirst = [
    'السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة',
  ];

  /// e.g. "12 مايو 2024"
  static String full(DateTime date) => '${date.day} ${months[date.month - 1]} ${date.year}';

  /// e.g. "مايو 2024"
  static String monthYear(DateTime date) => '${months[date.month - 1]} ${date.year}';
}
