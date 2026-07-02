class DateRange {
  const DateRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
  bool contains(DateTime dt) =>
      (dt.isAfter(start) || dt.isAtSameMomentAs(start)) &&
      (dt.isBefore(end) || dt.isAtSameMomentAs(end));
}

enum AnalyticsPeriod { week, month, allTime }

extension AnalyticsPeriodRange on AnalyticsPeriod {
  DateRange dateRange({DateTime? now}) {
    final n = now ?? DateTime.now();
    return switch (this) {
      AnalyticsPeriod.week => DateRange(
        start: n.subtract(const Duration(days: 7)),
        end: n,
      ),
      AnalyticsPeriod.month => DateRange(
        start: DateTime(n.year, n.month, 1),
        end: n,
      ),
      AnalyticsPeriod.allTime => DateRange(start: DateTime(2000), end: n),
    };
  }

  String get arabicLabel => switch (this) {
    AnalyticsPeriod.week => 'أسبوع',
    AnalyticsPeriod.month => 'شهر',
    AnalyticsPeriod.allTime => 'الكل',
  };
}
