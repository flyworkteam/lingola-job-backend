import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_app/Models/saved_word_item.dart';
import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/src/state/saved_words_store.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/word_card.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';

/// Saved Word sayfası — Word Practice ile aynı kart ve önizleme.
/// Kayıtlı kelimeler [savedWordsProvider] ile reaktif; liste değişince UI güncellenir.
/// [returnToHomeOnPop]: Anasayfadan girildiyse true; çıkışta anasayfaya dönmek için kullanılır.
class SavedWordScreen extends ConsumerStatefulWidget {
  const SavedWordScreen({
    super.key,
    this.savedWordsCount = 0,
    this.returnToHomeOnPop = false,
  });

  final int savedWordsCount;
  final bool returnToHomeOnPop;

  @override
  ConsumerState<SavedWordScreen> createState() => _SavedWordScreenState();
}

class _SavedWordScreenState extends ConsumerState<SavedWordScreen> {
  static const List<SavedWordItem> _placeholderWords = [
    SavedWordItem(
      word: 'Friend',
      phonetic: '/frend/',
      translations: 'Arkadaş, Dost, Yoldaş',
      exampleEn: '\u201CA good friend is hard to find.\u201D',
      exampleTr: 'İyi bir arkadaş bulmak zordur.',
    ),
    SavedWordItem(
      word: 'Journey',
      phonetic: '/ˈdʒɜː.ni/',
      translations: 'Yolculuk, Seyahat',
      exampleEn: '\u201CThe journey was longer than we expected.\u201D',
      exampleTr: 'Yolculuk beklediğimizden daha uzundu.',
    ),
    SavedWordItem(
      word: 'Improve',
      phonetic: '/ɪmˈpruːv/',
      translations: 'Geliştirmek, İyileştirmek',
      exampleEn: '\u201CPractice every day to improve your skills.\u201D',
      exampleTr: 'Becerilerini geliştirmek için her gün pratik yap.',
    ),
  ];

  int _currentIndex = 0;
  int _lastSwipeDirection = 1;

  /// Provider'dan liste; reaktif olduğu için liste değişince build yeniden çalışır.
  List<SavedWordItem> _cards(WidgetRef ref) {
    final items = ref.watch(savedWordsProvider).items;
    if (items.isNotEmpty) return items;
    return _placeholderWords;
  }

  void _goNext(List<SavedWordItem> cards) {
    if (cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = 1;
      _currentIndex = (_currentIndex + 1) % cards.length;
    });
  }

  void _goPrev(List<SavedWordItem> cards) {
    if (cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = -1;
      _currentIndex = (_currentIndex - 1) < 0 ? cards.length - 1 : _currentIndex - 1;
    });
  }

  void _handleBack() {
    Navigator.of(context).pop(widget.returnToHomeOnPop);
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cards(ref);
    if (cards.isNotEmpty && _currentIndex >= cards.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = cards.length - 1);
      });
    }
    final index = _currentIndex.clamp(0, cards.length - 1);
    final currentCard = cards[index];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FC),
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WordCard3D(
                    onSwipeLeft: () => _goPrev(cards),
                    onSwipeRight: () => _goNext(cards),
                    childKey: ValueKey<int>(_currentIndex),
                    lastSwipeDirection: _lastSwipeDirection,
                    child: WordCardBody(
                      data: WordCardData.fromSavedWordItem(currentCard),
                      showSaveWord: false,
                      savedWordStyle: true,
                      onListen: () {},
                      onHint: () {},
                    ),
                  ),
                  const SizedBox(height: 180),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BackNextButton(
                        label: 'Back',
                        isPrimary: false,
                        onTap: () => _goPrev(cards),
                      ),
                      const SizedBox(width: 16),
                      BackNextButton(
                        label: 'Next',
                        isPrimary: true,
                        onTap: () => _goNext(cards),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        onPressed: _handleBack,
      ),
      titleSpacing: 4,
      title: Text(
        'Saved Word',
        style: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/frame_saved_words.svg',
            width: 80,
            height: 80,
            colorFilter: const ColorFilter.mode(Color(0xFF0575E6), BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No saved words yet',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save words from Word Practice\nto review them here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

}

