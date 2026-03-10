import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lingola_app/src/theme/typography.dart';

/// Ortak ipucu (ampul) butonu — 2 katmanlı gölge efektiyle. Kart içinde kullanılır.
class WordCardHintButton extends StatelessWidget {
  const WordCardHintButton({super.key, required this.onTap});

  final VoidCallback onTap;

  static const Color _shadowLayer = Color(0xFFA8A8A8);
  static const double _layerOffset = 4;
  static const double _radius = 12;
  static const double _btnWidth = 72;
  static const double _btnHeight = 52;

  Widget _buildButtonLayer(Color color) {
    return Container(
      width: _btnWidth,
      height: _btnHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _btnWidth,
      height: _btnHeight + _layerOffset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          Positioned(left: 0, top: _layerOffset, child: _buildButtonLayer(_shadowLayer)),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: _btnWidth,
              height: _btnHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(_radius),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(_radius),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/icon_hint.svg',
                      width: 24,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Colors.black87,
                        BlendMode.srcIn,
                      ),
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

/// Ortak Save Word butonu — 2 katmanlı gölge efektiyle.
class WordCardSaveWordButton extends StatelessWidget {
  const WordCardSaveWordButton({super.key, required this.onTap});

  final VoidCallback onTap;

  static const Color _mainColor = Color(0xFFEE6A5E);
  static const Color _shadowLayer = Color(0xFFD3544B);
  static const double _layerOffset = 4;
  static const double _radius = 10;
  static const double _btnWidth = 139;
  static const double _btnHeight = 44;

  Widget _buildButtonLayer(Color color) {
    return Container(
      width: _btnWidth,
      height: _btnHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _btnWidth,
      height: _btnHeight + _layerOffset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          Positioned(left: 0, top: _layerOffset, child: _buildButtonLayer(_shadowLayer)),
          Positioned(
            left: 0,
            top: 0,
            child: Material(
              color: _mainColor,
              borderRadius: BorderRadius.circular(_radius),
              elevation: 2,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(_radius),
                child: SizedBox(
                  width: _btnWidth,
                  height: _btnHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/icon_heart_save.svg',
                              width: 20,
                              height: 18,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'word_practice.save_word'.tr(),
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
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

/// Ortak Listen butonu — 2 katmanlı gölge efektiyle.
class WordCardListenButton extends StatelessWidget {
  const WordCardListenButton({super.key, required this.onTap});

  final VoidCallback onTap;

  static const Color _shadowLayer = Color(0xFFA8A8A8);
  static const double _layerOffset = 4;
  static const double _radius = 10;
  static const double _btnWidth = 139;
  static const double _btnHeight = 44;

  Widget _buildButtonLayer(Color color) {
    return Container(
      width: _btnWidth,
      height: _btnHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _btnWidth,
      height: _btnHeight + _layerOffset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topLeft,
        children: [
          Positioned(left: 0, top: _layerOffset, child: _buildButtonLayer(_shadowLayer)),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: _btnWidth,
              height: _btnHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(_radius),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(_radius),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volume_up, color: Color(0xFF0575E6), size: 28),
                            const SizedBox(width: 10),
                            Text(
                              'word_practice.listen'.tr(),
                              style: AppTypography.labelLarge.copyWith(
                                color: const Color(0xFF0575E6),
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

/// Ortak Back / Next butonu — Saved Word sayfasındaki gibi 155x46, radius 50.
/// Ok ikonu: icon_arrow_right.svg — Back: siyah, Next: beyaz.
class BackNextButton extends StatelessWidget {
  const BackNextButton({
    super.key,
    required this.label,
    required this.isPrimary,
    required this.onTap,
    this.isBack,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  /// Çeviri kullanıldığında label "Back" olmayacağı için stil için kullanılır.
  final bool? isBack;

  static const Color _blue = Color(0xFF0575E6);
  static const double _width = 155;
  static const double _height = 46;
  static const double _radius = 40;

  static const Color _backBg = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    final back = isBack ?? label == 'Back';
    final arrowColor = back ? Colors.black : Colors.white;
    final textColor = back ? Colors.black : Colors.white;
    final bgColor = back ? _backBg : _blue;

    final arrowWidget = SvgPicture.asset(
      'assets/icons/icon_arrow_back_next.svg',
      width: 20,
      height: 17,
      colorFilter: ColorFilter.mode(arrowColor, BlendMode.srcIn),
      fit: BoxFit.contain,
    );

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: SizedBox(
          width: _width,
          height: _height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (back) ...[
                arrowWidget,
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (!back) ...[
                const SizedBox(width: 10),
                Transform.scale(scaleX: -1, child: arrowWidget),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
