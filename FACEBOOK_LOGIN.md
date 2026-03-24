# Facebook ile giriş – yapılacaklar

Backend zaten Firebase ID token ile doğrulama yaptığı için **sunucu tarafında ek işlem yok**. Aşağıdakileri yapmanız yeterli.

## 1. Facebook Developer Console

1. [developers.facebook.com](https://developers.facebook.com) → **My Apps** → **Create App** (veya mevcut uygulama).
2. **Use case**: "Consumer" veya "Other" seçin.
3. Uygulama oluşturulunca sol menüden **Facebook Login** → **Settings**.
4. **Valid OAuth Redirect URIs** kısmına Firebase’den alacağınız URI’yi ekleyeceksiniz (3. adımda).
5. Sol menü **Settings** → **Basic**:
   - **App ID**
   - **App Secret** (Firebase’e gireceksiniz)
   - **Client token** (görmek için "Show" deyin) – bunu hem Android hem iOS’ta kullanacaksınız.

## 2. Firebase Console

1. [Firebase Console](https://console.firebase.google.com) → projeniz → **Authentication** → **Sign-in method**.
2. **Facebook** satırına tıklayın → **Enable**.
3. Facebook’tan kopyaladığınız **App ID** ve **App Secret**’ı yapıştırın.
4. **Save** deyin. Açılan pencerede **Authorized redirect URI**’yi kopyalayın (örn. `https://...firebaseapp.com/__/auth/handler`).
5. Bu URI’yi Facebook Developer → **Facebook Login** → **Settings** → **Valid OAuth Redirect URIs** kısmına ekleyin ve **Save Changes** deyin.

## 3. Flutter uygulaması (lingola_app)

Kod tarafı hazır. Sadece **App ID** ve **Client token** değerlerini koymanız gerekiyor:

### Android

- `lingola_app/android/app/src/main/res/values/strings.xml`
  - `YOUR_FACEBOOK_APP_ID` → Facebook **App ID**
  - `YOUR_FACEBOOK_CLIENT_TOKEN` → Facebook **Client token**

### iOS

- `lingola_app/ios/Runner/Info.plist`
  - Tüm `YOUR_FACEBOOK_APP_ID` → Facebook **App ID**
  - `fbYOUR_FACEBOOK_APP_ID` → `fb` + App ID (örn. `fb123456789012345`)
  - `YOUR_FACEBOOK_CLIENT_TOKEN` → Facebook **Client token**

## 4. Bağımlılık

Flutter projesinde:

```bash
cd lingola_app && flutter pub get
```

---

Özet: **Facebook**’ta uygulama + App ID/Secret/Client token → **Firebase**’te Facebook provider + redirect URI → **Facebook**’ta bu URI’yi ekle → **Flutter**’da Android/iOS’ta App ID ve Client token’ı doldur. Backend değişikliği gerekmez.
