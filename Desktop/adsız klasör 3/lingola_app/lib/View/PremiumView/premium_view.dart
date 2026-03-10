import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

class PremiumBenefitsScreen extends ConsumerStatefulWidget {
  const PremiumBenefitsScreen({super.key});

  @override
  ConsumerState<PremiumBenefitsScreen> createState() =>
      _PremiumBenefitsScreenState();
}

class _PremiumBenefitsScreenState extends ConsumerState<PremiumBenefitsScreen> {
  static const _benefits = <String>[
    'Sınırsız mesleki kelime öğrenme ve tekrar erişimi',
    'Sınırsız kelime kaydetme',
    'Öğrenilen mesleki kelimeler için akıllı tekrar hatırlatmaları',
    'Günlük ve haftalık öğrenme hedefleri',
    'Öğrenilen kelimelerle mesleki testler yapma',
    'Öncelikli destek',
    'Yeni özelliklere erken erişim',
  ];

  List<Package> _packages = [];
  bool _loadingOfferings = true;
  String? _offeringsError;
  bool _purchasing = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _offeringsError = null;
    });
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null && current.availablePackages.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _packages = current.availablePackages;
          _loadingOfferings = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _packages = [];
          _loadingOfferings = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _packages = [];
        _loadingOfferings = false;
        _offeringsError = e.toString();
      });
    }
  }

  Future<void> _purchase(Package package) async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      if (!mounted) return;
      ref.invalidate(premiumProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium hesabınız aktif.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final cancelled = e is PlatformException &&
          PurchasesErrorHelper.getErrorCode(e) ==
              PurchasesErrorCode.purchaseCancelledError;
      if (!cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alınamadı: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    setState(() => _restoring = true);
    try {
      await Purchases.restorePurchases();
      if (!mounted) return;
      ref.invalidate(premiumProvider);
      final isPremium = ref.read(premiumProvider).valueOrNull ?? false;
      if (isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satın alımlarınız geri yüklendi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktif abonelik bulunamadı.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geri yükleme hatası: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPurchase = _packages.isNotEmpty && !_purchasing;
    final isLoading = _loadingOfferings || _purchasing;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
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
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Premium',
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Premium ayrıcalıklar',
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildBenefitsCard(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Deneme süresi',
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTrialCard(),
                    const SizedBox(height: AppSpacing.xl),
                    if (_offeringsError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          _offeringsError!,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: theme.elevatedButtonTheme.style?.copyWith(
                              minimumSize:
                                  WidgetStateProperty.all(const Size.fromHeight(52)),
                              backgroundColor:
                                  WidgetStateProperty.all(AppColors.primaryBrand),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                            ) ??
                            ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: AppColors.primaryBrand,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                        onPressed: canPurchase
                            ? () {
                                final pkg = _packages.first;
                                _purchase(pkg);
                              }
                            : null,
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _packages.isNotEmpty
                                    ? _packages.first.storeProduct.priceString
                                        .isNotEmpty
                                        ? 'Premium\'a geç — ${_packages.first.storeProduct.priceString}'
                                        : 'Premium\'a geç'
                                    : 'Yakında — Premium\'a geç',
                                style: AppTypography.labelLarge.copyWith(
                                  color: canPurchase
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: (_restoring || _loadingOfferings)
                          ? null
                          : _restore,
                      child: _restoring
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Satın alımları geri yükle',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primaryBrand,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0575E6), Color(0xFF021B79)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/vector_premium.svg',
                    width: 26,
                    height: 26,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Text(
                'Lingola Job Premium',
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Kariyerine uygun kelimeleri sınırsız öğren, kaydet ve tekrar et.',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flash_on_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '2 gün ücretsiz dene',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _benefits
            .map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrand.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        b,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTrialCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Lingola Job ilk indirildiğinde kullanıcıya 2 gün ücretsiz deneme süresi sunulur. Deneme süresi boyunca premium özelliklerin bazılarını veya tamamını deneyimleyebilir; süre sonunda premium pakete geçiş yaparak ayrıcalıklı özellikleri kullanmaya devam edebilirsiniz.',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}
