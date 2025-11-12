/// Phrase model for phrasebook
class Phrase {
  final String english;
  final String sinhala;
  final String sinhalaRomanized;
  final String tamil;
  final String tamilRomanized;
  final PhraseCategory category;
  final String? culturalNote;

  const Phrase({
    required this.english,
    required this.sinhala,
    required this.sinhalaRomanized,
    required this.tamil,
    required this.tamilRomanized,
    required this.category,
    this.culturalNote,
  });
}

enum PhraseCategory {
  greetings,
  basics,
  directions,
  food,
  shopping,
  emergency,
  temple,
  numbers,
  time,
}

/// Phrasebook data
class PhrasebookData {
  static const Map<PhraseCategory, String> categoryNames = {
    PhraseCategory.greetings: 'Greetings',
    PhraseCategory.basics: 'Basic Phrases',
    PhraseCategory.directions: 'Directions',
    PhraseCategory.food: 'Food & Dining',
    PhraseCategory.shopping: 'Shopping',
    PhraseCategory.emergency: 'Emergency',
    PhraseCategory.temple: 'At the Temple',
    PhraseCategory.numbers: 'Numbers',
    PhraseCategory.time: 'Time',
  };

  static List<Phrase> getAllPhrases() {
    return [
      // Greetings
      const Phrase(
        english: 'Hello',
        sinhala: 'ආයුබෝවන්',
        sinhalaRomanized: 'Ayubowan',
        tamil: 'வணக்கம்',
        tamilRomanized: 'Vanakkam',
        category: PhraseCategory.greetings,
        culturalNote: 'Traditional greeting meaning "may you live long"',
      ),
      const Phrase(
        english: 'Good morning',
        sinhala: 'සුභ උදෑසනක්',
        sinhalaRomanized: 'Suba udhasanak',
        tamil: 'காலை வணக்கம்',
        tamilRomanized: 'Kaalai vanakkam',
        category: PhraseCategory.greetings,
      ),
      const Phrase(
        english: 'Good evening',
        sinhala: 'සුභ සන්ධ්‍යාවක්',
        sinhalaRomanized: 'Suba sandhyavak',
        tamil: 'மாலை வணக்கம்',
        tamilRomanized: 'Maalai vanakkam',
        category: PhraseCategory.greetings,
      ),
      const Phrase(
        english: 'Goodbye',
        sinhala: 'ආයුබෝවන්',
        sinhalaRomanized: 'Ayubowan',
        tamil: 'போய் வருகிறேன்',
        tamilRomanized: 'Poy varukiren',
        category: PhraseCategory.greetings,
      ),
      const Phrase(
        english: 'How are you?',
        sinhala: 'කොහොමද?',
        sinhalaRomanized: 'Kohomada?',
        tamil: 'எப்படி இருக்கிறீர்கள்?',
        tamilRomanized: 'Eppadi irukkireergal?',
        category: PhraseCategory.greetings,
      ),

      // Basics
      const Phrase(
        english: 'Thank you',
        sinhala: 'ස්තූතියි',
        sinhalaRomanized: 'Sthoothiy',
        tamil: 'நன்றி',
        tamilRomanized: 'Nandri',
        category: PhraseCategory.basics,
      ),
      const Phrase(
        english: 'You\'re welcome',
        sinhala: 'ඔයාට කමක් නෑ',
        sinhalaRomanized: 'Oyata kamak naha',
        tamil: 'வரவேற்பு',
        tamilRomanized: 'Varavelpu',
        category: PhraseCategory.basics,
      ),
      const Phrase(
        english: 'Yes',
        sinhala: 'ඔව්',
        sinhalaRomanized: 'Ow',
        tamil: 'ஆம்',
        tamilRomanized: 'Aam',
        category: PhraseCategory.basics,
      ),
      const Phrase(
        english: 'No',
        sinhala: 'නෑ',
        sinhalaRomanized: 'Naa',
        tamil: 'இல்லை',
        tamilRomanized: 'Illai',
        category: PhraseCategory.basics,
      ),
      const Phrase(
        english: 'Please',
        sinhala: 'කරුණාකර',
        sinhalaRomanized: 'Karunakara',
        tamil: 'தயவுசெய்து',
        tamilRomanized: 'Thayavuseithu',
        category: PhraseCategory.basics,
      ),
      const Phrase(
        english: 'Excuse me / Sorry',
        sinhala: 'සමාවෙන්න',
        sinhalaRomanized: 'Samavenna',
        tamil: 'மன்னிக்கவும்',
        tamilRomanized: 'Mannikkavum',
        category: PhraseCategory.basics,
      ),
      const Phrase(
        english: 'I don\'t understand',
        sinhala: 'මට තේරෙන්නේ නෑ',
        sinhalaRomanized: 'Mata therenne naha',
        tamil: 'எனக்கு புரியவில்லை',
        tamilRomanized: 'Enakku puriyavillai',
        category: PhraseCategory.basics,
      ),
      const Phrase(
        english: 'Do you speak English?',
        sinhala: 'ඔයාට ඉංග්‍රීසි කතා කරන්න පුළුවන්ද?',
        sinhalaRomanized: 'Oyata English katha karanna puluwanda?',
        tamil: 'உங்களுக்கு ஆங்கிலம் தெரியுமா?',
        tamilRomanized: 'Ungalukku aangilam theriyuma?',
        category: PhraseCategory.basics,
      ),

      // Directions
      const Phrase(
        english: 'Where is...?',
        sinhala: '...කොහෙද?',
        sinhalaRomanized: '...koheda?',
        tamil: '...எங்கே?',
        tamilRomanized: '...enge?',
        category: PhraseCategory.directions,
      ),
      const Phrase(
        english: 'How far is it?',
        sinhala: 'කොච්චර දුරද?',
        sinhalaRomanized: 'Kochchara dhuratha?',
        tamil: 'எவ்வளவு தூரம்?',
        tamilRomanized: 'Evvalavu thooram?',
        category: PhraseCategory.directions,
      ),
      const Phrase(
        english: 'Left',
        sinhala: 'වම',
        sinhalaRomanized: 'Wama',
        tamil: 'இடது',
        tamilRomanized: 'Idathu',
        category: PhraseCategory.directions,
      ),
      const Phrase(
        english: 'Right',
        sinhala: 'දකුණ',
        sinhalaRomanized: 'Dakuna',
        tamil: 'வலது',
        tamilRomanized: 'Valathu',
        category: PhraseCategory.directions,
      ),
      const Phrase(
        english: 'Straight',
        sinhala: 'කෙලින්ම',
        sinhalaRomanized: 'Kelinma',
        tamil: 'நேராக',
        tamilRomanized: 'Neraaga',
        category: PhraseCategory.directions,
      ),
      const Phrase(
        english: 'Stop here',
        sinhala: 'මෙතන නවත්තන්න',
        sinhalaRomanized: 'Methana nawattanna',
        tamil: 'இங்கே நிறுத்துங்கள்',
        tamilRomanized: 'Inge niruththungal',
        category: PhraseCategory.directions,
      ),

      // Food
      const Phrase(
        english: 'I\'m vegetarian',
        sinhala: 'මම එළවළු කන කෙනෙක්',
        sinhalaRomanized: 'Mama elawalu kana kenek',
        tamil: 'நான் சைவ உணவு உண்பவன்',
        tamilRomanized: 'Naan saiva unavu unpavan',
        category: PhraseCategory.food,
      ),
      const Phrase(
        english: 'Not too spicy',
        sinhala: 'ගොඩක් රස නෑ',
        sinhalaRomanized: 'Godak rasa naha',
        tamil: 'மிக காரமாக வேண்டாம்',
        tamilRomanized: 'Miga kaaramaaga vendaam',
        category: PhraseCategory.food,
      ),
      const Phrase(
        english: 'Very spicy',
        sinhala: 'ගොඩක් රස',
        sinhalaRomanized: 'Godak rasa',
        tamil: 'மிக காரமாக',
        tamilRomanized: 'Miga kaaramaaga',
        category: PhraseCategory.food,
      ),
      const Phrase(
        english: 'Water please',
        sinhala: 'වතුර දෙන්න',
        sinhalaRomanized: 'Wathura denna',
        tamil: 'தண்ணீர் தாருங்கள்',
        tamilRomanized: 'Thanneer thaarungal',
        category: PhraseCategory.food,
      ),
      const Phrase(
        english: 'Delicious!',
        sinhala: 'රසයි!',
        sinhalaRomanized: 'Rasai!',
        tamil: 'சுவையாக இருக்கிறது!',
        tamilRomanized: 'Suvaiyaaga irukkirthu!',
        category: PhraseCategory.food,
      ),
      const Phrase(
        english: 'The bill please',
        sinhala: 'බිල ගෙනාවද',
        sinhalaRomanized: 'Bill genaawada',
        tamil: 'பில் தாருங்கள்',
        tamilRomanized: 'Bill thaarungal',
        category: PhraseCategory.food,
      ),

      // Shopping
      const Phrase(
        english: 'How much?',
        sinhala: 'කීයද?',
        sinhalaRomanized: 'Keeyada?',
        tamil: 'எவ்வளவு?',
        tamilRomanized: 'Evvalavu?',
        category: PhraseCategory.shopping,
      ),
      const Phrase(
        english: 'Too expensive',
        sinhala: 'වැඩියි',
        sinhalaRomanized: 'Wadiy',
        tamil: 'மிக விலை அதிகம்',
        tamilRomanized: 'Miga vilai adhigam',
        category: PhraseCategory.shopping,
      ),
      const Phrase(
        english: 'Can you reduce the price?',
        sinhala: 'මිල අඩු කරන්න පුළුවන්ද?',
        sinhalaRomanized: 'Mila adu karanna puluwanda?',
        tamil: 'விலை குறைக்க முடியுமா?',
        tamilRomanized: 'Vilai kuraikkka mudiyuma?',
        category: PhraseCategory.shopping,
      ),
      const Phrase(
        english: 'I\'ll take it',
        sinhala: 'මම අරගන්නම්',
        sinhalaRomanized: 'Mama aragannam',
        tamil: 'நான் எடுத்துக்கொள்கிறேன்',
        tamilRomanized: 'Naan eduththukkolgiren',
        category: PhraseCategory.shopping,
      ),

      // Emergency
      const Phrase(
        english: 'Help!',
        sinhala: 'උදව්!',
        sinhalaRomanized: 'Udaw!',
        tamil: 'உதவி!',
        tamilRomanized: 'Uthavi!',
        category: PhraseCategory.emergency,
      ),
      const Phrase(
        english: 'I need a doctor',
        sinhala: 'මට වෛද්‍යවරයෙක් ඕන',
        sinhalaRomanized: 'Mata vaidyawarayak ona',
        tamil: 'எனக்கு மருத்துவர் தேவை',
        tamilRomanized: 'Enakku maruththuvar thevai',
        category: PhraseCategory.emergency,
      ),
      const Phrase(
        english: 'Call the police',
        sinhala: 'පොලිසියට කතා කරන්න',
        sinhalaRomanized: 'Polisiyata katha karanna',
        tamil: 'காவல்துறைக்கு அழைக்கவும்',
        tamilRomanized: 'Kaavalthuraiku azhaikkavum',
        category: PhraseCategory.emergency,
      ),
      const Phrase(
        english: 'Where is the hospital?',
        sinhala: 'රෝහල කොහෙද?',
        sinhalaRomanized: 'Rohala koheda?',
        tamil: 'மருத்துவமனை எங்கே?',
        tamilRomanized: 'Maruththuvamanai enge?',
        category: PhraseCategory.emergency,
      ),

      // Temple
      const Phrase(
        english: 'Can I visit the temple?',
        sinhala: 'පන්සලට යන්න පුළුවන්ද?',
        sinhalaRomanized: 'Pansalata yanna puluwanda?',
        tamil: 'கோயிலுக்கு செல்லலாமா?',
        tamilRomanized: 'Koyilukku sellalaama?',
        category: PhraseCategory.temple,
        culturalNote: 'Remove shoes and cover shoulders/knees',
      ),
      const Phrase(
        english: 'Can I take photos?',
        sinhala: 'ඡායාරූප ගන්න පුළුවන්ද?',
        sinhalaRomanized: 'Chayaroopa ganna puluwanda?',
        tamil: 'புகைப்படம் எடுக்கலாமா?',
        tamilRomanized: 'Pugaippadam edukkalaama?',
        category: PhraseCategory.temple,
        culturalNote: 'Always ask permission first',
      ),
      const Phrase(
        english: 'Where do I remove my shoes?',
        sinhala: 'සපත්තු ගලවන්නේ කොහෙද?',
        sinhalaRomanized: 'Sapaththu galawaenne koheda?',
        tamil: 'காலணிகளை எங்கே கழற்றுவது?',
        tamilRomanized: 'Kaalanigalai enge kazhatruvathu?',
        category: PhraseCategory.temple,
      ),

      // Numbers 1-10
      const Phrase(
        english: 'One',
        sinhala: 'එක',
        sinhalaRomanized: 'Eka',
        tamil: 'ஒன்று',
        tamilRomanized: 'Ondru',
        category: PhraseCategory.numbers,
      ),
      const Phrase(
        english: 'Two',
        sinhala: 'දෙක',
        sinhalaRomanized: 'Deka',
        tamil: 'இரண்டு',
        tamilRomanized: 'Irandu',
        category: PhraseCategory.numbers,
      ),
      const Phrase(
        english: 'Three',
        sinhala: 'තුන',
        sinhalaRomanized: 'Thuna',
        tamil: 'மூன்று',
        tamilRomanized: 'Moondru',
        category: PhraseCategory.numbers,
      ),
      const Phrase(
        english: 'Five',
        sinhala: 'පහ',
        sinhalaRomanized: 'Paha',
        tamil: 'ஐந்து',
        tamilRomanized: 'Ainthu',
        category: PhraseCategory.numbers,
      ),
      const Phrase(
        english: 'Ten',
        sinhala: 'දහය',
        sinhalaRomanized: 'Dahaya',
        tamil: 'பத்து',
        tamilRomanized: 'Paththu',
        category: PhraseCategory.numbers,
      ),
      const Phrase(
        english: 'One hundred',
        sinhala: 'සීය',
        sinhalaRomanized: 'Seeya',
        tamil: 'நூறு',
        tamilRomanized: 'Nooru',
        category: PhraseCategory.numbers,
      ),

      // Time
      const Phrase(
        english: 'What time is it?',
        sinhala: 'වේලාව කීයද?',
        sinhalaRomanized: 'Velaawa keeyada?',
        tamil: 'நேரம் என்ன?',
        tamilRomanized: 'Neram enna?',
        category: PhraseCategory.time,
      ),
      const Phrase(
        english: 'Today',
        sinhala: 'අද',
        sinhalaRomanized: 'Adha',
        tamil: 'இன்று',
        tamilRomanized: 'Indru',
        category: PhraseCategory.time,
      ),
      const Phrase(
        english: 'Tomorrow',
        sinhala: 'හෙට',
        sinhalaRomanized: 'Heta',
        tamil: 'நாளை',
        tamilRomanized: 'Naalai',
        category: PhraseCategory.time,
      ),
      const Phrase(
        english: 'Yesterday',
        sinhala: 'ඊයේ',
        sinhalaRomanized: 'Eeye',
        tamil: 'நேற்று',
        tamilRomanized: 'Netru',
        category: PhraseCategory.time,
      ),
    ];
  }

  static List<Phrase> getPhrasesByCategory(PhraseCategory category) {
    return getAllPhrases().where((p) => p.category == category).toList();
  }
}
