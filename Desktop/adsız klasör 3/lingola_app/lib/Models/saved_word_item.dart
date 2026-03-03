import 'dart:convert';

/// Word Practice'tan kaydedilen kelime modelidir.
/// JSON ile serileştirilip lokal depolama (ör. SharedPreferences) için kullanılır.
class SavedWordItem {
  const SavedWordItem({
    required this.word,
    required this.phonetic,
    required this.translations,
    required this.exampleEn,
    required this.exampleTr,
  });

  final String word;
  final String phonetic;
  final String translations;
  final String exampleEn;
  final String exampleTr;

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'translations': translations,
        'exampleEn': exampleEn,
        'exampleTr': exampleTr,
      };

  factory SavedWordItem.fromJson(Map<String, dynamic> json) {
    return SavedWordItem(
      word: json['word'] as String? ?? '',
      phonetic: json['phonetic'] as String? ?? '',
      translations: json['translations'] as String? ?? '',
      exampleEn: json['exampleEn'] as String? ?? '',
      exampleTr: json['exampleTr'] as String? ?? '',
    );
  }

  static List<SavedWordItem> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(SavedWordItem.fromJson)
        .toList(growable: false);
  }

  static String encodeList(List<SavedWordItem> items) {
    final list = items.map((e) => e.toJson()).toList(growable: false);
    return jsonEncode(list);
  }
}

