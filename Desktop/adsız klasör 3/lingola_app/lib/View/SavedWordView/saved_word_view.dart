import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  int _currentIndex = 0;
  int _lastSwipeDirection = 1;
  FlutterTts? _flutterTts;
  bool _ttsInitialized = false;

  List<SavedWordItem> _cards(WidgetRef ref) {
    return ref.watch(savedWordsProvider).items;
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

  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    _flutterTts ??= FlutterTts();
    await _flutterTts!.awaitSpeakCompletion(true);
    if (Platform.isIOS) {
      try {
        await _flutterTts!.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      } on MissingPluginException catch (_) {} on Exception catch (_) {}
    }
    _flutterTts!.setErrorHandler((msg) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Ses hatası: $msg'), behavior: SnackBarBehavior.floating),
        );
      }
    });
    _ttsInitialized = true;
  }

  Future<void> _speakWord(String word) async {
    if (word.trim().isEmpty) return;
    await _initTts();
    if (_flutterTts == null) return;
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setSpeechRate(0.5);
    try {
      await _flutterTts!.setLanguage('en-US');
    } catch (_) {
      try {
        await _flutterTts!.setLanguage('en');
      } catch (_) {}
    }
    await _flutterTts!.speak(word.trim());
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cards(ref);
    if (cards.isEmpty) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) _handleBack();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF2F5FC),
          appBar: _buildAppBar(context),
          body: _buildEmptyState(context),
        ),
      );
    }
    if (_currentIndex >= cards.length) {
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
                      onListen: () => _speakWord(currentCard.word),
                      onHint: () {},
                    ),
                  ),
                  const SizedBox(height: 180),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BackNextButton(
                        label: 'common.back'.tr(),
                        isPrimary: false,
                        onTap: () => _goPrev(cards),
                        isBack: true,
                      ),
                      const SizedBox(width: 16),
                      BackNextButton(
                        label: 'common.next'.tr(),
                        isPrimary: true,
                        onTap: () => _goNext(cards),
                        isBack: false,
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
        'saved_word.title'.tr(),
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
            'saved_word.empty_title'.tr(),
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'saved_word.empty_subtitle'.tr(),
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

