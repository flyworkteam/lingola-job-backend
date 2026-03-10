# Lingola App — Senior Geliştirici İncelemesi ve Teslim Checklist

**İnceleme Tarihi:** Mart 2025  
**Proje:** Lingola — Dil öğrenme uygulaması (Flutter)

---

## 1. Genel Değerlendirme Özeti

- **Mimari:** View / Services / Repositories / Models ayrımı net; Riverpod ve go_router kullanımı tutarlı.
- **Özellik seti:** Onboarding, auth (Google/Facebook, şifre sıfırlama), kelime öğrenme, günlük test, okuma testi, kütüphane, profil ve bildirimler mevcut.
- **Eksikler:** Store teslimi için kritik konfigürasyonlar, testler, yasal linkler ve bazı tamamlanmamış özellikler var.

---

## 2. Teslim Edilmeden Önce Yapılması Gerekenler

### 2.1 Kritik (Store / Yasal / Güvenlik)

| # | Eksik | Açıklama | Nerede |
|---|--------|----------|--------|
| 1 | **Release imzalama (Android)** | Release build şu an debug key ile imzalanıyor. Play Store için kendi keystore ile imzalama gerekli. | `android/app/build.gradle.kts` → `buildTypes.release.signingConfig` |
| 2 | **Facebook Login konfigürasyonu** | `YOUR_FACEBOOK_APP_ID` ve `YOUR_FACEBOOK_CLIENT_TOKEN` placeholder; gerçek değerler olmadan Facebook girişi çalışmaz. | `ios/Runner/Info.plist`, `android/.../res/values/strings.xml` |
| 3 | **Terms of Service / Privacy Policy / Cookies Policy** | Onboarding’de metin var ama tıklanabilir link yok. Store politikaları genelde gerçek URL’ler ve kullanıcı onayı ister. | `lib/View/OnboardingView/onboarding_view.dart` — `url_launcher` ile URL açılmalı |
| 4 | **API base URL (production)** | Varsayılan `http://192.168.1.8:3000`; canlı ortam için production URL’i `--dart-define=API_BASE_URL=...` ile verilmeli ve dokümante edilmeli. | `lib/Services/api_service.dart` |
| 5 | **RevenueCat key** | `main.dart` içinde test key sabit; production için ayrı key ve mümkünse ortam bazlı config. | `lib/main.dart` |

### 2.2 Özellik / UX

| # | Eksik | Açıklama | Nerede |
|---|--------|----------|--------|
| 6 | **Profil fotoğrafı (kamera / galeri)** | “Kamera aç” ve “Galeri aç” TODO; özellik yarım. Ya implement edilmeli ya da UI’dan kaldırılmalı. | `lib/View/ProfileSettingsView/profile_settings_view.dart` |
| 7 | **Android uygulama adı** | `android:label="lingola_app"`; kullanıcıya görünen isim “Lingola” veya “Lingola Job” gibi olmalı. | `AndroidManifest.xml` / `strings.xml` |

### 2.3 Kalite / Bakım

| # | Eksik | Açıklama | Nerede |
|---|--------|----------|--------|
| 8 | **Widget testi** | `test/widget_test.dart` hâlâ counter örneği; mevcut uygulamayla uyuşmuyor ve muhtemelen fail eder. Düzeltilmeli veya kaldırılıp gerçek bir smoke test yazılmalı. | `test/widget_test.dart` |
| 9 | **Unit / entegrasyon testleri** | Servisler, repository’ler ve kritik state için test yok. En azından ApiService, AuthService ve bir iki provider için unit test eklenmeli. | `test/` |
| 10 | **Sessiz hata yutma** | Birçok yerde `catch (_) {}` ile hata yutuluyor; kullanıcı bilgilendirilmiyor, log da yok. En azından debug log veya kullanıcıya anlamlı mesaj. | `word_services.dart`, `word_database_service.dart`, `saved_words_store.dart`, `practice_words_store.dart`, `xp_store.dart`, `notification_activity_service.dart`, çeşitli View’lar |
| 11 | **TODO’lar** | Kamera/Galeri TODO’ları kodda duruyor; ya tamamlanmalı ya da ticket’a alınıp koddan kaldırılmalı. | `profile_settings_view.dart` |

### 2.4 Opsiyonel ama Önerilen

| # | Öneri | Açıklama |
|---|--------|----------|
| 12 | **Crash / hata izleme** | Sentry veya Firebase Crashlytics ile release’te crash ve non-fatal hata takibi. |
| 13 | **Analytics** | Firebase Analytics veya benzeri ile temel event’ler (ekran, giriş, kelime tamamlama vb.). |
| 14 | **Ortam yapılandırması** | Dev / staging / prod için tek bir config sınıfı (örn. `String.fromEnvironment` + dart-define) ile API URL, RevenueCat key. |
| 15 | **Erişilebilirlik** | `Semantics` / `semanticsLabel` kullanımı yok; TalkBack / VoiceOver için temel etiketler eklenebilir. |

---

## 3. Güçlü Yönler

- **Mimari:** Katmanlı yapı (View, Service, Repository, Model) ve Riverpod kullanımı düzenli.
- **Navigasyon:** go_router + nested Navigator (Learn sekmesi) ile tutarlı routing ve route args.
- **API katmanı:** `ApiResult<T>` ve repository pattern ile hata yönetimi merkezi.
- **Çoklu dil:** Easy Localization ve çok sayıda dil desteği.
- **Lint:** `flutter_lints` ile statik analiz açık.
- **Loading / hata durumları:** Birçok ekranda `_loading` ve `_errorMessage` ile kullanıcı bilgilendirmesi var.

---

## 4. Puan: 10 Üzerinden 6.5 / 10

| Kriter | Puan | Not |
|--------|------|-----|
| Mimari ve kod organizasyonu | 8/10 | Temiz ayrım, Riverpod ve router iyi kullanılmış. |
| Özellik bütünlüğü | 6/10 | Çekirdek özellikler var; profil fotoğrafı ve yasal linkler eksik. |
| Konfigürasyon ve güvenlik | 4/10 | Hardcoded/test key’ler, placeholder’lar, release imzalama eksik. |
| Test ve kalite güvencesi | 2/10 | Sadece eski/generic widget test; unit/integration yok. |
| Hata yönetimi ve loglama | 5/10 | API tarafı iyi; birçok yerde sessiz catch. |
| Store / yasal uyumluluk | 5/10 | Terms/Privacy linkleri yok; Facebook config eksik. |
| Dokümantasyon ve bakım | 6/10 | README var; env ve deploy notları zayıf. |

**Ortalama:** ~6.5/10

**Yorum:** Uygulama günlük kullanım ve demo için “çalışır” durumda; ancak store teslimi ve uzun vadeli bakım için yukarıdaki kritik maddelerin tamamlanması gerekir. Kritik konfigürasyonlar ve en azından temel testler eklendikten sonra puan 7.5–8 bandına çıkabilir.

---

## 5. Öncelik Sırası Özeti

1. **Hemen:** Release signing (Android), Facebook ID/Token, Terms/Privacy/Cookies tıklanabilir URL’ler, production API URL.
2. **Kısa vadede:** Widget testini düzeltme/kaldırma, en az 1–2 kritik servis için unit test, sessiz catch’lere log veya kullanıcı mesajı.
3. **Orta vadede:** Profil fotoğrafı (veya UI’dan kaldırma), Crashlytics/Sentry, ortam config’i, erişilebilirlik.

Bu doküman teslim öncesi checklist olarak kullanılabilir; her madde tamamlandıkça işaretlenebilir.
