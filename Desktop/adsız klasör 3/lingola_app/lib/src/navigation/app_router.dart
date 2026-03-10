import 'package:go_router/go_router.dart';

import 'package:lingola_app/View/MainView/main_view.dart';
import 'package:lingola_app/View/SplashView/splash_view.dart';
import 'package:lingola_app/View/SplashIntroView/splash_intro_view.dart';
import 'package:lingola_app/View/Splash1View/splash1_view.dart';
import 'package:lingola_app/View/Splash2View/splash2_view.dart';
import 'package:lingola_app/View/Splash3View/splash3_view.dart';
import 'package:lingola_app/View/OnboardingView/onboarding_view.dart';
import 'package:lingola_app/View/Onboarding2View/onboarding2_view.dart';
import 'package:lingola_app/View/Onboarding3View/onboarding3_view.dart';
import 'package:lingola_app/View/Onboarding4View/onboarding4_view.dart';
import 'package:lingola_app/View/Onboarding5View/onboarding5_view.dart';
import 'package:lingola_app/View/Onboarding6View/onboarding6_view.dart';
import 'package:lingola_app/View/Onboarding7View/onboarding7_view.dart';
import 'package:lingola_app/View/NotificationsView/notifications_view.dart';
import 'package:lingola_app/View/FaqView/faq_view.dart';
import 'package:lingola_app/View/MostFrequentlyUsedTermsView/most_frequently_used_terms_view.dart';
import 'package:lingola_app/View/ProfileSettingsView/profile_settings_view.dart';
import 'package:lingola_app/View/ForgotPasswordView/forgot_password_view.dart';
import 'package:lingola_app/View/PremiumView/premium_view.dart';
import 'package:lingola_app/src/config/app_prefs.dart';

import 'app_routes.dart';

/// Uygulama GoRouter konfigürasyonu. Tip güvenli [AppPaths] ve route arg sınıfları kullanır.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppPaths.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final completed = await AppPrefs.isOnboardingCompleted();
      if (!completed) return null;

      final loc = state.matchedLocation;
      final isIntroOrSplash = loc == AppPaths.splash || loc == AppPaths.splashIntro;
      final isOnboarding = loc == AppPaths.onboarding ||
          loc == AppPaths.onboarding2 ||
          loc == AppPaths.onboarding3 ||
          loc == AppPaths.onboarding4 ||
          loc == AppPaths.onboarding5 ||
          loc == AppPaths.onboarding6 ||
          loc == AppPaths.onboarding7;

      if (isIntroOrSplash || isOnboarding) return AppPaths.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppPaths.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPaths.splashIntro,
        builder: (_, __) => const SplashIntroScreen(),
      ),
      GoRoute(
        path: AppPaths.splash1,
        builder: (_, __) => const Splash1Screen(),
      ),
      GoRoute(
        path: AppPaths.splash2,
        builder: (_, __) => const Splash2Screen(),
      ),
      GoRoute(
        path: AppPaths.splash3,
        builder: (_, __) => const Splash3Screen(),
      ),
      GoRoute(
        path: AppPaths.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppPaths.onboarding2,
        builder: (_, __) => const Onboarding2Screen(),
      ),
      GoRoute(
        path: AppPaths.onboarding3,
        builder: (_, __) => const Onboarding3Screen(),
      ),
      GoRoute(
        path: AppPaths.onboarding4,
        builder: (_, __) => const Onboarding4Screen(),
      ),
      GoRoute(
        path: AppPaths.onboarding5,
        builder: (_, __) => const Onboarding5Screen(),
      ),
      GoRoute(
        path: AppPaths.onboarding6,
        builder: (_, __) => const Onboarding6Screen(),
      ),
      GoRoute(
        path: AppPaths.onboarding7,
        builder: (_, __) => const Onboarding7Screen(),
      ),
      GoRoute(
        path: AppPaths.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppPaths.home,
        builder: (context, state) {
          final args = state.extra as HomeRouteArgs? ?? const HomeRouteArgs();
          return MainScreen(
            initialIndex: args.initialIndex,
            isPremium: false,
          );
        },
      ),
      GoRoute(
        path: AppPaths.notifications,
        builder: (context, state) {
          final args = state.extra as NotificationsRouteArgs? ?? const NotificationsRouteArgs(isPremium: false);
          return NotificationsScreen(isPremium: args.isPremium);
        },
      ),
      GoRoute(
        path: AppPaths.profileSettings,
        builder: (context, state) {
          final args = state.extra as ProfileSettingsRouteArgs? ?? const ProfileSettingsRouteArgs();
          return ProfileSettingsScreen(initialName: args.initialName);
        },
      ),
      GoRoute(
        path: AppPaths.faq,
        builder: (_, __) => const FaqScreen(),
      ),
      GoRoute(
        path: AppPaths.mostFrequentlyUsedTerms,
        builder: (_, __) => const MostFrequentlyUsedTermsScreen(),
      ),
      GoRoute(
        path: AppPaths.premium,
        builder: (_, __) => const PremiumBenefitsScreen(),
      ),
    ],
  );
}
