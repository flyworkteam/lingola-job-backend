import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingola_app/Models/saved_word_item.dart';

const String _kSavedWordsKey = 'saved_words';

/// Reaktif kayıtlı kelimeler store'u.
/// [SavedWordItem] listesini SharedPreferences ile kalıcı tutar; değişince dinleyicileri bilgilendirir.
class SavedWordsNotifier extends ChangeNotifier {
  SavedWordsNotifier() {
    _load();
  }

  final List<SavedWordItem> _items = [];
  bool _loaded = false;

  /// Yüklü liste (salt okunur). Değişiklikler [add] / [remove] ile yapılır.
  List<SavedWordItem> get items => List.unmodifiable(_items);

  int get count => _items.length;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSavedWordsKey);
      if (raw != null && raw.isNotEmpty) {
        _items
          ..clear()
          ..addAll(SavedWordItem.decodeList(raw));
      }
    } catch (_) {
      _items.clear();
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSavedWordsKey, SavedWordItem.encodeList(_items));
    } catch (_) {}
  }

  /// Kelime ekler; aynı [word] varsa eklemez. Diske yazar ve dinleyicileri günceller.
  Future<void> add(SavedWordItem item) async {
    await _ensureLoaded();
    if (_items.any((e) => e.word == item.word)) return;
    _items.add(item);
    await _save();
    notifyListeners();
  }

  /// Kelimeyi listeden kaldırır. Diske yazar ve dinleyicileri günceller.
  Future<void> remove(String word) async {
    await _ensureLoaded();
    _items.removeWhere((e) => e.word == word);
    await _save();
    notifyListeners();
  }

  /// Kelimenin kayıtlı olup olmadığını döner (yükleme tamamlandıktan sonra anlamlı).
  Future<bool> contains(String word) async {
    await _ensureLoaded();
    return _items.any((e) => e.word == word);
  }
}
