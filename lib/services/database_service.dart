import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/attraction.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Singleton service for reading attractions from bundled database
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  bool _isInitialized = false;

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null && _isInitialized) return _database!;
    _database = await _initDatabase();
    _isInitialized = true;
    return _database!;
  }

  /// Initialize database by copying from assets on first launch
  Future<Database> _initDatabase() async {
    try {
      final String databasesPath = await getDatabasesPath();
      final String path = join(databasesPath, AppConstants.attractionsDbName);

      // Check if database already exists
      final bool exists = await databaseExists(path);

      if (!exists) {
        // Create parent directory if needed
        final Directory directory = Directory(dirname(path));
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Copy database from assets
        final ByteData data = await rootBundle.load(
          'assets/database/${AppConstants.attractionsDbName}',
        );
        final List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await File(path).writeAsBytes(bytes, flush: true);

        print('✓ Database copied from assets to $path');
      }

      // Open database in read-only mode
      // Note: Don't specify version when opening in readOnly mode to avoid write attempts
      return await openDatabase(
        path,
        readOnly: true,
      );
    } catch (e) {
      print('✗ Error initializing database: $e');
      rethrow;
    }
  }

  /// Get all attractions with optional filters
  Future<List<Attraction>> getAttractions({
    String? category,
    String? province,
    bool includePremium = false,
  }) async {
    try {
      final Database db = await database;
      final List<String> whereClauses = [];
      final List<dynamic> whereArgs = [];

      // Add category filter
      if (category != null && category.isNotEmpty && category != 'All') {
        whereClauses.add('category = ?');
        whereArgs.add(category);
      }

      // Add province filter
      if (province != null && province.isNotEmpty) {
        whereClauses.add('province = ?');
        whereArgs.add(province);
      }

      // Add premium filter
      if (!includePremium) {
        whereClauses.add('is_premium = 0');
      }

      // Build query
      final String whereClause = whereClauses.isNotEmpty
          ? whereClauses.join(' AND ')
          : '';

      final List<Map<String, dynamic>> maps = await db.query(
        'attractions',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'name_en ASC',
      );

      return maps.map((map) => Attraction.fromJson(map)).toList();
    } catch (e) {
      print('✗ Error fetching attractions: $e');
      return [];
    }
  }

  /// Get single attraction by ID
  Future<Attraction?> getAttraction(int id) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'attractions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Attraction.fromJson(maps.first);
    } catch (e) {
      print('✗ Error fetching attraction $id: $e');
      return null;
    }
  }

  /// Search attractions by name and tags
  Future<List<Attraction>> searchAttractions(
    String query,
    String locale,
    bool includePremium,
  ) async {
    if (query.length < AppConstants.minSearchLength) {
      return [];
    }

    try {
      final Database db = await database;
      final String sanitizedQuery = Helpers.sanitizeSearchQuery(query);
      final String searchPattern = '%$sanitizedQuery%';

      // Determine which name column to search based on locale
      final String nameColumn = locale == 'si'
          ? 'name_si'
          : locale == 'ta'
              ? 'name_ta'
              : 'name_en';

      // Build WHERE clause
      final List<String> whereClauses = [
        '($nameColumn LIKE ? OR name_en LIKE ? OR tags LIKE ?)',
      ];
      final List<dynamic> whereArgs = [
        searchPattern,
        searchPattern,
        searchPattern,
      ];

      if (!includePremium) {
        whereClauses.add('is_premium = 0');
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'attractions',
        where: whereClauses.join(' AND '),
        whereArgs: whereArgs,
        orderBy: 'name_en ASC',
      );

      return maps.map((map) => Attraction.fromJson(map)).toList();
    } catch (e) {
      print('✗ Error searching attractions: $e');
      return [];
    }
  }

  /// Get attractions by list of IDs (for trips and favorites)
  Future<List<Attraction>> getAttractionsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    try {
      final Database db = await database;
      final String placeholders = List.filled(ids.length, '?').join(',');

      final List<Map<String, dynamic>> maps = await db.query(
        'attractions',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );

      // Sort results to match input order
      final Map<int, Attraction> attractionsMap = {
        for (var map in maps) map['id'] as int: Attraction.fromJson(map)
      };

      return ids
          .where((id) => attractionsMap.containsKey(id))
          .map((id) => attractionsMap[id]!)
          .toList();
    } catch (e) {
      print('✗ Error fetching attractions by IDs: $e');
      return [];
    }
  }

  /// Get nearby attractions using Haversine distance
  Future<List<Attraction>> getNearbyAttractions(
    int attractionId,
    double radiusKm,
  ) async {
    try {
      final Attraction? sourceAttraction = await getAttraction(attractionId);
      if (sourceAttraction == null) return [];

      final List<Attraction> allAttractions = await getAttractions(
        includePremium: true,
      );

      // Calculate distances and filter by radius
      final List<MapEntry<Attraction, double>> attractionsWithDistance = [];

      for (final attraction in allAttractions) {
        if (attraction.id == attractionId) continue; // Skip source attraction

        final double distance = sourceAttraction.distanceFrom(
          attraction.latitude,
          attraction.longitude,
        );

        if (distance <= radiusKm) {
          attractionsWithDistance.add(MapEntry(attraction, distance));
        }
      }

      // Sort by distance
      attractionsWithDistance.sort((a, b) => a.value.compareTo(b.value));

      // Return top results
      return attractionsWithDistance
          .take(AppConstants.maxNearbyResults)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      print('✗ Error fetching nearby attractions: $e');
      return [];
    }
  }

  /// Get attractions count
  Future<int> getAttractionsCount({bool includePremium = false}) async {
    try {
      final Database db = await database;
      final String whereClause = includePremium ? '' : 'is_premium = 0';

      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM attractions ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}',
      );

      return result.first['count'] as int;
    } catch (e) {
      print('✗ Error counting attractions: $e');
      return 0;
    }
  }

  /// Get attractions by category (for statistics)
  Future<Map<String, int>> getAttractionsByCategory() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT category, COUNT(*) as count FROM attractions GROUP BY category ORDER BY count DESC',
      );

      return {for (var row in result) row['category'] as String: row['count'] as int};
    } catch (e) {
      print('✗ Error fetching category statistics: $e');
      return {};
    }
  }

  /// Get attractions by province (for statistics)
  Future<Map<String, int>> getAttractionsByProvince() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT province, COUNT(*) as count FROM attractions GROUP BY province ORDER BY count DESC',
      );

      return {for (var row in result) row['province'] as String: row['count'] as int};
    } catch (e) {
      print('✗ Error fetching province statistics: $e');
      return {};
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }

  /// Get database file size
  Future<int> getDatabaseSize() async {
    try {
      final String databasesPath = await getDatabasesPath();
      final String path = join(databasesPath, AppConstants.attractionsDbName);
      final File dbFile = File(path);

      if (await dbFile.exists()) {
        return await dbFile.length();
      }
      return 0;
    } catch (e) {
      print('✗ Error getting database size: $e');
      return 0;
    }
  }
}
