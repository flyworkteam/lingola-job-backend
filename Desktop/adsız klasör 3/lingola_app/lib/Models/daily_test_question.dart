import 'package:lingola_app/Models/word_item.dart';

/// Daily Test'te gösterilecek tek bir soru.
/// Artık çeviri yerine boşluk doldurma (cloze) sorusu gösteriyoruz:
/// örn. "My father ______ newspaper every morning." + 4 seçenek.
class DailyTestQuestion {
  const DailyTestQuestion({
    required this.wordId,
    required this.word,
    required this.sentence,
    required this.options,
    required this.correctOptionIndex,
  });

  final int wordId;
  final String word;
  /// Boşluklu soru cümlesi (örneğin "My father ______ newspaper every morning.")
  final String sentence;
  final List<String> options;
  final int correctOptionIndex;

  /// Kelime listesinden en az 4 kelime ile soru listesi üretir (boşluk doldurma).
  static List<DailyTestQuestion> fromWords(List<WordItem> words, {int maxQuestions = 10}) {
    final list = List<WordItem>.from(words)..shuffle();
    if (list.length < 4) return [];
    final take = list.length < maxQuestions ? list.length : maxQuestions;
    final selected = list.take(take).toList();
    final questions = <DailyTestQuestion>[];
    for (var i = 0; i < selected.length; i++) {
      final correct = selected[i];
      final cloze = _buildClozeQuestion(correct);
      if (cloze == null) continue;
      questions.add(DailyTestQuestion(
        wordId: correct.id,
        word: correct.word,
        sentence: cloze.sentence,
        options: cloze.options,
        correctOptionIndex: cloze.correctIndex,
      ));
    }
    return questions;
  }

  /// Bir kelime için cloze soru üretir: cümle + seçenekler + doğru index.
  /// Örnek:
  /// exampleEn: "My father reads newspaper every morning."
  /// → sentence: "My father ______ newspaper every morning."
  /// → options: ["to read", "read", "reading", "reads"] (doğru: "reads")
  static ({String sentence, List<String> options, int correctIndex})? _buildClozeQuestion(
    WordItem item,
  ) {
    final base = item.word.trim();
    if (base.isEmpty) return null;
    final example = (item.exampleEn ?? '').trim();

    // Önerilen cevap formları: base + basit varyasyonlar
    final candidates = <String>[
      base,
      'to $base',
      '${base}s',
      '${base}es',
      '${base}ing',
      '${base}ed',
    ];

    String? answerForm;
    String lowerExample = example.toLowerCase();

    if (lowerExample.isNotEmpty) {
      for (final c in candidates) {
        final lc = c.toLowerCase();
        if (lowerExample.contains(lc)) {
          answerForm = c;
          break;
        }
      }
    }

    // Eğer exampleEn'de herhangi bir form geçmiyorsa:
    // 1) exampleEn zaten boşluklu yazılmış olabilir: "My father ______ newspaper..."
    //    Bu durumda doğru cevabı base form olarak al.
    // 2) completely farklı bir metinse, fallback olarak generic cümle üret.
    String sentence;
    if (example.isNotEmpty) {
      if (example.contains('______')) {
        sentence = example;
        answerForm ??= base;
      } else if (answerForm != null) {
        sentence = example.replaceAll(
          RegExp(RegExp.escape(answerForm), caseSensitive: false),
          '______',
        );
      } else {
        // Kelimeyi bulamadıysa example'ı bozmadan generic bir boşluk ekle
        sentence = '$example ______';
        answerForm = base;
      }
    } else {
      sentence = '______ $base';
      answerForm = base;
    }

    final options = _buildOptionsForWord(base, answerForm);
    if (options.length < 4) return null;
    final correctIndex = options.indexOf(answerForm);
    if (correctIndex < 0) return null;
    return (sentence: sentence, options: options, correctIndex: correctIndex);
  }

  /// Verilen kelime için 4 çoktan seçmeli seçenek üretir:
  /// [correctForm] doğru cevap, diğerleri basit varyasyonlar (to + verb, -s, -ing, -ed).
  static List<String> _buildOptionsForWord(String rawWord, String correctForm) {
    final w = rawWord.trim();
    final c = correctForm.trim();
    if (w.isEmpty || c.isEmpty) return [];
    final set = <String>{};
    set.add(c); // doğru cevabı ekle
    set.add('to $w');
    set.add('${w}s');
    set.add('${w}es');
    set.add('${w}ing');
    set.add('${w}ed');
    final options = set.toList();
    options.shuffle();
    return options.take(4).toList();
  }
}
