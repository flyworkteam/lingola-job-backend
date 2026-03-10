#!/usr/bin/env node
/**
 * words.json'daki ilk 13.000 kelime için TÜM dillerde (tr, de, fr, es, it, pt, ru, ja, ko, hi)
 * eksik çevirileri LibreTranslate API ile doldurur.
 * Mevcut word_translations_XX.json dosyaları korunur, sadece eksik kelimeler eklenir.
 *
 * Kullanım:
 *   node tool/fill_all_translations.js              # Tüm diller, tüm 13k kelime
 *   node tool/fill_all_translations.js --lang=ja    # Sadece Japonca
 *   node tool/fill_all_translations.js --limit=1000 # İlk 1000 kelime (test)
 *   node tool/fill_all_translations.js --dry-run    # Sadece eksikleri listele
 *   node tool/fill_all_translations.js --parallel=4 # 4 dili aynı anda işle (hızlandırma)
 *
 * Ücretsiz mod (API anahtarı yok): npm install sonra node tool/fill_all_translations.js
 * Tüm çeviriler LOCAL assets/word_translations_XX.json dosyalarına yazılır.
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const ASSETS = path.join(__dirname, '../assets');
const WORD_LIST_PATH = path.join(ASSETS, 'words.json');
const TOTAL_WORDS_NEEDED = 13000; // Uygulamanın kullandığı kelime sayısı

const LANGUAGES = [
  { code: 'en', name: 'English' },
  { code: 'tr', name: 'Turkish' },
  { code: 'de', name: 'German' },
  { code: 'fr', name: 'French' },
  { code: 'es', name: 'Spanish' },
  { code: 'it', name: 'Italian' },
  { code: 'pt', name: 'Portuguese' },
  { code: 'ru', name: 'Russian' },
  { code: 'ja', name: 'Japanese' },
  { code: 'ko', name: 'Korean' },
  { code: 'hi', name: 'Hindi' },
];

const BATCH_SIZE = 30;
const DELAY_MS = 3000;
const DELAY_MS_FREE = 250;
const LIBRE_URL = 'libretranslate.com';
const MAX_RETRIES = 3;

function getArgs() {
  const args = { lang: null, limit: null, dryRun: false, parallel: 20 };
  for (const a of process.argv.slice(2)) {
    if (a.startsWith('--lang=')) args.lang = a.slice(7).toLowerCase();
    else if (a.startsWith('--limit=')) args.limit = parseInt(a.slice(8), 10) || null;
    else if (a.startsWith('--parallel=')) args.parallel = Math.max(1, parseInt(a.slice(11), 10) || 4);
    else if (a === '--dry-run') args.dryRun = true;
  }
  return args;
}

function loadWords(limit = TOTAL_WORDS_NEEDED) {
  const list = JSON.parse(fs.readFileSync(WORD_LIST_PATH, 'utf8'));
  const words = [];
  for (let i = 0; i < Math.min(list.length, limit); i++) {
    const w = (list[i].word || '').trim().toLowerCase();
    if (w) words.push(w);
  }
  return [...new Set(words)];
}

function loadExistingTranslations(langCode) {
  const p = path.join(ASSETS, `word_translations_${langCode}.json`);
  if (!fs.existsSync(p)) return {};
  try {
    return JSON.parse(fs.readFileSync(p, 'utf8'));
  } catch {
    return {};
  }
}

function saveTranslations(langCode, map) {
  const p = path.join(ASSETS, `word_translations_${langCode}.json`);
  fs.writeFileSync(p, JSON.stringify(map, null, 2), 'utf8');
}

async function translateOneFree(word, targetLang) {
  try {
    const translate = require('translate');
    translate.engine = 'google';
    const out = await translate(word, { from: 'en', to: targetLang });
    return (out && String(out).trim()) || word;
  } catch (e) {
    return word;
  }
}

function translateBatch(texts, targetLang, apiKey) {
  return new Promise((resolve, reject) => {
    const payload = { q: texts, source: 'en', target: targetLang };
    if (apiKey) payload.api_key = apiKey;
    const body = JSON.stringify(payload);
    const req = https.request(
      {
        hostname: LIBRE_URL,
        path: '/translate',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(body),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (ch) => (data += ch));
        res.on('end', () => {
          if (res.statusCode !== 200) {
            reject(new Error(`HTTP ${res.statusCode}: ${data}`));
            return;
          }
          try {
            const j = JSON.parse(data);
            const out = j.translatedText;
            const arr = Array.isArray(out) ? out : [out];
            resolve(arr);
          } catch (e) {
            reject(e);
          }
        });
      }
    );
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function fillLanguage(langCode, allWords, dryRun, apiKey) {
  const existing = loadExistingTranslations(langCode);
  const missing = allWords.filter((w) => !(existing[w] && existing[w].trim()));
  if (missing.length === 0) {
    console.log(`  [${langCode}] Zaten tam, atlanıyor.`);
    return;
  }
  console.log(`  [${langCode}] Eksik: ${missing.length} kelime.`);

  if (dryRun) return;

  const result = { ...existing };

  if (langCode === 'en') {
    for (const w of missing) result[w] = w;
    saveTranslations(langCode, result);
    console.log(`  [en] İngilizce: kelime aynen (API yok), ${missing.length} eklendi.`);
    return;
  }

  if (apiKey) {
    let done = 0;
    for (let i = 0; i < missing.length; i += BATCH_SIZE) {
      const batch = missing.slice(i, i + BATCH_SIZE);
      let ok = false;
      for (let r = 0; r < MAX_RETRIES && !ok; r++) {
        try {
          const translated = await translateBatch(batch, langCode, apiKey);
          for (let j = 0; j < batch.length; j++) {
            result[batch[j]] = (translated[j] && String(translated[j]).trim()) || batch[j];
          }
          done += batch.length;
          process.stdout.write(`\r  [${langCode}] ${done}/${missing.length}   `);
          ok = true;
        } catch (e) {
          if (e.message && e.message.includes('429')) {
            await sleep(15000);
            continue;
          }
          console.error(`\n  [${langCode}] Hata (batch ${i}-${i + batch.length}):`, e.message);
          break;
        }
      }
      if (!ok) break;
      await sleep(DELAY_MS);
    }
  } else {
    console.log(`  [${langCode}] Ücretsiz mod (Google), kelime kelime...`);
    for (let i = 0; i < missing.length; i++) {
      const w = missing[i];
      result[w] = await translateOneFree(w, langCode);
      process.stdout.write(`\r  [${langCode}] ${i + 1}/${missing.length}   `);
      await sleep(DELAY_MS_FREE);
      if ((i + 1) % 500 === 0) saveTranslations(langCode, result);
    }
  }

  saveTranslations(langCode, result);
  console.log(`\n  [${langCode}] Kaydedildi: ${path.join(ASSETS, `word_translations_${langCode}.json`)}`);
}

function chunk(arr, n) {
  const out = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

async function main() {
  const { lang, limit, dryRun, parallel } = getArgs();
  const apiKey = process.env.LIBRE_API_KEY || process.env.LIBRE_TRANSLATE_API_KEY || '';
  if (!dryRun && !apiKey) {
    console.log('Mod: Ücretsiz (Google çeviri, API anahtarı gerekmez).');
    console.log('Çeviriler local assets/word_translations_XX.json dosyalarına yazılacak.\n');
  }

  console.log('Kelime listesi yükleniyor...');
  const allWords = loadWords(limit || TOTAL_WORDS_NEEDED);
  console.log(`Toplam kelime (limit: ${limit || TOTAL_WORDS_NEEDED}): ${allWords.length}`);

  const langs = lang ? LANGUAGES.filter((l) => l.code === lang) : LANGUAGES;
  if (langs.length === 0) {
    console.log('Geçersiz --lang. Örnek: --lang=tr');
    process.exit(1);
  }

  if (dryRun) console.log('(Dry-run: sadece eksikler listeleniyor, çeviri yapılmayacak)\n');
  if (!dryRun && langs.length > 1 && parallel > 1) {
    const actual = Math.min(parallel, langs.length);
    console.log(`Paralel mod: ${actual} dil aynı anda işlenecek.\n`);
  }

  if (parallel <= 1 || langs.length === 1) {
    for (const { code, name } of langs) {
      console.log(`\nDil: ${name} (${code})`);
      await fillLanguage(code, allWords, dryRun, apiKey || null);
    }
  } else {
    const groups = chunk(langs, parallel);
    for (const group of groups) {
      await Promise.all(
        group.map(async ({ code, name }) => {
          console.log(`\nDil: ${name} (${code})`);
          await fillLanguage(code, allWords, dryRun, apiKey || null);
        })
      );
    }
  }

  console.log('\nBitti.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
