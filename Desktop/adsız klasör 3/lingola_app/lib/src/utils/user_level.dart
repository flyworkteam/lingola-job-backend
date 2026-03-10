/// Kullanıcı dil seviyesi (A1–C2) yardımcıları.
/// Word Practice'ta "seçilen seviyeye kadar" kelimeleri göstermek için kullanılır.
abstract final class UserLevel {
  UserLevel._();

  /// Sıralı seviye listesi: A1 en düşük, C2 en yüksek.
  static const List<String> orderedLevels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

  /// Kullanıcı [userLevel] seçtiyse gösterilecek seviyeler.
  /// Örn: A1 → [a1], A2 → [a1, a2], B1 → [a1, a2, b1].
  static List<String> allowedLevelsFor(String? userLevel) {
    if (userLevel == null || userLevel.isEmpty) return [];
    final lower = userLevel.toLowerCase();
    final index = orderedLevels.indexOf(lower);
    if (index < 0) return [lower];
    return orderedLevels.sublist(0, index + 1);
  }

  /// Kelimenin seviye değerini normalize eder (API 'A1' veya 'a1' dönebilir).
  static String? normalizedLevel(dynamic level) {
    if (level == null) return null;
    final s = level.toString().trim().toLowerCase();
    return s.isEmpty ? null : s;
  }

  /// [wordLevel] kullanıcının [userLevel] seviyesine göre gösterilebilir mi?
  static bool isAllowedForUser(dynamic wordLevel, String? userLevel) {
    final allowed = allowedLevelsFor(userLevel);
    if (allowed.isEmpty) return true;
    final w = normalizedLevel(wordLevel);
    if (w == null) return true;
    return allowed.contains(w);
  }
}
