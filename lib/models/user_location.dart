/// User location from IP geolocation
class UserLocation {
  final String ip;
  final String city;
  final String region;
  final String country;
  final String countryCode;
  final String countryFlag;
  final double latitude;
  final double longitude;
  final String timezone;
  final String currency;
  final String language;

  UserLocation({
    required this.ip,
    required this.city,
    required this.region,
    required this.country,
    required this.countryCode,
    required this.countryFlag,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.currency,
    required this.language,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      ip: json['ip'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      country: json['country_name'] as String? ?? json['country'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
      countryFlag: _getCountryFlag(json['country_code'] as String? ?? ''),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      language: json['languages'] as String? ?? '',
    );
  }

  static String _getCountryFlag(String countryCode) {
    if (countryCode.isEmpty) return '🌍';
    // Convert country code to flag emoji
    return countryCode
        .toUpperCase()
        .split('')
        .map((char) => String.fromCharCode(char.codeUnitAt(0) + 127397))
        .join();
  }

  bool get isInSriLanka {
    return countryCode.toUpperCase() == 'LK';
  }

  String get locationDisplay {
    if (city.isNotEmpty && country.isNotEmpty) {
      return '$city, $country';
    } else if (country.isNotEmpty) {
      return country;
    }
    return 'Unknown';
  }

  String get fullDisplay {
    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (region.isNotEmpty) parts.add(region);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  /// Get greeting based on user's location
  String get localizedGreeting {
    switch (countryCode.toUpperCase()) {
      case 'LK':
        return 'ආයුබෝවන්! Welcome to Sri Lanka! 🇱🇰';
      case 'IN':
        return 'नमस्ते! Planning to visit Sri Lanka? 🇮🇳';
      case 'US':
      case 'GB':
      case 'CA':
      case 'AU':
      case 'NZ':
        return 'Hello! Welcome to Serendib Guide! $countryFlag';
      case 'CN':
        return '你好! Welcome! 🇨🇳';
      case 'JP':
        return 'こんにちは! Welcome! 🇯🇵';
      case 'KR':
        return '안녕하세요! Welcome! 🇰🇷';
      case 'FR':
        return 'Bonjour! Bienvenue! 🇫🇷';
      case 'DE':
        return 'Hallo! Willkommen! 🇩🇪';
      case 'ES':
        return '¡Hola! ¡Bienvenido! 🇪🇸';
      case 'IT':
        return 'Ciao! Benvenuto! 🇮🇹';
      case 'RU':
        return 'Привет! Добро пожаловать! 🇷🇺';
      case 'BR':
        return 'Olá! Bem-vindo! 🇧🇷';
      case 'AE':
        return 'مرحبا! Welcome! 🇦🇪';
      default:
        return 'Welcome to Serendib Guide! $countryFlag';
    }
  }

  /// Get recommended currency to display
  String? get recommendedCurrency {
    if (isInSriLanka) return 'LKR';

    switch (countryCode.toUpperCase()) {
      case 'US':
        return 'USD';
      case 'GB':
        return 'GBP';
      case 'IN':
        return 'INR';
      case 'AU':
        return 'AUD';
      case 'CA':
        return 'CAD';
      case 'JP':
        return 'JPY';
      case 'CN':
        return 'CNY';
      case 'AE':
        return 'AED';
      default:
        if (currency.isNotEmpty) return currency;
        return 'USD'; // Default to USD
    }
  }
}
