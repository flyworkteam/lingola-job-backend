import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_app/Models/word_item.dart';
import 'package:lingola_app/Riverpod/Providers/user_repository_provider.dart';
import 'package:lingola_app/Riverpod/Providers/xp_provider.dart';
import 'package:lingola_app/Services/word_database_service.dart';
import 'package:lingola_app/Services/word_services.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/utils/user_level.dart';
import 'package:lingola_app/src/widgets/word_card.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reading Test sayfası — Word Practice ile aynı mavi kart + header + button bar.
class ReadingTestScreen extends ConsumerStatefulWidget {
  const ReadingTestScreen({super.key});

  @override
  ConsumerState<ReadingTestScreen> createState() => _ReadingTestScreenState();
}

class _ReadingTestScreenState extends ConsumerState<ReadingTestScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  FlutterTts? _flutterTts;

  static const int _xpPerCorrect = 10;

  List<WordItem>? _wordItems;
  List<WordCardData>? _cards;
  bool _loading = true;
  String? _errorMessage;
  int _currentCardIndex = 0;
  int _lastSwipeDirection = 1; // 1: next, -1: prev

  final Set<String> _translationRequested = {};
  final Set<String> _phoneticRequested = {};

  static const String _keyProfileLevel = 'profile_level';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWords();
    });
  }

  Future<void> _loadWords() async {
    if (!mounted) return;
    final localeCode = context.locale.languageCode;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userLevel = prefs.getString(_keyProfileLevel);

      var rawList = await WordDatabaseService.getWords();
      rawList = await WordService.enrichWordsWithTranslations(rawList, localeCode: localeCode);

      if (rawList.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _errorMessage = 'word_practice.words_load_error';
        });
        return;
      }

      final words = rawList.map((e) => WordItem.fromJson(e)).toList();
      final filtered = words
          .where((w) => UserLevel.isAllowedForUser(w.level, userLevel))
          .toList();
      // Reading Test için kelimeleri alfabetik sıraya göre göster.
      filtered.sort(
        (a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()),
      );
      final cards = filtered.map((w) => WordCardData.fromWordItem(w)).toList();

      if (!mounted) return;
      setState(() {
        _wordItems = filtered;
        _cards = cards;
        _loading = false;
        _errorMessage = cards.isEmpty ? 'word_practice.words_load_error' : null;
        _currentCardIndex = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  WordCardData? get _currentCard {
    final cards = _cards;
    if (cards == null || cards.isEmpty) return null;
    return cards[_currentCardIndex.clamp(0, cards.length - 1)];
  }

  WordItem? get _currentWordItem {
    final items = _wordItems;
    if (items == null || items.isEmpty) return null;
    return items[_currentCardIndex.clamp(0, items.length - 1)];
  }

  Future<void> _fetchTranslationForCurrentCard() async {
    final card = _currentCard;
    if (card == null || card.translations.trim().isNotEmpty) return;
    final localeCode = context.locale.languageCode;
    final translation =
        await WordService.fetchAndCacheTranslationForLocale(card.word, localeCode);
    if (!mounted || translation.isEmpty) return;
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    final idx = _currentCardIndex.clamp(0, cards.length - 1);
    final c = cards[idx];
    if (c.word != card.word) return;
    setState(() {
      _cards = [
        ...cards.sublist(0, idx),
        WordCardData(
          word: c.word,
          phonetic: c.phonetic,
          translations: translation,
          exampleEn: c.exampleEn,
          exampleTr: c.exampleTr,
        ),
        ...cards.sublist(idx + 1),
      ];
    });
  }

  Future<void> _fetchPhoneticForCurrentCard() async {
    final card = _currentCard;
    if (card == null || card.phonetic.trim().isNotEmpty) return;
    final phonetic = await WordService.fetchAndCachePhonetic(card.word);
    if (!mounted || phonetic.isEmpty) return;
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    final idx = _currentCardIndex.clamp(0, cards.length - 1);
    final c = cards[idx];
    if (c.word != card.word) return;
    setState(() {
      _cards = [
        ...cards.sublist(0, idx),
        WordCardData(
          word: c.word,
          phonetic: phonetic,
          translations: c.translations,
          exampleEn: c.exampleEn,
          exampleTr: c.exampleTr,
        ),
        ...cards.sublist(idx + 1),
      ];
    });
  }

  /// Ampul (Hint) butonuna basılınca: karttaki kelimeyi İngilizce seslendir.
  Future<void> _speakCurrentWord() async {
    final card = _currentCard;
    if (card == null || card.word.trim().isEmpty) return;
    final word = card.word.trim();

    _flutterTts ??= FlutterTts();

    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setSpeechRate(0.5);
    try {
      await _flutterTts!.setLanguage('en-US');
    } catch (_) {
      try {
        await _flutterTts!.setLanguage('en');
      } catch (_) {}
    }

    await _flutterTts!.speak(word);
  }

  void _goNextCard() {
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = 1;
      _currentCardIndex = (_currentCardIndex + 1) % cards.length;
    });
  }

  void _goPrevCard() {
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = -1;
      _currentCardIndex = (_currentCardIndex - 1) < 0
          ? (cards.length - 1)
          : (_currentCardIndex - 1);
    });
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      final available = await _speech.initialize(
        onError: (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mikrofon hatası: ${error.errorMsg}')),
          );
        },
      );
      if (!available) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mikrofon veya konuşma tanıma bu cihazda kullanılamıyor.'),
          ),
        );
        return;
      }

      setState(() {
        _isListening = true;
        _recognizedText = '';
      });

      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _recognizedText = result.recognizedWords;
          });
          if (result.finalResult) {
            _speech.stop();
            setState(() {
              _isListening = false;
            });
            _checkSpokenWord();
          }
        },
        localeId: 'en_US',
      );
    } else {
      await _speech.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      _checkSpokenWord();
    }
  }

  void _checkSpokenWord() {
    if (!mounted) return;
    final card = _currentCard;
    final wordItem = _currentWordItem;
    final targetWord = card?.word ?? '';
    if (targetWord.trim().isEmpty) return;
    final target = targetWord.toLowerCase().trim();
    final spoken = _recognizedText.toLowerCase().trim();
    if (spoken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seni duyamadık, tekrar dener misin?')),
      );
      return;
    }

    final isCorrect = spoken.contains(target);

    if (isCorrect) {
      // XP ekle
      ref.read(xpProvider).addXp(_xpPerCorrect);
      // Backend'e user_answers kaydı gönder (mümkünse).
      final wordId = wordItem?.id;
      if (wordId != null) {
        ref.read(userRepositoryProvider).submitUserAnswer(
              wordId: wordId,
              userAnswer: _recognizedText,
              isCorrect: true,
              questionType: 'reading_test',
            ).ignore();
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect
              ? 'Harika, \"$targetWord\" kelimesini doğru okudun! +$_xpPerCorrect XP'
              : 'Duyduğumuz: \"$_recognizedText\". Karttaki kelime: \"$targetWord\"',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _currentCard;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Transform.translate(
            offset: const Offset(6, 0),
            child: Transform.scale(
              scaleX: -1,
              child: SvgPicture.asset(
                'assets/icons/icon_arrow_right.svg',
                width: 20,
                height: 9,
                colorFilter: const ColorFilter.mode(Color(0xFF000000), BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 4,
        title: Text(
          context.tr('learn.reading_test'),
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
            child: Builder(
              builder: (context) {
                if (_loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_errorMessage != null) {
                  return Center(
                    child: Text(
                      _errorMessage!.startsWith('word_practice.')
                          ? _errorMessage!.tr()
                          : _errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                if (card == null) {
                  return Center(
                    child: Text(
                      'word_practice.no_words'.tr(),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                // Eksik çeviri/okunuşu lazily doldur (Word Practice ile aynı mantık).
                if (card.translations.trim().isEmpty &&
                    !_translationRequested.contains(card.word)) {
                  _translationRequested.add(card.word);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fetchTranslationForCurrentCard();
                  });
                }
                if (card.phonetic.trim().isEmpty &&
                    !_phoneticRequested.contains(card.word)) {
                  _phoneticRequested.add(card.word);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fetchPhoneticForCurrentCard();
                  });
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WordCard3D(
                      height: 340,
                      onSwipeLeft: _goPrevCard,
                      onSwipeRight: _goNextCard,
                      childKey: ValueKey<int>(_currentCardIndex),
                      lastSwipeDirection: _lastSwipeDirection,
                      child: WordCardReadingTestBody(
                        word: card.word,
                        phonetic: card.phonetic,
                        translation: card.translations,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WordCardHintButton(onTap: _speakCurrentWord),
                        const SizedBox(width: 12),
                        _MicButton(
                          onTap: _toggleListening,
                          isListening: _isListening,
                        ),
                      ],
                    ),
                    const SizedBox(height: 180),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BackNextButton(
                          label: context.tr('common.back'),
                          isPrimary: false,
                          onTap: _goPrevCard,
                          isBack: true,
                        ),
                        const SizedBox(width: 16),
                        BackNextButton(
                          label: context.tr('common.next'),
                          isPrimary: true,
                          onTap: _goNextCard,
                          isBack: false,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

}

/// Reading Test mikrofon butonu — 2 katmanlı gölge efekti (Save Word / Listen ile aynı stil).
class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.onTap,
    required this.isListening,
  });

  final VoidCallback onTap;
  final bool isListening;

  static const Color _mainColor = Color(0xFF0575E6);
  static const Color _activeColor = Color(0xFF00C853);
  static const Color _shadowLayer = Color(0xFF002D5C);
  static const double _layerOffset = 7;
  static const double _radius = 18;
  static const double _btnWidth = 72;
  static const double _btnHeight = 52;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _btnWidth,
      height: _btnHeight + _layerOffset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          Positioned(
            left: 0,
            top: _layerOffset,
            child: Container(
              width: _btnWidth,
              height: _btnHeight,
              decoration: BoxDecoration(
                color: _shadowLayer,
                borderRadius: BorderRadius.circular(_radius),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Material(
              color: isListening ? _activeColor : _mainColor,
              borderRadius: BorderRadius.circular(_radius),
              elevation: 0,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(_radius),
                child: SizedBox(
                  width: _btnWidth,
                  height: _btnHeight,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/icon_mic.svg',
                      width: 28,
                      height: 32,
                      colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

