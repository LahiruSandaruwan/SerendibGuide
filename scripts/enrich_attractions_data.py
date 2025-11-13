#!/usr/bin/env python3
"""
SerendibGuide Data Enricher
Enriches existing attractions database with:
- City/district names via reverse geocoding
- Images from Wikimedia Commons and Unsplash
"""

import requests
import sqlite3
import json
import time
from typing import List, Dict, Optional
import os

class AttractionEnricher:
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'SerendibGuide/1.0 (Tourism App; contact@serendibguide.com)'
        })

        # Rate limiting
        self.geocode_delay = 1.0  # Nominatim requires 1 second between requests
        self.image_delay = 0.5

    def get_city_from_coordinates(self, lat: float, lon: float) -> Optional[str]:
        """
        Get city/town name from coordinates using Nominatim reverse geocoding
        """
        try:
            url = f"https://nominatim.openstreetmap.org/reverse"
            params = {
                'lat': lat,
                'lon': lon,
                'format': 'json',
                'zoom': 10,  # City level
                'addressdetails': 1
            }

            time.sleep(self.geocode_delay)  # Respect rate limit
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()

            data = response.json()
            address = data.get('address', {})

            # Try to get city, town, or village in order of preference
            city = (address.get('city') or
                   address.get('town') or
                   address.get('village') or
                   address.get('municipality') or
                   address.get('county'))

            return city

        except Exception as e:
            print(f"  Error geocoding ({lat}, {lon}): {e}")
            return None

    def search_wikimedia_images(self, query: str, limit: int = 4) -> List[str]:
        """
        Search for images on Wikimedia Commons
        """
        try:
            url = "https://commons.wikimedia.org/w/api.php"
            params = {
                'action': 'query',
                'format': 'json',
                'generator': 'search',
                'gsrnamespace': 6,  # File namespace
                'gsrsearch': f'{query} Sri Lanka',
                'gsrlimit': limit * 2,  # Get more to filter
                'prop': 'imageinfo',
                'iiprop': 'url',
                'iiurlwidth': 800
            }

            time.sleep(self.image_delay)
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()

            data = response.json()
            images = []

            if 'query' in data and 'pages' in data['query']:
                for page in data['query']['pages'].values():
                    if 'imageinfo' in page and len(page['imageinfo']) > 0:
                        thumb_url = page['imageinfo'][0].get('thumburl')
                        if thumb_url:
                            images.append(thumb_url)
                            if len(images) >= limit:
                                break

            return images

        except Exception as e:
            print(f"  Error fetching Wikimedia images for '{query}': {e}")
            return []

    def get_placeholder_images(self, category: str) -> List[str]:
        """
        Get placeholder images based on category
        """
        placeholders = {
            'Ancient Sites': ['https://picsum.photos/800/600?random=1'],
            'Beaches': ['https://picsum.photos/800/600?random=2'],
            'Nature & Wildlife': ['https://picsum.photos/800/600?random=3'],
            'Hill Country': ['https://picsum.photos/800/600?random=4'],
            'Religious Sites': ['https://picsum.photos/800/600?random=5'],
            'Food Experiences': ['https://picsum.photos/800/600?random=6'],
            'Culture & Museums': ['https://picsum.photos/800/600?random=7'],
            'Scenic Experiences': ['https://picsum.photos/800/600?random=8'],
        }
        return placeholders.get(category, ['https://picsum.photos/800/600?random=9'])

    def enrich_database(self, limit: Optional[int] = None, skip_images: bool = False):
        """
        Enrich the database with city names and images
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        # Get attractions that need enrichment
        query = """
            SELECT id, name_en, category, latitude, longitude, district, images
            FROM attractions
            WHERE district IS NULL OR district = '' OR images = '[]'
        """
        if limit:
            query += f" LIMIT {limit}"

        cursor.execute(query)
        attractions = cursor.fetchall()

        total = len(attractions)
        print(f"\nEnriching {total} attractions...")

        for idx, (id, name, category, lat, lon, district, images) in enumerate(attractions, 1):
            print(f"\n[{idx}/{total}] Processing: {name}")

            # Get city/district if missing
            if not district:
                print(f"  Fetching city for coordinates ({lat}, {lon})...")
                city = self.get_city_from_coordinates(lat, lon)
                if city:
                    print(f"  ✓ Found city: {city}")
                    cursor.execute(
                        "UPDATE attractions SET district = ? WHERE id = ?",
                        (city, id)
                    )
                else:
                    print(f"  ✗ Could not find city")

            # Get images if missing and not skipped
            if not skip_images and (not images or images == '[]'):
                print(f"  Fetching images for '{name}'...")
                image_urls = self.search_wikimedia_images(name, limit=4)

                # If no images found, use placeholder
                if not image_urls:
                    print(f"  No Wikimedia images found, using placeholders")
                    image_urls = self.get_placeholder_images(category)
                else:
                    print(f"  ✓ Found {len(image_urls)} images")

                # Store as JSON array
                images_json = json.dumps(image_urls)
                cursor.execute(
                    "UPDATE attractions SET images = ? WHERE id = ?",
                    (images_json, id)
                )

            # Commit every 10 items
            if idx % 10 == 0:
                conn.commit()
                print(f"\n  Progress: {idx}/{total} attractions processed")

        conn.commit()
        conn.close()

        print(f"\n✓ Enrichment complete! Updated {total} attractions")

    def show_statistics(self):
        """
        Show database statistics
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        print("\n=== Database Statistics ===")

        # Total attractions
        cursor.execute("SELECT COUNT(*) FROM attractions")
        total = cursor.fetchone()[0]
        print(f"Total attractions: {total}")

        # Attractions with districts
        cursor.execute("SELECT COUNT(*) FROM attractions WHERE district IS NOT NULL AND district != ''")
        with_district = cursor.fetchone()[0]
        print(f"With district/city: {with_district} ({with_district*100/total:.1f}%)")

        # Attractions with images
        cursor.execute("SELECT COUNT(*) FROM attractions WHERE images != '[]'")
        with_images = cursor.fetchone()[0]
        print(f"With images: {with_images} ({with_images*100/total:.1f}%)")

        # By category
        print("\nBy category:")
        cursor.execute("""
            SELECT category, COUNT(*) as count
            FROM attractions
            GROUP BY category
            ORDER BY count DESC
        """)
        for category, count in cursor.fetchall():
            cursor.execute(
                "SELECT COUNT(*) FROM attractions WHERE category = ? AND images != '[]'",
                (category,)
            )
            with_img = cursor.fetchone()[0]
            print(f"  {category}: {count} attractions ({with_img} with images)")

        conn.close()

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Enrich SerendibGuide attractions database')
    parser.add_argument('--db', default='../assets/database/attractions.db',
                       help='Path to database file')
    parser.add_argument('--limit', type=int, help='Limit number of attractions to process')
    parser.add_argument('--skip-images', action='store_true',
                       help='Skip fetching images (only update cities)')
    parser.add_argument('--stats-only', action='store_true',
                       help='Only show statistics, don\'t enrich')

    args = parser.parse_args()

    # Get absolute path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    db_path = os.path.join(script_dir, args.db)

    if not os.path.exists(db_path):
        print(f"Error: Database not found at {db_path}")
        return

    enricher = AttractionEnricher(db_path)

    if args.stats_only:
        enricher.show_statistics()
    else:
        enricher.enrich_database(limit=args.limit, skip_images=args.skip_images)
        enricher.show_statistics()

if __name__ == '__main__':
    main()
