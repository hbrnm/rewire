/// Derivă, din istoricul local, ora din zi cu cea mai mare frecvență de impulsuri.
/// Rezultatul e doar o *sugestie* — nu activează notificări fără consimțământ.
class RiskPatternAnalyzer {
  const RiskPatternAnalyzer();

  /// Returnează ora (0–23) cu cele mai multe evenimente, sau `null` dacă
  /// eșantionul e prea mic ca să merite o recomandare.
  int? peakHour(List<DateTime> timestamps, {int minSamples = 5}) {
    if (timestamps.length < minSamples) return null;

    final counts = List<int>.filled(24, 0);
    for (final stamp in timestamps) {
      counts[stamp.hour]++;
    }

    var bestHour = 0;
    var bestCount = 0;
    for (var hour = 0; hour < 24; hour++) {
      if (counts[hour] > bestCount) {
        bestCount = counts[hour];
        bestHour = hour;
      }
    }

    // Evită o „recomandare” când totul e plat (ex. 5 evenimente în 5 ore diferite).
    if (bestCount < 2) return null;
    return bestHour;
  }

  String formatHour(int hour) {
    final hh = hour.toString().padLeft(2, '0');
    return '$hh:00';
  }
}
