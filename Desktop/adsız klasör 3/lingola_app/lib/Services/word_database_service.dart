import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'word_services.dart';

/// Word Practice için kelimeleri SQLite'da saklar.
/// Seviye başına kelime sayıları: A1=800, A2=1200, B1=2000, B2=2500, C1=3000, C2=3500 (toplam 13.000)
class WordDatabaseService {
  WordDatabaseService._();

  static const String _dbName = 'lingola_words.db';
  static const String _tableName = 'practice_words';
  static const String _professionalTableName = 'professional_words';
  static const int _schemaVersion = 9;

  /// Mesleki İngilizce kategorileri
  static const List<String> professionalCategories = [
    'Psychology',
    'Business',
    'Finance',
    'Technology',
    'Marketing',
    'Engineering',
    'Medicine',
    'Legal',
  ];

  /// Onboarding 2'de seçilen meslek id'si → professional_words category.
  /// null dönerse tüm kategoriler (filtresiz) kullanılır.
  static String? professionIdToCategory(String? professionId) {
    if (professionId == null || professionId.isEmpty) return null;
    switch (professionId) {
      case 'legal':
        return 'Legal';
      case 'tech':
      case 'it':
        return 'Technology';
      case 'medicine':
        return 'Medicine';
      case 'finance':
        return 'Finance';
      case 'marketing':
      case 'sales':
        return 'Marketing';
      case 'engineering':
        return 'Engineering';
      case 'education':
        return 'Academic';
      case 'tourism':
      case 'support':
      case 'hr':
      case 'entrepreneurship':
      case 'logistics':
        return 'Business';
      default:
        return null;
    }
  }

  // Seviye başına kelime sayıları
  static const int a1Count = 800;
  static const int a2Count = 1200;
  static const int b1Count = 2000;
  static const int b2Count = 2500;
  static const int c1Count = 3000;
  static const int c2Count = 3500;
  static const int totalCount =
      a1Count + a2Count + b1Count + b2Count + c1Count + c2Count;

  static Database? _db;

