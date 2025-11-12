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
