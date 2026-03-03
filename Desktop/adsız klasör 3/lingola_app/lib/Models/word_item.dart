/// Backend'den gelen kelime modeli (words tablosu).
class WordItem {
  const WordItem({
    required this.id,
    required this.learningTrackId,
    required this.word,
    required this.translation,
    this.level,
    this.sortOrder,
  });

  final int id;
  final int learningTrackId;
  final String word;
  final String translation;
  final dynamic level;
  final dynamic sortOrder;

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      id: _intFrom(json['id']),
      learningTrackId: _intFrom(json['learning_track_id']) ?? 0,
      word: _stringFrom(json['word']) ?? '',
      translation: _stringFrom(json['translation']) ?? '',
      level: json['level'],
      sortOrder: json['sort_order'],
    );
  }

  static int? _intFrom(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static String? _stringFrom(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }
}
