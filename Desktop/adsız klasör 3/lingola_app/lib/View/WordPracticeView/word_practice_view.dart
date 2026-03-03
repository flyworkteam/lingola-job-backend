import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/Models/saved_word_item.dart';
import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/src/state/saved_words_store.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/word_card.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';

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

  static const List<WordCardData> _cards = [
    WordCardData(
      word: 'Friend',
      phonetic: '/frend/',
      translations: 'Arkadaş, Dost, Yoldaş',
      exampleEn: '“A good friend is hard to find.”',
      exampleTr: 'İyi bir arkadaş bulmak zordur.',
    ),
    WordCardData(
      word: 'Journey',
      phonetic: '/ˈdʒɜː.ni/',
      translations: 'Yolculuk, Seyahat',
      exampleEn: '\u201CThe journey was longer than we expected.\u201D',
      exampleTr: 'Yolculuk beklediğimizden daha uzundu.',
    ),
    WordCardData(
      word: 'Improve',
      phonetic: '/ɪmˈpruːv/',
      translations: 'Geliştirmek, İyileştirmek',
      exampleEn: '\u201CPractice every day to improve your skills.\u201D',
      exampleTr: 'Becerilerini geliştirmek için her gün pratik yap.',
    ),
  ];

  int _currentCardIndex = 0;
  int _lastSwipeDirection = 1; // 1: next, -1: prev

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertTutorialOverlay();
      _reportTrackAccess();
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
    super.dispose();
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
    if (_cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = 1;
      _currentCardIndex = (_currentCardIndex + 1) % _cards.length;
    });
  }

  void _goPrevCard() {
    if (_cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = -1;
      _currentCardIndex = (_currentCardIndex - 1) < 0 ? (_cards.length - 1) : (_currentCardIndex - 1);
    });
  }

  WordCardData get _currentCard => _cards[_currentCardIndex];

  void _handleBack() {
    Navigator.of(context).pop(widget.returnToHomeOnPop);
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
          'Word Practice',
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
            child: WordCard3D(
              onSwipeLeft: _goPrevCard,
              onSwipeRight: _goNextCard,
              childKey: ValueKey<int>(_currentCardIndex),
              lastSwipeDirection: _lastSwipeDirection,
              child: WordCardBody(
                data: _currentCard,
                onSaveWord: () async {
                  final card = _currentCard;
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
                    const SnackBar(
                      content: Text('Kaydedildi'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onListen: () {},
                onHint: () {},
              ),
            ),
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
                            'Previous',
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
                            'Next',
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
                  'Swipe Finger',
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

