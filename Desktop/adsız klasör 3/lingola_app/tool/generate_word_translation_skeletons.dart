import 'dart:convert';
import 'dart:io';

/// Bu script, assets/words.json içindeki TÜM kelimeleri okuyup
/// her hedef dil için (de, fr, es, it, pt, ru, ja, ko, hi, en)
/// boş çeviri iskeleti JSON dosyaları üretir / günceller:
///
/// - assets/word_translations_de.json
/// - assets/word_translations_fr.json
/// - ...
///
/// Mevcut dosyalar varsa içeriğini korur, eksik kelimeleri ekler.
/// Değerler başlangıçta "" bırakılır; çevirileri sen doldurursun.
///
/// Çalıştırmak için proje kökünde:
///   dart run tool/generate_word_translation_skeletons.dart
///
Future<void> main() async {
  final projectRoot = Directory.current.path;
  final assetsDir = Directory('$projectRoot/assets');
  final wordsFile = File('${assetsDir.path}/words.json');

  if (!await wordsFile.exists()) {
    stderr.writeln('words.json bulunamadı: ${wordsFile.path}');
    exit(1);
  }

  final wordsJson = jsonDecode(await wordsFile.readAsString()) as List<dynamic>?;
  if (wordsJson == null || wordsJson.isEmpty) {
    stderr.writeln('words.json boş veya geçersiz.');
    exit(1);
  }

  final words = <String>{};
  for (final item in wordsJson) {
    if (item is Map<String, dynamic>) {
      final w = item['word']?.toString().trim().toLowerCase() ?? '';
      if (w.isNotEmpty) {
        words.add(w);
      }
    }
  }

  if (words.isEmpty) {
    stderr.writeln('words.json içinde kelime bulunamadı.');
    exit(1);
  }

  // 11 dil: uygulamadaki tüm diller.
  const locales = <String>[
    'tr',
    'en',
    'de',
    'fr',
    'es',
    'it',
    'pt',
    'ru',
    'ja',
    'ko',
    'hi',
  ];

  // Türkçe için mevcut word_translations.json ile başla.
  final trSourceFile = File('${assetsDir.path}/word_translations.json');
  Map<String, dynamic> trExisting = {};
  if (await trSourceFile.exists()) {
    try {
      final m = jsonDecode(await trSourceFile.readAsString()) as Map<String, dynamic>?;
      if (m != null) trExisting = Map<String, dynamic>.from(m);
    } catch (_) {}
  }

  for (final locale in locales) {
    final outFile = File('${assetsDir.path}/word_translations_$locale.json');
    Map<String, dynamic> existing = {};

    if (locale == 'tr' && trExisting.isNotEmpty) {
      existing = Map<String, dynamic>.from(trExisting);
    }
    if (await outFile.exists()) {
      try {
        final jsonMap = jsonDecode(await outFile.readAsString()) as Map<String, dynamic>?;
        if (jsonMap != null) {
          for (final e in jsonMap.entries) {
            existing[e.key] = e.value;
          }
        }
      } catch (_) {}
    }

    // Tüm kelimeler için key oluştur; mevcut değeri koru, yoksa "".
    for (final w in words) {
      existing.putIfAbsent(w, () => '');
    }

    // Anahtarları alfabetik sırala.
    final sortedKeys = existing.keys.toList()..sort();
    final sortedMap = <String, dynamic>{};
    for (final k in sortedKeys) {
      sortedMap[k] = existing[k];
    }

    final encoder = const JsonEncoder.withIndent('  ');
    await outFile.writeAsString(encoder.convert(sortedMap));
    stdout.writeln('Güncellendi: ${outFile.path} (${sortedMap.length} kelime)');
  }

  stdout.writeln('İşlem tamam. 11 dil için word_translations_<lang>.json oluşturuldu/güncellendi.');
}

