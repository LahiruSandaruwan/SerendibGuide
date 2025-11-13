/// Country information for Sri Lanka
class CountryInfo {
  final String name;
  final String officialName;
  final List<String> capital;
  final String region;
  final String subregion;
  final int population;
  final double area; // in km²
  final List<String> languages;
  final List<Currency> currencies;
  final String flag;
  final String coatOfArms;
  final List<String> timezones;
  final String drivingSide;
  final String callingCode;
  final List<String> borders;
  final Map<String, double> coordinates;
  final Map<String, String> maps;

  CountryInfo({
    required this.name,
    required this.officialName,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.area,
    required this.languages,
    required this.currencies,
    required this.flag,
    required this.coatOfArms,
    required this.timezones,
    required this.drivingSide,
    required this.callingCode,
    required this.borders,
    required this.coordinates,
    required this.maps,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    // Parse languages
    final languagesMap = json['languages'] as Map<String, dynamic>? ?? {};
    final languages = languagesMap.values.cast<String>().toList();

    // Parse currencies
    final currenciesMap = json['currencies'] as Map<String, dynamic>? ?? {};
    final currencies = currenciesMap.entries.map((entry) {
      final currencyData = entry.value as Map<String, dynamic>;
      return Currency(
        code: entry.key,
        name: currencyData['name'] as String? ?? '',
        symbol: currencyData['symbol'] as String? ?? '',
      );
    }).toList();

    // Parse calling codes
    final idd = json['idd'] as Map<String, dynamic>? ?? {};
    final root = idd['root'] as String? ?? '';
    final suffixes = (idd['suffixes'] as List?)?.cast<String>() ?? [];
    final callingCode = suffixes.isNotEmpty ? '$root${suffixes[0]}' : root;

    // Parse coordinates
    final latlng = (json['latlng'] as List?)?.cast<double>() ?? [0.0, 0.0];
    final coordinates = {
      'lat': latlng.isNotEmpty ? latlng[0] : 0.0,
      'lng': latlng.length > 1 ? latlng[1] : 0.0,
    };

    // Parse maps
    final mapsData = json['maps'] as Map<String, dynamic>? ?? {};
    final maps = {
      'googleMaps': mapsData['googleMaps'] as String? ?? '',
      'openStreetMaps': mapsData['openStreetMaps'] as String? ?? '',
    };

    return CountryInfo(
      name: json['name']?['common'] as String? ?? 'Sri Lanka',
      officialName: json['name']?['official'] as String? ?? 'Democratic Socialist Republic of Sri Lanka',
      capital: (json['capital'] as List?)?.cast<String>() ?? ['Colombo'],
      region: json['region'] as String? ?? 'Asia',
      subregion: json['subregion'] as String? ?? 'Southern Asia',
      population: json['population'] as int? ?? 21919000,
      area: (json['area'] as num?)?.toDouble() ?? 65610.0,
      languages: languages,
      currencies: currencies,
      flag: json['flag'] as String? ?? '🇱🇰',
      coatOfArms: json['coatOfArms']?['png'] as String? ?? '',
      timezones: (json['timezones'] as List?)?.cast<String>() ?? ['UTC+05:30'],
      drivingSide: json['car']?['side'] as String? ?? 'left',
      callingCode: callingCode,
      borders: (json['borders'] as List?)?.cast<String>() ?? [],
      coordinates: coordinates,
      maps: maps,
    );
  }

  String get populationFormatted {
    if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(0)}K';
    }
    return population.toString();
  }

  String get areaFormatted {
    return '${area.toStringAsFixed(0)} km²';
  }

  String get languagesFormatted {
    if (languages.isEmpty) return 'N/A';
    if (languages.length == 1) return languages[0];
    if (languages.length == 2) return '${languages[0]} & ${languages[1]}';
    return '${languages.take(languages.length - 1).join(', ')} & ${languages.last}';
  }

  String get currenciesFormatted {
    return currencies.map((c) => '${c.name} (${c.symbol})').join(', ');
  }

  String get timezonesFormatted {
    return timezones.join(', ');
  }
}

