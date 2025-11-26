import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

/// Script to populate attractions.db from attractions.json
///
/// Usage:
/// 1. Ensure attractions.json is in assets/data/
/// 2. Run: dart run scripts/populate_database.dart
/// 3. Database will be created at assets/database/attractions.db

Future<void> main() async {
  print('🗄️  Serendib Guide - Database Population Script');
  print('=' * 60);

  // Initialize FFI for desktop/CLI usage
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  try {
    // Step 1: Load attractions.json
    print('\n📂 Step 1: Loading attractions.json...');
    final jsonFile = File('assets/data/attractions.json');

    if (!await jsonFile.exists()) {
      print('❌ Error: attractions.json not found at ${jsonFile.path}');
      print('   Please ensure the file exists before running this script.');
      exit(1);
    }

    final jsonContent = await jsonFile.readAsString();
    final List<dynamic> attractionsJson = jsonDecode(jsonContent);
    print('✅ Loaded ${attractionsJson.length} attractions from JSON');

    // Step 2: Create database directory if needed
    print('\n📂 Step 2: Preparing database directory...');
    final dbDirectory = Directory('assets/database');
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
      print('✅ Created assets/database/ directory');
    }

    final dbPath = join(dbDirectory.path, 'attractions.db');

    // Delete existing database if present
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
      print('🗑️  Deleted existing database');
    }

    // Step 3: Create database and schema
    print('\n📂 Step 3: Creating database schema...');
    final database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE attractions (
            id INTEGER PRIMARY KEY,
            name_en TEXT NOT NULL,
            name_si TEXT,
            name_ta TEXT,
            category TEXT NOT NULL,
            province TEXT NOT NULL,
            description_en TEXT NOT NULL,
            description_si TEXT,
            description_ta TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            entry_fee TEXT,
            opening_hours TEXT,
            best_time TEXT,
            duration TEXT,
            difficulty TEXT,
            tags TEXT,
            images TEXT NOT NULL,
            is_premium INTEGER DEFAULT 0,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Create indexes for performance
        await db.execute('CREATE INDEX idx_category ON attractions(category)');
        await db.execute('CREATE INDEX idx_province ON attractions(province)');
        await db.execute('CREATE INDEX idx_premium ON attractions(is_premium)');
        await db.execute('CREATE INDEX idx_tags ON attractions(tags)');

        print('✅ Created attractions table with indexes');
      },
    );

    // Step 4: Insert attractions
    print('\n📂 Step 4: Inserting attractions...');
    int successCount = 0;
    int errorCount = 0;

    for (final attraction in attractionsJson) {
      try {
        await database.insert(
          'attractions',
          {
            'id': attraction['id'],
            'name_en': attraction['name_en'],
            'name_si': attraction['name_si'],
            'name_ta': attraction['name_ta'],
            'category': attraction['category'],
            'province': attraction['province'],
            'description_en': attraction['description_en'],
            'description_si': attraction['description_si'],
            'description_ta': attraction['description_ta'],
            'latitude': attraction['latitude'],
            'longitude': attraction['longitude'],
            'entry_fee': attraction['entry_fee'],
            'opening_hours': attraction['opening_hours'],
            'best_time': attraction['best_time'],
            'duration': attraction['duration'],
            'difficulty': attraction['difficulty'],
            'tags': attraction['tags'],
            'images': attraction['images'],
            'is_premium': attraction['is_premium'] ?? 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        successCount++;

        if (successCount % 10 == 0) {
          print('   Inserted $successCount attractions...');
        }
      } catch (e) {
        errorCount++;
        print('❌ Error inserting attraction ${attraction['id']}: $e');
      }
    }

    print('✅ Successfully inserted $successCount attractions');
    if (errorCount > 0) {
      print('⚠️  Failed to insert $errorCount attractions');
    }

    // Step 5: Verify database
    print('\n📂 Step 5: Verifying database...');
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM attractions'),
    );
    print('✅ Database contains $count total attractions');

    // Get counts by category
    final categories = await database.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM attractions
      GROUP BY category
      ORDER BY count DESC
    ''');

    print('\n📊 Attractions by category:');
    for (final cat in categories) {
      print('   ${cat['category']}: ${cat['count']}');
    }

    // Get free vs premium counts
    final freeCount = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM attractions WHERE is_premium = 0'),
    );
    final premiumCount = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM attractions WHERE is_premium = 1'),
    );

    print('\n💰 Freemium distribution:');
    print('   Free: $freeCount attractions');
    print('   Premium: $premiumCount attractions');

    await database.close();

    // Step 6: Get file size
    final dbStat = await dbFile.stat();
    final sizeKB = (dbStat.size / 1024).toStringAsFixed(2);
    print('\n📦 Database size: $sizeKB KB');

    print('\n' + '=' * 60);
    print('✅ SUCCESS! Database created at: $dbPath');
    print('=' * 60);
    print('\n📝 Next steps:');
    print('   1. Verify the database using a SQLite browser');
    print('   2. Test the app: flutter run');
    print('   3. Add more attractions to reach 300+ goal');
    print('');

  } catch (e, stackTrace) {
    print('\n❌ FATAL ERROR: $e');
    print('\nStack trace:');
    print(stackTrace);
    exit(1);
  }
}
