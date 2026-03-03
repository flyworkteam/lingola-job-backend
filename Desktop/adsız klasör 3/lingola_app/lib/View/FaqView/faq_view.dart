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
    _FaqItem(
      question: 'Lingola Job nedir?',
      answer: 'Lingola Job, mesleki dil becerilerini geliştirmek isteyenler için tasarlanmış bir dil öğrenme uygulamasıdır.',
    ),
    _FaqItem(
      question: 'Joblingo genel dil mi öğretir?',
      answer: 'Hayır. Lingola Job, günlük sohbetten çok iş hayatında kullanılan kelime ve ifadeleri öğretir.',
    ),
    _FaqItem(
      question: 'Hangi meslekler için uygundur?',
      answer: 'IT, pazarlama, finans, sağlık, insan kaynakları ve daha birçok sektör için içerikler sunar.',
    ),
    _FaqItem(
      question: 'Dil seviyemi bilmiyorsam ne yapmalıyım?',
      answer: 'Uygulama içindeki seviye belirleme ile seviyen otomatik olarak tespit edilir.',
    ),
    _FaqItem(
      question: 'Yeni başlayanlar Lingola Job kullanabilir mi?',
      answer: 'Evet. A1 seviyesinden itibaren herkes için uygun içerikler bulunmaktadır.',
    ),
    _FaqItem(
      question: 'İçerikler nasıl hazırlanıyor?',
      answer: 'İçerikler, gerçek iş senaryoları ve mesleki kullanım örnekleri temel alınarak hazırlanır.',
    ),
    _FaqItem(
      question: 'Sadece kelime mi öğretiyor?',
      answer: 'Hayır. Kelimelerin yanı sıra cümle yapıları, diyaloglar ve kullanım örnekleri de sunulur.',
    ),
    _FaqItem(
      question: 'Günlük ne kadar zaman ayırmam gerekir?',
      answer: 'Günde 10–15 dakika düzenli kullanım için yeterlidir.',
    ),
    _FaqItem(
      question: 'Öğrendiklerimi gerçekten iş hayatında kullanabilir miyim?',
      answer: 'Evet. İçerikler doğrudan toplantı, e-posta ve iş iletişimine uyarlanmıştır.',
    ),
    _FaqItem(
      question: 'Lingola Job ücretsiz mi?',
      answer: 'Uygulama ücretsiz olarak kullanılabilir, gelişmiş içerikler için premium seçenekler sunulur.',
    ),
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
              'F.A.Q.',
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
                        question: _items[i].question,
                        isExpanded: _expandedIndex == i,
                        onTap: () => setState(() {
                          _expandedIndex = _expandedIndex == i ? null : i;
                        }),
                      ),
                      if (_expandedIndex == i) _FaqAnswerCard(answer: _items[i].answer),
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
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
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

