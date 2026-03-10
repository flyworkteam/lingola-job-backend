# Senior Code Review — Lingola App

**Tarih:** Mart 2026  
**Kapsam:** Mimari, state management, servisler, güvenlik, test, bakım kolaylığı.

---

## Genel Puan: **6.8 / 10**

Ürün odaklı, çalışan bir dil öğrenme uygulaması; Riverpod, go_router ve temiz View/Service/Repository ayrımı var. Eksikler özellikle test, tutarlı hata yönetimi, gizli veri yönetimi ve state/preferences tekilleştirmede. Production’a çıkmadan önce bu alanların güçlendirilmesi önerilir.

---

## Güçlü Yönler

- **Mimari:** View / Services / Repositories / Models ayrımı net. API `ApiResult<T>` ile sarmalanmış; auth, API ve kelime servisleri tek sorumlulukla ayrılmış.
- **State management:** Riverpod kullanımı (Provider, StateNotifierProvider, ChangeNotifierProvider) doğru. Typed route args (örn. `HomeRouteArgs`, `LearnWordPracticeArgs`) ile go_router kullanımı iyi.
- **Çoklu dil:** easy_localization + çok sayıda locale (tr, en, de, fr, es, it, pt, ru, ja, ko, hi) destekleniyor.
- **Auth:** Firebase Auth + Google + Facebook + e-posta/şifre; iptal ve hata mesajları string ile dönülüyor, kullanılabilir.
- **Tema:** `AppTheme`, `AppTypography`, `colors.dart`, `spacing.dart` ile tutarlı UI altyapısı var.
- **Lint:** `flutter_lints` ile analyzer kuralları açık.

---

## Eksikler ve İyileştirme Önerileri

### 1. Test (Kritik)

| Durum | Öneri |
|--------|--------|
| Sadece 1 widget testi (`SplashScreen`) | En az: API/Auth/Repository için unit testler, kritik ekranlar için widget testleri, 1–2 kritik akış için integration test. |
| Coverage yok | `flutter test --coverage` ve CI’da minimum coverage hedefi (örn. %50). |
| Servisler singleton, mock zor | `ApiService` / `AuthService` için interface + dependency injection (Riverpod üzerinden) ekleyerek testte mock’lanabilir yap. |

### 2. Gizli Veri ve Ortam (Kritik)

| Sorun | Öneri |
|--------|--------|
| RevenueCat API key `main.dart` içinde sabit | `--dart-define=REVENUECAT_API_KEY=...` veya flavor’a göre config; key’i repo’da tutma. |
| Firebase keys `firebase_options.dart` içinde (kabul edilebilir ama risk) | Production’da Firebase’i farklı projede kullan; keys’i CI’da inject etmeyi düşün. |
| `API_BASE_URL` default local IP | Default’u production URL veya boş bırak; geliştirme için sadece `--dart-define` kullan. |

### 3. Preferences ve State Tutarlılığı (Yüksek)

| Sorun | Öneri |
|--------|--------|
| `profile_name`, `profile_level`, `profile_profession` vb. key’ler birçok dosyada tekrarlanıyor (`MainView`, `ProfileSettingsView`, `Onboarding2View`, `DailyTestView`, `WordPracticeView`, `ReadingTestView`, `MostFrequentlyUsedTermsView`). | Tek bir `PreferencesKeys` (veya `lib/src/config/preferences_keys.dart`) tanımla; tüm okuma/yazmaları bu key’ler üzerinden yap. |
| Bazı yerler string literal (`'profile_profession'`), bazı yerler `_keyProfileProfession` | Tüm projede aynı sabitleri kullan; typo ve tutarsızlık riskini kaldır. |
| Hem Riverpod hem `ChangeNotifier` store’lar (saved_words_store, practice_words_store, xp_store) | Uzun vadede tüm UI-relevant state’i Riverpod’a taşıyıp tek pattern’e indirge; ya da store’ları net bir “local persistence layer” olarak dokümante et. |

### 4. Hata Yönetimi (Yüksek)

| Sorun | Öneri |
|--------|--------|
| `ApiResult` kullanılıyor ama birçok çağrı yerde hata kullanıcıya gösterilmiyor. | Tüm API çağrılarında en az SnackBar/dialog ile `result.error` göster; kritik akışlarda retry/offline mesajı ekle. |
| `NotificationActivityService.pingActivity()` ve `onTokenRefresh` içinde `catch (_) {}` / `.ignore()` | Hataları logla (örn. `debugPrint` veya crash reporting); isteğe bağlı olarak kullanıcıya “Bildirimler güncellenemedi” gibi bilgi ver. |
| Bazı `SharedPreferences` / dosya erişimleri try/catch ile sessizce yutuluyor | Hata durumunda fallback değer kullan ve gerekirse log/crash report. |

