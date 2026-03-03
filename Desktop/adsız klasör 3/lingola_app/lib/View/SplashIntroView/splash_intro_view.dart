import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/app_primary_button.dart';

/// Otomatik kayan onboarding slider: splash1, splash2, splash3 tek ekranda.
/// Belirli aralıklarla sonraki sayfaya geçer; kullanıcı kaydırarak da ilerleyebilir.
class SplashIntroScreen extends StatefulWidget {
  const SplashIntroScreen({super.key});

  @override
  State<SplashIntroScreen> createState() => _SplashIntroScreenState();
}

class _SplashIntroScreenState extends State<SplashIntroScreen> {
  static const int _pageCount = 3;
  static const Duration _autoSlideDuration = Duration(seconds: 4);

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer(_autoSlideDuration, () {
      if (!mounted) return;
      if (_currentPage < _pageCount - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
      _startAutoSlide();
    });
  }

  void _onPageChanged(int index) {
    if (_currentPage == index) return;
    setState(() => _currentPage = index);
    _startAutoSlide();
  }

  void _goToOnboarding() {
    _autoSlideTimer?.cancel();
    context.go(AppPaths.onboarding);
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _IntroSlide(
                currentPage: _currentPage,
                pageCount: _pageCount,
                imageTopPadding: 0,
                imagePath: 'assets/splash/splash1.png',
                titleLines: const [
                  'English is no longer',
                  'difficult when traveling',
                ],
                descriptionLines: const [
                  'Learn the most commonly used words at the',
                  'airport, hotel, restaurant, and for transportation.',
                ],
                isLastPage: false,
                onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                ),
                onGetStarted: _goToOnboarding,
              ),
              _IntroSlide(
                currentPage: _currentPage,
                pageCount: _pageCount,
                imagePath: 'assets/splash/splash2.png',
                titleLines: const [
                  'Real travel',
                  'scenarios',
                ],
                descriptionLines: const [
                  "Practice with words and phrases you'll actually need while traveling.",
                ],
                isLastPage: false,
                onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                ),
                onGetStarted: _goToOnboarding,
              ),
              _IntroSlide(
                currentPage: _currentPage,
                pageCount: _pageCount,
                imagePath: 'assets/splash/splash3.png',
                titleLines: const [
                  'Learn on the go, travel',
                  'comfortably',
                ],
                descriptionLines: const [
                  'Learn English words in just a few minutes, focus',
                  'on your trip.',
                ],
                isLastPage: true,
                onNext: null,
                onGetStarted: _goToOnboarding,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBrand : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({
    required this.currentPage,
    required this.pageCount,
    required this.imagePath,
    required this.titleLines,
    required this.descriptionLines,
    required this.isLastPage,
    required this.onGetStarted,
    this.onNext,
    this.imageTopPadding = 0,
  });

  final int currentPage;
  final int pageCount;
  final String imagePath;
  final double imageTopPadding;
  final List<String> titleLines;
  final List<String> descriptionLines;
  final bool isLastPage;
  final VoidCallback? onNext;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageHeight = size.height * 0.60;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            if (imageTopPadding > 0) SizedBox(height: imageTopPadding),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: SizedBox(
                width: size.width,
                height: imageHeight,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: imageHeight - 50,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.55,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg + 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pageCount,
                        (index) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm / 2),
                          child: _PageDot(active: index == currentPage),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    ...titleLines.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: AppTitle(
                            line,
                            style: AppTypography.onboardingTitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    ...descriptionLines.map(
                      (line) => SizedBox(
                        width: double.infinity,
                        child: AppBody(
                          line,
                          style: AppTypography.onboardingDescription,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl + 48),
                    if (isLastPage)
                      AppPrimaryButton(
                        label: 'Get Started',
                        onPressed: onGetStarted,
                        borderRadius: 10,
                      )
                    else
                      AppPrimaryButton(
                        label: 'Get Started',
                        onPressed: onNext ?? () {},
                        borderRadius: 10,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