/// Currency information
class Currency {
  final String code;
  final String name;
  final String symbol;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

/// Quick facts about Sri Lanka for travelers
class SriLankaFacts {
  static const List<Map<String, String>> facts = [
    {
      'icon': '🏝️',
      'title': 'Island Nation',
      'fact': 'Sri Lanka is an island country in the Indian Ocean, known as the "Pearl of the Indian Ocean"',
    },
    {
      'icon': '🕐',
      'title': 'Time Zone',
      'fact': 'Sri Lanka operates on Sri Lanka Standard Time (UTC+5:30), 30 minutes ahead of India',
    },
    {
      'icon': '🚗',
      'title': 'Driving',
      'fact': 'Traffic drives on the LEFT side of the road (British colonial influence)',
    },
    {
      'icon': '📞',
      'title': 'Calling Code',
      'fact': 'International calling code is +94',
    },
    {
      'icon': '🗣️',
      'title': 'Languages',
      'fact': 'Sinhala and Tamil are official languages. English is widely spoken in tourist areas',
    },
    {
      'icon': '💰',
      'title': 'Currency',
      'fact': 'Sri Lankan Rupee (LKR/රු). Credit cards accepted in cities, cash needed in rural areas',
    },
    {
      'icon': '⚡',
      'title': 'Electricity',
      'fact': '230V, 50Hz. Type D, G, and M plugs (same as India and UK)',
    },
    {
      'icon': '🌡️',
      'title': 'Climate',
      'fact': 'Tropical climate year-round. Two monsoon seasons affect different parts of the island',
    },
    {
      'icon': '✈️',
      'title': 'Entry',
      'fact': 'Electronic Travel Authorization (ETA) required for most visitors. Available online',
    },
    {
      'icon': '🍛',
      'title': 'Cuisine',
      'fact': 'Rice and curry is the staple dish. Sri Lankan food is known for its spices and coconut',
    },
    {
      'icon': '🙏',
      'title': 'Religion',
      'fact': 'Buddhist majority (70%), with Hindu, Muslim, and Christian minorities',
    },
    {
      'icon': '📏',
      'title': 'Size',
      'fact': 'Approximately 65,610 km² - about the size of Ireland or West Virginia',
    },
    {
      'icon': '🏛️',
      'title': 'Heritage',
      'fact': '8 UNESCO World Heritage Sites including ancient cities, fortresses, and rainforests',
    },
    {
      'icon': '🐘',
      'title': 'Wildlife',
      'fact': 'Home to elephants, leopards, sloth bears, blue whales, and over 400 bird species',
    },
    {
      'icon': '☕',
      'title': 'Tea',
      'fact': 'One of the world\'s largest tea exporters. Ceylon tea is famous worldwide',
    },
  ];

  static const List<Map<String, String>> travelTips = [
    {
      'icon': '👗',
      'title': 'Dress Code',
      'tip': 'Dress modestly when visiting temples. Cover shoulders and knees. Remove shoes and hats',
    },
    {
      'icon': '💵',
      'title': 'Tipping',
      'tip': 'Tipping is appreciated but not mandatory. 10% in restaurants, 100-200 LKR for porters',
    },
    {
      'icon': '🚰',
      'title': 'Water',
      'tip': 'Drink only bottled or boiled water. Avoid ice in drinks unless in reputable hotels',
    },
    {
      'icon': '🚕',
      'title': 'Transportation',
      'tip': 'Use metered taxis or ride-sharing apps in cities. Agree on tuk-tuk fares before riding',
    },
    {
      'icon': '📱',
      'title': 'Internet',
      'tip': 'Buy a local SIM card for cheap data. Available at airport and shops with passport',
    },
    {
      'icon': '🏖️',
      'title': 'Beach Safety',
      'tip': 'Be cautious of strong currents. Swim only at designated areas with lifeguards',
    },
  ];
}
