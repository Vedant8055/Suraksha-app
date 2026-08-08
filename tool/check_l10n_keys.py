import re
from pathlib import Path

text = Path('lib/localization/app_localizations.dart').read_text(encoding='utf-8')

def keys_for(lang):
    m = re.search(rf"'{lang}':\s*\{{", text)
    if not m:
        return set()
    start = m.end()
    depth = 1
    i = start
    while i < len(text) and depth:
        if text[i] == '{':
            depth += 1
        elif text[i] == '}':
            depth -= 1
        i += 1
    block = text[start:i - 1]
    return set(re.findall(r"'([^']+)':", block))

en, hi, mr = keys_for('en'), keys_for('hi'), keys_for('mr')
print('EN', len(en), 'HI', len(hi), 'MR', len(mr))
print('Missing in HI', len(en - hi))
for k in sorted(en - hi):
    print('  HI missing:', k)
print('Missing in MR', len(en - mr))
for k in sorted(en - mr):
    print('  MR missing:', k)
