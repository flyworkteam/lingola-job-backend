import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_app/Models/word_item.dart';
import 'package:lingola_app/Services/word_services.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';

/// Ortak 3D mavi kelime kartı boyutları ve renkleri.
abstract final class WordCardTheme {
  WordCardTheme._();

  static const Color cardBlue = Color(0xFF0575E6);
  static const Color cardBlueLayer1 = Color(0xFF3D8FEA);
  static const Color cardBlueLayer2 = Color(0xFF7BAEF2);
  /// Kart metinleri (çeviri, okunuş, örnek cümle) — font/renk değiştirilmesin.
  static const Color cardTextWhite = Color(0xFFFFFFFF);
  static const double width = 330;
  static const double height = 421;
  static const double radius = 30;
  static const double layerOffset = 10;
}

/// Kelime kartı veri modeli — Word Practice, Saved Word, Frequently Used Terms için ortak.
class WordCardData {
  const WordCardData({
    required this.word,
    required this.phonetic,
    required this.translations,
    required this.exampleEn,
    required this.exampleTr,
  });

  final String word;
  final String phonetic;
  final String translations;
  final String exampleEn;
  final String exampleTr;

  factory WordCardData.fromSavedWordItem(dynamic item) {
    return WordCardData(
      word: item.word,
      phonetic: item.phonetic,
      translations: item.translations,
      exampleEn: item.exampleEn,
      exampleTr: item.exampleTr,
    );
  }

  /// Mesleki kelime map'i (word, translation, example, example_translation) → kart için.
  factory WordCardData.fromProfessionalWord(Map<String, dynamic> m) {
    return WordCardData(
      word: (m['word'] as String?)?.trim() ?? '',
      phonetic: (m['phonetic'] as String?)?.trim() ?? '',
      translations: (m['translation'] as String?)?.trim() ?? '',
      exampleEn: (m['example'] as String?)?.trim() ?? '',
      exampleTr: (m['example_translation'] as String?)?.trim() ?? '',
    );
  }

  /// Backend [WordItem] (word, translation, phonetic?, exampleEn?, exampleTr?) → kart için.
  factory WordCardData.fromWordItem(WordItem item) {
    String exampleEn = item.exampleEn?.trim() ?? '';
    String exampleTr = item.exampleTr?.trim() ?? '';
    if (exampleEn.isEmpty && exampleTr.isEmpty) {
      final w = item.word.trim().toLowerCase();
      final fallback = _fallbackExamples[w];
      if (fallback != null) {
        exampleEn = fallback.$1;
        exampleTr = fallback.$2;
      }
    }
    return WordCardData(
      word: item.word,
      phonetic: item.phonetic ?? '',
      translations: item.translation,
      exampleEn: exampleEn,
      exampleTr: exampleTr,
    );
  }

