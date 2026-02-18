#!/usr/bin/env python3
import json
import re

# Read AppStrings file
with open('lib/core/constants/app_strings.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

translations = {}
i = 0
while i < len(lines):
    line = lines[i]
    
    # Check if this line has a static String get
    if 'static String get' in line and '=>' in line:
        # Extract the string value
        # Handle single line declarations
        match = re.search(r"=> (['\"])(.+?)\1\.tr", line)
        if match:
            key = match.group(2).replace("\\'", "'").replace('\\"', '"').replace('\\n', '\n')
            translations[key] = key
        else:
            # Might be multiline, collect until we find .tr
            full_line = line
            j = i + 1
            while j < len(lines) and '.tr' not in full_line:
                full_line += lines[j]
                j += 1
            
            # Now try to extract
            match = re.search(r"=> (['\"])(.+?)\1\.tr", full_line, re.DOTALL)
            if match:
                key = match.group(2).replace("\\'", "'").replace('\\"', '"').replace('\\n', '\n')
                translations[key] = key
    
    i += 1

print(f"Found {len(translations)} translations")

# Save English
with open('assets/translations/en_US.json', 'w', encoding='utf-8') as f:
    json.dump(translations, f, ensure_ascii=False, indent=2, sort_keys=True)

print("English translations saved!")
