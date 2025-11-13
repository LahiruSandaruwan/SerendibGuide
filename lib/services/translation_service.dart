import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/translation.dart';

/// Translation service using LibreTranslate API
/// 100% FREE - No API key required!
class TranslationService {
  static const String _baseUrl = 'https://libretranslate.de/translate';

  // Cache for recent translations
  static final Map<String, Translation> _cache = {};
  static const int _maxCacheSize = 100;

  /// Translate text from one language to another
  ///
  /// [text] - Text to translate
  /// [from] - Source language code (en, si, ta, etc.)
  /// [to] - Target language code
  Future<Translation> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    // Check if already in same language
    if (from == to) {
      return Translation(
        originalText: text,
        translatedText: text,
        sourceLanguage: from,
        targetLanguage: to,
        timestamp: DateTime.now(),
      );
    }

    // Check cache
    final cacheKey = '$from-$to-$text';
    if (_cache.containsKey(cacheKey)) {
      print('📚 Using cached translation');
      return _cache[cacheKey]!;
    }

    try {
      print('🔤 Translating from $from to $to...');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': from,
          'target': to,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Translation failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final translatedText = data['translatedText'] as String;

      final translation = Translation(
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: from,
        targetLanguage: to,
        timestamp: DateTime.now(),
      );

      // Cache the translation
      _addToCache(cacheKey, translation);

      print('✅ Translation complete: "$text" → "$translatedText"');

      return translation;
    } catch (e) {
      print('✗ Translation error: $e');
      rethrow;
    }
  }

  /// Translate to Sinhala
  Future<Translation> translateToSinhala(String text, {String from = 'en'}) async {
    return translate(text: text, from: from, to: 'si');
  }

  /// Translate to Tamil
  Future<Translation> translateToTamil(String text, {String from = 'en'}) async {
    return translate(text: text, from: from, to: 'ta');
  }

  /// Translate to English
  Future<Translation> translateToEnglish(String text, String from) async {
    return translate(text: text, from: from, to: 'en');
  }

  /// Detect language and translate to target
  Future<Translation> autoTranslate({
    required String text,
    required String to,
  }) async {
    // Simple language detection - can be improved
    String from = 'en';

    // Check if text contains Sinhala characters
    if (text.contains(RegExp(r'[\u0D80-\u0DFF]'))) {
      from = 'si';
    }
    // Check if text contains Tamil characters
    else if (text.contains(RegExp(r'[\u0B80-\u0BFF]'))) {
      from = 'ta';
    }

    return translate(text: text, from: from, to: to);
  }

  /// Translate multiple texts in batch
  Future<List<Translation>> translateBatch({
    required List<String> texts,
    required String from,
    required String to,
  }) async {
    final translations = <Translation>[];

    for (final text in texts) {
      try {
        final translation = await translate(text: text, from: from, to: to);
        translations.add(translation);
      } catch (e) {
        print('Error translating "$text": $e');
        // Add failed translation with original text
        translations.add(Translation(
          originalText: text,
          translatedText: text,
          sourceLanguage: from,
          targetLanguage: to,
          timestamp: DateTime.now(),
        ));
      }
    }

    return translations;
  }

  /// Add translation to cache
  void _addToCache(String key, Translation translation) {
    if (_cache.length >= _maxCacheSize) {
      // Remove oldest entry
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = translation;
  }

  /// Clear translation cache
  void clearCache() {
    _cache.clear();
  }

  /// Get cache size
  int get cacheSize => _cache.length;
}
