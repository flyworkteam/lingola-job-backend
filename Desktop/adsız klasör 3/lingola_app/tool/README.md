# Çeviri araçları

## Her kelime için her dilde çeviri — hepsi LOCAL saklanır

Uygulama **ilk 13.000 İngilizce kelimeyi** kullanıyor. Bu kelimelerin **hepsinin** her dilde çevirisini **local** `assets/word_translations_XX.json` dosyalarına yazmak için bu script kullanılır. **API anahtarı gerekmez.**

### 1. Eksikleri listele (çeviri yapmadan)

```bash
node tool/fill_all_translations.js --dry-run
```

### 2. Çevirileri doldur (ücretsiz, local’e yazar)

```bash
npm install
node tool/fill_all_translations.js
```

- **Ücretsiz mod:** Google çeviri kullanılır, API anahtarı yok. Çeviriler doğrudan `assets/word_translations_tr.json`, `word_translations_ja.json` vb. dosyalarına **local** yazılır.
- Mevcut dosyalar korunur, sadece eksik kelimeler eklenir.
- Kelime kelime çevrildiği için tam 13k×10 dil uzun sürebilir; her 500 kelimede dosya kaydedilir (yarıda kesersen kayıtlar durur).

**Sadece bir dil (ör. Japonca):**

```bash
node tool/fill_all_translations.js --lang=ja
```

**Test (ilk 500 kelime):**

```bash
node tool/fill_all_translations.js --limit=500
```

**Paralel mod (4 dili aynı anda — daha hızlı):**

```bash
node tool/fill_all_translations.js --parallel=4
```

Varsayılan 4. Google rate limit alırsan `--parallel=2` dene.

### 3. İsteğe bağlı: LibreTranslate (ücretli, daha hızlı)

LibreTranslate portal artık ücretli ($29/ay). Anahtarınız varsa:

```bash
LIBRE_API_KEY=your-key node tool/fill_all_translations.js
```

### 4. Çıktı

Tüm çeviriler **local** `assets/word_translations_XX.json` dosyalarında. Uygulama sadece bu dosyaları okur; çalışırken hiçbir çeviri API’sine istek atılmaz.
