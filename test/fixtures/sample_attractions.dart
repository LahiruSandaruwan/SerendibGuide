/// Sample attraction data for testing
///
/// This file provides mock attraction data that can be used in tests
/// without needing to access the actual database.

import 'package:serendib_guide/models/attraction.dart';
import 'package:serendib_guide/models/category.dart';
import 'package:serendib_guide/models/province.dart';
import 'package:serendib_guide/models/difficulty.dart';

class SampleAttractions {
  /// Sample free attraction - Sigiriya
  static Attraction get sigiriya => Attraction(
        id: 1,
        nameEn: 'Sigiriya Rock Fortress',
        nameSi: 'සීගිරිය',
        nameTa: 'சிகிரியா',
        category: Category.ancientSites,
        province: Province.central,
        descriptionEn:
            'Rising 200 meters above the jungle canopy, Sigiriya is an ancient rock fortress and palace ruin built in the 5th century by King Kashyapa.',
        descriptionSi: 'වනාන්තරයට මීටර 200ක් උසින් පිහිටි සීගිරිය පුරාණ ගල් බලකොටුවක් සහ මාළිගා නටබුන් ය.',
        descriptionTa: 'காட்டுக்கு மேலே 200 மீட்டர் உயரத்தில் உள்ள சிகிரியா ஒரு பண்டைய பாறை கோட்டை மற்றும் அரண்மனை இடிபாடுகள்.',
        latitude: 7.9571,
        longitude: 80.7603,
        entryFee: 'USD 30 (foreigners), LKR 100 (locals)',
        openingHours: '7:00 AM - 5:30 PM',
        bestTime: 'Early morning (7-9 AM) to avoid heat and crowds',
        duration: '3-4 hours',
        difficulty: Difficulty.moderate,
        tags: 'unesco,historical,photography,ancient,fortress,must-see',
        images: 'sigiriya_1.jpg,sigiriya_2.jpg,sigiriya_3.jpg,sigiriya_4.jpg',
        isPremium: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

  /// Sample free attraction - Mirissa Beach
  static Attraction get mirissa => Attraction(
        id: 2,
        nameEn: 'Mirissa Beach',
        nameSi: 'මිරිස්ස වෙරළ',
        nameTa: 'மிரிசா கடற்கரை',
        category: Category.beaches,
        province: Province.southern,
        descriptionEn:
            'Stunning crescent-shaped beach on Sri Lanka\'s south coast, famous for golden sands, turquoise waters, and whale watching from November to April.',
        descriptionSi: 'ශ්‍රී ලංකාවේ දකුණු වෙරළ තීරයේ පිහිටි අපූරු අර්ධ චන්ද්‍රාකාර වෙරළ, රන්වන් වැලි, නිල් ජලය සහ තල්මසුන් නැරඹීම සඳහා ප්‍රසිද්ධයි.',
        descriptionTa: 'இலங்கையின் தென் கடற்கரையில் உள்ள அழகான பிறை வடிவ கடற்கரை, தங்க மணல், நீலநிற நீர் மற்றும் திமிங்கலம் பார்ப்பதற்கு பிரபலமானது.',
        latitude: 5.9467,
        longitude: 80.4564,
        entryFee: 'Free',
        openingHours: '24 hours',
        bestTime: 'November to April (dry season)',
        duration: 'Half day to full day',
        difficulty: Difficulty.easy,
        tags: 'beach,whale-watching,surfing,sunset,swimming,family-friendly',
        images: 'mirissa_1.jpg,mirissa_2.jpg,mirissa_3.jpg,mirissa_4.jpg',
        isPremium: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

  /// Sample premium attraction - Yala National Park
  static Attraction get yala => Attraction(
        id: 3,
        nameEn: 'Yala National Park',
        nameSi: 'යාල ජාතික වනෝද්‍යානය',
        nameTa: 'யாலா தேசிய பூங்கா',
        category: Category.natureWildlife,
        province: Province.southern,
        descriptionEn:
            'Sri Lanka\'s most visited and second largest national park, famous for having one of the highest leopard densities in the world.',
        descriptionSi: 'ශ්‍රී ලංකාවේ වඩාත්ම ජනප්‍රිය සහ දෙවන විශාලතම ජාතික වනෝද්‍යානය, ලෝකයේ ඉහළම දිවියන් ඝනත්වය ඇති බවට ප්‍රසිද්ධයි.',
        descriptionTa: 'இலங்கையின் மிகவும் பிரபலமான மற்றும் இரண்டாவது பெரிய தேசிய பூங்கா, உலகின் மிக உயர்ந்த சிறுத்தை அடர்த்தி இருப்பதற்கு புகழ்பெற்றது.',
        latitude: 6.3724,
        longitude: 81.5185,
        entryFee: 'USD 25 (foreigners), LKR 60 (locals) + vehicle fees',
        openingHours: '6:00 AM - 6:00 PM',
        bestTime: 'February to July (dry season)',
        duration: '4-6 hours (safari)',
        difficulty: Difficulty.easy,
        tags: 'wildlife,safari,leopard,elephant,birds,nature,premium',
        images: 'yala_1.jpg,yala_2.jpg,yala_3.jpg,yala_4.jpg',
        isPremium: true,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

  /// Sample attraction - Ella
  static Attraction get ella => Attraction(
        id: 4,
        nameEn: 'Ella',
        nameSi: 'ඇල්ල',
        nameTa: 'எல்லா',
        category: Category.hillCountry,
        province: Province.uva,
        descriptionEn:
            'Charming hill country town surrounded by tea plantations, offering stunning views, hiking trails, and a laid-back atmosphere.',
        descriptionSi: 'තේ වතු වලින් වට වූ සිත් ඇදගන්නා කඳුකර නගරය, විශිෂ්ට දර්ශන, කඳු නැගීමේ මාර්ග සහ සන්සුන් වාතාවරණයක් ඇත.',
        descriptionTa: 'தேயிலை தோட்டங்களால் சூழப்பட்ட அழகான மலைநாட்டு நகரம், அற்புதமான காட்சிகள், நடைபாதைகள் மற்றும் அமைதியான சூழல்.',
        latitude: 6.8667,
        longitude: 81.0467,
        entryFee: 'Free (attractions within may charge)',
        openingHours: '24 hours',
        bestTime: 'January to March (best weather)',
        duration: '2-3 days recommended',
        difficulty: Difficulty.moderate,
        tags: 'hiking,viewpoint,tea-plantations,scenic,backpacker,nature',
        images: 'ella_1.jpg,ella_2.jpg,ella_3.jpg,ella_4.jpg',
        isPremium: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

  /// Sample attraction - Temple of the Tooth
  static Attraction get toothTemple => Attraction(
        id: 5,
        nameEn: 'Temple of the Sacred Tooth Relic',
        nameSi: 'ශ්‍රී දළදා මාළිගාව',
        nameTa: 'புனித பல் நினைவுச்சின்ன கோவில்',
        category: Category.religiousSites,
        province: Province.central,
        descriptionEn:
            'Sacred Buddhist temple in Kandy housing the relic of the tooth of the Buddha, a major pilgrimage site and UNESCO World Heritage Site.',
        descriptionSi: 'බුදුරජාණන් වහන්සේගේ දළදා ධාතුව තැන්පත් කර ඇති කැන්ඩි නුවර පිහිටි පූජනීය බෞද්ධ විහාරය, ප්‍රධාන වන්දනා ස්ථානයක් සහ යුනෙස්කෝ ලෝක උරුම ස්ථානයකි.',
        descriptionTa: 'புத்தரின் பல் நினைவுச்சின்னத்தை வைத்திருக்கும் கண்டியில் உள்ள புனித பௌத்த கோவில், முக்கிய புனித யாத்திரை தளம் மற்றும் யுனெஸ்கோ உலக பாரம்பரிய தளம்.',
        latitude: 7.2934,
        longitude: 80.6411,
        entryFee: 'LKR 2000 (foreigners), LKR 500 (locals)',
        openingHours: '5:30 AM - 8:00 PM',
        bestTime: 'During puja times (morning, afternoon, evening)',
        duration: '1-2 hours',
        difficulty: Difficulty.easy,
        tags: 'unesco,buddhist,temple,cultural,historical,kandy,must-see',
        images: 'tooth_temple_1.jpg,tooth_temple_2.jpg,tooth_temple_3.jpg,tooth_temple_4.jpg',
        isPremium: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

  /// Get all sample attractions
  static List<Attraction> get all => [
        sigiriya,
        mirissa,
        yala,
        ella,
        toothTemple,
      ];

  /// Get only free attractions
  static List<Attraction> get freeAttractions =>
      all.where((a) => !a.isPremium).toList();

  /// Get only premium attractions
  static List<Attraction> get premiumAttractions =>
      all.where((a) => a.isPremium).toList();

  /// Get attractions by category
  static List<Attraction> byCategory(Category category) =>
      all.where((a) => a.category == category).toList();

  /// Get attractions by province
  static List<Attraction> byProvince(Province province) =>
      all.where((a) => a.province == province).toList();
}
