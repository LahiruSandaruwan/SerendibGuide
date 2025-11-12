import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_data_service.dart';
import '../utils/constants.dart';

/// Global app state provider using ChangeNotifier
class AppStateProvider with ChangeNotifier {
  // Locale
  Locale _currentLocale = const Locale('en');

  // Premium status
  bool _isPremium = false;

  // Filters
  String? _selectedCategory;
  String? _selectedProvince;

  // Favorites
  Set<int> _favoriteIds = {};

  // Ad impression tracking
  int _adImpressionCount = 0;

  // Theme
  bool _isDarkMode = false;

  // Maps
  bool _useOfflineMaps = false;

  // Loading state
  bool _isLoading = false;

  // Services
  final UserDataService _userDataService = UserDataService();

  // Getters
  Locale get currentLocale => _currentLocale;
  String get languageCode => _currentLocale.languageCode;
  bool get isPremium => _isPremium;
  String? get selectedCategory => _selectedCategory;
  String? get selectedProvince => _selectedProvince;
  Set<int> get favoriteIds => _favoriteIds;
  int get adImpressionCount => _adImpressionCount;
  bool get isDarkMode => _isDarkMode;
  bool get useOfflineMaps => _useOfflineMaps;
  bool get isLoading => _isLoading;

  /// Initialize app state from SharedPreferences and database
  Future<void> initialize() async {
    try {
      _setLoading(true);
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load language
      final String? savedLanguageCode = prefs.getString(AppConstants.keyLanguageCode);
      if (savedLanguageCode != null &&
          AppConstants.supportedLanguageCodes.contains(savedLanguageCode)) {
        _currentLocale = Locale(savedLanguageCode);
      }

      // Load premium status
      _isPremium = prefs.getBool(AppConstants.keyIsPremium) ?? false;

      // Load ad impression count
      _adImpressionCount = prefs.getInt(AppConstants.keyAdImpressionCount) ?? 0;

      // Load dark mode preference
      _isDarkMode = prefs.getBool(AppConstants.keyIsDarkMode) ?? false;

      // Load offline maps preference
      _useOfflineMaps = prefs.getBool(AppConstants.keyUseOfflineMaps) ?? false;

      // Load favorites from database
      _favoriteIds = (await _userDataService.getFavoriteIds()).toSet();

      print('✓ App state initialized: locale=$languageCode, premium=$_isPremium, favorites=${_favoriteIds.length}');

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      print('✗ Error initializing app state: $e');
      _setLoading(false);
    }
  }

  // ==================== LOCALE MANAGEMENT ====================

