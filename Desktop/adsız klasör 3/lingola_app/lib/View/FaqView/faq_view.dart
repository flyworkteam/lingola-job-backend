import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Sıkça sorulan sorular sayfası — Profil > F.A.Q. ile açılır.
/// Soru ve cevap ayrı kartlarda: soru kartına tıklanınca altında cevap kartı açılır.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;

  static const List<_FaqItem> _items = [
    _FaqItem(questionKey: 'faq.q1', answerKey: 'faq.a1'),
    _FaqItem(questionKey: 'faq.q2', answerKey: 'faq.a2'),
    _FaqItem(questionKey: 'faq.q3', answerKey: 'faq.a3'),
    _FaqItem(questionKey: 'faq.q4', answerKey: 'faq.a4'),
    _FaqItem(questionKey: 'faq.q5', answerKey: 'faq.a5'),
    _FaqItem(questionKey: 'faq.q6', answerKey: 'faq.a6'),
    _FaqItem(questionKey: 'faq.q7', answerKey: 'faq.a7'),
    _FaqItem(questionKey: 'faq.q8', answerKey: 'faq.a8'),
    _FaqItem(questionKey: 'faq.q9', answerKey: 'faq.a9'),
    _FaqItem(questionKey: 'faq.q10', answerKey: 'faq.a10'),
  ];

  static const double _headerExpandedHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: CustomScrollView(
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
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF000000),
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            titleSpacing: 4,
            title: Text(
              context.tr('faq.title'),
              style: AppTypography.titleLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            centerTitle: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FaqQuestionCard(
                        question: context.tr(_items[i].questionKey),
                        isExpanded: _expandedIndex == i,
                        onTap: () => setState(() {
                          _expandedIndex = _expandedIndex == i ? null : i;
                        }),
                      ),
                      if (_expandedIndex == i) _FaqAnswerCard(answer: context.tr(_items[i].answerKey)),
                      if (_expandedIndex == i) const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
                childCount: _items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.questionKey, required this.answerKey});
  final String questionKey;
  final String answerKey;
}

/// Soru kartı — tıklanınca açılır/kapanır, sağda chevron.
class _FaqQuestionCard extends StatelessWidget {
  const _FaqQuestionCard({
    required this.question,
    required this.isExpanded,
    required this.onTap,
  });

  final String question;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 24,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cevap kartı — soru açıldığında altında ayrı beyaz kart.
class _FaqAnswerCard extends StatelessWidget {
  const _FaqAnswerCard({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        child: Text(
          answer,
          style: AppTypography.body.copyWith(
            color: const Color(0xFF000000),
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

