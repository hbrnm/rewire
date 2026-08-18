import 'package:flutter_test/flutter_test.dart';
import 'package:rewire/core/services/risk_pattern_analyzer.dart';

void main() {
  const analyzer = RiskPatternAnalyzer();

  test('returns null when there are too few samples', () {
    final stamps = [
      DateTime(2026, 1, 1, 21),
      DateTime(2026, 1, 2, 21),
      DateTime(2026, 1, 3, 22),
    ];
    expect(analyzer.peakHour(stamps), isNull);
  });

  test('returns the hour with the highest frequency', () {
    final stamps = [
      DateTime(2026, 1, 1, 21),
      DateTime(2026, 1, 2, 21),
      DateTime(2026, 1, 3, 21),
      DateTime(2026, 1, 4, 18),
      DateTime(2026, 1, 5, 22),
      DateTime(2026, 1, 6, 21),
    ];
    expect(analyzer.peakHour(stamps), 21);
  });

  test('returns null when the peak is not actually a peak', () {
    final stamps = [
      DateTime(2026, 1, 1, 10),
      DateTime(2026, 1, 2, 11),
      DateTime(2026, 1, 3, 12),
      DateTime(2026, 1, 4, 13),
      DateTime(2026, 1, 5, 14),
    ];
    expect(analyzer.peakHour(stamps), isNull);
  });

  test('formats hours with two digits', () {
    expect(analyzer.formatHour(9), '09:00');
    expect(analyzer.formatHour(21), '21:00');
  });
}
