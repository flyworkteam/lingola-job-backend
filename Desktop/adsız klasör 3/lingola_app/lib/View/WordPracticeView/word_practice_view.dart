import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/Models/saved_word_item.dart';
import 'package:lingola_app/Models/word_item.dart';
import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/Services/word_database_service.dart';
import 'package:lingola_app/Services/word_services.dart';
import 'package:lingola_app/src/state/practice_words_store.dart';
import 'package:lingola_app/src/state/saved_words_store.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/utils/user_level.dart';
import 'package:lingola_app/src/widgets/word_card.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Word Practice sayfası — Learn sekmesindeki Word Practice kartına tıklanınca açılır.
/// Görseldeki gibi flashcard: kelime, okunuş, çeviri, örnek cümle, Save Word / Listen butonları.
/// Kaydedilen kelimeler [savedWordsProvider] ile diske yazılır ve UI reaktif güncellenir.
/// [returnToHomeOnPop]: Anasayfadan girildiyse true; çıkışta anasayfaya dönmek için kullanılır.
/// [trackId]: Verilirse backend user_tracks'a son erişim kaydedilir.
class WordPracticeScreen extends ConsumerStatefulWidget {
  const WordPracticeScreen({
    super.key,
    this.returnToHomeOnPop = false,
    this.trackId,
  });

  final bool returnToHomeOnPop;
  final int? trackId;

