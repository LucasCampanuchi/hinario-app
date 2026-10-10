/// Formatação de datas em português sem depender de locale do intl
/// (o app não inicializa `initializeDateFormatting`).
class DateBr {
  static const _weekdays = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  static const _weekdaysLong = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// "dom, 12/10"
  static String short(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${_two(date.day)}/${_two(date.month)}';

  /// "Hoje", "Amanhã", "Domingo, 12/10"
  static String serviceDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    if (diff == -1) return 'Ontem';
    return '${_weekdaysLong[date.weekday - 1]}, ${_two(date.day)}/${_two(date.month)}';
  }

  /// "2026-10-12"
  static String iso(DateTime date) =>
      '${date.year}-${_two(date.month)}-${_two(date.day)}';
}
