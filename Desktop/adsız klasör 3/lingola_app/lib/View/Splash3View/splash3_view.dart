import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/app_primary_button.dart';

/// Splash 3: üstte görsel (splash3), altta sabit beyaz kart.
class Splash3Screen extends StatelessWidget {
  const Splash3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: SizedBox(
                  width: 447,
                  height: 503,
                  child: Image.asset(
                    'assets/splash/splash3.png',
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
            top: 460,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
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
                        children: [
                          _PageDot(active: false),
                          SizedBox(width: AppSpacing.sm),
                          _PageDot(active: false),
                          SizedBox(width: AppSpacing.sm),
                          _PageDot(active: true),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: AppTitle(
                          'Learn on the go, travel',
                          style: AppTypography.onboardingTitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AppTitle(
                          'comfortably',
                          style: AppTypography.onboardingTitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: AppBody(
                          'Learn English words in just a few minutes, focus',
                          style: AppTypography.onboardingDescription,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AppBody(
                          'on your trip.',
                          style: AppTypography.onboardingDescription,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxl + 56),
                      AppPrimaryButton(
                        label: 'Get Started',
                        borderRadius: 10,
                        onPressed: () => context.go(AppPaths.onboarding),
                      ),
                    ],
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

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryBrand : AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
    );
  }
}

