import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Kelime paketi (words.json) asset'ten yükler.
/// Seviye ataması: sıralı indekse göre A1 → C2.
/// Çeviri: her dil için word_translations_<lang>.json (tr, en, de, fr, es, it, pt, ru, ja, ko, hi) + disk cache.
class WordService {
  WordService._();

  static const String _assetPath = 'assets/words.json';
  static const String _phoneticsPath = 'assets/word_phonetics.json';
  static const String _examplesPath = 'assets/word_examples.json';
  static const String _cacheFileName = 'translation_cache.json';
  static const String _phoneticCacheFileName = 'phonetic_cache.json';
  static const String _exampleCacheFileName = 'example_cache.json';
  static const String _sentenceTranslationCacheFileName = 'sentence_translation_cache.json';

  static Map<String, String>? _translationCache;
  static Map<String, String>? _phoneticsMap;
  static Map<String, String>? _phoneticCache;
  static Map<String, String>? _exampleCache;
  static Map<String, String>? _sentenceTranslationCache;

  /// Disk üzerindeki çeviri cache'ini yükler (API'dan alınan çeviriler).
  static Future<Map<String, String>> _loadTranslationCache() async {
    if (_translationCache != null) return _translationCache!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_cacheFileName');
      if (!await file.exists()) return _translationCache = {};
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _translationCache = {};
      _translationCache = map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
      return _translationCache!;
    } catch (_) {
      _translationCache = {};
      return _translationCache!;
    }
  }

  static Future<void> _saveTranslationCache() async {
    final cache = _translationCache;
    if (cache == null || cache.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_cacheFileName');
      await file.writeAsString(jsonEncode(cache));
    } catch (_) {}
  }

  /// Tüm çeviri kaynaklarını birleştirir: asset sözlük + disk cache (locale yok, geriye dönük uyumluluk).
  static Future<Map<String, String>> _getFullTranslationMap() async {
    return _getFullTranslationMapForLocale('tr');
  }

  /// Verilen dil için çeviri map'i: word_translations_<lang>.json + o dildeki disk cache (key: "word|lang").
  static Future<Map<String, String>> _getFullTranslationMapForLocale(String lang) async {
    final localeMap = await _loadTranslationMapForLocale(lang);
    final cache = await _loadTranslationCache();
    final suffix = '|${lang.toLowerCase()}';
    final cacheForLang = <String, String>{};
    for (final e in cache.entries) {
      if (e.key.endsWith(suffix)) {
        final wordKey = e.key.substring(0, e.key.length - suffix.length);
        if (wordKey.isNotEmpty) cacheForLang[wordKey] = e.value;
      }
    }
    return {...localeMap, ...cacheForLang};
  }

  /// word_phonetics.json (kelime -> IPA okunuşu) yükler.
  static Future<Map<String, String>> _loadPhoneticsMap() async {
    if (_phoneticsMap != null) return _phoneticsMap!;
    try {
      final jsonString = await rootBundle.loadString(_phoneticsPath);
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _phoneticsMap = {};
      _phoneticsMap = map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
      return _phoneticsMap!;
    } catch (_) {
      _phoneticsMap = {};
      return _phoneticsMap!;
    }
  }

  /// Disk üzerindeki okunuş cache'ini yükler (API'dan alınan okunuşlar).
  static Future<Map<String, String>> _loadPhoneticCache() async {
    if (_phoneticCache != null) return _phoneticCache!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_phoneticCacheFileName');
      if (!await file.exists()) return _phoneticCache = {};
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _phoneticCache = {};
      _phoneticCache = map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
      return _phoneticCache!;
    } catch (_) {
      _phoneticCache = {};
      return _phoneticCache!;
    }
  }

  static Future<void> _savePhoneticCache() async {
    final cache = _phoneticCache;
    if (cache == null || cache.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_phoneticCacheFileName');
      await file.writeAsString(jsonEncode(cache));
    } catch (_) {}
  }

  static Future<Map<String, String>> _loadExampleCache() async {
    if (_exampleCache != null) return _exampleCache!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_exampleCacheFileName');
      if (!await file.exists()) return _exampleCache = {};
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _exampleCache = {};
      _exampleCache = map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
      return _exampleCache!;
    } catch (_) {
      _exampleCache = {};
      return _exampleCache!;
    }
  }

  static Future<void> _saveExampleCache() async {
    final cache = _exampleCache;
    if (cache == null || cache.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_exampleCacheFileName');
      await file.writeAsString(jsonEncode(cache));
    } catch (_) {}
  }

  static Future<Map<String, String>> _loadSentenceTranslationCache() async {
    if (_sentenceTranslationCache != null) return _sentenceTranslationCache!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_sentenceTranslationCacheFileName');
      if (!await file.exists()) return _sentenceTranslationCache = {};
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _sentenceTranslationCache = {};
      _sentenceTranslationCache = map.map((k, v) =>
          MapEntry(k.toString(), v?.toString() ?? ''));
      return _sentenceTranslationCache!;
    } catch (_) {
      _sentenceTranslationCache = {};
      return _sentenceTranslationCache!;
    }
  }

  static Future<void> _saveSentenceTranslationCache() async {
    final cache = _sentenceTranslationCache;
    if (cache == null || cache.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_sentenceTranslationCacheFileName');
      await file.writeAsString(jsonEncode(cache));
    } catch (_) {}
  }

  /// Dictionary API yanıtından ilk örnek cümleyi çıkarır.
  static String? _extractFirstExample(Map<String, dynamic>? entry) {
    final meanings = entry?['meanings'] as List<dynamic>?;
    if (meanings == null) return null;
    for (final m in meanings) {
      final defs = (m as Map<String, dynamic>?)?['definitions'] as List<dynamic>?;
      if (defs == null) continue;
      for (final d in defs) {
        final ex = (d as Map<String, dynamic>?)?['example']?.toString().trim();
        if (ex != null && ex.isNotEmpty) return ex;
      }
    }
    return null;
  }

  static const String _dictionaryApiBase = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Free Dictionary API'den kelime bilgisi çeker (okunuş + örnek cümle). Ağ hatasında null döner.
  static Future<({String? phonetic, String? exampleEn})> _fetchFromDictionaryApi(String word) async {
    final w = word.trim();
    if (w.isEmpty) return (phonetic: null, exampleEn: null);
    try {
      final uri = Uri.parse('$_dictionaryApiBase/${Uri.encodeComponent(w)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return (phonetic: null, exampleEn: null);
      final list = jsonDecode(response.body) as List<dynamic>?;
      if (list == null || list.isEmpty) return (phonetic: null, exampleEn: null);
      final entry = list.first as Map<String, dynamic>?;
      if (entry == null) return (phonetic: null, exampleEn: null);
      String? phonetic = entry['phonetic']?.toString().trim();
      if (phonetic == null || phonetic.isEmpty) {
        final phonetics = entry['phonetics'] as List<dynamic>?;
        if (phonetics != null && phonetics.isNotEmpty) {
          final first = phonetics.first as Map<String, dynamic>?;
          phonetic = first?['text']?.toString().trim();
        }
      }
      final exampleEn = _extractFirstExample(entry);
      return (phonetic: phonetic, exampleEn: exampleEn);
    } catch (_) {
      return (phonetic: null, exampleEn: null);
    }
  }

  static const String _myMemoryBase = 'https://api.mymemory.translated.net/get';

  /// MyMemory API ile metni hedef dile çevirir (en -> tr). Ağ hatasında boş döner.
  static Future<String> _fetchTranslationViaApi(String text, String targetLang) async {
    final t = text.trim();
    if (t.isEmpty) return '';
    final lang = targetLang.toLowerCase();
    if (lang == 'en') return t;
    try {
      final uri = Uri.parse('$_myMemoryBase?q=${Uri.encodeComponent(t)}&langpair=en|$lang');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return '';
      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      final responseData = map?['responseData'] as Map<String, dynamic>?;
      final translated = responseData?['translatedText']?.toString().trim();
      return translated ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Tüm okunuş kaynaklarını birleştirir: word_phonetics.json + disk cache.
  static Future<Map<String, String>> _getFullPhoneticsMap() async {
    final staticMap = await _loadPhoneticsMap();
    final cacheMap = await _loadPhoneticCache();
    return {...staticMap, ...cacheMap};
  }

  /// IPA metnini normal alfabeye çevirir. Okunuşta nokta kullanılmaz.
  static String ipaToPlain(String s) {
    if (s.isEmpty) return s;
    return s
        .replaceAll('ð', 'th')
        .replaceAll('θ', 'th')
        .replaceAll('æ', 'a')
        .replaceAll('ə', 'uh')
        .replaceAll('ɛ', 'e')
        .replaceAll('ɹ', 'r')
        .replaceAll('ʃ', 'sh')
        .replaceAll('ʒ', 'zh')
        .replaceAll('ŋ', 'ng')
        .replaceAll('ɜ', 'er')
        .replaceAll('ɡ', 'g')
        .replaceAll('ɔ', 'o')
        .replaceAll('ɑ', 'a')
        .replaceAll('ɪ', 'i')
        .replaceAll('ʊ', 'u')
        .replaceAll('ʌ', 'u')
        .replaceAll('ɒ', 'o')
        .replaceAll('ɫ', 'l')
        .replaceAll('ɾ', 'r')
        .replaceAll('ʔ', '')
        .replaceAll('ʰ', 'h')
        .replaceAll('ː', '')
        .replaceAll('ˈ', '')
        .replaceAll('ˌ', '')
        .replaceAll('́', '')
        .replaceAll('̃', '')
        .replaceAll('̈', '')
        .replaceAll('.', '');
  }

  /// Okunuşu önce yerel kaynaklardan (word_phonetics.json + disk cache) döner; yoksa Free Dictionary API ile çekip cache'ler.
  static Future<String> fetchAndCachePhonetic(String word) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final key = w.toLowerCase();
    final full = await _getFullPhoneticsMap();
    var text = full[key];
    if (text != null && text.isNotEmpty) return ipaToPlain(text);
    try {
      final api = await _fetchFromDictionaryApi(w);
      if (api.phonetic != null && api.phonetic!.isNotEmpty) {
        _phoneticCache ??= await _loadPhoneticCache();
        _phoneticCache![key] = api.phonetic!;
        await _savePhoneticCache();
        return ipaToPlain(api.phonetic!);
      }
    } catch (_) {}
    return '';
  }

  /// Örnek cümleyi yalnızca yerel cache'den döner. İnternet çağrısı yok.
  static Future<String> fetchAndCacheExample(String word) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final key = w.toLowerCase();
    final existing = _exampleCache?[key] ?? (await _loadExampleCache())[key];
    return existing ?? '';
  }

  /// Cümle çevirisini yalnızca yerel cache'den döner. İnternet çağrısı yok.
  static Future<String> translateSentence(String sentence, String targetLangCode) async {
    final s = sentence.trim();
    if (s.isEmpty) return '';
    if (targetLangCode.toLowerCase() == 'en') return s;
    final cacheKey = '$s|${targetLangCode.toLowerCase()}';
    final existing = _sentenceTranslationCache?[cacheKey] ??
        (await _loadSentenceTranslationCache())[cacheKey];
    return existing ?? '';
  }

  /// Örnek cümleyi seçili dile çevirir: önce cache, yoksa MyMemory API ile çekip cache'ler.
  static Future<String> translateAndCacheSentence(String sentence, String targetLangCode) async {
    final s = sentence.trim();
    if (s.isEmpty) return '';
    final lang = targetLangCode.toLowerCase();
    if (lang == 'en') return s;
    final cacheKey = '$s|$lang';
    _sentenceTranslationCache ??= await _loadSentenceTranslationCache();
    final cached = _sentenceTranslationCache![cacheKey];
    if (cached != null && cached.isNotEmpty) return cached;
    final translated = await _fetchTranslationViaApi(s, lang);
    if (translated.isNotEmpty) {
      _sentenceTranslationCache![cacheKey] = translated;
      await _saveSentenceTranslationCache();
    }
    return translated.isEmpty ? s : translated;
  }

  /// Verilen dil için tam çeviri map'ini döner (asset + cache). Diğer servisler için public.
  static Future<Map<String, String>> getTranslationMapForLocale(String lang) =>
      _getFullTranslationMapForLocale(lang.toLowerCase());

  /// 11 dil için yerel çeviri asset'ini yükler (assets/word_translations_<lang>.json).
  /// en için boş map (kelime aynen gösterilir). Dosya yoksa boş map döner.
  static Future<Map<String, String>> _loadTranslationMapForLocale(String lang) async {
    if (lang == 'en') return {};
    try {
      final path = 'assets/word_translations_$lang.json';
      final jsonString = await rootBundle.loadString(path);
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return {};
      return map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
    } catch (_) {
      return {};
    }
  }

  /// Çeviriyi yalnızca yerel kaynaklardan döner (word_translations.json + disk cache). İnternet çağrısı yok.
  static Future<String> fetchAndCacheTranslation(String word) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final key = w.toLowerCase();
    final full = await _getFullTranslationMap();
    final result = full[key]?.trim() ?? '';
    return result.isNotEmpty ? result : w;
  }

  /// Seçilen uygulama diline göre çeviriyi döner: sadece o dildeki asset (word_translations_<lang>.json) + cache.
  /// Yoksa İngilizce kelimenin kendisi döner (çeviri yok demek).
  static Future<String> fetchAndCacheTranslationForLocale(
    String word,
    String localeCode,
  ) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final lang = localeCode.toLowerCase();
    final key = w.toLowerCase();

    if (lang == 'en') return w;

    final fullMap = await _getFullTranslationMapForLocale(lang);
    final result = fullMap[key]?.trim() ?? '';
    return result.isNotEmpty ? result : w;
  }

  /// word_examples.json (kelime -> { en, tr, de, ... }) yükler. Her çağrıda asset'ten okur (güncel örnek cümleler için cache yok).
  static Future<Map<String, Map<String, String>>> _loadExamplesMap() async {
    try {
      final jsonString = await rootBundle.loadString(_examplesPath);
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

  /// Mesleki terimler için kullanılan şablon örnek cümleler (word_examples.json'da yoksa).
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

  /// Kelime için örnek cümle. word_examples.json'da seçili dil yoksa cümle API ile çevrilir ve cache'lenir.
  static Future<({String exampleEn, String exampleTr})> getExampleForWord(
    String word,
    String localeCode,
  ) async {
    final w = word.trim();
    if (w.isEmpty) return (exampleEn: '', exampleTr: '');
    final key = w.toLowerCase();
    final lang = localeCode.toLowerCase();
    final map = await _loadExamplesMap();
    final entry = map[key];
    String exampleEn;
    String exampleTr;
    if (entry != null && entry.isNotEmpty) {
      exampleEn = entry['en'] ?? entry.values.first;
      if (lang == 'en') {
        exampleTr = exampleEn;
      } else if (entry[lang] != null && entry[lang]!.isNotEmpty) {
        exampleTr = entry[lang]!;
      } else {
        // word_examples.json'da bu dil yok; İngilizce cümleyi seçili dile çevir (API + cache).
        exampleTr = await translateAndCacheSentence(exampleEn, lang);
        if (exampleTr.isEmpty) exampleTr = exampleEn;
      }
      return (exampleEn: exampleEn, exampleTr: exampleTr);
    }
    final idx = key.hashCode.abs() % _professionalExampleTemplates.length;
    final t = _professionalExampleTemplates[idx];
    final en = t.$1.contains('{w}') ? t.$1.replaceAll('{w}', w) : t.$1;
    if (lang == 'tr') {
      final tr = t.$2.contains('{w}') ? t.$2.replaceAll('{w}', w) : t.$2;
      return (exampleEn: en, exampleTr: tr);
    }
    if (lang == 'en') {
      return (exampleEn: en, exampleTr: en);
    }
    // Diğer diller: İngilizce cümleyi API ile çevir.
    exampleTr = await translateAndCacheSentence(en, lang);
    return (exampleEn: en, exampleTr: exampleTr.isEmpty ? en : exampleTr);
  }

  /// Önce [assets/words.json], yoksa [assets/words/words.json] dener.
  /// Çeviri: word_translations.json + disk cache ile doldurulur.
  static Future<List<Map<String, dynamic>>> loadWordsFromAsset() async {
    String jsonString;
    try {
      jsonString = await rootBundle.loadString(_assetPath);
    } catch (_) {
      jsonString = await rootBundle.loadString('assets/words/words.json');
    }
    final list = jsonDecode(jsonString) as List<dynamic>?;
    if (list == null || list.isEmpty) return [];

    // Not: Burada artık yalnızca asset içindeki ham veriyi kullanıyoruz.
    // Çeviriler seçili dile göre daha sonra [enrichWordsWithTranslations] ile doldurulacak.
    final phoneticsMap = await _getFullPhoneticsMap();

    final levels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];
    const a1End = 2000;
    const a2End = 5000;
    const b1End = 10000;
    const b2End = 20000;
    const c1End = 50000;

    String levelForIndex(int i) {
      if (i < a1End) return levels[0];
      if (i < a2End) return levels[1];
      if (i < b1End) return levels[2];
      if (i < b2End) return levels[3];
      if (i < c1End) return levels[4];
      return levels[5];
    }

    final result = <Map<String, dynamic>>[];
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final map = item is Map<String, dynamic>
          ? Map<String, dynamic>.from(item)
          : <String, dynamic>{};
      final word = map['word']?.toString().trim() ?? '';
      if (word.isEmpty) continue;
      // Asset'te varsa çeviri aynen alınır, yoksa boş bırakılır.
      // Böylece kartlar seçilen dile göre sonradan doldurulur.
      final translation = map['translation']?.toString().trim() ?? '';
      final rawPhonetic = map['phonetic']?.toString().trim() ?? '';
      final phonetic = rawPhonetic.isNotEmpty
          ? rawPhonetic
          : (phoneticsMap[word.toLowerCase()] ?? '');
      result.add({
        'id': i + 1,
        'learning_track_id': 0,
        'word': word,
        'translation': translation,
        'phonetic': phonetic,
        'level': levelForIndex(i),
        'sort_order': i,
      });
    }
    return result;
  }

  /// Verilen kelime listesinde çeviri, okunuş ve örnek cümle boş olanları sözlükten doldurur.
  /// Çeviri seçilen dildeki word_translations_<locale>.json dosyasından doldurulur.
  static Future<List<Map<String, dynamic>>> enrichWordsWithTranslations(
    List<Map<String, dynamic>> words, {
    String? localeCode,
  }) async {
    if (words.isEmpty) return words;
    final lang = (localeCode ?? 'tr').toLowerCase();
    final translationMap = await _getFullTranslationMapForLocale(lang);
    final phoneticsMap = await _getFullPhoneticsMap();
    final examplesMap = await _loadExamplesMap();
    return words.map((e) {
      final word = e['word']?.toString().trim() ?? '';
      final key = word.toLowerCase();
      final out = Map<String, dynamic>.from(e);
      // Kartta çeviri her zaman seçili dilde gösterilsin (üstte İngilizce, altta seçili dil).
      if (word.isNotEmpty) {
        final translated = lang == 'en' ? word : (translationMap[key] ?? '');
        out['translation'] = translated.trim().isEmpty ? word : translated;
      }
      if ((e['phonetic']?.toString().trim() ?? '').isEmpty && word.isNotEmpty) {
        out['phonetic'] = phoneticsMap[key] ?? '';
      }
      // Örnek cümle: İngilizce sabit, alttaki seçili dilde.
      final ex = examplesMap[key];
      if (ex != null && ex.isNotEmpty) {
        final valEn = ex['en'] ?? ex.values.first;
        final valLocale = ex[lang] ?? ex['en'] ?? ex.values.first;
        out['example_en'] = valEn;
        out['exampleEn'] = valEn;
        out['example_tr'] = valLocale;
        out['exampleTr'] = valLocale;
      }
      return out;
    }).toList();
  }
}
