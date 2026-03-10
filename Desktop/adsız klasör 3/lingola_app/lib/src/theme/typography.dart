import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Tipografi tek kaynak: font Quicksand, weight, lineHeight burada tanımlanır.
/// Çıplak Text yerine AppTitle, AppBody, AppCaption, AppLabel kullanılır.
abstract final class AppTypography {
  AppTypography._();

  // --- Tek kaynak: font & metrikler (proje fontu: Quicksand)
  static const String fontFamily = 'Quicksand';
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.5;

  static TextStyle _quicksand({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    Color? color,
  }) =>
      GoogleFonts.quicksand(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color,
      );

  // --- Stiller (tüm ekranlar bu stilleri kullanır)
  static TextStyle get title => _quicksand(
        fontSize: 20,
        fontWeight: weightSemiBold,
        height: lineHeightTight,
        color: AppColors.onSurface,
      );

  static TextStyle get titleLarge => _quicksand(
        fontSize: 24,
        fontWeight: weightBold,
        height: lineHeightTight,
        color: AppColors.onSurface,
      );

  /// Splash ekranı marka yazısı: 45px, SemiBold (600).
  static TextStyle get splashBrandTitle => _quicksand(
        fontSize: 45,
        fontWeight: weightSemiBold,
        height: lineHeightTight,
        color: AppColors.onSurface,
      );

  /// Onboarding bottom sheet başlığı: 28px, Bold (700), siyah, line height 40px, sıkı harf aralığı.
  static TextStyle get onboardingTitle => _quicksand(
        fontSize: 32,
        fontWeight: weightBold,
        height: 40 / 28,
        color: AppColors.onboardingTitle,
      ).copyWith(letterSpacing: -1.2);

  /// Onboarding 2 sayfa başlığı: "What is your profession?" — 28px, Bold (700), tek stil (copyWith kalınlığı kaybettirmesin diye).
  static TextStyle get onboardingPageTitle => _quicksand(
        fontSize: 28,
        fontWeight: weightBold,
        height: 40 / 28,
        color: AppColors.onboardingText,
      ).copyWith(letterSpacing: -1.2);

  /// Meslek kartı başlığı: 16px, Bold (700), line height 15.
  static TextStyle get professionCardTitle => _quicksand(
        fontSize: 16,
        fontWeight: weightBold,
        height: 15 / 16,
        color: AppColors.onboardingText,
      );

  /// Onboarding bottom sheet açıklama: siyah (#000000), gövde metni, 14px, line height 22px.
  static TextStyle get onboardingDescription => _quicksand(
        fontSize: 14,
        fontWeight: weightRegular,
        height: 22 / 14,
        color: const Color(0xFF000000),
      );

  static TextStyle get body => _quicksand(
        fontSize: 16,
        fontWeight: weightRegular,
        height: lineHeightNormal,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMedium => _quicksand(
        fontSize: 14,
        fontWeight: weightRegular,
        height: lineHeightNormal,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySmall => _quicksand(
        fontSize: 14,
        fontWeight: weightRegular,
        height: lineHeightNormal,
        color: AppColors.onSurface,
      );

  static TextStyle get caption => _quicksand(
        fontSize: 12,
        fontWeight: weightRegular,
        height: lineHeightNormal,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get label => _quicksand(
        fontSize: 12,
        fontWeight: weightMedium,
        height: lineHeightNormal,
        color: AppColors.onSurface,
      );

  static TextStyle get labelLarge => _quicksand(
        fontSize: 14,
        fontWeight: weightSemiBold,
        height: lineHeightNormal,
        color: AppColors.onSurface,
      );

  /// ThemeData.textTheme ile uyumlu TextTheme (tek kaynaktan).
  static TextTheme get textTheme => TextTheme(
        displayLarge: titleLarge.copyWith(fontSize: 32),
        displayMedium: titleLarge.copyWith(fontSize: 28),
        displaySmall: titleLarge.copyWith(fontSize: 24),
        headlineLarge: titleLarge.copyWith(fontSize: 22),
        headlineMedium: title.copyWith(fontSize: 20),
        headlineSmall: title.copyWith(fontSize: 18),
        titleLarge: title.copyWith(fontSize: 18),
        titleMedium: title.copyWith(fontSize: 16),
        titleSmall: labelLarge,
        bodyLarge: body,
        bodyMedium: body.copyWith(fontSize: 14),
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: label,
        labelSmall: label.copyWith(fontSize: 10),
      );
}

// --- Ortak tipografi bileşenleri (çıplak Text yerine bunlar kullanılır)

/// Başlık metni. AppBar title, ekran başlığı vb.
class AppTitle extends StatelessWidget {
  const AppTitle(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  /// Büyük başlık (splash, onboarding vb.)
  static TextStyle get largeStyle => AppTypography.titleLarge;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTypography.title.merge(style),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

/// Gövde metni. Paragraflar, açıklamalar.
class AppBody extends StatelessWidget {
  const AppBody(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  static TextStyle get smallStyle => AppTypography.bodySmall;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTypography.body.merge(style),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

/// Küçük yardımcı metin. Tarih, kaynak, ikincil bilgi.
class AppCaption extends StatelessWidget {
  const AppCaption(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTypography.caption.merge(style),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

/// Etiket metni. Buton, chip, form label.
class AppLabel extends StatelessWidget {
  const AppLabel(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  static TextStyle get largeStyle => AppTypography.labelLarge;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: AppTypography.label.merge(style),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
