import json

translations = {
    "ta_IN": {
        "home": "முகப்பு",
        "matrimony": "திருமணம்",
        "chat": "அரட்டை",
        "call": "அழைப்பு",
        "live": "நேரலை",
        "matching": "பொருத்தம்"
    },
    "bn_IN": {
        "home": "হোম",
        "matrimony": "বিবাহ",
        "chat": "চ্যাট",
        "call": "কল",
        "live": "লাইভ",
        "matching": "ম্যাচিং"
    },
    "te_IN": {
        "home": "హోమ్",
        "matrimony": "వివాహం",
        "chat": "చాట్",
        "call": "కాల్",
        "live": "లైవ్",
        "matching": "మ్యాచ్ మేకింగ్"
    },
    "mr_IN": {
        "home": "होम",
        "matrimony": "विवाह",
        "chat": "चॅट",
        "call": "कॉल",
        "live": "लाईव्ह",
        "matching": "जुळणी"
    },
    "kn_IN": {
        "home": "ಹೋಮ್",
        "matrimony": "ವಿವಾಹ",
        "chat": "ಚಾಟ್",
        "call": "ಕಾಲ್",
        "live": "ಲೈವ್",
        "matching": "ಹೊಂದಾಣಿಕೆ"
    },
    "gu_IN": {
        "home": "હોમ",
        "matrimony": "વિવાહ",
        "chat": "ચેટ",
        "call": "કૉલ",
        "live": "લાઇવ",
        "matching": "મેચિંગ"
    },
    "ml_IN": {
        "home": "ഹോം",
        "matrimony": "വിവാഹം",
        "chat": "ചാറ്റ്",
        "call": "കോൾ",
        "live": "ലൈവ്",
        "matching": "മാച്ചിംഗ്"
    }
}

for lang_code, trans_dict in translations.items():
    filename = f"{lang_code}.json"
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for k, v in trans_dict.items():
            data[k] = v
            
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write('\n')
        print(f"Updated {filename}")
    except Exception as e:
        print(f"Failed to update {filename}: {e}")