  @override
  ConsumerState<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends ConsumerState<WordPracticeScreen> {
  OverlayEntry? _tutorialOverlay;

  List<WordCardData>? _cards;
  bool _loading = true;
  String? _errorMessage;
  int _currentCardIndex = 0;
  int _lastSwipeDirection = 1; // 1: next, -1: prev
  final Set<String> _translationRequested = {};
  final Set<String> _phoneticRequested = {};
  final Set<String> _exampleRequested = {};
  FlutterTts? _flutterTts;
  bool _ttsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertTutorialOverlay();
      _reportTrackAccess();
      _loadWords();
      _initTts();
    });
  }

  static const String _keyProfileLevel = 'profile_level';

  Future<void> _loadWords() async {
    if (!mounted) return;
    final localeCode = context.locale.languageCode;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final userLevel = prefs.getString(_keyProfileLevel);

    List<Map<String, dynamic>> rawList;

    if (widget.trackId == null) {
      rawList = await WordDatabaseService.getWords();
      rawList = await WordService.enrichWordsWithTranslations(rawList, localeCode: localeCode);
    } else {
      final result = await ref.read(wordRepositoryProvider).getWords(
            learningTrackId: widget.trackId,
          );
      if (result.isOk && (result.data?.isNotEmpty ?? false)) {
        rawList = result.data!;
        await PracticeWordsStore.setWords(rawList);
      } else {
        rawList = await PracticeWordsStore.getWords();
        if (rawList.isNotEmpty) {
          rawList = await WordService.enrichWordsWithTranslations(rawList, localeCode: localeCode);
        }
        if (rawList.isEmpty && !result.isOk) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _errorMessage = result.error ?? 'word_practice.words_load_error';
          });
          return;
        }
      }
    }

    if (rawList.isEmpty && widget.trackId == null) {
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
    final cards = filtered.map((w) => WordCardData.fromWordItem(w)).toList();

    if (!mounted) return;
    final showError = cards.isEmpty && rawList.isEmpty;
    setState(() {
      _cards = cards;
      _loading = false;
      _errorMessage = showError ? 'word_practice.words_load_error' : null;
      _currentCardIndex = 0;
    });
  }

  void _reportTrackAccess() {
    final trackId = widget.trackId;
    if (trackId == null || !mounted) return;
    ref.read(userRepositoryProvider).updateTrackProgress(trackId).ignore();
  }

  @override
  void dispose() {
    _removeTutorialOverlay();
    _flutterTts?.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    _flutterTts ??= FlutterTts();
    await _flutterTts!.awaitSpeakCompletion(true);
    _flutterTts!.setErrorHandler((msg) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Ses hatası: $msg'), behavior: SnackBarBehavior.floating),
        );
      }
    });
    _ttsInitialized = true;
  }

  /// Listen butonu: o anki karttaki kelimeyi İngilizce okutur.
  Future<void> _speakCurrentWord() async {
    final card = _currentCard;
    if (card == null || card.word.trim().isEmpty) return;
    final word = card.word.trim();
    await _initTts();
    if (_flutterTts == null) return;
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setSpeechRate(0.5);
    try {
      await _flutterTts!.setLanguage('en-US');
    } catch (_) {
      try { await _flutterTts!.setLanguage('en'); } catch (_) {}
    }
    await _flutterTts!.speak(word);
  }

  void _insertTutorialOverlay() {
    if (!mounted || _tutorialOverlay != null) return;

    final entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: _TutorialFullScreenOverlay(onDismiss: _removeTutorialOverlay),
      ),
    );

    final overlay = Overlay.of(context, rootOverlay: true);
    overlay.insert(entry);
    _tutorialOverlay = entry;
  }

  void _removeTutorialOverlay() {
    _tutorialOverlay?.remove();
    _tutorialOverlay = null;
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
      _currentCardIndex = (_currentCardIndex - 1) < 0 ? (cards.length - 1) : (_currentCardIndex - 1);
    });
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

  Future<void> _fetchExampleForCurrentCard() async {
    final card = _currentCard;
    if (card == null) return;
    final localeCode = context.locale.languageCode;
    final result = await WordService.getExampleForWord(card.word, localeCode);
    if (!mounted || (result.exampleEn.isEmpty && result.exampleTr.isEmpty)) return;
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
          translations: c.translations,
          exampleEn: result.exampleEn,
          exampleTr: result.exampleTr.isNotEmpty ? result.exampleTr : result.exampleEn,
        ),
        ...cards.sublist(idx + 1),
      ];
    });
  }

  WordCardData? get _currentCard {
    final cards = _cards;
    if (cards == null || cards.isEmpty) return null;
    return cards[_currentCardIndex.clamp(0, cards.length - 1)];
  }

  void _handleBack() {
    Navigator.of(context).pop(widget.returnToHomeOnPop);
  }

  static bool _isConnectionError(String? msg) {
    if (msg == null || msg.isEmpty) return false;
    final lower = msg.toLowerCase();
    return lower.contains('istek hatası') ||
        lower.contains('connection') ||
        lower.contains('socket') ||
        lower.contains('failed host') ||
        lower.contains('network') ||
        lower.contains('refused') ||
        lower.contains('unreachable') ||
        lower.contains('timeout');
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      final displayMessage = _isConnectionError(_errorMessage)
          ? 'word_practice.connection_error'.tr()
          : (_errorMessage!.startsWith('word_practice.') ? _errorMessage!.tr() : _errorMessage!);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: _loadWords,
                child: Text('word_practice.retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }
    final card = _currentCard;
    if (card == null) {
      return Center(
        child: Text(
          'word_practice.no_words'.tr(),
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    if (card.translations.trim().isEmpty && !_translationRequested.contains(card.word)) {
      _translationRequested.add(card.word);
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTranslationForCurrentCard());
    }
    if (card.phonetic.trim().isEmpty && !_phoneticRequested.contains(card.word)) {
      _phoneticRequested.add(card.word);
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPhoneticForCurrentCard());
    }
    final exampleKey = '${card.word}|${context.locale.languageCode}';
    if (!_exampleRequested.contains(exampleKey)) {
      _exampleRequested.add(exampleKey);
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchExampleForCurrentCard());
    }
    return WordCard3D(
      onSwipeLeft: _goPrevCard,
      onSwipeRight: _goNextCard,
      childKey: ValueKey<int>(_currentCardIndex),
      lastSwipeDirection: _lastSwipeDirection,
      child: WordCardBody(
        data: card,
        onSaveWord: () async {
          final notifier = ref.read(savedWordsProvider);
          await notifier.add(SavedWordItem(
            word: card.word,
            phonetic: card.phonetic,
            translations: card.translations,
            exampleEn: card.exampleEn,
            exampleTr: card.exampleTr,
          ));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('word_practice.saved'.tr()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onListen: _speakCurrentWord,
        onHint: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
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
                colorFilter: const ColorFilter.mode(
                  Color(0xFF000000),
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          onPressed: _handleBack,
        ),
        titleSpacing: 4,
        title: Text(
          'word_practice.title'.tr(),
          style: AppTypography.titleLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
          child: Center(
            child: _buildBody(),
          ),
        ),
      ),
    ),
    );
  }

}

/// Full-screen tutorial overlay — header ve footer dahil tüm ekranı kaplar. Tıklanınca kapanır.
class _TutorialFullScreenOverlay extends StatefulWidget {
  const _TutorialFullScreenOverlay({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<_TutorialFullScreenOverlay> createState() =>
      _TutorialFullScreenOverlayState();
}

class _TutorialFullScreenOverlayState extends State<_TutorialFullScreenOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _handController;
  late final Animation<double> _handAnimation;

  @override
  void initState() {
    super.initState();
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // 180° (sol) -> 0° (sağ) arasında sağa-sola hareket ve dönüş
    _handAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: widget.onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // içeride tıklayınca kapanmasın
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/icon_tutorial_arrow_prev.svg',
                            width: 52,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'tutorial.previous'.tr(),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      AnimatedBuilder(
                        animation: _handAnimation,
                        builder: (context, child) {
                          // -1 (sol) -> 1 (sağ): 40px hareket, swipe yönüne hafif eğim
                          final t = _handAnimation.value;
                          final dx = t * 40;
                          // Hareket yönüne doğru hafif eğim (sağa giderken sağa yatık)
                          final angle = t * (math.pi / 12);
                          return Transform.translate(
                            offset: Offset(dx, 0),
                            child: Transform.rotate(
                              angle: angle,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/icons/icon_tutorial_hand.svg',
                          width: 72,
                          height: 78,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/icon_tutorial_arrow_next.svg',
                            width: 52,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'tutorial.next'.tr(),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'tutorial.swipe_finger'.tr(),
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

