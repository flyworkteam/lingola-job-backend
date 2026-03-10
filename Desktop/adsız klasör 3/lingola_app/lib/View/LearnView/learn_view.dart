import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Learn sekmesi: header (geri + başlık + selamlama + avatar) + Learning Content kartları.
/// Header kaydırma ile küçülür (SliverAppBar).
class LearnScreen extends StatefulWidget {
  const LearnScreen({
    super.key,
    this.userName = 'Jhon Doe',
    this.savedWordsCount = 255,
    this.onBackTap,
  });

  final String userName;
  final int savedWordsCount;
  final VoidCallback? onBackTap;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  static const Color _learnBlue = Color(0xFF0575E6);
  static const Color _learnBlueDark = Color(0xFF021B79);
  static const double _headerExpandedHeight = 150;

  File? _avatarFile;
  static const String _keyProfileAvatar = 'profile_avatar_path';

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_keyProfileAvatar);
    File? file;
    if (path != null && path.isNotEmpty) {
      final f = File(path);
      if (await f.exists()) {
        file = f;
      }
    }
    if (!mounted) return;
    setState(() => _avatarFile = file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: _headerExpandedHeight,
              pinned: false,
              floating: false,
              stretch: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 50),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
                            child: Row(
                              children: [
                                if (widget.onBackTap != null)
                                  IconButton(
                                    onPressed: widget.onBackTap,
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
                                  ),
                                Text(
                                  context.tr('learn.title'),
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, AppSpacing.xs, 0, AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  context.tr('learn.hello_user', args: [widget.userName.split(' ').first]),
                                  style: AppTypography.titleLarge.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                    const SizedBox(height: 2),
                                    Text(
                                  context.tr('learn.subtitle'),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 15,
                                  ),
                                ),
                                    ],
                                  ),
                                ),
                              const SizedBox(width: AppSpacing.md),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: _avatarFile != null
                                      ? Image.file(
                                          _avatarFile!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/dummy/image 2.png',
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
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
            ),
            ), // SliverAppBar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg + 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    context.tr('learn.learning_content'),
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildWordPracticeCard(context),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDailyTestCard(context)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildReadingTestCard(context)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSavedWordCard(context),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Word Practice: mavi gradient, 20.000+ Words, progress %20, sağ altta ok butonu.
  Widget _buildWordPracticeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/word_practice', arguments: const LearnWordPracticeArgs()),
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_learnBlue, _learnBlueDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _learnBlueDark.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  context.tr('learn.word_practice'),
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('learn.words_20k'),
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    context.tr('learn.words_count'),
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '%20',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.2,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed('/word_practice', arguments: const LearnWordPracticeArgs()),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset(
                        'assets/icons/icon_frame_arrow.svg',
                        width: 35,
                        height: 35,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    ),
    );
  }

  /// Daily Test: beyaz kart, A/translate ikonu, Daily Test + Business English, Continue Test butonu.
  Widget _buildDailyTestCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/daily_test'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      context.tr('learn.daily_test'),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/icon_translate.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('learn.business_english'),
                style: AppTypography.title.copyWith(
                  color: _learnBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0575E6), Color(0xFF021B79)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed('/daily_test'),
                      borderRadius: BorderRadius.circular(50),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            context.tr('learn.continue_test'),
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
      ),
    );
  }

  /// Reading Test: beyaz kart, mikrofon ikonu, Reading Test + Business Negotiation, Continue Test.
  Widget _buildReadingTestCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/reading_test'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  context.tr('learn.reading_test'),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Quicksand',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/icon_mic.svg',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('learn.business_negotiation'),
            style: AppTypography.title.copyWith(
              color: _learnBlue,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0575E6), Color(0xFF021B79)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed('/reading_test'),
                  borderRadius: BorderRadius.circular(50),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        context.tr('learn.continue_test'),
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
      ),
    );
  }

  /// Saved Word: beyaz kart, kitap ikonu sağ üst, başlık + açıklama, altta sayı + ok butonu.
  /// Word Practice kartı ile aynı boyutlar: padding lg, radius 22.
  Widget _buildSavedWordCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/saved_word', arguments: const LearnSavedWordArgs()),
        borderRadius: BorderRadius.circular(22),
        child: Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF0575E6), Color(0xFF021B79)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Text(
                        context.tr('learn.saved_word'),
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          height: AppTypography.lineHeightTight,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('learn.saved_word_subtitle'),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/frame_saved_words.svg',
                width: 50,
                height: 50,
                colorFilter: const ColorFilter.mode(_learnBlue, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                context.tr('learn.saved_word_count', args: ['${widget.savedWordsCount}']),
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed('/saved_word', arguments: const LearnSavedWordArgs()),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF0575E6), Color(0xFF021B79)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: SvgPicture.asset(
                        'assets/icons/icon_frame_arrow.svg',
                        width: 35,
                        height: 35,
                        fit: BoxFit.contain,
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
    );
  }
}

