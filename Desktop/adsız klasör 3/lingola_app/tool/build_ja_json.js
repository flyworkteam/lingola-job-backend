#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const tr = JSON.parse(fs.readFileSync(path.join(__dirname, '../assets/word_translations_tr.json'), 'utf8'));
const jaDict = require('./ja_dict.js');
const out = {};
for (const en of Object.keys(tr)) {
  out[en] = jaDict[en] || en;
}
fs.writeFileSync(
  path.join(__dirname, '../assets/word_translations_ja.json'),
  JSON.stringify(out, null, 2),
  'utf8'
);
console.log('word_translations_ja.json yazıldı,', Object.keys(out).length, 'kelime.');
