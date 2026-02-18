#!/usr/bin/env python3
import json
import re

# Read AppStrings
with open('lib/core/constants/app_strings.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Read generated JSON
with open('assets/translations/en_US.json', 'r', encoding='utf-8') as f:
    generated = json.load(f)

# Find all getter names
getters = re.findall(r'static String get (\w+) =>', content)
print(f"Total getters found: {len(getters)}")
print(f"Total translations generated: {len(generated)}")
print(f"Difference: {len(getters) - len(generated)}")

# Find which strings are in the file but not in JSON
all_strings_in_file = set()
for match in re.finditer(r"=> (['\"])(.+?)\1\.tr", content, re.DOTALL):
    key = match.group(2).replace("\\'", "'").replace('\\"', '"').replace('\\n', '\n')
    all_strings_in_file.add(key)

print(f"\nUnique strings in file: {len(all_strings_in_file)}")

missing = all_strings_in_file - set(generated.keys())
if missing:
    print(f"\nMissing {len(missing)} strings:")
    for m in sorted(missing)[:10]:
        print(f"  - {m[:80]}")
