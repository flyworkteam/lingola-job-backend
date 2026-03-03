import 'package:lingola_app/Models/word_item.dart';

/// Daily Test'te gösterilecek tek bir soru: kelime + 4 seçenek (1 doğru, 3 yanlış).
class DailyTestQuestion {
  const DailyTestQuestion({
    required this.wordId,
    required this.word,
    required this.correctTranslation,
    required this.options,
    required this.correctOptionIndex,
  });

  final int wordId;
  final String word;
  final String correctTranslation;
  final List<String> options;
  final int correctOptionIndex;

  /// Kelime listesinden en az 4 kelime ile soru listesi üretir (çeviri sorusu).
  static List<DailyTestQuestion> fromWords(List<WordItem> words, {int maxQuestions = 10}) {
    final list = List<WordItem>.from(words)..shuffle();
    if (list.length < 4) return [];
    final take = list.length < maxQuestions ? list.length : maxQuestions;
    final selected = list.take(take).toList();
    final others = list.where((w) => !selected.any((s) => s.id == w.id)).toList();
    final questions = <DailyTestQuestion>[];
    for (var i = 0; i < selected.length; i++) {
      final correct = selected[i];
      final wrongPool = [
        ...others.map((w) => w.translation),
        ...selected.where((s) => s.id != correct.id).map((s) => s.translation),
      ];
      wrongPool.shuffle();
      final wrong = wrongPool.take(3).toList();
      final options = [correct.translation, ...wrong]..shuffle();
      final correctIndex = options.indexOf(correct.translation);
      if (correctIndex < 0) continue;
      questions.add(DailyTestQuestion(
        wordId: correct.id,
        word: correct.word,
        correctTranslation: correct.translation,
        options: options,
        correctOptionIndex: correctIndex,
      ));
    }
    return questions;
  }
}
