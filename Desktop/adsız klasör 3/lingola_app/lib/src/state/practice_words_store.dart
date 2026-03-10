import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String _kPracticeWordsKey = 'practice_words_cache';

/// Word Practice için kelime listesini local'de saklar.
/// API'den gelen ham liste (Map listesi) kaydedilir; seviye filtresi ekranda uygulanır.
class PracticeWordsStore {
  /// Cache'deki kelime listesini döner (ham API formatında).
  static Future<List<Map<String, dynamic>>> getWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPracticeWordsKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>?;
      if (list == null) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Kelime listesini cache'e yazar (ham API formatında).
  static Future<void> setWords(List<Map<String, dynamic>> words) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPracticeWordsKey, jsonEncode(words));
    } catch (_) {}
  }

  /// Cache'i temizler.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPracticeWordsKey);
    } catch (_) {}
  }
}
