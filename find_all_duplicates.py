#!/usr/bin/env python3
import re
from collections import defaultdict

# Read AppStrings
with open('lib/core/constants/app_strings.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find all getters with their strings
getters_map = defaultdict(list)
for match in re.finditer(r"static String get (\w+) => (['\"])(.+?)\2\.tr", content, re.DOTALL):
    getter_name = match.group(1)
    string_value = match.group(3).replace("\\'", "'").replace('\\"', '"').replace('\\n', '\n')
    getters_map[string_value].append(getter_name)

# Find duplicates
duplicates = {k: v for k, v in getters_map.items() if len(v) > 1}

print(f"Found {len(duplicates)} duplicate strings:\n")
for string, getters in sorted(duplicates.items()):
    print(f"String: '{string}'")
    print(f"  Used by: {', '.join(getters)}")
    print()