  static const Map<String, (String, String)> _fallbackExamples = {
    'the': ('The book is on the table.', 'Kitap masanın üzerinde.'),
    'of': ('The capital of Turkey is Ankara.', 'Türkiye\'nin başkenti Ankara\'dır.'),
    'and': ('I like tea and coffee.', 'Çay ve kahve severim.'),
    'to': ('I want to learn English.', 'İngilizce öğrenmek istiyorum.'),
    'in': ('She lives in Istanbul.', 'İstanbul\'da yaşıyor.'),
    'is': ('This is my book.', 'Bu benim kitabım.'),
    'that': ('That is a good idea.', 'Bu iyi bir fikir.'),
    'for': ('This gift is for you.', 'Bu hediye senin için.'),
    'it': ('It is raining today.', 'Bugün yağmur yağıyor.'),
    'with': ('I went there with my friend.', 'Oraya arkadaşımla gittim.'),
    'on': ('The keys are on the desk.', 'Anahtarlar masanın üzerinde.'),
    'be': ('I want to be a teacher.', 'Öğretmen olmak istiyorum.'),
    'have': ('I have two brothers.', 'İki erkek kardeşim var.'),
    'this': ('This is my first time here.', 'Burada ilk kez bulunuyorum.'),
    'from': ('I am from Turkey.', 'Türkiye\'den geliyorum.'),
    'time': ('What time is it?', 'Saat kaç?'),
    'water': ('Please give me a glass of water.', 'Lütfen bana bir bardak su verin.'),
    'call': ('I will call you tomorrow.', 'Yarın seni arayacağım.'),
    'day': ('Have a nice day!', 'İyi günler!'),
    'make': ('She can make a cake.', 'Pasta yapabilir.'),
    'go': ('Let\'s go to the cinema.', 'Sinemaya gidelim.'),
    'see': ('I see a bird in the sky.', 'Gökyüzünde bir kuş görüyorum.'),
    'number': ('What is your phone number?', 'Telefon numaranız nedir?'),
    'way': ('Which way is the station?', 'İstasyon hangi yönde?'),
    'find': ('I cannot find my keys.', 'Anahtarlarımı bulamıyorum.'),
    'long': ('How long does it take?', 'Ne kadar sürer?'),
    'first': ('This is my first visit.', 'Bu benim ilk ziyaretim.'),
    'electronic': ('I bought an electronic device.', 'Elektronik bir cihaz aldım.'),
    'word': ('Learn a new word every day.', 'Her gün yeni bir kelime öğren.'),
    'learn': ('I want to learn German.', 'Almanca öğrenmek istiyorum.'),
    'practice': ('Practice makes perfect.', 'Alıştırma mükemmelleştirir.'),
    'hello': ('Hello, how are you?', 'Merhaba, nasılsın?'),
    'good': ('That sounds good.', 'Kulağa iyi geliyor.'),
    'book': ('I am reading a book.', 'Bir kitap okuyorum.'),
    'school': ('She goes to school by bus.', 'Okula otobüsle gidiyor.'),
    'work': ('I work from home.', 'Evden çalışıyorum.'),
    'home': ('I am at home now.', 'Şimdi evdeyim.'),
    'english': ('English is a global language.', 'İngilizce küresel bir dildir.'),
    'language': ('She speaks three languages.', 'Üç dil konuşuyor.'),
    'carefully': ('Listen carefully.', 'Dikkatlice dinle.'),
  };
}

/// 3D katmanlı mavi kart stack — tüm kelime kartları için ortak.
class WordCard3D extends StatelessWidget {
  const WordCard3D({
    super.key,
    required this.child,
    this.width = WordCardTheme.width,
    this.height = WordCardTheme.height,
    this.layerOffset = WordCardTheme.layerOffset,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.childKey,
    this.lastSwipeDirection = 1,
  });

  final Widget child;
  final double width;
  final double height;
  final double layerOffset;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final Key? childKey;
  /// 1: next (sağa), -1: prev (sola) — AnimatedSwitcher kayma yönü için.
  final int lastSwipeDirection;

  @override
  Widget build(BuildContext context) {
    final mainCard = _buildMainCard();
    return SizedBox(
      width: width,
      height: height + layerOffset * 2,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            top: layerOffset * 2,
            child: _buildBackLayer(WordCardTheme.cardBlueLayer2),
          ),
          Positioned(
            left: 0,
            top: layerOffset,
            child: _buildBackLayer(WordCardTheme.cardBlueLayer1),
          ),
          Positioned(left: 0, top: 0, child: mainCard),
        ],
      ),
    );
  }

  Widget _buildBackLayer(Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(WordCardTheme.radius),
      ),
    );
  }

  Widget _buildMainCard() {
    const minSwipeVelocity = 250.0;
    final hasSwipe = onSwipeLeft != null || onSwipeRight != null;
    final useAnimatedSwitcher = childKey != null;

    Widget content = Container(
      key: childKey,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: WordCardTheme.cardBlue,
        borderRadius: BorderRadius.circular(WordCardTheme.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WordCardTheme.radius),
        child: child,
      ),
    );

    if (useAnimatedSwitcher) {
      final beginOffset = lastSwipeDirection == 1 ? const Offset(0.18, 0) : const Offset(-0.18, 0);
      content = AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(animation);
          return ClipRRect(
            borderRadius: BorderRadius.circular(WordCardTheme.radius),
            child: SlideTransition(
              position: slide,
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
        child: content,
      );
    }

    if (hasSwipe) {
      content = GestureDetector(
        onHorizontalDragEnd: (details) {
          final dx = details.velocity.pixelsPerSecond.dx;
          if (dx.abs() < minSwipeVelocity) return;
          if (dx > 0) {
            onSwipeRight?.call();
          } else {
            onSwipeLeft?.call();
          }
        },
        child: content,
      );
    }

    return content;
  }
}

