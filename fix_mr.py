import json

# Read the file and find where the issue is
with open('assets/translations/mr_IN.json', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the first closing brace position
first_brace = content.find('\n},')
if first_brace > 0:
    # Keep everything before the extra closing brace
    content = content[:first_brace+1] + '\n}'
    
with open('assets/translations/mr_IN.json', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed!")
