# Facebook ile girişi açmak

**App ID** projeye eklendi. Sadece **Client token** değerini eklemeniz kaldı.

> **Not:** **App Secret** uygulama içine yazılmaz; sadece Firebase Console ve Facebook ayarlarında kullanılır. Uygulama için **Client token** gerekir (Facebook → Settings → Basic → "Client token" / Show).

## 1. Facebook’tan Client token alın

1. [developers.facebook.com](https://developers.facebook.com) → **My Apps** → uygulamanızı seçin.
2. Sol menü **Settings** → **Basic**.
3. **Client token** satırında **Show** deyip değeri kopyalayın (App Secret’tan farklıdır).

Ayrıca **Facebook Login** ürününü ekleyin: **Use cases** / **Add Products** → **Facebook Login** → **Set up**.

## 2. Firebase’de Facebook’u açın

1. [Firebase Console](https://console.firebase.google.com) → projeniz → **Authentication** → **Sign-in method**.
2. **Facebook** → **Enable**.
3. **App ID** ve **App Secret** (Facebook Settings → Basic’ten) girin, **Save**.
4. Çıkan **Authorized redirect URI**’yi kopyalayın.
5. Facebook Developer → **Facebook Login** → **Settings** → **Valid OAuth Redirect URIs**’e bu URI’yi ekleyin, **Save**.

## 3. Lingola uygulamasında Client token ekleyin

**App ID (2197501337662982)** zaten eklendi. Sadece **Client token**’ı aşağıdaki dosyalarda `YOUR_FACEBOOK_CLIENT_TOKEN` yerine yazın.

### Android

Dosya: **`android/app/src/main/res/values/strings.xml`**

- `YOUR_FACEBOOK_CLIENT_TOKEN` → Facebook’tan kopyaladığınız **Client token**.

### iOS

Dosya: **`ios/Runner/Info.plist`**

- `YOUR_FACEBOOK_CLIENT_TOKEN` → aynı **Client token**.

## 4. Android Key Hash (gerekirse)

Facebook bazen “Key hash bulunamadı” hatası verir. O zaman:

1. Release key hash:  
   `keytool -exportcert -alias YOUR_KEY_ALIAS -keystore ~/path/to/keystore.jks | openssl sha1 -binary | openssl base64`
2. Debug key hash (geliştirme):  
   `keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android | openssl sha1 -binary | openssl base64`
3. Facebook Developer → **Settings** → **Basic** → **Add Platform** → **Android** → Package name: `com.flywork.lingolajobapp`, Key Hashes’e yukarıdaki hash’i ekleyin.

## 5. Kontrol

Değerleri kaydettikten sonra uygulamayı **tamamen kapatıp yeniden** çalıştırın (hot reload yeterli olmayabilir). Sonra **Facebook ile giriş** butonuna basın.

Hâlâ hata alırsanız: SnackBar’da görünen hata mesajına bakın; Facebook Developer ve Firebase ayarlarını (App ID, Secret, Redirect URI, Key Hash / Bundle ID) tekrar kontrol edin.