/// İlk harfi büyük yapar (kart metinleri için).
String _capitalizeFirst(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

/// Kelime kartı standart içerik — word, phonetic, translations, quote, examples, hint, Save/Listen.
class WordCardBody extends StatelessWidget {
  const WordCardBody({
    super.key,
    required this.data,
    this.showHint = true,
    this.showSaveWord = true,
    this.savedWordStyle = false,
    this.onHint,
    this.onSaveWord,
    this.onListen,
  });

  final WordCardData data;
  final bool showHint;
  final bool showSaveWord;
  /// Saved Word sayfası tipografi: word Quicksand 700/40, phonetic Nunito Sans 400, çeviri Quicksand 600.
  final bool savedWordStyle;
  final VoidCallback? onHint;
  final VoidCallback? onSaveWord;
  final VoidCallback? onListen;

  @override
  Widget build(BuildContext context) {
    // "Tebrikler" kartında alttaki çeviri seçilen uygulama dilinde gösterilir
    final String translationText = data.word.trim().toLowerCase() == 'tebrikler'
        ? 'word_practice.card_tebrikler'.tr()
        : (data.translations.trim().isEmpty ? '—' : data.translations);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHint)
            Align(
              alignment: Alignment.topRight,
              child: WordCardHintButton(onTap: onHint ?? () {}),
            ),
          if (showHint) const SizedBox(height: 8),
          Text(
            _capitalizeFirst(data.word),
            textAlign: TextAlign.center,
            style: savedWordStyle
                ? GoogleFonts.quicksand(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    color: WordCardTheme.cardTextWhite,
                  )
                : GoogleFonts.quicksand(
                    color: WordCardTheme.cardTextWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            WordService.ipaToPlain(data.phonetic),
            textAlign: TextAlign.center,
            style: savedWordStyle
                ? GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    color: WordCardTheme.cardTextWhite,
                    fontSize: 15,
                  )
                : GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    color: WordCardTheme.cardTextWhite,
                    fontSize: 14,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            _capitalizeFirst(translationText),
            textAlign: TextAlign.center,
            style: savedWordStyle
                ? GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    color: WordCardTheme.cardTextWhite,
                    fontSize: 16,
                  )
                : GoogleFonts.quicksand(
                    color: WordCardTheme.cardTextWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '\u201C',
              style: GoogleFonts.quicksand(
                color: WordCardTheme.cardTextWhite,
                fontSize: 48,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.exampleEn.trim().isEmpty
                ? '—'
                : '\u201C${_capitalizeFirst(data.exampleEn)}\u201D',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: WordCardTheme.cardTextWhite,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.exampleTr.trim().isEmpty
                ? '—'
                : _capitalizeFirst(data.exampleTr),
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w400,
              color: WordCardTheme.cardTextWhite,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showSaveWord) ...[
                WordCardSaveWordButton(onTap: onSaveWord ?? () {}),
                const SizedBox(width: 12),
              ],
              WordCardListenButton(onTap: onListen ?? () {}),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reading Test için özel kart içeriği — kelime, okunuş, bayrak çizgisi, çeviri.
class WordCardReadingTestBody extends StatelessWidget {
  const WordCardReadingTestBody({
    super.key,
    required this.word,
    required this.phonetic,
    required this.translation,
  });

  final String word;
  final String phonetic;
  final String translation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Friend + phonetic — üstten sabit
          Text(
            word,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: const Color(0xFFFFFFFF),
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            WordService.ipaToPlain(phonetic),
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w400,
              color: WordCardTheme.cardTextWhite,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 45),
          // Bayrak + çizgiler — sadece yukarıdaki boşluk değişince hareket eder
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SvgPicture.asset(
                  'assets/bayrak/flag_turkish.svg',
                  width: 32,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Çeviri — sadece yukarıdaki boşluk değişince hareket eder
          Text(
            translation,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