  /// Set app locale
  Future<void> setLocale(Locale locale) async {
    if (!AppConstants.supportedLanguageCodes.contains(locale.languageCode)) {
      print('✗ Unsupported language code: ${locale.languageCode}');
      return;
    }

    try {
      _currentLocale = locale;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLanguageCode, locale.languageCode);
      print('✓ Locale set to: ${locale.languageCode}');
      notifyListeners();
    } catch (e) {
      print('✗ Error setting locale: $e');
    }
  }

  // ==================== PREMIUM MANAGEMENT ====================

  /// Toggle premium status
  Future<void> setPremiumStatus(bool isPremium) async {
    try {
      _isPremium = isPremium;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsPremium, isPremium);
      print('✓ Premium status set to: $isPremium');
      notifyListeners();
    } catch (e) {
      print('✗ Error setting premium status: $e');
    }
  }

  // ==================== FILTER MANAGEMENT ====================

  /// Set selected category filter
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    print('Category filter: $category');
    notifyListeners();
  }

  /// Set selected province filter
  void setSelectedProvince(String? province) {
    _selectedProvince = province;
    print('Province filter: $province');
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedProvince = null;
    print('Filters cleared');
    notifyListeners();
  }

  // ==================== FAVORITES MANAGEMENT ====================

  /// Add attraction to favorites
  Future<void> addFavorite(int attractionId) async {
    // Check free tier limit
    if (!_isPremium && _favoriteIds.length >= AppConstants.freeFavoritesLimit) {
      throw Exception('Free users can save up to ${AppConstants.freeFavoritesLimit} favorites. Upgrade to Premium for unlimited favorites!');
    }

    try {
      await _userDataService.addFavorite(attractionId);
      _favoriteIds.add(attractionId);
      print('✓ Added favorite: $attractionId');
      notifyListeners();
    } catch (e) {
      print('✗ Error adding favorite: $e');
      rethrow;
    }
  }

  /// Remove attraction from favorites
  Future<void> removeFavorite(int attractionId) async {
    try {
      await _userDataService.removeFavorite(attractionId);
      _favoriteIds.remove(attractionId);
      print('✓ Removed favorite: $attractionId');
      notifyListeners();
    } catch (e) {
      print('✗ Error removing favorite: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(int attractionId) async {
    if (_favoriteIds.contains(attractionId)) {
      await removeFavorite(attractionId);
    } else {
      await addFavorite(attractionId);
    }
  }

  /// Check if attraction is favorited
  bool isFavorite(int attractionId) {
    return _favoriteIds.contains(attractionId);
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    try {
      await _userDataService.clearFavorites();
      _favoriteIds.clear();
      print('✓ Cleared all favorites');
      notifyListeners();
    } catch (e) {
      print('✗ Error clearing favorites: $e');
    }
  }

  // ==================== AD MANAGEMENT ====================

  /// Increment ad impression count
  /// Returns true if interstitial ad should be shown
  Future<bool> incrementAdImpressions() async {
    if (_isPremium) return false; // No ads for premium users

    try {
      _adImpressionCount++;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyAdImpressionCount, _adImpressionCount);

      // Show interstitial every N impressions
      final bool shouldShowInterstitial =
          _adImpressionCount % AppConstants.interstitialAdFrequency == 0;

      if (shouldShowInterstitial) {
        print('✓ Show interstitial ad (impression #$_adImpressionCount)');
      }

      return shouldShowInterstitial;
    } catch (e) {
      print('✗ Error incrementing ad impressions: $e');
      return false;
    }
  }

  /// Reset ad impression count
  Future<void> resetAdImpressions() async {
    try {
      _adImpressionCount = 0;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.keyAdImpressionCount, 0);
    } catch (e) {
      print('✗ Error resetting ad impressions: $e');
    }
  }

  // ==================== THEME MANAGEMENT ====================

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    try {
      _isDarkMode = !_isDarkMode;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsDarkMode, _isDarkMode);
      print('✓ Dark mode: $_isDarkMode');
      notifyListeners();
    } catch (e) {
      print('✗ Error toggling dark mode: $e');
    }
  }

  /// Set dark mode
  Future<void> setDarkMode(bool isDark) async {
    try {
      _isDarkMode = isDark;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsDarkMode, isDark);
      notifyListeners();
    } catch (e) {
      print('✗ Error setting dark mode: $e');
    }
  }

  // ==================== MAPS MANAGEMENT ====================

  /// Toggle offline maps
  Future<void> toggleOfflineMaps() async {
    try {
      _useOfflineMaps = !_useOfflineMaps;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyUseOfflineMaps, _useOfflineMaps);
      print('✓ Offline maps: $_useOfflineMaps');
      notifyListeners();
    } catch (e) {
      print('✗ Error toggling offline maps: $e');
    }
  }

  /// Set offline maps
  Future<void> setOfflineMaps(bool useOffline) async {
    try {
      _useOfflineMaps = useOffline;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyUseOfflineMaps, useOffline);
      notifyListeners();
    } catch (e) {
      print('✗ Error setting offline maps: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) {
      notifyListeners(); // Only notify when loading completes
    }
  }

  /// Refresh favorites from database
  Future<void> refreshFavorites() async {
    try {
      _favoriteIds = (await _userDataService.getFavoriteIds()).toSet();
      notifyListeners();
    } catch (e) {
      print('✗ Error refreshing favorites: $e');
    }
  }

  /// Reset all app state (for debugging)
  Future<void> resetAppState() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _userDataService.resetAllData();

      _currentLocale = const Locale('en');
      _isPremium = false;
      _selectedCategory = null;
      _selectedProvince = null;
      _favoriteIds.clear();
      _adImpressionCount = 0;
      _isDarkMode = false;
      _useOfflineMaps = false;

      print('✓ App state reset');
      notifyListeners();
    } catch (e) {
      print('✗ Error resetting app state: $e');
    }
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}
