import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/View/Onboarding5View/onboarding5_view.dart';
import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/navigation/route_transitions.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Onboarding 6. sayfa: "Set Your Daily Goal"
class Onboarding6Screen extends StatefulWidget {
  const Onboarding6Screen({super.key});

  @override
  State<Onboarding6Screen> createState() => _Onboarding6ScreenState();
}

class _Onboarding6ScreenState extends State<Onboarding6Screen> {
  String? _selectedGoal;

  static const _goals = [
    _Goal(id: 'casual', title: 'Casual', subtitle: '5 Min / day'),
    _Goal(id: 'steady', title: 'Steady', subtitle: '15 Min / day'),
    _Goal(id: 'serious', title: 'Serious', subtitle: '30 Min / day'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl + MediaQuery.paddingOf(context).top,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProgressIndicator(4),
                    SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Set Your Daily Goal',
                      style: AppTypography.onboardingTitle.copyWith(
                        fontSize: 28,
                        color: AppColors.onboardingText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Choose a pace that fits your schedule',
                      style: AppTypography.body.copyWith(
                        fontSize: 16,
                        color: AppColors.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    ..._goals.map((goal) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: _GoalCard(
                            goal: goal,
                            isSelected: _selectedGoal == goal.id,
                            onTap: () =>
                                setState(() => _selectedGoal = goal.id),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => pushReplacementWithBackAnimation(
                        context,
                        const Onboarding5Screen(),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        foregroundColor: AppColors.onSurface,
                        side: BorderSide(color: AppColors.surfaceVariant),
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                    child: Opacity(
                      opacity: _selectedGoal != null ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: _selectedGoal == null,
                        child: Material(
                          color: AppColors.primaryBrand,
                          borderRadius: BorderRadius.circular(50),
                          child: InkWell(
                            onTap: _selectedGoal != null
                                ? () => context.go(AppPaths.onboarding7)
                                : null,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              alignment: Alignment.center,
                              child: Text(
                                'Next',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.onPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
            ),
          ],
        ),
    );
  }

  Widget _buildProgressIndicator(int activeIndex) {
    return Row(
      children: List.generate(5, (index) {
        final isActive = index <= activeIndex;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 4 ? AppSpacing.xs : 0),
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryBrand : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _Goal {
  const _Goal({
    required this.id,
    required this.title,
    required this.subtitle,
  });
  final String id;
  final String title;
  final String subtitle;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  final _Goal goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrand : AppColors.surfaceVariant,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: SizedBox(
                width: 44,
                height: 44,
                child: goal.id == 'casual'
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/seviye/rectangle_165.svg',
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                          SvgPicture.asset(
                            'assets/seviye/vector_11.svg',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ],
                      )
                    : goal.id == 'steady'
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/seviye/rectangle_165.svg',
                                width: 44,
                                height: 44,
                                fit: BoxFit.contain,
                              ),
                              SvgPicture.asset(
                                'assets/seviye/time_fast.svg',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            ],
                          )
                        : goal.id == 'serious'
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/seviye/rectangle_165.svg',
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.contain,
                                  ),
                                  SvgPicture.asset(
                                    'assets/seviye/vector_12.svg',
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              )
                            : SvgPicture.asset(
                                'assets/seviye/rectangle_165.svg',
                                width: 44,
                                height: 44,
                                fit: BoxFit.contain,
                              ),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? AppColors.primaryBrand : AppColors.onboardingText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    goal.subtitle,
                    style: AppTypography.body.copyWith(
                      color: isSelected ? AppColors.primaryBrand : AppColors.onboardingText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