  static Future<Database> _getDb() async {
    if (_db != null && (_db!.isOpen)) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: _schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        translation TEXT,
        phonetic TEXT,
        example_en TEXT,
        example_tr TEXT,
        level TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        learning_track_id INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $_professionalTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT,
        translation TEXT,
        example TEXT,
        example_translation TEXT,
        level TEXT,
        category TEXT
      )
    ''');
    await _seedFromAsset(db);
    await _seedProfessionalWords(db);
  }

  static const List<String> _professionalSeedAssets = [
    'assets/professional_words/academic_words.json',
    'assets/professional_words/business_words.json',
    'assets/professional_words/technology_words.json',
    'assets/professional_words/medicine_words.json',
    'assets/professional_words/legal_words.json',
    'assets/professional_words/engineering_words.json',
    'assets/professional_words/marketing_words.json',
    'assets/professional_words/finance_words.json',
    'assets/professional_words/psychology_words.json',
  ];

  static Future<void> _seedProfessionalWords(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $_professionalTableName'),
      );
      if ((count ?? 0) > 0) return;
      final batch = db.batch();
      for (final assetPath in _professionalSeedAssets) {
        final jsonString = await rootBundle.loadString(assetPath);
        final list = jsonDecode(jsonString) as List<dynamic>?;
        if (list == null || list.isEmpty) continue;
        for (final item in list) {
          final m = item is Map<String, dynamic> ? item : <String, dynamic>{};
          batch.insert(_professionalTableName, {
            'word': m['word']?.toString().trim() ?? '',
            'translation': m['translation']?.toString().trim() ?? '',
            'example': m['example']?.toString().trim() ?? '',
            'example_translation': m['example_translation']?.toString().trim() ?? '',
            'level': m['level']?.toString().trim() ?? 'b2',
            'category': m['category']?.toString().trim() ?? 'Academic',
          });
        }
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN example_en TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN example_tr TEXT');
      await _updateExamplesFromAsset(db);
    }
    if (oldVersion < 3) {
      await _fillEmptyExamplesWithLocalTemplate(db);
    }
    if (oldVersion < 4) {
      await _fillExamplesWithVariedTemplates(db);
    }
    if (oldVersion < 5) {
      await _fillExamplesWithVariedTemplates(db);
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_professionalTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT,
          translation TEXT,
          example TEXT,
          example_translation TEXT,
          level TEXT,
          category TEXT
        )
      ''');
    }
    if (oldVersion < 7) {
      await _seedProfessionalWords(db);
    }
    // Tüm mesleki kelime kategorilerini (Legal, Engineering, vb.) ekleyebilmek için
    // tabloyu temizleyip seed'i yeniden çalıştır.
    if (oldVersion < 8) {
      await db.delete(_professionalTableName);
      await _seedProfessionalWords(db);
    }
    // Mesleki terimlerde boş örnek cümleleri şablonla doldur.
    if (oldVersion < 9) {
      await _fillProfessionalWordsExamples(db);
    }
  }

  static const List<(String, String)> _professionalExampleTemplates = [
    (r'This term is commonly used in professional contexts.', r'Bu terim mesleki bağlamda yaygın kullanılır.'),
    (r'The word {w} appears in formal documents.', r'{w} kelimesi resmi belgelerde geçer.'),
    (r'You will encounter {w} in business communication.', r'İş iletişiminde {w} ile karşılaşacaksınız.'),
    (r'{w} is an important term in this field.', r'{w} bu alanda önemli bir terimdir.'),
    (r'Please use {w} in your report.', r'Lütfen raporunuzda {w} kullanın.'),
    (r'She explained the meaning of {w}.', r'{w} kelimesinin anlamını açıkladı.'),
    (r'We need to define {w} clearly.', r'{w} terimini net tanımlamalıyız.'),
    (r'This sentence uses the word {w}.', r'Bu cümlede {w} kelimesi kullanılıyor.'),
    (r'{w} is often used in legal documents.', r'{w} hukuki belgelerde sık kullanılır.'),
    (r'Understanding {w} is essential here.', r'{w} terimini anlamak burada gereklidir.'),
  ];

  static Future<void> _fillProfessionalWordsExamples(Database db) async {
    final rows = await db.query(_professionalTableName);
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      final ex = (r['example'] as String?)?.trim() ?? '';
      if (ex.isNotEmpty) continue;
      final word = (r['word'] as String?)?.trim() ?? '';
      if (word.isEmpty) continue;
      final idx = i % _professionalExampleTemplates.length;
      final t = _professionalExampleTemplates[idx];
      final en = t.$1.contains('{w}') ? t.$1.replaceAll('{w}', word) : t.$1;
      final tr = t.$2.contains('{w}') ? t.$2.replaceAll('{w}', word) : t.$2;
      await db.update(
        _professionalTableName,
        {'example': en, 'example_translation': tr},
        where: 'id = ?',
        whereArgs: [r['id']],
      );
    }
  }

  /// Mesleki İngilizce kelimelerini döner. [category] verilirse filtrelenir.
  static Future<List<Map<String, dynamic>>> getProfessionalWords({
    String? category,
    String? level,
  }) async {
    final db = await _getDb();
    String? where;
    List<Object?>? whereArgs;
    if (category != null && category.isNotEmpty) {
      where = 'category = ?';
      whereArgs = [category];
      if (level != null && level.isNotEmpty) {
        where += ' AND level = ?';
        whereArgs.add(level);
      }
    } else if (level != null && level.isNotEmpty) {
      where = 'level = ?';
      whereArgs = [level];
    }
    final rows = await db.query(
      _professionalTableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'id ASC',
    );
    return rows.map((r) => {
      'id': r['id'],
      'word': r['word'] ?? '',
      'translation': r['translation'] ?? '',
      'example': r['example'] ?? '',
      'example_translation': r['example_translation'] ?? '',
      'level': r['level'] ?? '',
      'category': r['category'] ?? '',
    }).toList();
  }

  /// Mesleki kelimenin örnek cümlesini günceller (kelimeye göre; aynı kelime birden fazla kategorideyse hepsi güncellenir).
  static Future<int> updateProfessionalWordExampleByWord({
    required String word,
    required String example,
    required String exampleTranslation,
  }) async {
    final db = await _getDb();
    return db.update(
      _professionalTableName,
      {
        'example': example,
        'example_translation': exampleTranslation,
      },
      where: 'word = ?',
      whereArgs: [word.trim()],
    );
  }

  /// Mesleki İngilizce kelimesi ekler.
  static Future<int> insertProfessionalWord({
    required String word,
    required String translation,
    required String example,
    required String exampleTranslation,
    required String level,
    required String category,
  }) async {
    final db = await _getDb();
    return db.insert(
      _professionalTableName,
      {
        'word': word,
        'translation': translation,
        'example': example,
        'example_translation': exampleTranslation,
        'level': level,
        'category': category,
      },
    );
  }

  /// Tüm şablon cümleleri farklı varyasyonlarla günceller (word_examples hariç).
  static Future<void> _fillExamplesWithVariedTemplates(Database db) async {
    final examplesMap = await _loadExamplesMap();
    final translationMap = await WordService.getTranslationMapForLocale('tr');
    final rows = await db.query(_tableName);
    for (final r in rows) {
      final word = (r['word'] as String?)?.trim() ?? '';
      if (word.isEmpty) continue;
      final key = word.toLowerCase();
      final ex = examplesMap[key];
      if (ex != null && ex.isNotEmpty) continue; // word_examples'taki kelimeleri değiştirme
      final tr = (r['translation'] as String?)?.trim() ?? translationMap[key] ?? '';
      final idx = r['sort_order'] as int? ?? 0;
      final local = _localExampleForWord(word, tr, idx);
      await db.update(
        _tableName,
        {'example_en': local.$1, 'example_tr': local.$2},
        where: 'id = ?',
        whereArgs: [r['id']],
      );
    }
  }

  /// Boş example_en/example_tr olan satırları yerel şablonla doldurur (13k kelime tamamı local).
  static Future<void> _fillEmptyExamplesWithLocalTemplate(Database db) async {
    final examplesMap = await _loadExamplesMap();
    final translationMap = await WordService.getTranslationMapForLocale('tr');
    final rows = await db.query(_tableName);
    for (final r in rows) {
      final word = (r['word'] as String?)?.trim() ?? '';
      if (word.isEmpty) continue;
      var exEn = (r['example_en'] as String?)?.trim() ?? '';
      var exTr = (r['example_tr'] as String?)?.trim() ?? '';
      if (exEn.isNotEmpty && exTr.isNotEmpty) continue;
      final key = word.toLowerCase();
      final ex = examplesMap[key];
      if (ex != null && ex.isNotEmpty) {
        exEn = ex['en'] ?? ex.values.first;
        exTr = ex['tr'] ?? ex['en'] ?? exEn;
      } else {
        final tr = (r['translation'] as String?)?.trim() ?? translationMap[key] ?? '';
        final idx = r['sort_order'] as int? ?? 0;
        final local = _localExampleForWord(word, tr, idx);
        exEn = local.$1;
        exTr = local.$2;
      }
      await db.update(
        _tableName,
        {'example_en': exEn, 'example_tr': exTr},
        where: 'id = ?',
        whereArgs: [r['id']],
      );
    }
  }

  static String _levelForIndex(int i) {
    if (i < a1Count) return 'a1';
    if (i < a1Count + a2Count) return 'a2';
    if (i < a1Count + a2Count + b1Count) return 'b1';
    if (i < a1Count + a2Count + b1Count + b2Count) return 'b2';
    if (i < a1Count + a2Count + b1Count + b2Count + c1Count) return 'c1';
    return 'c2';
  }

  static Future<Map<String, Map<String, String>>> _loadExamplesMap() async {
    try {
      final jsonString = await rootBundle.loadString('assets/word_examples.json');
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return {};
      final result = <String, Map<String, String>>{};
      for (final e in map.entries) {
        final key = e.key.toString().trim().toLowerCase();
        final val = e.value;
        if (val is! Map<String, dynamic>) continue;
        final langMap = <String, String>{};
        for (final le in val.entries) {
          final lang = le.key.toString().toLowerCase();
          final text = le.value?.toString().trim() ?? '';
          if (text.isNotEmpty) langMap[lang] = text;
        }
        if (langMap.isNotEmpty) result[key] = langMap;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  static const List<(String, String)> _exampleTemplates = [
    (r'I use the word {w} in my vocabulary.', r'{t} kelimesini kelime dağarcığımda kullanıyorum.'),
    (r'Can you spell {w}?', r'{t} kelimesini heceleyebilir misin?'),
    (r'{w} is an important word.', r'{t} önemli bir kelimedir.'),
    (r'I learned the word {w} today.', r'Bugün {t} kelimesini öğrendim.'),
    (r'This sentence contains the word {w}.', r'Bu cümlede {t} kelimesi geçiyor.'),
    (r'She wrote the word {w} on the board.', r'Tahtaya {t} kelimesini yazdı.'),
    (r'Do you know the meaning of {w}?', r'{t} kelimesinin anlamını biliyor musun?'),
    (r'I want to learn the word {w}.', r'{t} kelimesini öğrenmek istiyorum.'),
    (r'He explained the word {w} to me.', r'Bana {t} kelimesini açıkladı.'),
    (r'The word {w} appears in the text.', r'Metinde {t} kelimesi geçiyor.'),
  ];

  /// word_examples.json'da yoksa farklı şablonlarla yerel cümle üretir (her kelime farklı).
  static (String, String) _localExampleForWord(String word, String translation, int index) {
    final w = word.trim();
    final tr = translation.trim().isNotEmpty ? translation.trim() : w;
    final t = _exampleTemplates[index % _exampleTemplates.length];
    return (
      t.$1.replaceAll('{w}', w),
      t.$2.replaceAll('{t}', tr),
    );
  }

  static Future<void> _seedFromAsset(Database db) async {
    String jsonString;
    try {
      jsonString = await rootBundle.loadString('assets/words.json');
    } catch (_) {
      jsonString = await rootBundle.loadString('assets/words/words.json');
    }
    final list = jsonDecode(jsonString) as List<dynamic>?;
    if (list == null || list.isEmpty) return;

    final examplesMap = await _loadExamplesMap();
    final translationMap = await WordService.getTranslationMapForLocale('tr');
    final batch = db.batch();
    var inserted = 0;
    for (var i = 0; i < list.length && inserted < totalCount; i++) {
      final item = list[i];
      final map = item is Map<String, dynamic> ? item : <String, dynamic>{};
      final word = map['word']?.toString().trim() ?? '';
      if (word.isEmpty) continue;

      final key = word.toLowerCase();
      final rawTranslation = map['translation']?.toString().trim() ?? '';
      final translation = rawTranslation.isNotEmpty
          ? rawTranslation
          : (translationMap[key] ?? '');

      String exampleEn;
      String exampleTr;
      final ex = examplesMap[key];
      if (ex != null && ex.isNotEmpty) {
        exampleEn = ex['en'] ?? ex.values.first;
        exampleTr = ex['tr'] ?? ex['en'] ?? exampleEn;
      } else {
        final local = _localExampleForWord(word, translation, inserted);
        exampleEn = local.$1;
        exampleTr = local.$2;
      }

      final level = _levelForIndex(inserted);
      batch.insert(
        _tableName,
        {
          'word': word,
          'translation': translation,
          'phonetic': map['phonetic']?.toString().trim() ?? '',
          'example_en': exampleEn,
          'example_tr': exampleTr,
          'level': level,
          'sort_order': inserted,
          'learning_track_id': 0,
        },
      );
      inserted++;
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _updateExamplesFromAsset(Database db) async {
    final examplesMap = await _loadExamplesMap();
    final rows = await db.query(_tableName);
    for (final r in rows) {
      final word = (r['word'] as String?)?.trim() ?? '';
      if (word.isEmpty) continue;
      final ex = examplesMap[word.toLowerCase()];
      if (ex == null || ex.isEmpty) continue;
      final exampleEn = ex['en'] ?? ex.values.first;
      final exampleTr = ex['tr'] ?? ex['en'] ?? exampleEn;
      await db.update(
        _tableName,
        {'example_en': exampleEn, 'example_tr': exampleTr},
        where: 'id = ?',
        whereArgs: [r['id']],
      );
    }
  }

  /// Veritabanının boş olup olmadığını kontrol eder, boşsa asset'ten doldurur.
  static Future<void> ensureSeeded() async {
    final db = await _getDb();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    if (count == 0) {
      await _seedFromAsset(db);
    }
  }

  /// Tüm practice kelimelerini döner (Word Practice formatında).
  static Future<List<Map<String, dynamic>>> getWords() async {
    await ensureSeeded();
    final db = await _getDb();
    final rows = await db.query(
      _tableName,
      orderBy: 'sort_order ASC',
    );
    return rows.map((r) {
      final exEn = (r['example_en'] ?? r['exampleEn'])?.toString().trim() ?? '';
      final exTr = (r['example_tr'] ?? r['exampleTr'])?.toString().trim() ?? '';
      return {
        'id': r['id'],
        'learning_track_id': r['learning_track_id'] ?? 0,
        'word': r['word'] ?? '',
        'translation': r['translation'] ?? '',
        'phonetic': r['phonetic'] ?? '',
        'example_en': exEn,
        'example_tr': exTr,
        'exampleEn': exEn,
        'exampleTr': exTr,
        'level': r['level'] ?? 'a1',
        'sort_order': r['sort_order'] ?? 0,
      };
    }).toList();
  }

  /// Veritabanını kapatır (test/cleanup için).
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
