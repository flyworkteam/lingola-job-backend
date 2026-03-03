import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/View/Onboarding3View/onboarding3_view.dart';
import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/navigation/route_transitions.dart';
import 'package:lingola_app/src/state/onboarding_state.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Onboarding 4. sayfa: "Which language would you like to learn?"
class Onboarding4Screen extends StatefulWidget {
  const Onboarding4Screen({super.key});

  @override
  State<Onboarding4Screen> createState() => _Onboarding4ScreenState();
}

class _Onboarding4ScreenState extends State<Onboarding4Screen> {
  String? _selectedLanguage;

  static const _languages = [
    _Language(id: 'english', title: 'English', flagAsset: 'assets/bayrak/flag_english.svg'),
    _Language(id: 'german', title: 'German', flagAsset: 'assets/bayrak/flag_german.svg'),
    _Language(id: 'italian', title: 'Italian', flagAsset: 'assets/bayrak/flag_italian.svg'),
    _Language(id: 'french', title: 'French', flagAsset: 'assets/bayrak/flag_french.svg'),
    _Language(id: 'japanese', title: 'Japanese', flagAsset: 'assets/bayrak/flag_japanese.svg'),
    _Language(id: 'spanish', title: 'Spanish', flagAsset: 'assets/bayrak/Spain.png'),
    _Language(id: 'russian', title: 'Russian', flagAsset: 'assets/bayrak/flag_russian.svg'),
    _Language(id: 'turkish', title: 'Turkish', flagAsset: 'assets/bayrak/flag_turkish.svg'),
    _Language(id: 'korean', title: 'Korean', flagAsset: 'assets/bayrak/flag_korean.svg'),
    _Language(id: 'hindi', title: 'Hindi', flagAsset: 'assets/bayrak/flag_hindi.svg'),
    _Language(id: 'portuguese', title: 'Portuguese', flagAsset: 'assets/bayrak/flag_portuguese.svg'),
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
                  AppSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProgressIndicator(2),
                    SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Which language would\nyou like to learn?',
                      style: AppTypography.onboardingTitle.copyWith(
                        fontSize: 28,
                        color: AppColors.onboardingText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    ..._languages.map((lang) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: _LanguageCard(
                        language: lang,
                        isSelected: _selectedLanguage == lang.id,
                        onTap: () => setState(() => _selectedLanguage = lang.id),
                      ),
                    )),
                    SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => pushReplacementWithBackAnimation(
                              context,
                              const Onboarding3Screen(),
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
                            opacity: _selectedLanguage != null ? 1.0 : 0.5,
                            child: IgnorePointer(
                              ignoring: _selectedLanguage == null,
                              child: Material(
                                color: AppColors.primaryBrand,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  onTap: _selectedLanguage != null
                                      ? () {
                                          OnboardingState.selectedLanguageId = _selectedLanguage;
                                          context.go(AppPaths.onboarding5);
                                        }
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
                  ],
                ),
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

class _Language {
  const _Language({
    required this.id,
    required this.title,
    this.flagAsset,
  });
  final String id;
  final String title;
  final String? flagAsset;
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final _Language language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
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
          children: [
            SizedBox(
              width: 40,
              height: 30,
              child: language.flagAsset != null
                  ? language.flagAsset!.toLowerCase().endsWith('.png')
                      ? Image.asset(
                          language.flagAsset!,
                          width: 40,
                          height: 30,
                          fit: BoxFit.contain,
                        )
                      : SvgPicture.asset(
                          language.flagAsset!,
                          width: 40,
                          height: 30,
                          fit: BoxFit.contain,
                        )
                  : const SizedBox(),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                language.title,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.onboardingText,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

