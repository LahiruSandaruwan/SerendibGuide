#!/usr/bin/env python3
"""
SerendibGuide Data Fetcher
Fetches tourism data for Sri Lanka from free APIs and creates SQLite database
"""

import requests
import sqlite3
import json
import time
from typing import List, Dict, Optional
from dataclasses import dataclass
import os

@dataclass
class Attraction:
    name_en: str
    name_si: str
    name_ta: str
    description_en: str
    description_si: str
    description_ta: str
    category: str
    province: str
    district: str
    latitude: float
    longitude: float
    images: str  # JSON array of image URLs
    duration: Optional[str]
    best_time: Optional[str]
    entrance_fee: Optional[str]
    is_premium: int

class SriLankaDataFetcher:
    def __init__(self):
        self.attractions = []
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'SerendibGuide/1.0 (Tourism App)'
        })

        # Sri Lanka bounding box
        self.bbox = {
            'south': 5.9,
            'west': 79.4,
            'north': 9.9,
            'east': 82.0
        }

        # Category mappings
        self.osm_to_category = {
            'archaeological_site': 'Ancient Sites',
            'ruins': 'Ancient Sites',
            'castle': 'Ancient Sites',
            'monument': 'Ancient Sites',
            'beach': 'Beaches',
            'national_park': 'Nature & Wildlife',
            'nature_reserve': 'Nature & Wildlife',
            'viewpoint': 'Scenic Experiences',
            'peak': 'Hill Country',
            'waterfall': 'Nature & Wildlife',
            'temple': 'Religious Sites',
            'place_of_worship': 'Religious Sites',
            'mosque': 'Religious Sites',
            'church': 'Religious Sites',
            'museum': 'Culture & Museums',
            'gallery': 'Culture & Museums',
            'attraction': 'Scenic Experiences',
            'zoo': 'Nature & Wildlife',
            'theme_park': 'Scenic Experiences',
            'restaurant': 'Food Experiences',
            'cafe': 'Food Experiences'
        }

        # Province boundaries (approximate)
        self.province_map = {
            'Western': {'lat_range': (6.7, 7.3), 'lon_range': (79.8, 80.3)},
            'Central': {'lat_range': (7.0, 7.5), 'lon_range': (80.3, 81.0)},
            'Southern': {'lat_range': (5.9, 6.5), 'lon_range': (80.0, 81.2)},
            'Northern': {'lat_range': (9.0, 9.9), 'lon_range': (79.8, 80.8)},
            'Eastern': {'lat_range': (7.4, 9.0), 'lon_range': (80.8, 82.0)},
            'North Western': {'lat_range': (7.3, 8.5), 'lon_range': (79.8, 80.5)},
            'North Central': {'lat_range': (7.8, 8.8), 'lon_range': (80.2, 81.2)},
            'Uva': {'lat_range': (6.5, 7.4), 'lon_range': (80.8, 81.8)},
            'Sabaragamuwa': {'lat_range': (6.5, 7.2), 'lon_range': (80.2, 80.8)}
        }

    def get_province(self, lat: float, lon: float) -> str:
        """Determine province based on coordinates"""
        for province, bounds in self.province_map.items():
            if (bounds['lat_range'][0] <= lat <= bounds['lat_range'][1] and
                bounds['lon_range'][0] <= lon <= bounds['lon_range'][1]):
                return province
        return 'Western'  # Default

    def fetch_from_overpass(self):
        """Fetch tourist attractions from OpenStreetMap via Overpass API"""
        print("Fetching data from OpenStreetMap (Overpass API)...")

        overpass_url = "http://overpass-api.de/api/interpreter"

        # Query for various tourist attractions in Sri Lanka
        query = f"""
        [out:json][timeout:120];
        (
          node["tourism"~"attraction|viewpoint|museum|gallery|theme_park|zoo"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          way["tourism"~"attraction|viewpoint|museum|gallery|theme_park|zoo"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          node["historic"~"archaeological_site|ruins|monument|castle"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          way["historic"~"archaeological_site|ruins|monument|castle"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          node["natural"~"beach|waterfall|peak"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          way["natural"~"beach|waterfall|peak"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          node["leisure"~"park|nature_reserve"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          way["leisure"~"park|nature_reserve"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          node["amenity"~"place_of_worship"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
          way["amenity"~"place_of_worship"]({self.bbox['south']},{self.bbox['west']},{self.bbox['north']},{self.bbox['east']});
        );
        out center;
        """

        try:
            response = self.session.post(overpass_url, data={'data': query}, timeout=180)
            response.raise_for_status()
            data = response.json()

            print(f"Found {len(data.get('elements', []))} attractions from OSM")

            for element in data.get('elements', []):
                self.process_osm_element(element)

            time.sleep(1)  # Be nice to the API

        except Exception as e:
            print(f"Error fetching from Overpass: {e}")

    def process_osm_element(self, element: Dict):
        """Process a single OSM element into an attraction"""
        tags = element.get('tags', {})

        # Get name
        name = (tags.get('name:en') or tags.get('name') or
                tags.get('alt_name') or 'Unknown')

        if not name or name == 'Unknown':
            return

        # Get coordinates
        if element.get('type') == 'node':
            lat = element.get('lat')
            lon = element.get('lon')
        elif 'center' in element:
            lat = element['center'].get('lat')
            lon = element['center'].get('lon')
        else:
            return

        if not lat or not lon:
            return

        # Determine category
        category = self.determine_category(tags)
        if not category:
            return

        # Get description
        description = (tags.get('description:en') or tags.get('description') or
                      tags.get('note') or f"A beautiful {category.lower()} in Sri Lanka")

        # Get images from Wikimedia if available
        images = []
        if 'wikimedia_commons' in tags or 'image' in tags:
            images.append(f"https://upload.wikimedia.org/wikipedia/commons/placeholder.jpg")

        # Create attraction
        attraction = Attraction(
            name_en=name,
            name_si=tags.get('name:si', name),
            name_ta=tags.get('name:ta', name),
            description_en=description[:500],  # Limit length
            description_si=description[:500],
            description_ta=description[:500],
            category=category,
            province=self.get_province(lat, lon),
            district=tags.get('addr:district', 'Unknown'),
            latitude=lat,
            longitude=lon,
            images=json.dumps(images if images else []),
            duration=self.estimate_duration(category),
            best_time=self.estimate_best_time(category),
            entrance_fee=tags.get('fee', 'Free'),
            is_premium=0
        )

        self.attractions.append(attraction)

    def determine_category(self, tags: Dict) -> Optional[str]:
        """Determine attraction category from OSM tags"""
        # Check tourism tag
        if 'tourism' in tags:
            tourism_type = tags['tourism']
            if tourism_type in self.osm_to_category:
                return self.osm_to_category[tourism_type]
            if tourism_type == 'attraction':
                return 'Scenic Experiences'

        # Check historic tag
        if 'historic' in tags:
            return 'Ancient Sites'

        # Check natural tag
        if 'natural' in tags:
            natural_type = tags['natural']
            if natural_type == 'beach':
                return 'Beaches'
            elif natural_type in ['waterfall', 'peak']:
                return 'Nature & Wildlife'

        # Check leisure tag
        if 'leisure' in tags:
            return 'Nature & Wildlife'

        # Check amenity tag
        if 'amenity' in tags and tags['amenity'] == 'place_of_worship':
            return 'Religious Sites'

        return None

    def estimate_duration(self, category: str) -> str:
        """Estimate visit duration based on category"""
        durations = {
            'Ancient Sites': '2-3 hours',
            'Beaches': '3-4 hours',
            'Nature & Wildlife': '4-6 hours',
            'Hill Country': '3-4 hours',
            'Cities': '4-6 hours',
            'Religious Sites': '1-2 hours',
            'Food Experiences': '1-2 hours',
            'Culture & Museums': '2-3 hours',
            'Scenic Experiences': '1-2 hours'
        }
        return durations.get(category, '2-3 hours')

    def estimate_best_time(self, category: str) -> str:
        """Estimate best time to visit based on category"""
        times = {
            'Ancient Sites': 'Early morning or late afternoon',
            'Beaches': 'Morning or evening',
            'Nature & Wildlife': 'Early morning',
            'Hill Country': 'Year-round, morning preferred',
            'Cities': 'Any time',
            'Religious Sites': 'Morning',
            'Food Experiences': 'Lunch or dinner',
            'Culture & Museums': 'Any time',
            'Scenic Experiences': 'Morning or evening'
        }
        return times.get(category, 'Any time')

    def add_curated_attractions(self):
        """Add well-known curated attractions"""
        print("Adding curated famous attractions...")

        curated = [
            {
                'name_en': 'Sigiriya Rock Fortress',
                'name_si': 'සීගිරිය',
                'name_ta': 'சிகிரியா',
                'description_en': 'Ancient rock fortress and palace ruins, one of Sri Lanka\'s eight UNESCO World Heritage Sites. Built by King Kashyapa in the 5th century AD.',
                'category': 'Ancient Sites',
                'province': 'Central',
                'district': 'Matale',
                'lat': 7.9570,
                'lon': 80.7597,
                'duration': '3-4 hours',
                'best_time': 'Early morning to avoid heat',
                'entrance_fee': 'USD 30',
                'is_premium': 0
            },
            {
                'name_en': 'Temple of the Tooth',
                'name_si': 'ශ්‍රී දළදා මාළිගාව',
                'name_ta': 'பல் மாடம்',
                'description_en': 'Sacred Buddhist temple in Kandy that houses the relic of the tooth of the Buddha. A UNESCO World Heritage Site.',
                'category': 'Religious Sites',
                'province': 'Central',
                'district': 'Kandy',
                'lat': 7.2936,
                'lon': 80.6414,
                'duration': '1-2 hours',
                'best_time': 'Morning puja ceremony',
                'entrance_fee': 'LKR 2000',
                'is_premium': 0
            },
            {
                'name_en': 'Unawatuna Beach',
                'name_si': 'ඌනවටුන වෙරළ',
                'name_ta': 'ஊனாவடுன கடற்கரை',
                'description_en': 'Beautiful crescent-shaped beach on the southern coast, perfect for swimming, snorkeling, and relaxation.',
                'category': 'Beaches',
                'province': 'Southern',
                'district': 'Galle',
                'lat': 6.0094,
                'lon': 80.2492,
                'duration': '3-4 hours',
                'best_time': 'Morning or evening',
                'entrance_fee': 'Free',
                'is_premium': 0
            },
            {
                'name_en': 'Yala National Park',
                'name_si': 'යාල ජාතික වනෝද්‍යානය',
                'name_ta': 'யாலா தேசிய பூங்கா',
                'description_en': 'Most visited and second largest national park in Sri Lanka, famous for its wildlife including leopards, elephants, and over 200 bird species.',
                'category': 'Nature & Wildlife',
                'province': 'Southern',
                'district': 'Hambantota',
                'lat': 6.3726,
                'lon': 81.5194,
                'duration': '4-6 hours',
                'best_time': 'Early morning safari',
                'entrance_fee': 'USD 15-25',
                'is_premium': 1
            },
            {
                'name_en': 'Mirissa Beach',
                'name_si': 'මිරිස්ස වෙරළ',
                'name_ta': 'மிரிசா கடற்கரை',
                'description_en': 'Stunning beach town famous for whale watching, surfing, and pristine golden sand beaches.',
                'category': 'Beaches',
                'province': 'Southern',
                'district': 'Matara',
                'lat': 5.9467,
                'lon': 80.4594,
                'duration': '3-4 hours',
                'best_time': 'Morning for whale watching',
                'entrance_fee': 'Free',
                'is_premium': 0
            },
            {
                'name_en': 'Galle Fort',
                'name_si': 'ගාල්ල කොටුව',
                'name_ta': 'காலி கோட்டை',
                'description_en': 'Historic fortified city built by Portuguese in 1588, then fortified by the Dutch. UNESCO World Heritage Site.',
                'category': 'Ancient Sites',
                'province': 'Southern',
                'district': 'Galle',
                'lat': 6.0268,
                'lon': 80.2170,
                'duration': '2-3 hours',
                'best_time': 'Evening walk on ramparts',
                'entrance_fee': 'Free',
                'is_premium': 0
            },
            {
                'name_en': 'Ella',
                'name_si': 'ඇල්ල',
                'name_ta': 'எல்லா',
                'description_en': 'Charming hill country town surrounded by tea plantations, offering stunning views, hiking trails, and cool climate.',
                'category': 'Hill Country',
                'province': 'Uva',
                'district': 'Badulla',
                'lat': 6.8667,
                'lon': 81.0469,
                'duration': 'Full day',
                'best_time': 'Year-round, morning preferred',
                'entrance_fee': 'Free',
                'is_premium': 0
            },
            {
                'name_en': 'Dambulla Cave Temple',
                'name_si': 'දඹුල්ල රජමහා විහාරය',
                'name_ta': 'தம்புள்ளை குகைக் கோயில்',
                'description_en': 'Largest and best-preserved cave temple complex in Sri Lanka, dating back to 1st century BCE. UNESCO World Heritage Site.',
                'category': 'Religious Sites',
                'province': 'Central',
                'district': 'Matale',
                'lat': 7.8567,
                'lon': 80.6489,
                'duration': '2-3 hours',
                'best_time': 'Morning',
                'entrance_fee': 'LKR 2000',
                'is_premium': 0
            },
            {
                'name_en': 'Nuwara Eliya',
                'name_si': 'නුවර එළිය',
                'name_ta': 'நுவரெலியா',
                'description_en': 'Hill station town known as "Little England" for its cool climate, tea plantations, colonial architecture, and beautiful gardens.',
                'category': 'Hill Country',
                'province': 'Central',
                'district': 'Nuwara Eliya',
                'lat': 6.9497,
                'lon': 80.7891,
                'duration': 'Full day',
                'best_time': 'April (flower season)',
                'entrance_fee': 'Free',
                'is_premium': 0
            },
            {
                'name_en': 'Anuradhapura',
                'name_si': 'අනුරාධපුරය',
                'name_ta': 'அனுராதபுரம்',
                'description_en': 'Ancient capital city and UNESCO World Heritage Site, featuring sacred Buddhist ruins including massive dagobas and the sacred Bo tree.',
                'category': 'Ancient Sites',
                'province': 'North Central',
                'district': 'Anuradhapura',
                'lat': 8.3114,
                'lon': 80.4037,
                'duration': 'Full day',
                'best_time': 'Early morning',
                'entrance_fee': 'USD 25',
                'is_premium': 1
            }
        ]

        for item in curated:
            attraction = Attraction(
                name_en=item['name_en'],
                name_si=item['name_si'],
                name_ta=item['name_ta'],
                description_en=item['description_en'],
                description_si=item['description_en'],  # Would need translation
                description_ta=item['description_en'],  # Would need translation
                category=item['category'],
                province=item['province'],
                district=item['district'],
                latitude=item['lat'],
                longitude=item['lon'],
                images=json.dumps([]),  # Would need actual image URLs
                duration=item['duration'],
                best_time=item['best_time'],
                entrance_fee=item['entrance_fee'],
                is_premium=item['is_premium']
            )
            self.attractions.append(attraction)

    def create_database(self, db_path: str):
        """Create SQLite database with attractions"""
        print(f"Creating database at {db_path}...")

        # Remove existing database
        if os.path.exists(db_path):
            os.remove(db_path)

        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # Create attractions table
        cursor.execute('''
            CREATE TABLE attractions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name_en TEXT NOT NULL,
                name_si TEXT NOT NULL,
                name_ta TEXT NOT NULL,
                description_en TEXT NOT NULL,
                description_si TEXT NOT NULL,
                description_ta TEXT NOT NULL,
                category TEXT NOT NULL,
                province TEXT NOT NULL,
                district TEXT NOT NULL,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                images TEXT NOT NULL,
                duration TEXT,
                best_time TEXT,
                entrance_fee TEXT,
                is_premium INTEGER DEFAULT 0
            )
        ''')

        # Insert attractions
        for attraction in self.attractions:
            cursor.execute('''
                INSERT INTO attractions (
                    name_en, name_si, name_ta, description_en, description_si, description_ta,
                    category, province, district, latitude, longitude, images,
                    duration, best_time, entrance_fee, is_premium
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                attraction.name_en, attraction.name_si, attraction.name_ta,
                attraction.description_en, attraction.description_si, attraction.description_ta,
                attraction.category, attraction.province, attraction.district,
                attraction.latitude, attraction.longitude, attraction.images,
                attraction.duration, attraction.best_time, attraction.entrance_fee,
                attraction.is_premium
            ))

        conn.commit()

        # Print statistics
        cursor.execute('SELECT category, COUNT(*) FROM attractions GROUP BY category')
        stats = cursor.fetchall()

        print("\nDatabase Statistics:")
        print(f"Total attractions: {len(self.attractions)}")
        print("\nBy category:")
        for category, count in stats:
            print(f"  {category}: {count}")

        conn.close()

def main():
    """Main execution function"""
    print("=" * 60)
    print("SerendibGuide Data Fetcher")
    print("=" * 60)

    fetcher = SriLankaDataFetcher()

    # Add curated famous attractions first
    fetcher.add_curated_attractions()

    # Fetch from APIs
    fetcher.fetch_from_overpass()

    # Remove duplicates based on name and location
    seen = set()
    unique_attractions = []
    for attraction in fetcher.attractions:
        key = (attraction.name_en, round(attraction.latitude, 3), round(attraction.longitude, 3))
        if key not in seen:
            seen.add(key)
            unique_attractions.append(attraction)

    fetcher.attractions = unique_attractions

    print(f"\nFound {len(fetcher.attractions)} unique attractions")

    # Create database
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    assets_dir = os.path.join(project_root, 'assets', 'database')
    os.makedirs(assets_dir, exist_ok=True)

    db_path = os.path.join(assets_dir, 'attractions.db')
    fetcher.create_database(db_path)

    print(f"\n✓ Database created successfully at: {db_path}")
    print("\nNext steps:")
    print("1. Update pubspec.yaml to include the database in assets")
    print("2. Run the Flutter app to see the data")

if __name__ == '__main__':
    main()
