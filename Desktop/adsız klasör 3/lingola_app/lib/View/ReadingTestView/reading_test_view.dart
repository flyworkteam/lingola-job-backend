import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/word_card.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';

/// Reading Test sayfası — Word Practice ile aynı mavi kart + header + button bar.
class ReadingTestScreen extends StatelessWidget {
  const ReadingTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Reading Test',
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WordCard3D(
                  height: 340,
                  child: WordCardReadingTestBody(
                    word: 'Friend',
                    phonetic: '/frend/',
                    translation: 'Arkadaş, Dost, Yoldaş',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WordCardHintButton(onTap: () {}),
                    const SizedBox(width: 12),
                    _MicButton(onTap: () {}),
                  ],
                ),
                const SizedBox(height: 180),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BackNextButton(
                      label: 'Back',
                      isPrimary: false,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    BackNextButton(
                      label: 'Next',
                      isPrimary: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

/// Reading Test mikrofon butonu — 2 katmanlı gölge efekti (Save Word / Listen ile aynı stil).
class _MicButton extends StatelessWidget {
  const _MicButton({required this.onTap});

  final VoidCallback onTap;

  static const Color _mainColor = Color(0xFF0575E6);
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
              color: _mainColor,
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

