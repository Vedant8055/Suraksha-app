import fs from 'fs';

const text = fs.readFileSync('lib/localization/app_localizations.dart', 'utf8');

function keysFor(lang) {
  const marker = `'${lang}': {`;
  const start = text.indexOf(marker);
  if (start < 0) return new Set();
  let i = start + marker.length;
  let depth = 1;
  while (i < text.length && depth > 0) {
    if (text[i] === '{') depth += 1;
    else if (text[i] === '}') depth -= 1;
    i += 1;
  }
  const block = text.slice(start + marker.length, i - 1);
  return new Set([...block.matchAll(/'([^']+)':/g)].map((m) => m[1]));
}

const en = keysFor('en');
const hi = keysFor('hi');
const mr = keysFor('mr');
const missingHi = [...en].filter((k) => !hi.has(k)).sort();
const missingMr = [...en].filter((k) => !mr.has(k)).sort();

console.log(`EN ${en.size} | HI ${hi.size} | MR ${mr.size}`);
console.log(`Missing in HI: ${missingHi.length}`);
console.log(missingHi.join('\n'));
console.log(`Missing in MR: ${missingMr.length}`);
console.log(missingMr.join('\n'));
