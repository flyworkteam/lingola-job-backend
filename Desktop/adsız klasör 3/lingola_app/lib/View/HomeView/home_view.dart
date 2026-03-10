import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/app_card.dart';
import 'package:lingola_app/src/widgets/app_gradient_button.dart';
import 'package:lingola_app/src/widgets/app_icon_button.dart';

class _HomeLanguage {
  const _HomeLanguage({required this.id, required this.flagAsset});
  final String id;
  final String flagAsset;
}

/// Anasayfa (onboarding tamamlandıktan sonra açılır).
/// Üstte custom header + hero container (beyaz kart) yapısı.
/// Header kaydırma ile küçülür (SliverAppBar).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.title = 'Lingola',
    this.userName = 'Jhon Doe',
    this.isPremium = false,
    this.savedWordsCount = 0,
    this.totalXp = 0,
    this.onLearnNewWordsTap,
    this.onSavedWordsTap,
    this.onDictionaryTap,
  });

  final String title;
  final String userName;
  final bool isPremium;
  /// Kaydedilen kelime sayısı (Saved Words kartında gösterilir).
  final int savedWordsCount;
  /// Kullanıcının toplam XP'si (Quick Actions barları için).
  final int totalXp;
  /// Learn New Words kartına tıklanınca — Learn sekmesine geçip Word Practice açılır.
  final VoidCallback? onLearnNewWordsTap;
  /// Saved Words kartına tıklanınca — Learn sekmesine geçip Saved Word sayfası açılır.
  final VoidCallback? onSavedWordsTap;
  /// Dictionary kartına tıklanınca — Library sekmesine geçip Dictionary sekmesi açılır.
  final VoidCallback? onDictionaryTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<_HomeLanguage> _languages = [
    _HomeLanguage(id: 'english', flagAsset: 'assets/bayrak/flag_english.svg'),
    _HomeLanguage(id: 'german', flagAsset: 'assets/bayrak/flag_german.svg'),
    _HomeLanguage(id: 'italian', flagAsset: 'assets/bayrak/flag_italian.svg'),
    _HomeLanguage(id: 'french', flagAsset: 'assets/bayrak/flag_french.svg'),
    _HomeLanguage(id: 'japanese', flagAsset: 'assets/bayrak/flag_japanese.svg'),
    _HomeLanguage(id: 'spanish', flagAsset: 'assets/bayrak/Spain.png'),
    _HomeLanguage(id: 'russian', flagAsset: 'assets/bayrak/flag_russian.svg'),
    _HomeLanguage(id: 'turkish', flagAsset: 'assets/bayrak/flag_turkish.svg'),
    _HomeLanguage(id: 'korean', flagAsset: 'assets/bayrak/flag_korean.svg'),
    _HomeLanguage(id: 'hindi', flagAsset: 'assets/bayrak/flag_hindi.svg'),
    _HomeLanguage(id: 'portuguese', flagAsset: 'assets/bayrak/flag_portuguese.svg'),
  ];

  String _selectedLanguageId = 'english';
  bool _hasSyncedLocaleFromContext = false;
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

  /// Dil id (english, german, ...) → locale kodu (en, de, ...)
  static String? _languageIdToLocale(String id) {
    const m = {
      'english': 'en', 'german': 'de', 'italian': 'it', 'french': 'fr',
      'japanese': 'ja', 'spanish': 'es', 'russian': 'ru', 'turkish': 'tr',
      'korean': 'ko', 'hindi': 'hi', 'portuguese': 'pt',
    };
    return m[id];
  }

  /// Mevcut locale'e göre dil id (dropdown ile senkron)
  static String? _localeToLanguageId(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    const m = {
      'en': 'english', 'de': 'german', 'it': 'italian', 'fr': 'french',
      'ja': 'japanese', 'es': 'spanish', 'ru': 'russian', 'tr': 'turkish',
      'ko': 'korean', 'hi': 'hindi', 'pt': 'portuguese',
    };
    return m[code];
  }

  _HomeLanguage get _selectedLanguage =>
      _languages.firstWhere((l) => l.id == _selectedLanguageId, orElse: () => _languages.first);

  static const double _cardWidth = 180;
  static const double _cardHeight = 250;
  static const double _cardGap = 10;
  static const double _headerExpandedHeight = 190;
  static const double _maskCardIconTop = 32;
  static const double _maskCardTextTop = 115; // yazı orijinal konumda (xxxl+icon+gap)
  static const double _contentMaxWidth = 380;
  static const double _continueLessonMaxWidth = 370;

  double get _levelProgress {
    const xpForFullBar = 500; // 500 XP'de bar %100 olsun
    if (widget.totalXp <= 0) return 0;
    final v = widget.totalXp / xpForFullBar;
    return v.clamp(0.0, 1.0);
  }

  int get _levelPercent => (_levelProgress * 100).round();

  double get _continueLessonProgress => _levelProgress;
  int get _continueLessonPercent => _levelPercent;

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.6),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
                itemCount: _languages.length,
                itemBuilder: (ctx, i) {
                  final lang = _languages[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final localeCode = _languageIdToLocale(lang.id);
                        if (localeCode != null) {
                          await ctx.setLocale(Locale(localeCode));
                          if (!mounted) return;
                          setState(() => _selectedLanguageId = lang.id);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 30,
                              child: lang.flagAsset.toLowerCase().endsWith('.png')
                                  ? Image.asset(lang.flagAsset, width: 40, height: 30, fit: BoxFit.contain)
                                  : SvgPicture.asset(
                                      lang.flagAsset,
                                      width: 40,
                                      height: 30,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                'languages.${lang.id}'.tr(),
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSyncedLocaleFromContext) {
      final id = _localeToLanguageId(context.locale);
      if (id != null) {
        _hasSyncedLocaleFromContext = true;
        if (id != _selectedLanguageId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedLanguageId = id);
          });
        }
      }
    }
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
                        _buildHeaderContent(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg + 100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildQuickActionsHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLevelCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMaskGroupCards(context),
                  if (!widget.isPremium) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildGetPremiumCard(),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _buildContinueLessonCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildBottomCards(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.xs),
            child: Row(
                      children: [
                        // Avatar (kare, yuvarlatılmış köşe)
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
                        AppSpacing.md.width,
                        // Free / Premium badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isPremium
                                ? const Color(0xFFF8F9FA)
                                : const Color(0xFFD9D9D9)
                                    .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: widget.isPremium
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF021B79)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: widget.isPremium
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/Vector.svg',
                                      width: 18,
                                      height: 18,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'home.premium_badge'.tr(),
                                      style: AppTypography.labelLarge.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'home.free_badge'.tr(),
                                  style: AppTypography.labelLarge.copyWith(
                                    color: const Color(0xFF5C5C5C),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                        const Spacer(),
            AppIconButton(
              onTap: () {
                context.push(
                  AppPaths.notifications,
                  extra: NotificationsRouteArgs(isPremium: widget.isPremium),
                );
              },
              child: SvgPicture.asset(
                'assets/icons/frame_notification.svg',
                width: 23,
                height: 23,
                fit: BoxFit.contain,
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
                                'home.hello_user'.tr(args: [widget.userName.split(' ').first]),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'home.continue_to_language'.tr(args: ['languages.${_selectedLanguage.id}'.tr()]),
                                style: AppTypography.titleLarge.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Dil seçici butonu (bayrak + seçilen dil + chevron)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showLanguageSheet(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFCFCFCF),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: _selectedLanguage.flagAsset.toLowerCase().endsWith('.png')
                                        ? Image.asset(_selectedLanguage.flagAsset, fit: BoxFit.contain)
                                        : SvgPicture.asset(
                                            _selectedLanguage.flagAsset,
                                            width: 13,
                                            height: 13,
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'languages.${_selectedLanguage.id}'.tr(),
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.onSurface,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ],
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

  Widget _buildQuickActionsHeader() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'home.quick_actions'.tr(),
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
        child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home.level_beginner'.tr(),
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final progress = _levelProgress;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 12,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8E8E8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                child: Container(
                                  width: constraints.maxWidth * progress,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBrand,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              Text(
                                '$_levelPercent%',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildMaskGroupCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: widget.onLearnNewWordsTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: _cardWidth,
              height: _cardHeight,
              child: Stack(
                children: [
                  SvgPicture.asset(
                    'assets/icons/mask_group.svg',
                    fit: BoxFit.fill,
                    width: _cardWidth,
                    height: _cardHeight,
                  ),
                              Positioned(
                                top: _maskCardIconTop,
                                left: AppSpacing.lg,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 37,
                                      height: 37,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00061C).withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/icons/vector_search.svg',
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: _maskCardTextTop,
                                left: AppSpacing.lg,
                                right: AppSpacing.lg,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'home.learn_new_words_title'.tr(),
                                      style: AppTypography.title.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'home.learn_new_words_subtitle'.tr(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.3,
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
        SizedBox(width: _cardGap),
        GestureDetector(
          onTap: () => context.push(AppPaths.mostFrequentlyUsedTerms),
          child: SizedBox(
            width: _cardWidth,
            height: _cardHeight,
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/icons/mask_group_1.svg',
                  fit: BoxFit.fill,
                  width: _cardWidth,
                  height: _cardHeight,
                ),
                            Positioned(
                              top: _maskCardIconTop,
                              left: AppSpacing.lg,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF021B79).withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/icons/frame_terms.svg',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: _maskCardTextTop,
                              left: AppSpacing.lg,
                              right: AppSpacing.lg,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'home.mfut_title'.tr(),
                                    style: AppTypography.title.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'home.mfut_subtitle'.tr(),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontSize: 11,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
  }

  Widget _buildGetPremiumCard() {
    return Center(
                    child: SizedBox(
                      width: 336,
                      height: 127,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0575E6), Color(0xFF021B79)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              6,
                              AppSpacing.lg,
                              AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: AppSpacing.xs),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/vector_premium.svg',
                                    width: 18,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'home.get_premium_title'.tr(),
                                style: AppTypography.title.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -8),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                'home.get_premium_subtitle'.tr(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: AppGradientButton(
                            label: 'home.get_premium'.tr(),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
                ),
    );
  }

  Widget _buildContinueLessonCard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _continueLessonMaxWidth),
        child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, -8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'home.continue_lesson'.tr(),
                                    style: AppTypography.title.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'home.business_negotiations'.tr(),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/icons/kupa.svg',
                              width: 36,
                              height: 46,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: _continueLessonProgress,
                                  minHeight: 12,
                                  backgroundColor: const Color(0xFFE8E8E8),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryBrand,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_continueLessonPercent%',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  static const double _bottomCardGap = 20;
  static const double _bottomCardWidth = 177;
  static const double _bottomCardHeight = 177;

  Widget _buildBottomCards(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: widget.onSavedWordsTap,
            child: SizedBox(
              width: _bottomCardWidth,
              height: _bottomCardHeight,
                        child: AppCard(
                        borderRadius: 22,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.lg,
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 52,
                                    height: 52,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/rectangle_141.svg',
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.contain,
                                        ),
                                        SvgPicture.asset(
                                          'assets/icons/frame_saved_words.svg',
                                          width: 42,
                                          height: 42,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'home.saved_word_title'.tr(),
                                    style: AppTypography.titleLarge.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'home.saved_word_count'.tr(args: ['${widget.savedWordsCount}']),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: SvgPicture.asset(
                                'assets/icons/icon_arrow_right.svg',
                                width: 24,
                                height: 11,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          SizedBox(width: _bottomCardGap),
          GestureDetector(
            onTap: widget.onDictionaryTap,
            child: SizedBox(
              width: _bottomCardWidth,
              height: _bottomCardHeight,
                        child: AppCard(
                          borderRadius: 22,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.lg,
                          ),
                          child: Stack(
                            children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 6),
                                    SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/rectangle_141.svg',
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.contain,
                                          ),
                                          SvgPicture.asset(
                                            'assets/icons/frame_dictionary.svg',
                                            width: 42,
                                            height: 42,
                                            fit: BoxFit.contain,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      'home.dictionary_title'.tr(),
                                      style: AppTypography.titleLarge.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                        height: 1.25,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'home.dictionary_subtitle'.tr(),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: SvgPicture.asset(
                                  'assets/icons/icon_arrow_right.svg',
                                  width: 24,
                                  height: 11,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}

extension _SpacingExtension on double {
  SizedBox get width => SizedBox(width: this);
}

