import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:lingola_app/Services/api_service.dart';

/// Uygulama açıldığında / ön plana geldiğinde backend'e aktivite ping'i atar ve
/// FCM token'ı kaydettirir. Backend 24 saat girmeyen kullanıcıya bildirim gönderir.
class NotificationActivityService {
  NotificationActivityService._();

  static final ApiService _api = ApiService.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static bool _subscribedToTokenRefresh = false;

  /// İzin iste (iOS); FCM token al; backend'e POST /me/activity ile gönder.
  /// Giriş yapmamışsa API hata döner, sessizce yutulur.
  static Future<void> pingActivity() async {
    try {
      String? fcmToken;
      if (Platform.isIOS) {
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (settings.authorizationStatus != AuthorizationStatus.authorized &&
            settings.authorizationStatus != AuthorizationStatus.provisional) {
          // İzin yok, yine de last_activity_at güncellemek için ping at (token olmadan).
        }
      }
      fcmToken = await _messaging.getToken();
      final result = await _api.postUserActivity(fcmToken: fcmToken);
      if (!result.isOk) return; // Giriş yok veya ağ hatası, sessizce bırak.
      _ensureTokenRefreshSubscription();
    } catch (_) {}
  }

  static void _ensureTokenRefreshSubscription() {
    if (_subscribedToTokenRefresh) return;
    _subscribedToTokenRefresh = true;
    _messaging.onTokenRefresh.listen((String token) {
      _api.postUserActivity(fcmToken: token).ignore();
    });
  }
}
