import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/trip.dart';
import '../utils/constants.dart';

/// Singleton service for managing user data (favorites, trips, settings)
class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  Database? _database;

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize user data database with schema
  Future<Database> _initDatabase() async {
    try {
      final String databasesPath = await getDatabasesPath();
      final String path = join(databasesPath, AppConstants.userDataDbName);

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('✗ Error initializing user data database: $e');
      rethrow;
    }
  }

  /// Create database schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attraction_id INTEGER NOT NULL UNIQUE,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_favorite_attraction ON favorites(attraction_id)
    ''');

    await db.execute('''
      CREATE TABLE trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL CHECK(length(name) > 0),
        attraction_ids TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_trip_updated ON trips(updated_at DESC)
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    print('✓ User data database schema created');
  }

  // ==================== FAVORITES OPERATIONS ====================

  /// Add attraction to favorites
  Future<void> addFavorite(int attractionId) async {
    try {
      final Database db = await database;
      await db.insert(
        'favorites',
        {
          'attraction_id': attractionId,
          'added_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      print('✓ Added attraction $attractionId to favorites');
    } catch (e) {
      print('✗ Error adding favorite: $e');
    }
  }

  /// Remove attraction from favorites
  Future<void> removeFavorite(int attractionId) async {
    try {
      final Database db = await database;
      await db.delete(
        'favorites',
        where: 'attraction_id = ?',
        whereArgs: [attractionId],
      );
      print('✓ Removed attraction $attractionId from favorites');
    } catch (e) {
      print('✗ Error removing favorite: $e');
    }
  }

  /// Get all favorite attraction IDs
  Future<List<int>> getFavoriteIds() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'favorites',
        columns: ['attraction_id'],
        orderBy: 'added_at DESC',
      );
      return maps.map((map) => map['attraction_id'] as int).toList();
    } catch (e) {
      print('✗ Error fetching favorites: $e');
      return [];
    }
  }

  /// Check if attraction is favorited
  Future<bool> isFavorite(int attractionId) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'favorites',
        where: 'attraction_id = ?',
        whereArgs: [attractionId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      print('✗ Error checking favorite: $e');
      return false;
    }
  }

  /// Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM favorites',
      );
      return result.first['count'] as int;
    } catch (e) {
      print('✗ Error counting favorites: $e');
      return 0;
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    try {
      final Database db = await database;
      await db.delete('favorites');
      print('✓ Cleared all favorites');
    } catch (e) {
      print('✗ Error clearing favorites: $e');
    }
  }

  // ==================== TRIPS OPERATIONS ====================

  /// Create new trip
  Future<int> createTrip(String name, List<int> attractionIds) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Trip name cannot be empty');
    }

    try {
      final Database db = await database;
      final int id = await db.insert(
        'trips',
        Trip(
          name: name,
          attractionIds: attractionIds,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ).toJson(),
      );
      print('✓ Created trip: $name (ID: $id)');
      return id;
    } catch (e) {
      print('✗ Error creating trip: $e');
      rethrow;
    }
  }

  /// Get all trips
  Future<List<Trip>> getTrips() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trips',
        orderBy: 'updated_at DESC',
      );
      return maps.map((map) => Trip.fromJson(map)).toList();
    } catch (e) {
      print('✗ Error fetching trips: $e');
      return [];
    }
  }

  /// Get single trip by ID
  Future<Trip?> getTrip(int id) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trips',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Trip.fromJson(maps.first);
    } catch (e) {
      print('✗ Error fetching trip $id: $e');
      return null;
    }
  }

  /// Update trip
  Future<void> updateTrip(int tripId, String name, List<int> attractionIds) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Trip name cannot be empty');
    }

    try {
      final Database db = await database;
      await db.update(
        'trips',
        {
          'name': name,
          'attraction_ids': Trip(name: name, attractionIds: attractionIds)
              .toJson()['attraction_ids'],
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [tripId],
      );
      print('✓ Updated trip $tripId');
    } catch (e) {
      print('✗ Error updating trip: $e');
      rethrow;
    }
  }

  /// Delete trip
  Future<void> deleteTrip(int tripId) async {
    try {
      final Database db = await database;
      await db.delete(
        'trips',
        where: 'id = ?',
        whereArgs: [tripId],
      );
      print('✓ Deleted trip $tripId');
    } catch (e) {
      print('✗ Error deleting trip: $e');
    }
  }

  /// Get trips count
  Future<int> getTripsCount() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM trips',
      );
      return result.first['count'] as int;
    } catch (e) {
      print('✗ Error counting trips: $e');
      return 0;
    }
  }

  // ==================== SETTINGS OPERATIONS ====================

  /// Get setting value
  Future<String?> getSetting(String key) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return maps.first['value'] as String?;
    } catch (e) {
      print('✗ Error fetching setting $key: $e');
      return null;
    }
  }

  /// Set setting value
  Future<void> setSetting(String key, String value) async {
    try {
      final Database db = await database;
      await db.insert(
        'app_settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('✗ Error setting $key: $e');
    }
  }

  /// Delete setting
  Future<void> deleteSetting(String key) async {
    try {
      final Database db = await database;
      await db.delete(
        'app_settings',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e) {
      print('✗ Error deleting setting $key: $e');
    }
  }

  // ==================== EXPENSES OPERATIONS ====================

  /// Initialize expenses table if it doesn't exist
  Future<void> _ensureExpensesTable() async {
    final Database db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_expense_date ON expenses(date DESC)
    ''');
  }

  /// Add expense
  Future<int> addExpense(String category, double amount, String currency, String description, DateTime date) async {
    try {
      await _ensureExpensesTable();
      final Database db = await database;
      final int id = await db.insert('expenses', {
        'category': category,
        'amount': amount,
        'currency': currency,
        'description': description,
        'date': date.toIso8601String(),
      });
      print('✓ Added expense: $description (ID: $id)');
      return id;
    } catch (e) {
      print('✗ Error adding expense: $e');
      rethrow;
    }
  }

  /// Get all expenses
  Future<List<Map<String, dynamic>>> getExpenses() async {
    try {
      await _ensureExpensesTable();
      final Database db = await database;
      return await db.query('expenses', orderBy: 'date DESC');
    } catch (e) {
      print('✗ Error fetching expenses: $e');
      return [];
    }
  }

  /// Delete expense
  Future<void> deleteExpense(int id) async {
    try {
      await _ensureExpensesTable();
      final Database db = await database;
      await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
      print('✓ Deleted expense $id');
    } catch (e) {
      print('✗ Error deleting expense: $e');
    }
  }

  /// Get expenses by date range
  Future<List<Map<String, dynamic>>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      await _ensureExpensesTable();
      final Database db = await database;
      return await db.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );
    } catch (e) {
      print('✗ Error fetching expenses by date: $e');
      return [];
    }
  }

  /// Get total expenses by category
  Future<Map<String, double>> getExpensesByCategory() async {
    try {
      await _ensureExpensesTable();
      final Database db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM expenses GROUP BY category',
      );
      return Map.fromEntries(
        result.map((row) => MapEntry(row['category'] as String, row['total'] as double)),
      );
    } catch (e) {
      print('✗ Error getting expenses by category: $e');
      return {};
    }
  }

  /// Clear all expenses
  Future<void> clearAllExpenses() async {
    try {
      await _ensureExpensesTable();
      final Database db = await database;
      await db.delete('expenses');
      print('✓ Cleared all expenses');
    } catch (e) {
      print('✗ Error clearing expenses: $e');
    }
  }

  // ==================== JOURNAL OPERATIONS ====================

  /// Initialize journal table if it doesn't exist
  Future<void> _ensureJournalTable() async {
    final Database db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attraction_id INTEGER,
        attraction_name TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        rating INTEGER DEFAULT 0,
        photo_path TEXT,
        tags TEXT
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_journal_visit_date ON journal_entries(visit_date DESC)
    ''');
  }

  /// Add journal entry
  Future<int> addJournalEntry({
    int? attractionId,
    required String attractionName,
    required String title,
    required String content,
    required DateTime visitDate,
    int rating = 0,
    String? photoPath,
    List<String> tags = const [],
  }) async {
    try {
      await _ensureJournalTable();
      final Database db = await database;
      final int id = await db.insert('journal_entries', {
        'attraction_id': attractionId,
        'attraction_name': attractionName,
        'title': title,
        'content': content,
        'visit_date': visitDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'rating': rating,
        'photo_path': photoPath,
        'tags': tags.join(','),
      });
      print('✓ Added journal entry: $title (ID: $id)');
      return id;
    } catch (e) {
      print('✗ Error adding journal entry: $e');
      rethrow;
    }
  }

  /// Get all journal entries
  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    try {
      await _ensureJournalTable();
      final Database db = await database;
      return await db.query('journal_entries', orderBy: 'visit_date DESC');
    } catch (e) {
      print('✗ Error fetching journal entries: $e');
      return [];
    }
  }

  /// Get journal entry by ID
  Future<Map<String, dynamic>?> getJournalEntry(int id) async {
    try {
      await _ensureJournalTable();
      final Database db = await database;
      final result = await db.query(
        'journal_entries',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isEmpty ? null : result.first;
    } catch (e) {
      print('✗ Error fetching journal entry: $e');
      return null;
    }
  }

  /// Update journal entry
  Future<void> updateJournalEntry(int id, Map<String, dynamic> updates) async {
    try {
      await _ensureJournalTable();
      final Database db = await database;
      await db.update(
        'journal_entries',
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );
      print('✓ Updated journal entry $id');
    } catch (e) {
      print('✗ Error updating journal entry: $e');
    }
  }

  /// Delete journal entry
  Future<void> deleteJournalEntry(int id) async {
    try {
      await _ensureJournalTable();
      final Database db = await database;
      await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
      print('✓ Deleted journal entry $id');
    } catch (e) {
      print('✗ Error deleting journal entry: $e');
    }
  }

  /// Get journal entries by attraction
  Future<List<Map<String, dynamic>>> getJournalEntriesByAttraction(int attractionId) async {
    try {
      await _ensureJournalTable();
      final Database db = await database;
      return await db.query(
        'journal_entries',
        where: 'attraction_id = ?',
        whereArgs: [attractionId],
        orderBy: 'visit_date DESC',
      );
    } catch (e) {
      print('✗ Error fetching journal entries by attraction: $e');
      return [];
    }
  }

  /// Clear all journal entries
  Future<void> clearAllJournalEntries() async {
    try {
      await _ensureJournalTable();
      final Database db = await database;
      await db.delete('journal_entries');
      print('✓ Cleared all journal entries');
    } catch (e) {
      print('✗ Error clearing journal entries: $e');
    }
  }

  // ==================== USER REVIEWS OPERATIONS ====================

  /// Initialize user reviews table if it doesn't exist
  Future<void> _ensureReviewsTable() async {
    final Database db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attraction_id INTEGER NOT NULL,
        attraction_name TEXT NOT NULL,
        user_name TEXT NOT NULL,
        rating INTEGER NOT NULL,
        review_text TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        posted_date TEXT NOT NULL,
        helpful_count INTEGER DEFAULT 0,
        photo_paths TEXT,
        user_country TEXT,
        category TEXT DEFAULT 'general'
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_review_attraction ON user_reviews(attraction_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_review_posted ON user_reviews(posted_date DESC)
    ''');
  }

  /// Add a user review
  Future<int> addReview({
    required int attractionId,
    required String attractionName,
    required String userName,
    required int rating,
    required String reviewText,
    required DateTime visitDate,
    List<String> photoPaths = const [],
    String? userCountry,
    String category = 'general',
  }) async {
    try {
      await _ensureReviewsTable();
      final Database db = await database;
      final int id = await db.insert('user_reviews', {
        'attraction_id': attractionId,
        'attraction_name': attractionName,
        'user_name': userName,
        'rating': rating,
        'review_text': reviewText,
        'visit_date': visitDate.toIso8601String(),
        'posted_date': DateTime.now().toIso8601String(),
        'helpful_count': 0,
        'photo_paths': photoPaths.join(','),
        'user_country': userCountry,
        'category': category,
      });
      print('✓ Added review for $attractionName (ID: $id)');
      return id;
    } catch (e) {
      print('✗ Error adding review: $e');
      rethrow;
    }
  }

  /// Get all reviews for an attraction
  Future<List<Map<String, dynamic>>> getReviewsByAttraction(int attractionId) async {
    try {
      await _ensureReviewsTable();
      final Database db = await database;
      return await db.query(
        'user_reviews',
        where: 'attraction_id = ?',
        whereArgs: [attractionId],
        orderBy: 'posted_date DESC',
      );
    } catch (e) {
      print('✗ Error fetching reviews: $e');
      return [];
    }
  }

  /// Get all reviews
  Future<List<Map<String, dynamic>>> getAllReviews() async {
    try {
      await _ensureReviewsTable();
      final Database db = await database;
      return await db.query('user_reviews', orderBy: 'posted_date DESC');
    } catch (e) {
      print('✗ Error fetching all reviews: $e');
      return [];
    }
  }

  /// Mark review as helpful
  Future<void> markReviewHelpful(int reviewId) async {
    try {
      await _ensureReviewsTable();
      final Database db = await database;
      await db.rawUpdate(
        'UPDATE user_reviews SET helpful_count = helpful_count + 1 WHERE id = ?',
        [reviewId],
      );
      print('✓ Marked review $reviewId as helpful');
    } catch (e) {
      print('✗ Error marking review helpful: $e');
    }
  }

  /// Delete a review
  Future<void> deleteReview(int reviewId) async {
    try {
      await _ensureReviewsTable();
      final Database db = await database;
      await db.delete('user_reviews', where: 'id = ?', whereArgs: [reviewId]);
      print('✓ Deleted review $reviewId');
    } catch (e) {
      print('✗ Error deleting review: $e');
    }
  }

  /// Get average rating for an attraction
  Future<double> getAverageRating(int attractionId) async {
    try {
      await _ensureReviewsTable();
      final Database db = await database;
      final result = await db.rawQuery(
        'SELECT AVG(rating) as avg_rating FROM user_reviews WHERE attraction_id = ?',
        [attractionId],
      );
      if (result.isNotEmpty && result.first['avg_rating'] != null) {
        return result.first['avg_rating'] as double;
      }
      return 0.0;
    } catch (e) {
      print('✗ Error calculating average rating: $e');
      return 0.0;
    }
  }

  // ==================== TRAVEL TIPS OPERATIONS ====================

  /// Initialize travel tips table if it doesn't exist
  Future<void> _ensureTipsTable() async {
    final Database db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS travel_tips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attraction_id INTEGER,
        attraction_name TEXT,
        user_name TEXT NOT NULL,
        title TEXT NOT NULL,
        tip_text TEXT NOT NULL,
        posted_date TEXT NOT NULL,
        helpful_count INTEGER DEFAULT 0,
        category TEXT DEFAULT 'general',
        tags TEXT
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_tip_posted ON travel_tips(posted_date DESC)
    ''');
  }

  /// Add a travel tip
  Future<int> addTravelTip({
    int? attractionId,
    String? attractionName,
    required String userName,
    required String title,
    required String tipText,
    String category = 'general',
    List<String> tags = const [],
  }) async {
    try {
      await _ensureTipsTable();
      final Database db = await database;
      final int id = await db.insert('travel_tips', {
        'attraction_id': attractionId,
        'attraction_name': attractionName,
        'user_name': userName,
        'title': title,
        'tip_text': tipText,
        'posted_date': DateTime.now().toIso8601String(),
        'helpful_count': 0,
        'category': category,
        'tags': tags.join(','),
      });
      print('✓ Added travel tip: $title (ID: $id)');
      return id;
    } catch (e) {
      print('✗ Error adding travel tip: $e');
      rethrow;
    }
  }

  /// Get all travel tips
  Future<List<Map<String, dynamic>>> getAllTravelTips() async {
    try {
      await _ensureTipsTable();
      final Database db = await database;
      return await db.query('travel_tips', orderBy: 'posted_date DESC');
    } catch (e) {
      print('✗ Error fetching travel tips: $e');
      return [];
    }
  }

  /// Get travel tips by attraction
  Future<List<Map<String, dynamic>>> getTipsByAttraction(int attractionId) async {
    try {
      await _ensureTipsTable();
      final Database db = await database;
      return await db.query(
        'travel_tips',
        where: 'attraction_id = ?',
        whereArgs: [attractionId],
        orderBy: 'posted_date DESC',
      );
    } catch (e) {
      print('✗ Error fetching tips by attraction: $e');
      return [];
    }
  }

  /// Get travel tips by category
  Future<List<Map<String, dynamic>>> getTipsByCategory(String category) async {
    try {
      await _ensureTipsTable();
      final Database db = await database;
      return await db.query(
        'travel_tips',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'helpful_count DESC, posted_date DESC',
      );
    } catch (e) {
      print('✗ Error fetching tips by category: $e');
      return [];
    }
  }

  /// Mark tip as helpful
  Future<void> markTipHelpful(int tipId) async {
    try {
      await _ensureTipsTable();
      final Database db = await database;
      await db.rawUpdate(
        'UPDATE travel_tips SET helpful_count = helpful_count + 1 WHERE id = ?',
        [tipId],
      );
      print('✓ Marked tip $tipId as helpful');
    } catch (e) {
      print('✗ Error marking tip helpful: $e');
    }
  }

  /// Delete a travel tip
  Future<void> deleteTravelTip(int tipId) async {
    try {
      await _ensureTipsTable();
      final Database db = await database;
      await db.delete('travel_tips', where: 'id = ?', whereArgs: [tipId]);
      print('✓ Deleted travel tip $tipId');
    } catch (e) {
      print('✗ Error deleting travel tip: $e');
    }
  }

  // ==================== COMMUNITY PHOTOS OPERATIONS ====================

  /// Initialize community photos table if it doesn't exist
  Future<void> _ensureCommunityPhotosTable() async {
    final Database db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS community_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        attraction_id INTEGER NOT NULL,
        attraction_name TEXT NOT NULL,
        user_name TEXT NOT NULL,
        photo_path TEXT NOT NULL,
        caption TEXT,
        upload_date TEXT NOT NULL,
        taken_date TEXT,
        likes_count INTEGER DEFAULT 0,
        tags TEXT,
        location TEXT
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_photo_attraction ON community_photos(attraction_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_photo_upload ON community_photos(upload_date DESC)
    ''');
  }

  /// Add a community photo
  Future<int> addCommunityPhoto({
    required int attractionId,
    required String attractionName,
    required String userName,
    required String photoPath,
    String? caption,
    DateTime? takenDate,
    List<String> tags = const [],
    String? location,
  }) async {
    try {
      await _ensureCommunityPhotosTable();
      final Database db = await database;
      final int id = await db.insert('community_photos', {
        'attraction_id': attractionId,
        'attraction_name': attractionName,
        'user_name': userName,
        'photo_path': photoPath,
        'caption': caption,
        'upload_date': DateTime.now().toIso8601String(),
        'taken_date': takenDate?.toIso8601String(),
        'likes_count': 0,
        'tags': tags.join(','),
        'location': location,
      });
      print('✓ Added community photo for $attractionName (ID: $id)');
      return id;
    } catch (e) {
      print('✗ Error adding community photo: $e');
      rethrow;
    }
  }

  /// Get all community photos
  Future<List<Map<String, dynamic>>> getAllCommunityPhotos() async {
    try {
      await _ensureCommunityPhotosTable();
      final Database db = await database;
      return await db.query('community_photos', orderBy: 'upload_date DESC');
    } catch (e) {
      print('✗ Error fetching community photos: $e');
      return [];
    }
  }

  /// Get community photos by attraction
  Future<List<Map<String, dynamic>>> getPhotosByAttraction(int attractionId) async {
    try {
      await _ensureCommunityPhotosTable();
      final Database db = await database;
      return await db.query(
        'community_photos',
        where: 'attraction_id = ?',
        whereArgs: [attractionId],
        orderBy: 'upload_date DESC',
      );
    } catch (e) {
      print('✗ Error fetching photos by attraction: $e');
      return [];
    }
  }

  /// Like a community photo
  Future<void> likeCommunityPhoto(int photoId) async {
    try {
      await _ensureCommunityPhotosTable();
      final Database db = await database;
      await db.rawUpdate(
        'UPDATE community_photos SET likes_count = likes_count + 1 WHERE id = ?',
        [photoId],
      );
      print('✓ Liked photo $photoId');
    } catch (e) {
      print('✗ Error liking photo: $e');
    }
  }

  /// Delete a community photo
  Future<void> deleteCommunityPhoto(int photoId) async {
    try {
      await _ensureCommunityPhotosTable();
      final Database db = await database;
      await db.delete('community_photos', where: 'id = ?', whereArgs: [photoId]);
      print('✓ Deleted community photo $photoId');
    } catch (e) {
      print('✗ Error deleting community photo: $e');
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Get user data database size
  Future<int> getDatabaseSize() async {
    try {
      final String databasesPath = await getDatabasesPath();
      final String path = join(databasesPath, AppConstants.userDataDbName);
      final file = await getDatabasesPath().then((p) => join(p, AppConstants.userDataDbName));
      final dbFile = await openDatabase(file);
      final size = await dbFile.getVersion();
      return size;
    } catch (e) {
      print('✗ Error getting database size: $e');
      return 0;
    }
  }

  /// Reset all user data (for debugging or user request)
  Future<void> resetAllData() async {
    try {
      final Database db = await database;
      await db.delete('favorites');
      await db.delete('trips');
      await db.delete('app_settings');
      await db.delete('expenses');
      print('✓ Reset all user data');
    } catch (e) {
      print('✗ Error resetting data: $e');
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
