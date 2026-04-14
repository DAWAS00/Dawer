import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('relative returns minutes label when diff < 60 min', () {
      final date = DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateFormatter.relative(date), 'منذ 5 دقيقة');
    });

    test('relative returns hours label when 60 <= diff < 24h', () {
      final date = DateTime.now().subtract(const Duration(hours: 3));
      expect(DateFormatter.relative(date), 'منذ 3 ساعة');
    });

    test('relative returns days label when diff >= 24h', () {
      final date = DateTime.now().subtract(const Duration(days: 2));
      expect(DateFormatter.relative(date), 'منذ 2 يوم');
    });

    test('time pads single-digit hours and minutes', () {
      final dt = DateTime(2025, 1, 1, 9, 7);
      expect(DateFormatter.time(dt), '09:07');
    });

    test('date formats as DD/MM/YYYY', () {
      final dt = DateTime(2025, 3, 5);
      expect(DateFormatter.date(dt), '05/03/2025');
    });
  });
}
