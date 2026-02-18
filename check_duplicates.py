#!/usr/bin/env python3
import re
from collections import Counter

# Read AppStrings
with open('lib/core/constants/app_strings.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find all translation strings
strings = []
for match in re.finditer(r"=> (['\"])(.+?)\1\.tr", content, re.DOTALL):
    key = match.group(2).replace("\\'", "'").replace('\\"', '"').replace('\\n', '\n')
    strings.append(key)

# Count duplicates
counter = Counter(strings)
duplicates = {k: v for k, v in counter.items() if v > 1}

print(f"Total getter declarations: {len(strings)}")
print(f"Unique strings: {len(counter)}")
print(f"Duplicate strings: {len(duplicates)}")

if duplicates:
    print("\nDuplicate strings:")
    for string, count in sorted(duplicates.items(), key=lambda x: -x[1])[:10]:
        print(f"  {count}x: {string[:60]}")
