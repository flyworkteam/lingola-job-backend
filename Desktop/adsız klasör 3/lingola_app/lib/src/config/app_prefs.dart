import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppPrefs {
  AppPrefs._();

  static const String onboardingCompletedKey = 'onboarding_completed';

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingCompletedKey) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, true);
  }

  static Future<void> clearOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(onboardingCompletedKey);
  }
}

