import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Alt navigasyon barı için tek öğe (SVG ikon + etiket).
class AppNavItem {
  const AppNavItem({required this.iconAsset, required this.label});

  /// SVG asset yolu (örn. 'assets/icons/nav_home.svg').
  final String iconAsset;
  final String label;
}

/// Pill style alt navigasyon barı: yuvarlak kapsül içinde sekmeler, seçili olan pill vurgulu.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  /// Sekme listesi (ikon + etiket).
  final List<AppNavItem> items;

  /// Seçili sekme indeksi.
  final int currentIndex;

  /// Sekmeye tıklanınca çağrılır: onTap(index).
  final ValueChanged<int> onTap;

  static const double _pillRadius = 28;
  static const double _itemPillRadius = 20;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(_pillRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                items.length,
                (index) => _NavBarItem(
                  iconAsset: items[index].iconAsset,
                  label: items[index].label,
                  isSelected: currentIndex == index,
                  onTap: () => onTap(index),
                  pillRadius: _itemPillRadius,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.iconAsset,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.pillRadius,
  });

  final String iconAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double pillRadius;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? Colors.white : const Color(0xFFB2B2B2);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label.tr(),
                style: AppTypography.labelLarge.copyWith(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    if (isSelected) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(pillRadius),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0575E6), Color(0xFF021B79)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(pillRadius),
            ),
            child: content,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(pillRadius),
        child: content,
      ),
    );
  }
}
