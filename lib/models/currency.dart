/// Currency exchange rate data
class CurrencyRate {
  final String code;
  final String name;
  final String symbol;
  final double rate; // Rate relative to LKR
  final DateTime lastUpdated;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rate,
    required this.lastUpdated,
  });

  /// Convert amount from LKR to this currency
  double fromLKR(double lkrAmount) {
    return lkrAmount * rate;
  }

  /// Convert amount from this currency to LKR
  double toLKR(double amount) {
    return amount / rate;
  }

  /// Format currency value
  String format(double amount) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  @override
  String toString() => '$code: $symbol (1 LKR = ${rate.toStringAsFixed(4)} $code)';
}

/// Popular currencies for Sri Lanka tourists
class PopularCurrencies {
  static const Map<String, Map<String, String>> currencies = {
    'USD': {'name': 'US Dollar', 'symbol': '\$'},
    'EUR': {'name': 'Euro', 'symbol': '€'},
    'GBP': {'name': 'British Pound', 'symbol': '£'},
    'INR': {'name': 'Indian Rupee', 'symbol': '₹'},
    'AUD': {'name': 'Australian Dollar', 'symbol': 'A\$'},
    'CAD': {'name': 'Canadian Dollar', 'symbol': 'C\$'},
    'JPY': {'name': 'Japanese Yen', 'symbol': '¥'},
    'CNY': {'name': 'Chinese Yuan', 'symbol': '¥'},
    'SGD': {'name': 'Singapore Dollar', 'symbol': 'S\$'},
    'AED': {'name': 'UAE Dirham', 'symbol': 'د.إ'},
    'SAR': {'name': 'Saudi Riyal', 'symbol': '﷼'},
    'MYR': {'name': 'Malaysian Ringgit', 'symbol': 'RM'},
    'THB': {'name': 'Thai Baht', 'symbol': '฿'},
    'KRW': {'name': 'South Korean Won', 'symbol': '₩'},
    'LKR': {'name': 'Sri Lankan Rupee', 'symbol': 'Rs'},
  };

  static List<String> get popularCodes => [
        'USD',
        'EUR',
        'GBP',
        'INR',
        'AUD',
        'CAD',
        'JPY',
        'CNY',
      ];

  static String getName(String code) {
    return currencies[code]?['name'] ?? code;
  }

  static String getSymbol(String code) {
    return currencies[code]?['symbol'] ?? code;
  }

  static String getFlag(String code) {
    switch (code) {
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'INR':
        return '🇮🇳';
      case 'AUD':
        return '🇦🇺';
      case 'CAD':
        return '🇨🇦';
      case 'JPY':
        return '🇯🇵';
      case 'CNY':
        return '🇨🇳';
      case 'SGD':
        return '🇸🇬';
      case 'AED':
        return '🇦🇪';
      case 'SAR':
        return '🇸🇦';
      case 'MYR':
        return '🇲🇾';
      case 'THB':
        return '🇹🇭';
      case 'KRW':
        return '🇰🇷';
      case 'LKR':
        return '🇱🇰';
      default:
        return '🌍';
    }
  }
}

/// Currency conversion result
class CurrencyConversion {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double result;
  final double rate;
  final DateTime timestamp;

  CurrencyConversion({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.result,
    required this.rate,
    required this.timestamp,
  });

  String get displayResult {
    final symbol = PopularCurrencies.getSymbol(toCurrency);
    if (result >= 1000000) {
      return '$symbol${(result / 1000000).toStringAsFixed(2)}M';
    } else if (result >= 1000) {
      return '$symbol${(result / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${result.toStringAsFixed(2)}';
    }
  }

  @override
  String toString() {
    return '${PopularCurrencies.getSymbol(fromCurrency)}$amount = $displayResult';
  }
}
