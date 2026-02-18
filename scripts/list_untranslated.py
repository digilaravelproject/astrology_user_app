
import json
import os

def list_untranslated():
    assets_dir = '/Users/firozmohammad/Astrology/astro_user/assets/translations'
    target_langs = ['hi_IN.json', 'gu_IN.json', 'kn_IN.json']
    
    for lang in target_langs:
        filepath = os.path.join(assets_dir, lang)
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        untranslated = [k for k, v in data.items() if k == v]
        print(f"\n--- {lang} Untranslated ({len(untranslated)} keys) ---")
        # Print first 20 as sample
        for k in untranslated[:30]:
            print(f"  - {k}")
        if len(untranslated) > 30:
            print(f"  ... and {len(untranslated)-30} more")

if __name__ == "__main__":
    list_untranslated()
