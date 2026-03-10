# Facebook "URL'ye izin vermiyor" Hatası – Platform Ekleme

Bu hata, Facebook uygulama ayarlarında **cihaza özel platform** (iOS / Android) tanımlı olmadığı için çıkar. Aşağıdaki adımları uygulayın.

## 1. Facebook Developer Console

1. [developers.facebook.com](https://developers.facebook.com) → **My Apps** → **Lingola App**
2. Sol menüden **Use cases** veya **Products** bölümüne girin.
3. **Facebook Login** → **Settings** (Ayarlar) sayfasına gidin.
4. Aşağı kaydırıp **Platform** bölümüne bakın. Burada **iOS** ve **Android** kartları olmalı.

---

## 2. iOS platformu ekleyin / kontrol edin

1. **Settings** → **Basic** sayfasında değil; **Facebook Login** → **Settings** sayfasında, aşağıda **iOS** bölümüne gidin.
2. **Add Platform** (Platform Ekle) varsa **iOS** seçin; zaten **iOS** varsa **Edit** deyin.
3. Şunları girin:
   - **Bundle ID:** `com.flywork.lingolajobapp.dev`  
     (Release build kullanıyorsanız ve bundle ID farklıysa — Xcode’da **Runner** target → **General** → **Bundle Identifier** — oradaki değeri yazın.)
   - **Single Sign On** isteğe bağlı; açık bırakabilirsiniz.
4. **Save** / **Save Changes** deyin.

---

## 3. Android platformu ekleyin / kontrol edin

1. Aynı **Facebook Login** → **Settings** sayfasında **Android** bölümüne gidin.
2. **Add Platform** → **Android** veya mevcut Android satırında **Edit**.
3. Şunları girin:
   - **Package Name:** `com.flywork.lingolajobapp`
   - **Key Hashes:** Geliştirme için debug key hash gerekir. Aşağıda nasıl alınacağı var.
4. **Save** deyin.

### Android Key Hash nasıl alınır?

**Mac/Linux (debug key):**
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android | openssl sha1 -binary | openssl base64
```

Çıkan satırı (örn. `AbCdEf1234...`) kopyalayıp **Key Hashes** alanına yapıştırın. Birden fazla hash ekleyebilirsiniz (virgül veya her satıra bir tane, arayüze göre değişir).

**Windows (debug key):**  
`debug.keystore` genelde `C:\Users\KULLANICI\.android\` altındadır. Aynı `keytool` ve `openssl` komutunu Windows’ta da (Git Bash veya WSL ile) çalıştırabilirsiniz.

---

## 4. Kontrol

- Ayarları kaydettikten sonra **birkaç dakika** bekleyin.
- Uygulamayı **tamamen kapatıp** yeniden açın.
- Tekrar **Facebook ile giriş** deneyin.

Hâlâ aynı hata çıkarsa:
- Kullandığınız cihaz **iOS** ise: Bundle ID’nin `com.flywork.lingolajobapp.dev` ile birebir aynı olduğundan emin olun (Xcode’da kontrol edin).
- **Android** ise: Package name `com.flywork.lingolajobapp` ve kullandığınız keystore’un key hash’i Facebook’ta kayıtlı olsun.
