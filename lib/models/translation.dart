/// Translation model for LibreTranslate API
class Translation {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;

  Translation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  factory Translation.fromJson(Map<String, dynamic> json, String source, String target) {
    return Translation(
      originalText: json['original'] ?? '',
      translatedText: json['translatedText'] ?? '',
      sourceLanguage: source,
      targetLanguage: target,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() => '$sourceLanguage → $targetLanguage: "$originalText" = "$translatedText"';
}

/// Supported languages
class SupportedLanguages {
  static const Map<String, String> languages = {
    'en': 'English',
    'si': 'Sinhala (සිංහල)',
    'ta': 'Tamil (தமிழ்)',
    'hi': 'Hindi (हिन्दी)',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh': 'Chinese',
    'ar': 'Arabic',
  };

  static String getName(String code) {
    return languages[code] ?? code;
  }

  static String getFlag(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'si':
        return '🇱🇰';
      case 'ta':
        return '🇱🇰';
      case 'hi':
        return '🇮🇳';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇵🇹';
      case 'ru':
        return '🇷🇺';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'zh':
        return '🇨🇳';
      case 'ar':
        return '🇸🇦';
      default:
        return '🌍';
    }
  }
}

/// Common travel phrases for quick reference
class TravelPhrases {
  static const Map<String, Map<String, String>> phrases = {
    'Greetings': {
      'Hello': 'ආයුබෝවන් (Ayubowan)',
      'Good morning': 'සුභ උදෑසනක් (Suba udāsanak)',
      'Good evening': 'සුභ සන්ධ්‍යාවක් (Suba sandhyāvak)',
      'Goodbye': 'ගිහින් එන්නම් (Gihin ennam)',
      'Thank you': 'ඉස්තුති (Istuti)',
      'Please': 'කරුණාකරලා (Karunākarala)',
      'Sorry': 'සමාවෙන්න (Samāvenna)',
      'Excuse me': 'සමාවෙන්න (Samāvenna)',
    },
    'Directions': {
      'Where is...?': '...කොහෙද? (Koheda?)',
      'How far is...?': '...කොච්චර දුරද? (Kochchara durada?)',
      'Left': 'වමට (Vamaṭa)',
      'Right': 'දකුණට (Dakuṇaṭa)',
      'Straight': 'කෙළින් (Keḷin)',
      'Near': 'ළඟ (Ḷaga)',
      'Far': 'දුර (Dura)',
      'Here': 'මෙතන (Metana)',
      'There': 'ඔතන (Otana)',
    },
    'Numbers': {
      'One': 'එක (Eka)',
      'Two': 'දෙක (Deka)',
      'Three': 'තුන (Tuna)',
      'Four': 'හතර (Hatara)',
      'Five': 'පහ (Paha)',
      'Ten': 'දහය (Dahaya)',
      'Hundred': 'සියය (Siyaya)',
      'Thousand': 'දහස (Dahasa)',
    },
    'Food & Dining': {
      'Water': 'වතුර (Vatura)',
      'Food': 'කෑම (Kǣma)',
      'Rice': 'බත් (Bat)',
      'Curry': 'කරි (Kari)',
      'Tea': 'තේ (Tē)',
      'Coffee': 'කෝපි (Kōpi)',
      'Spicy': 'කැරි (Kǣri)',
      'Not spicy': 'කැරි නෑ (Kǣri nǣ)',
      'Delicious': 'රසයි (Rasayi)',
      'How much?': 'කීයද? (Kīyada?)',
    },
    'Emergency': {
      'Help!': 'උදව්! (Udav!)',
      'Emergency': 'හදිසි (Hadisi)',
      'Police': 'පොලිසිය (Polisiya)',
      'Hospital': 'රෝහල (Rōhala)',
      'Doctor': 'වෛද්‍යවරයා (Vaidyavaraya)',
      'I need help': 'මට උදව් ඕන (Maṭa udav ōna)',
      'Call ambulance': 'ඇම්බියුලන්ස් එක කෝල් කරන්න (Āmbiulans eka kōl karanna)',
    },
    'Shopping': {
      'How much?': 'කීයද? (Kīyada?)',
      'Too expensive': 'වැඩියි (Vǣḍiyi)',
      'Cheaper': 'අඩුයි (Aḍuyi)',
      'I want to buy': 'මට ගන්න ඕන (Maṭa ganna ōna)',
      'Market': 'පොළ (Poḷa)',
      'Shop': 'කඩය (Kaḍaya)',
      'Money': 'සල්ලි (Salli)',
    },
    'Transport': {
      'Bus': 'බස් එක (Bas eka)',
      'Train': 'කෝච්චිය (Kōchchiya)',
      'Taxi': 'ටැක්සි (Ṭǣksi)',
      'Tuk-tuk': 'ත්‍රී වීල් (Trī vīl)',
      'Station': 'ස්ථානය (Sthānaya)',
      'Ticket': 'ටිකට් පත (Ṭikaṭ pata)',
      'Airport': 'ගුවන් තොටුපළ (Guvan toṭupaḷa)',
    },
  };

  static List<String> get categories => phrases.keys.toList();

  static Map<String, String> getPhrasesForCategory(String category) {
    return phrases[category] ?? {};
  }
}
