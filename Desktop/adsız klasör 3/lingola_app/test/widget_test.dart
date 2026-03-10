// Lingola App — widget smoke test.
// Uygulamanın ilk ekranı (Splash) build oluyor ve başlık görünüyor mu kontrol eder.
// Splash ekranı 4 sn sonra splashIntro'ya yönlendirdiği için testte bu timer tamamlanır.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/View/SplashView/splash_view.dart';
import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/app_theme.dart';

void main() {
  testWidgets('Splash screen builds and shows app title', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppPaths.splash,
      routes: [
        GoRoute(
          path: AppPaths.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: AppPaths.splashIntro,
          builder: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
    await tester.pump();

    expect(find.text('Lingola Job'), findsOneWidget);

    // Splash ekranı initState'te 4 sn timer başlatıyor; test sonunda pending timer
    // kalmasın diye süreyi ilerletip timer'ın tetiklenmesini sağlıyoruz.
    await tester.pump(const Duration(seconds: 5));
  });
}
