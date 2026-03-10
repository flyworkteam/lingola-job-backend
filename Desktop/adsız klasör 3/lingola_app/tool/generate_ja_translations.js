#!/usr/bin/env node
/**
 * word_translations_tr.json'daki İngilizce kelimeleri MyMemory API ile Japoncaya çevirir,
 * word_translations_ja.json oluşturur.
 * Kullanım: node tool/generate_ja_translations.js
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const trPath = path.join(__dirname, '../assets/word_translations_tr.json');
const outPath = path.join(__dirname, '../assets/word_translations_ja.json');

const tr = JSON.parse(fs.readFileSync(trPath, 'utf8'));
const words = Object.keys(tr);

function translate(word) {
  return new Promise((resolve, reject) => {
    const url = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(word)}&langpair=en|ja`;
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const j = JSON.parse(data);
          const translated = j.responseData?.translatedText || word;
          resolve(translated);
        } catch (e) {
          resolve(word);
        }
      });
    }).on('error', reject);
  });
}

async function main() {
  const result = {};
  const delay = (ms) => new Promise((r) => setTimeout(r, ms));
  for (let i = 0; i < words.length; i++) {
    const w = words[i];
    try {
      result[w] = await translate(w);
      process.stdout.write(`\r${i + 1}/${words.length} ${w} -> ${result[w]}   `);
    } catch (e) {
      result[w] = w;
    }
    await delay(300);
  }
  fs.writeFileSync(outPath, JSON.stringify(result, null, 2), 'utf8');
  console.log(`\nYazıldı: ${outPath}`);
}

main().catch(console.error);
