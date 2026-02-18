
import json
import os
import re

def strict_sync():
    app_strings_path = '/Users/firozmohammad/Astrology/astro_user/lib/core/constants/app_strings.dart'
    assets_dir = '/Users/firozmohammad/Astrology/astro_user/assets/translations'
    
    # 1. Extract CURRENT ACTIVE keys from AppStrings.dart
    print("Scraping AppStrings.dart for active keys...")
    with open(app_strings_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Match patterns like 'Some String'.tr or "Some String".tr
    matches = re.findall(r"(['\"])(.*?)(?<!\\)\1\.tr", content)
    master_keys = set(m[1].replace("\\'", "'").replace('\\"', '"') for m in matches)
    
    print(f"Master Key List: {len(master_keys)} active keys found.")
    
    # 2. Process EVERY JSON file strictly
    json_files = [f for f in os.listdir(assets_dir) if f.endswith('.json')]
    
    print(f"\nProcessing {len(json_files)} files...")
    report = []
    report.append(f"{'Language File':<15} | {'Final Count':<12} | {'Cleaned (Removed)':<18}")
    report.append("-" * 55)
    
    for filename in sorted(json_files):
        filepath = os.path.join(assets_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            existing_data = json.load(f)
        
        # Create new data map ONLY from master keys
        new_data = {}
        removed_count = 0
        
        # First, preserve existing translations for master keys
        for key in master_keys:
            if key in existing_data:
                new_data[key] = existing_data[key]
            else:
                new_data[key] = key # Fallback to key itself
        
        # Count how many keys were removed (legacy/unused)
        for key in existing_data:
            if key not in master_keys:
                removed_count += 1
                
        # Sort keys alphabetically
        sorted_data = dict(sorted(new_data.items(), key=lambda item: item[0].lower()))
        
        # Write back (Overwrite)
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(sorted_data, f, ensure_ascii=False, indent=2)
            
        report.append(f"{filename:<15} | {len(sorted_data):<12} | {removed_count:<18}")
        
    print("\n".join(report))
    print("\nSUCCESS: All files now have the exact same key count based on AppStrings.dart.")

if __name__ == "__main__":
    strict_sync()
