#!/usr/bin/env python3
"""
Database Population Script for Serendib Guide
Converts attractions.json to attractions.db SQLite database

Usage:
    python populate_database.py

Requirements:
    - Python 3.6+
    - No external dependencies (uses stdlib only)

Output:
    - Creates assets/database/attractions.db
"""

import sqlite3
import json
import os
from datetime import datetime

# Paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
JSON_FILE = os.path.join(PROJECT_ROOT, 'assets', 'data', 'attractions.json')
DB_DIR = os.path.join(PROJECT_ROOT, 'assets', 'database')
DB_FILE = os.path.join(DB_DIR, 'attractions.db')


def create_database():
    """Create the attractions database with schema"""
    print(f'📁 Creating database directory: {DB_DIR}')
    os.makedirs(DB_DIR, exist_ok=True)

    # Remove old database if exists
    if os.path.exists(DB_FILE):
        print(f'🗑️  Removing old database: {DB_FILE}')
        os.remove(DB_FILE)

    print(f'✨ Creating new database: {DB_FILE}')
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()

    # Create attractions table
    cursor.execute('''
        CREATE TABLE attractions (
            id INTEGER PRIMARY KEY,
            name_en TEXT NOT NULL,
            name_si TEXT,
            name_ta TEXT,
            category TEXT NOT NULL CHECK(category IN (
                'Ancient Sites',
                'Beaches',
                'Nature & Wildlife',
                'Hill Country',
                'Cities',
                'Religious Sites',
                'Food Experiences',
                'Culture & Museums',
                'Scenic Experiences'
            )),
            province TEXT NOT NULL CHECK(province IN (
                'Western',
                'Central',
                'Southern',
                'Northern',
                'Eastern',
                'North Western',
                'North Central',
                'Uva',
                'Sabaragamuwa'
            )),
            description_en TEXT NOT NULL,
            description_si TEXT,
            description_ta TEXT,
            latitude REAL NOT NULL CHECK(latitude >= -90 AND latitude <= 90),
            longitude REAL NOT NULL CHECK(longitude >= -180 AND longitude <= 180),
            entry_fee TEXT,
            opening_hours TEXT,
            best_time TEXT,
            duration TEXT,
            difficulty TEXT CHECK(difficulty IN ('Easy', 'Moderate', 'Challenging') OR difficulty IS NULL),
            tags TEXT,
            images TEXT NOT NULL,
            is_premium INTEGER DEFAULT 0 CHECK(is_premium IN (0, 1)),
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    # Create indexes
    print('📇 Creating indexes...')
    cursor.execute('CREATE INDEX idx_category ON attractions(category)')
    cursor.execute('CREATE INDEX idx_province ON attractions(province)')
    cursor.execute('CREATE INDEX idx_premium ON attractions(is_premium)')
    cursor.execute('CREATE INDEX idx_tags ON attractions(tags)')

    conn.commit()
    return conn


def load_attractions():
    """Load attractions from JSON file"""
    print(f'📖 Reading attractions from: {JSON_FILE}')

    if not os.path.exists(JSON_FILE):
        raise FileNotFoundError(f'JSON file not found: {JSON_FILE}')

    with open(JSON_FILE, 'r', encoding='utf-8') as f:
        attractions = json.load(f)

    print(f'✅ Loaded {len(attractions)} attractions')
    return attractions


def populate_attractions(conn, attractions):
    """Populate database with attractions"""
    cursor = conn.cursor()

    print(f'💾 Inserting {len(attractions)} attractions...')

    for attraction in attractions:
        cursor.execute('''
            INSERT INTO attractions (
                id, name_en, name_si, name_ta,
                category, province,
                description_en, description_si, description_ta,
                latitude, longitude,
                entry_fee, opening_hours, best_time, duration, difficulty,
                tags, images, is_premium
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            attraction.get('id'),
            attraction.get('name_en'),
            attraction.get('name_si'),
            attraction.get('name_ta'),
            attraction.get('category'),
            attraction.get('province'),
            attraction.get('description_en'),
            attraction.get('description_si'),
            attraction.get('description_ta'),
            attraction.get('latitude'),
            attraction.get('longitude'),
            attraction.get('entry_fee'),
            attraction.get('opening_hours'),
            attraction.get('best_time'),
            attraction.get('duration'),
            attraction.get('difficulty'),
            attraction.get('tags'),
            attraction.get('images'),
            attraction.get('is_premium', 0),
        ))

    conn.commit()
    print(f'✅ Successfully inserted {len(attractions)} attractions')


def print_statistics(conn):
    """Print database statistics"""
    cursor = conn.cursor()

    # Total count
    cursor.execute('SELECT COUNT(*) FROM attractions')
    total = cursor.fetchone()[0]

    # Free vs Premium
    cursor.execute('SELECT COUNT(*) FROM attractions WHERE is_premium = 0')
    free_count = cursor.fetchone()[0]

    cursor.execute('SELECT COUNT(*) FROM attractions WHERE is_premium = 1')
    premium_count = cursor.fetchone()[0]

    # By category
    cursor.execute('''
        SELECT category, COUNT(*) as count
        FROM attractions
        GROUP BY category
        ORDER BY count DESC
    ''')
    categories = cursor.fetchall()

    # By province
    cursor.execute('''
        SELECT province, COUNT(*) as count
        FROM attractions
        GROUP BY province
        ORDER BY count DESC
    ''')
    provinces = cursor.fetchall()

    # Print statistics
    print('\n' + '=' * 60)
    print('📊 DATABASE STATISTICS')
    print('=' * 60)
    print(f'\n✅ Total Attractions: {total}')
    print(f'   ├─ Free: {free_count}')
    print(f'   └─ Premium: {premium_count}')

    print(f'\n📂 By Category:')
    for category, count in categories:
        print(f'   ├─ {category}: {count}')

    print(f'\n🗺️  By Province:')
    for province, count in provinces:
        print(f'   ├─ {province}: {count}')

    # Database file size
    db_size = os.path.getsize(DB_FILE)
    print(f'\n💾 Database Size: {db_size / 1024:.2f} KB')

    print('\n' + '=' * 60)


def main():
    """Main execution"""
    print('\n🌴 Serendib Guide - Database Population Script')
    print('=' * 60)

    try:
        # Create database
        conn = create_database()

        # Load attractions from JSON
        attractions = load_attractions()

        # Populate database
        populate_attractions(conn, attractions)

        # Print statistics
        print_statistics(conn)

        # Close connection
        conn.close()

        print('\n✅ SUCCESS! Database created successfully')
        print(f'📁 Location: {DB_FILE}')
        print('\n📱 Next steps:')
        print('   1. Copy attractions.db to Flutter assets/database/')
        print('   2. Run: flutter run')
        print('   3. Your app will now have working attractions data!')

    except Exception as e:
        print(f'\n❌ ERROR: {e}')
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == '__main__':
    exit(main())
