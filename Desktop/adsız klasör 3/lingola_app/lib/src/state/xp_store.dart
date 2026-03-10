import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kXpKey = 'user_xp';

/// Kullanıcının toplam XP'sini tutar (testlerden, vb. kazanılan).
/// SharedPreferences ile kalıcı; değişince dinleyicileri bilgilendirir.
class XpNotifier extends ChangeNotifier {
  XpNotifier() {
    _load();
  }

  int _totalXp = 0;
  bool _loaded = false;

  int get totalXp => _totalXp;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalXp = prefs.getInt(_kXpKey) ?? 0;
    } catch (_) {
      _totalXp = 0;
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kXpKey, _totalXp);
    } catch (_) {}
  }

  /// Puan ekler (test doğruları vb.). Negatif değer verilirse 0'ın altına düşmez.
  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    _totalXp += amount;
    await _save();
    notifyListeners();
  }
}
