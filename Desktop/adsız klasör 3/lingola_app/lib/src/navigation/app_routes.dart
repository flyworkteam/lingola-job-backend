// Tip güvenli route path sabitleri ve sayfa argümanları.
// Argümanlar sınıf olarak geçilir; runtime cast hatası yerine derleme zamanı güvenliği.

// --- Path sabitleri (tek kaynak; yazım hatası önlenir)
abstract final class AppPaths {
  AppPaths._();

  static const String splash = '/splash';
  static const String splashIntro = '/splash_intro';
  static const String splash1 = '/splash1';
  static const String splash2 = '/splash2';
  static const String splash3 = '/splash3';
  static const String onboarding = '/onboarding';
  static const String onboarding2 = '/onboarding2';
  static const String onboarding3 = '/onboarding3';
  static const String onboarding4 = '/onboarding4';
  static const String onboarding5 = '/onboarding5';
  static const String onboarding6 = '/onboarding6';
  static const String onboarding7 = '/onboarding7';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String profileSettings = '/profile_settings';
  static const String faq = '/faq';
  static const String mostFrequentlyUsedTerms = '/most_frequently_used_terms';
  static const String premium = '/premium';
}

// --- Home (MainScreen)
class HomeRouteArgs {
  const HomeRouteArgs({this.initialIndex = 0});
  final int initialIndex;
}

// --- Notifications
class NotificationsRouteArgs {
  const NotificationsRouteArgs({required this.isPremium});
  final bool isPremium;
}

// --- Profile Settings (giriş + çıkış sonucu)
class ProfileSettingsRouteArgs {
  const ProfileSettingsRouteArgs({this.initialName = ''});
  final String initialName;
}

/// Profil ayarlarından pop ile dönülen sonuç.
class ProfileSettingsResult {
  const ProfileSettingsResult({required this.name});
  final String name;
}

// --- Most Frequently Used Terms → Home'a dönüşte hangi tab
class MostFrequentlyUsedTermsRouteArgs {
  const MostFrequentlyUsedTermsRouteArgs();
}

/// MostFrequentlyUsedTerms'ten "Back" ile Home'a dönüşte kullanılır.
class HomeRouteArgsFromTerms {
  const HomeRouteArgsFromTerms({this.initialIndex = 0});
  final int initialIndex;
}

// --- Learn tab içi (nested Navigator) tip güvenli argümanlar
class LearnWordPracticeArgs {
  const LearnWordPracticeArgs({
    this.returnToHomeOnPop = false,
    this.trackId,
  });
  final bool returnToHomeOnPop;
  /// Backend'deki learning_track_id. Verilirse user_tracks'a son erişim kaydedilir.
  final int? trackId;
}

/// Daily Test için route argümanları (track + kelime cevabı backend sync).
class DailyTestRouteArgs {
  const DailyTestRouteArgs({
    this.trackId,
    this.wordId,
    this.questionType = 'daily_test',
  });
  /// Backend'deki learning_track_id. Verilirse track erişimi kaydedilir.
  final int? trackId;
  /// Mevcut sorunun word_id'si. Verilirse cevap backend'e gönderilir.
  final int? wordId;
  final String questionType;
}

class LearnSavedWordArgs {
  const LearnSavedWordArgs({this.returnToHomeOnPop = false});
  final bool returnToHomeOnPop;
}
