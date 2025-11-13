import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

/// Currency service using Exchangerate.host API
/// 100% FREE - No API key required!
class CurrencyService {
  static const String _baseUrl = 'https://api.exchangerate.host';

  // Cache for rates (valid for 1 hour)
  static Map<String, double>? _cachedRates;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Get all exchange rates relative to LKR
  Future<Map<String, CurrencyRate>> getExchangeRates() async {
    try {
      // Check cache first
      if (_cachedRates != null &&
          _cacheTime != null &&
          DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        print('💰 Using cached exchange rates');
        return _buildCurrencyRates(_cachedRates!, _cacheTime!);
      }

      final url = Uri.parse('$_baseUrl/latest?base=LKR');

      print('💱 Fetching exchange rates from Exchangerate.host...');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch rates: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;
      final date = DateTime.parse(data['date'] as String);

      // Cache the rates
      _cachedRates = rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
      _cacheTime = date;

      print('✅ Exchange rates fetched: ${rates.length} currencies');

      return _buildCurrencyRates(_cachedRates!, date);
    } catch (e) {
      print('✗ Error fetching exchange rates: $e');
      rethrow;
    }
  }

  Map<String, CurrencyRate> _buildCurrencyRates(
    Map<String, double> rates,
    DateTime lastUpdated,
  ) {
    final result = <String, CurrencyRate>{};

    for (final code in PopularCurrencies.currencies.keys) {
      if (rates.containsKey(code)) {
        result[code] = CurrencyRate(
          code: code,
          name: PopularCurrencies.getName(code),
          symbol: PopularCurrencies.getSymbol(code),
          rate: rates[code]!,
          lastUpdated: lastUpdated,
        );
      }
    }

    return result;
  }

  /// Convert currency
  Future<CurrencyConversion> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final rates = await getExchangeRates();

      double result;
      double rate;

      if (fromCurrency == 'LKR' && rates.containsKey(toCurrency)) {
        // LKR to other currency
        rate = rates[toCurrency]!.rate;
        result = amount * rate;
      } else if (toCurrency == 'LKR' && rates.containsKey(fromCurrency)) {
        // Other currency to LKR
        rate = 1 / rates[fromCurrency]!.rate;
        result = amount * rate;
      } else if (rates.containsKey(fromCurrency) && rates.containsKey(toCurrency)) {
        // Other currency to other currency (via LKR)
        final fromRate = rates[fromCurrency]!.rate;
        final toRate = rates[toCurrency]!.rate;
        rate = toRate / fromRate;
        result = amount * rate;
      } else {
        throw Exception('Currency conversion not supported');
      }

      return CurrencyConversion(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        result: result,
        rate: rate,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('✗ Error converting currency: $e');
      rethrow;
    }
  }

  /// Get popular currencies for quick access
  Future<List<CurrencyRate>> getPopularCurrencies() async {
    try {
      final rates = await getExchangeRates();
      return PopularCurrencies.popularCodes
          .where((code) => rates.containsKey(code))
          .map((code) => rates[code]!)
          .toList();
    } catch (e) {
      print('✗ Error getting popular currencies: $e');
      rethrow;
    }
  }

  /// Clear cache (useful for manual refresh)
  void clearCache() {
    _cachedRates = null;
    _cacheTime = null;
  }
}