### 5. Kod Tekrarı ve Bakım (Orta)

| Sorun | Öneri |
|--------|--------|
| TTS (FlutterTts) kurulumu (volume, speechRate, language, errorHandler) birçok ekranda neredeyse aynı. | Ortak bir `TtsHelper` veya `WordTtsController` ile tek yerde topla; view’lar sadece “şu metni oku” desin. |
| Profil bilgisi (isim, dil, seviye, meslek) hem MainView’da hem ProfileSettings’te okunuyor. | Profil state’ini tek bir Riverpod provider’da (ör. `profilePreferencesProvider`) topla; ekranlar bu provider’ı dinlesin. |

### 6. Erişilebilirlik ve UX (Orta)

| Eksik | Öneri |
|--------|--------|
| Semantik etiketler (Semantics) kullanımı belirgin değil. | Özellikle butonlar, kartlar ve liste öğeleri için `Semantics(label: ...)` ekle; screen reader uyumluluğunu artır. |
| Loading/skeleton tutarlılığı | API beklerken ortak bir loading/skeleton pattern’i (örn. `AsyncValue` + ortak widget) kullan. |

### 7. Performans (Düşük–Orta)

| Not | Öneri |
|--------|--------|
| Büyük JSON’lar (words, translations, phonetics) asset veya dosyadan yükleniyor. | İlk açılışta gerekirse lazy load veya sayfalama; çok büyük listelerde `ListView.builder` kullanıldığından emin ol. |
| Backend’e sık istek riski | Gerekli yerde cache (memory veya disk) ve throttle/debounce düşün. |

### 8. Dokümantasyon ve Onboarding (Düşük)

| Eksik | Öneri |
|--------|--------|
| README’de kurulum, env değişkenleri ve çalıştırma adımları kısa. | `README.md`: `API_BASE_URL`, RevenueCat key, Firebase, Facebook/Google config özeti; `flutter run` ve build komutları. |
| Karmaşık akışlar (örn. Learn tab nested Navigator, pending route) kod içi yorumla anlatılmış; üst seviye akış dokümanı yok. | `docs/ARCHITECTURE.md` veya `docs/NAVIGATION.md` ile kısa mimari ve navigasyon özeti ekle. |

---

## Özet Tablo

| Kategori            | Puan (1–10) | Not |
|---------------------|-------------|-----|
| Mimari / yapı       | 7.5         | Net katman ayrımı, API result pattern. |
| State management    | 7.0         | Riverpod iyi kullanılmış; preferences ve store’lar dağınık. |
| Test                | 2.0         | Neredeyse yok; en büyük açık. |
| Güvenlik / secrets  | 5.0         | Key’ler kodda; env/flavor ile iyileştirilmeli. |
| Hata yönetimi       | 5.5         | ApiResult var; UI’da tutarlı kullanım ve loglama eksik. |
| Bakım / tekrar      | 6.0         | Preferences ve TTS tekrarı; merkezi key ve helper ile düzelir. |
| Dokümantasyon       | 5.0         | README var; env ve mimari detay artırılabilir. |

---

## Öncelik Sırasıyla Aksiyonlar

1. **RevenueCat ve API base URL’i** ortam değişkeni / dart-define ile dışarı al; dokümante et.
2. **Preferences key’lerini** tek dosyada topla ve tüm kullanımları buna geçir.
3. **ApiResult** kullanan tüm UI noktalarında hata mesajı gösterimi ekle (SnackBar/dialog).
4. **Auth ve Api servisleri** için interface + Riverpod ile DI; ardından **en az 5–10 unit test** yaz.
5. **TTS kurulumunu** tek helper’da topla.
6. **NotificationActivityService** hata durumunda log (ve isteğe bağlı kullanıcı bilgisi).
7. **Widget testleri:** Login, Home, en az bir Learn ekranı.
8. **README + kısa ARCHITECTURE/NAVIGATION** dokümanı.

Bu rapor, projenin mevcut haliyle “çalışan MVP” seviyesinde olduğunu; production ve takım büyümesi için test, gizli veri yönetimi ve hata/preferences tutarlılığının güçlendirilmesi gerektiğini özetler.
