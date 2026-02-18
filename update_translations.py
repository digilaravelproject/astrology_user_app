#!/usr/bin/env python3
import json

# Common translations for all languages
common_additions = {
    "Success": {"hi": "सफलता", "mr": "यश", "bn": "সাফল্য", "gu": "સફળતા", "kn": "ಯಶಸ್ಸು", "ml": "വിജയം", "ta": "வெற்றி", "te": "విజయం"},
    "PRO": {"hi": "प्रो", "mr": "प्रो", "bn": "প্রো", "gu": "પ્રો", "kn": "ಪ್ರೊ", "ml": "പ്രോ", "ta": "ப்ரோ", "te": "ప్రో"},
    "Name": {"hi": "नाम", "mr": "नाव", "bn": "নাম", "gu": "નામ", "kn": "ಹೆಸರು", "ml": "പേര്", "ta": "பெயர்", "te": "పేరు"},
    "Gender": {"hi": "लिंग", "mr": "लिंग", "bn": "লিঙ্গ", "gu": "લિંગ", "kn": "ಲಿಂಗ", "ml": "ലിംഗം", "ta": "பாலினம்", "te": "లింగం"},
    "Under Development": {"hi": "विकास के अधीन", "mr": "विकासाधीन", "bn": "উন্নয়নাধীন", "gu": "વિકાસ હેઠળ", "kn": "ಅಭಿವೃದ್ಧಿಯಲ್ಲಿದೆ", "ml": "വികസനത്തിലാണ്", "ta": "மேம்பாட்டில் உள்ளது", "te": "అభివృద్ధిలో ఉంది"},
    "Go Back": {"hi": "वापस जाएं", "mr": "परत जा", "bn": "ফিরে যান", "gu": "પાછા જાઓ", "kn": "ಹಿಂತಿರುಗಿ", "ml": "തിരികെ പോകുക", "ta": "திரும்பிச் செல்", "te": "వెనక్కి వెళ్ళు"},
    "Something went wrong!": {"hi": "कुछ गलत हो गया!", "mr": "काहीतरी चूक झाली!", "bn": "কিছু ভুল হয়েছে!", "gu": "કંઈક ખોટું થયું!", "kn": "ಏನೋ ತಪ್ಪಾಗಿದೆ!", "ml": "എന്തോ തെറ്റ് സംഭവിച്ചു!", "ta": "ஏதோ தவறு நடந்துவிட்டது!", "te": "ఏదో తప్పు జరిగింది!"},
    "Retry": {"hi": "पुनः प्रयास करें", "mr": "पुन्हा प्रयत्न करा", "bn": "পুনরায় চেষ্টা করুন", "gu": "ફરી પ્રયાસ કરો", "kn": "ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ", "ml": "വീണ്ടും ശ്രമിക്കുക", "ta": "மீண்டும் முயற்சிக்கவும்", "te": "మళ్లీ ప్రయత్నించండి"},
    "No Internet Connection": {"hi": "कोई इंटरनेट कनेक्शन नहीं", "mr": "इंटरनेट कनेक्शन नाही", "bn": "ইন্টারনেট সংযোগ নেই", "gu": "ઇન્ટરનેટ કનેક્શન નથી", "kn": "ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕವಿಲ್ಲ", "ml": "ഇന്റർനെറ്റ് കണക്ഷൻ ഇല്ല", "ta": "இணைய இணைப்பு இல்லை", "te": "ఇంటర్నెట్ కనెక్షన్ లేదు"},
    "Open Settings": {"hi": "सेटिंग्स खोलें", "mr": "सेटिंग्ज उघडा", "bn": "সেটিংস খুলুন", "gu": "સેટિંગ્સ ખોલો", "kn": "ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ", "ml": "ക്രമീകരണങ്ങൾ തുറക്കുക", "ta": "அமைப்புகளைத் திறக்கவும்", "te": "సెట్టింగ్‌లను తెరవండి"},
    "Connected": {"hi": "कनेक्टेड", "mr": "कनेक्ट केले", "bn": "সংযুক্ত", "gu": "કનેક્ટેડ", "kn": "ಸಂಪರ್ಕಗೊಂಡಿದೆ", "ml": "കണക്റ്റുചെയ്തു", "ta": "இணைக்கப்பட்டது", "te": "కనెక్ట్ చేయబడింది"},
    "Wallet Recharge": {"hi": "वॉलेट रिचार्ज", "mr": "वॉलेट रिचार्ज", "bn": "ওয়ালেট রিচার্জ", "gu": "વૉલેટ રિચાર્જ", "kn": "ವಾಲೆಟ್ ರೀಚಾರ್ಜ್", "ml": "വാലറ്റ് റീചാർജ്", "ta": "வாலட் ரீசார்ஜ்", "te": "వాలెట్ రీఛార్జ్"},
    "Kundali Report": {"hi": "कुंडली रिपोर्ट", "mr": "कुंडली अहवाल", "bn": "কুন্ডলী রিপোর্ট", "gu": "કુંડળી રિપોર્ટ", "kn": "ಕುಂಡಲಿ ವರದಿ", "ml": "കുണ്ഡലി റിപ്പോർട്ട്", "ta": "குண்டலி அறிக்கை", "te": "కుండలి నివేదిక"}
}

# Language codes
lang_codes = {
    "hi_IN": "hi",
    "mr_IN": "mr",
    "bn_IN": "bn",
    "gu_IN": "gu",
    "kn_IN": "kn",
    "ml_IN": "ml",
    "ta_IN": "ta",
    "te_IN": "te"
}

# Update each language file
for file_code, lang_code in lang_codes.items():
    file_path = f"assets/translations/{file_code}.json"
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Add new translations
        for key, translations in common_additions.items():
            if key not in data and lang_code in translations:
                data[key] = translations[lang_code]
        
        # Write back
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"Updated {file_code}")
    except Exception as e:
        print(f"Error updating {file_code}: {e}")

print("All translations updated!")
