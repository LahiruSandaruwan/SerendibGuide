import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wikipedia_info.dart';

/// Wikipedia service using Wikipedia REST API
/// 100% FREE - No API key required!
class WikipediaService {
  static const String _baseUrl = 'https://en.wikipedia.org/api/rest_v1/page/summary';

  // Cache for Wikipedia articles
  static final Map<String, WikipediaInfo> _cache = {};
  static const int _maxCacheSize = 50;

  /// Get Wikipedia summary for a topic
  ///
  /// [title] - Article title (e.g., "Sigiriya", "Sri Lanka")
  Future<WikipediaInfo> getArticleSummary(String title) async {
    // Check cache
    final cacheKey = title.toLowerCase().trim();
    if (_cache.containsKey(cacheKey)) {
      print('📚 Using cached Wikipedia article');
      return _cache[cacheKey]!;
    }

    try {
      // URL encode the title
      final encodedTitle = Uri.encodeComponent(title);
      final url = Uri.parse('$_baseUrl/$encodedTitle');

      print('📖 Fetching Wikipedia summary for "$title"...');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 404) {
        throw Exception('Article not found: $title');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch article: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final info = WikipediaInfo.fromJson(data);

      // Cache the result
      _addToCache(cacheKey, info);

      print('✅ Wikipedia article loaded: ${info.title}');
      if (info.hasThumbnail) {
        print('   Image available: ${info.thumbnail}');
      }

      return info;
    } catch (e) {
      print('✗ Error fetching Wikipedia article: $e');
      rethrow;
    }
  }

  /// Search Wikipedia articles
  ///
  /// [query] - Search query
  /// [limit] - Maximum number of results (default: 10)
  Future<List<String>> search(String query, {int limit = 10}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://en.wikipedia.org/w/api.php'
        '?action=opensearch'
        '&search=$encodedQuery'
        '&limit=$limit'
        '&format=json',
      );

      print('🔍 Searching Wikipedia for "$query"...');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception('Search failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.length < 2) return [];

      final results = (data[1] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      print('✅ Found ${results.length} results');

      return results;
    } catch (e) {
      print('✗ Error searching Wikipedia: $e');
      rethrow;
    }
  }

  /// Get article summary with fallback search
  ///
  /// If exact title not found, searches and returns best match
  Future<WikipediaInfo?> getArticleSummaryWithFallback(String title) async {
    try {
      return await getArticleSummary(title);
    } catch (e) {
      print('Article not found, trying search...');

      try {
        final results = await search(title, limit: 1);
        if (results.isEmpty) return null;

        return await getArticleSummary(results.first);
      } catch (searchError) {
        print('Search also failed: $searchError');
        return null;
      }
    }
  }

  /// Add article to cache
  void _addToCache(String key, WikipediaInfo info) {
    if (_cache.length >= _maxCacheSize) {
      // Remove oldest entry
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = info;
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Get cache size
  int get cacheSize => _cache.length;
}
