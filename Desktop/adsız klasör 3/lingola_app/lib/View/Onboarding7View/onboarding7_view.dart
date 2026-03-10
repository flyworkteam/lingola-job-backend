import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/src/config/app_prefs.dart';
import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Onboarding 7. sayfa: Mavi arka plan, animasyonlu progress 0% → 100%
class Onboarding7Screen extends StatefulWidget {
  const Onboarding7Screen({super.key});

  @override
  State<Onboarding7Screen> createState() => _Onboarding7ScreenState();
}

class _Onboarding7ScreenState extends State<Onboarding7Screen>
    with TickerProviderStateMixin {
  static const Color _screenBackground = Color(0xFF0575E6);

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _contentController;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleOffset;
  late Animation<double> _processingOpacity;
  late Animation<Offset> _processingOffset;
  late Animation<double> _centerOpacity;
  late Animation<double> _centerScale;
  late AnimationController _floatController;
  late Animation<double> _float1;
  late Animation<double> _float2;
  late Animation<double> _float3;

  late AnimationController _charController;
  late Animation<double> _char1SlideX;
  late Animation<double> _char1Opacity;
  late Animation<double> _char2SlideX;
  late Animation<double> _char2Opacity;
  late Animation<double> _char3SlideX;
  late Animation<double> _char3Opacity;

  @override
  void initState() {
    super.initState();

    // Progress 55% → 100% in 3.5 seconds
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Content entrance animations – daha uzun ve belirgin (1.2 saniye)
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleOffset = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _processingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
      ),
    );
    _processingOffset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
      ),
    );
    _centerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _centerScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // 3 görsel için sürekli yukarı-aşağı hareket (progress süresince)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _float1 = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _float2 = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _float3 = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Karakterler sırayla sağdan/soldan giriş (sol, sağ, sol)
    _charController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _char1SlideX = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(
        parent: _charController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _char1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _charController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _char2SlideX = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(
        parent: _charController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );
    _char2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _charController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );
    _char3SlideX = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(
        parent: _charController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );
    _char3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _charController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );

    _contentController.forward();
    _progressController.forward();
    _charController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _contentController.dispose();
    _floatController.dispose();
    _charController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl + MediaQuery.paddingOf(context).top,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge([_contentController]),
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SlideTransition(
                        position: _titleOffset,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: Text(
                            'A personalized learning plan\nis being created for you.',
                            style: AppTypography.onboardingTitle.copyWith(
                              fontSize: 24,
                              color: AppColors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxl),
                      SlideTransition(
                        position: _processingOffset,
                        child: FadeTransition(
                          opacity: _processingOpacity,
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              final value = _progressAnimation.value;
                              final percent = (value * 100).round();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Processing',
                                        style: AppTypography.labelLarge
                                            .copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '$percent%',
                                        style: AppTypography.labelLarge
                                            .copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFF021B79),
                                      valueColor: const AlwaysStoppedAnimation<
                                          Color>(AppColors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _centerOpacity,
                    child: ScaleTransition(
                      scale: _centerScale,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              height: constraints.maxHeight,
                              child: AnimatedBuilder(
                          animation: Listenable.merge([_floatController, _charController]),
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 24,
                                  top: 16,
                                  child: FadeTransition(
                                    opacity: _char1Opacity,
                                    child: Transform.translate(
                                      offset: Offset(_char1SlideX.value, _float1.value),
                                      child: Image.asset(
                                        'assets/onboard/OBJECTS.png',
                                        fit: BoxFit.contain,
                                        width: 174,
                                        height: 166,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 200,
                                  top: 120,
                                  child: FadeTransition(
                                    opacity: _char2Opacity,
                                    child: Transform.translate(
                                      offset: Offset(_char2SlideX.value, _float2.value),
                                      child: Image.asset(
                                        'assets/onboard/objects_01.png',
                                        fit: BoxFit.contain,
                                        width: 138,
                                        height: 136,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 40,
                                  top: 120,
                                  bottom: 0,
                                  child: FadeTransition(
                                    opacity: _char3Opacity,
                                    child: Transform.translate(
                                      offset: Offset(_char3SlideX.value, _float3.value),
                                      child: Image.asset(
                                        'assets/onboard/OBJECTS_2.png',
                                        fit: BoxFit.contain,
                                        height: 173,
                                        width: 141,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 168,
                                  top: 42,
                                  child: FadeTransition(
                                    opacity: _char1Opacity,
                                    child: Transform.translate(
                                      offset: Offset(_char1SlideX.value, _float1.value),
                                      child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 154,
                                          height: 34,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.horizontal(
                                              left: Radius.circular(20),
                                              right: Radius.circular(20),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 3,
                                                width: 117,
                                                decoration: BoxDecoration(
                                                  color: AppColors.placeholderBar,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Container(
                                                height: 3,
                                                width: 67,
                                                decoration: BoxDecoration(
                                                  color: AppColors.placeholderBar,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ),
                                ),
                                Positioned(
                                  left: 145,
                                  top: 340,
                                  child: FadeTransition(
                                    opacity: _char3Opacity,
                                    child: Transform.translate(
                                      offset: Offset(_char3SlideX.value, _float3.value),
                                      child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 154,
                                          height: 34,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.horizontal(
                                              left: Radius.circular(20),
                                              right: Radius.circular(20),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/onboard/Frame.svg',
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.contain,
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 3,
                                                    width: 85,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.placeholderBar,
                                                      borderRadius:
                                                          BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                  SizedBox(height: 6),
                                                  Container(
                                                    height: 3,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.placeholderBar,
                                                      borderRadius:
                                                          BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                    ),
                  ),
                );
                },
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
                ),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    final value = _progressAnimation.value;
                    final clampedOpacity = value.clamp(0.5, 1.0);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await AppPrefs.setOnboardingCompleted();
                          if (!context.mounted) return;
                          context.go(AppPaths.home);
                        },
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(
                              alpha: clampedOpacity,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Center(
                            child: Text(
                              'Get Started',
                              style: AppTypography.labelLarge.copyWith(
                                color: _screenBackground,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
    );
  }
}

