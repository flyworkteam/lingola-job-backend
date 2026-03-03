import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/widgets/app_bottom_nav_bar.dart';
import 'package:lingola_app/src/widgets/word_card.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Most Frequently Used Terms sayfası — header + overlay + button bar.
class MostFrequentlyUsedTermsScreen extends StatefulWidget {
  const MostFrequentlyUsedTermsScreen({super.key});

  @override
  State<MostFrequentlyUsedTermsScreen> createState() => _MostFrequentlyUsedTermsScreenState();
}

class _MostFrequentlyUsedTermsScreenState extends State<MostFrequentlyUsedTermsScreen> {
  OverlayEntry? _tutorialOverlay;

  static const _deadlineCard = WordCardData(
    word: 'Deadline',
    phonetic: '/dedlayn/',
    translations: 'Son Teslim Tarihi',
    exampleEn: 'Bir işin bitirilmesi gereken en son zaman.',
    exampleTr: 'Bir işin bitirilmesi gereken en son zaman.',
  );
  int _navIndex = 0; // Home'dan geldiği için 0 (veya Learn'de gösterilebilir)

  static const List<AppNavItem> _navItems = [
    AppNavItem(iconAsset: 'assets/icons/nav_home.svg', label: 'Home'),
    AppNavItem(iconAsset: 'assets/icons/nav_learn.svg', label: 'Learn'),
    AppNavItem(iconAsset: 'assets/icons/nav_library.svg', label: 'Library'),
    AppNavItem(iconAsset: 'assets/icons/nav_profil.svg', label: 'Profile'),
  ];

  void _onNavTap(int index) {
    context.go(AppPaths.home, extra: HomeRouteArgs(initialIndex: index));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _insertTutorialOverlay());
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
    Overlay.of(context, rootOverlay: true).insert(entry);
    _tutorialOverlay = entry;
  }

  void _removeTutorialOverlay() {
    _tutorialOverlay?.remove();
    _tutorialOverlay = null;
  }

  static const double _headerExpandedHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: _headerExpandedHeight,
                  pinned: false,
                  floating: false,
                  stretch: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: const Color(0xFFF2F5FC),
                  surfaceTintColor: Colors.transparent,
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
                    'Frequently Used Terms',
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  centerTitle: false,
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                    child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 120),
                    child: Center(
                      child: WordCard3D(
                        child: WordCardBody(
                          data: _deadlineCard,
                          onSaveWord: () {},
                          onListen: () {},
                          onHint: () {},
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavBar(
              items: _navItems,
              currentIndex: _navIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }

}

/// Word Practice ile aynı overlay — Swipe Finger tutorial. Tıklanınca kapanır.
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

    // 180° (sol) -> 0° (sağ) arasında sağa-sola hareket
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
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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


