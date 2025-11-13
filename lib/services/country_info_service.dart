import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country_info.dart';

/// Service for Sri Lanka country information
/// Uses REST Countries API (completely free, no key required)
class CountryInfoService {
  static const String _baseUrl = 'https://restcountries.com/v3.1';

  CountryInfo? _cachedInfo;
  DateTime? _cacheTime;
  final Duration _cacheDuration = const Duration(days: 7); // Country info rarely changes

  /// Get Sri Lanka country information
  Future<CountryInfo> getSriLankaInfo() async {
    // Check cache first
    if (_cachedInfo != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedInfo!;
    }

    try {
      // Fetch from REST Countries API (completely free, no key needed)
      final response = await http.get(
        Uri.parse('$_baseUrl/alpha/LK'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // The API returns an array with one item
        final countryData = data is List && data.isNotEmpty ? data[0] : data;

        final info = CountryInfo.fromJson(countryData as Map<String, dynamic>);

        // Cache the result
        _cachedInfo = info;
        _cacheTime = DateTime.now();

        return info;
      } else {
        // Return fallback data
        return _getFallbackData();
      }
    } catch (e) {
      // Return fallback data on error
      return _getFallbackData();
    }
  }

  /// Get fallback data if API fails
  CountryInfo _getFallbackData() {
    return CountryInfo(
      name: 'Sri Lanka',
      officialName: 'Democratic Socialist Republic of Sri Lanka',
      capital: ['Sri Jayawardenepura Kotte', 'Colombo'],
      region: 'Asia',
      subregion: 'Southern Asia',
      population: 21919000,
      area: 65610.0,
      languages: ['Sinhala', 'Tamil'],
      currencies: [
        Currency(
          code: 'LKR',
          name: 'Sri Lankan Rupee',
          symbol: 'Rs',
        ),
      ],
      flag: '🇱🇰',
      coatOfArms: '',
      timezones: ['UTC+05:30'],
      drivingSide: 'left',
      callingCode: '+94',
      borders: [],
      coordinates: {'lat': 7.8731, 'lng': 80.7718},
      maps: {
        'googleMaps': 'https://goo.gl/maps/3FQ9UZiB9kDR8Qr58',
        'openStreetMaps': 'https://www.openstreetmap.org/relation/536807',
      },
    );
  }

  /// Clear cache
  void clearCache() {
    _cachedInfo = null;
    _cacheTime = null;
  }

  /// Get specific country by code (for future expansion)
  Future<CountryInfo?> getCountryByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/alpha/$code'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final countryData = data is List && data.isNotEmpty ? data[0] : data;
        return CountryInfo.fromJson(countryData as Map<String, dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Search countries by name (for future expansion)
  Future<List<CountryInfo>> searchCountries(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/name/$query'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((country) => CountryInfo.fromJson(country as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }
}
