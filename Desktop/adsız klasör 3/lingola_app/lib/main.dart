import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

import 'package:lingola_app/firebase_options.dart';
import 'package:lingola_app/src/navigation/app_router.dart';
import 'package:lingola_app/src/theme/app_theme.dart';

/// Tek instance: locale değişince MaterialApp yeniden build olur ama router aynı kalır,
/// böylece onboarding ortasında dil değişince başa dönülmez.
final _appRouter = createAppRouter();

const String _kRevenueCatAppleApiKey = String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
const String _kRevenueCatAndroidApiKey = String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final apiKey = Platform.isIOS ? _kRevenueCatAppleApiKey : _kRevenueCatAndroidApiKey;
  if (apiKey.isNotEmpty) {
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('it'),
        Locale('pt'),
        Locale('ru'),
        Locale('ja'),
        Locale('ko'),
        Locale('hi'),
      ],
      fallbackLocale: const Locale('tr'),
      startLocale: const Locale('tr'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Lingola',
        theme: AppTheme.light,
        routerConfig: _appRouter,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
