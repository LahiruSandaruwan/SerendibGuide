#!/usr/bin/env python3
"""
Serendib Guide - Offline Map Tile Downloader

Downloads OpenStreetMap tiles for Sri Lanka region (zoom levels 7-15)
to enable offline map functionality in the Flutter app.

Requirements:
    pip install requests pillow

Usage:
    python3 scripts/download_map_tiles.py

Configuration:
    - Tile server: OpenStreetMap (https://tile.openstreetmap.org)
    - Region: Sri Lanka (lat 5.9-9.9, lng 79.5-82.0)
    - Zoom levels: 7-15 (7=country view, 15=street level)
    - Output: assets/map_tiles/{z}/{x}/{y}.png

Note: Please respect OpenStreetMap's tile usage policy:
    - Maximum 2 download threads
    - 1 second delay between requests
    - Include User-Agent header
    - Consider using a tile cache service for production
"""

import os
import time
import math
import requests
from pathlib import Path
from typing import Tuple

# Configuration
TILE_SERVER = "https://tile.openstreetmap.org"
OUTPUT_DIR = "assets/map_tiles"
USER_AGENT = "SerendibGuide/1.0.0 (Educational Travel App)"

# Sri Lanka bounds
LAT_MIN, LAT_MAX = 5.9, 9.9
LNG_MIN, LNG_MAX = 79.5, 82.0

# Zoom levels (7=country view, 15=street level)
ZOOM_MIN, ZOOM_MAX = 7, 15

# Rate limiting (be respectful to OSM servers)
DELAY_BETWEEN_REQUESTS = 1.0  # seconds


def lat_lng_to_tile(lat: float, lng: float, zoom: int) -> Tuple[int, int]:
    """Convert latitude/longitude to tile coordinates."""
    lat_rad = math.radians(lat)
    n = 2.0 ** zoom
    x_tile = int((lng + 180.0) / 360.0 * n)
    y_tile = int((1.0 - math.asinh(math.tan(lat_rad)) / math.pi) / 2.0 * n)
    return x_tile, y_tile


def download_tile(zoom: int, x: int, y: int) -> bool:
    """Download a single tile from OpenStreetMap."""
    url = f"{TILE_SERVER}/{zoom}/{x}/{y}.png"
    output_path = Path(OUTPUT_DIR) / str(zoom) / str(x)
    output_file = output_path / f"{y}.png"

    # Skip if already exists
    if output_file.exists():
        return True

    # Create directory if needed
    output_path.mkdir(parents=True, exist_ok=True)

    try:
        headers = {
            "User-Agent": USER_AGENT,
        }
        response = requests.get(url, headers=headers, timeout=30)

        if response.status_code == 200:
            with open(output_file, "wb") as f:
                f.write(response.content)
            return True
        elif response.status_code == 404:
            # Tile doesn't exist (ocean, etc.) - this is normal
            return True
        else:
            print(f"   ❌ Failed to download {url}: HTTP {response.status_code}")
            return False

    except Exception as e:
        print(f"   ❌ Error downloading {url}: {e}")
        return False


def calculate_tiles_needed() -> int:
    """Calculate total number of tiles to download."""
    total = 0
    for zoom in range(ZOOM_MIN, ZOOM_MAX + 1):
        x_min, y_min = lat_lng_to_tile(LAT_MAX, LNG_MIN, zoom)
        x_max, y_max = lat_lng_to_tile(LAT_MIN, LNG_MAX, zoom)

        tiles_in_zoom = (x_max - x_min + 1) * (y_max - y_min + 1)
        total += tiles_in_zoom

    return total


def main():
    print("🗺️  Serendib Guide - Offline Map Tile Downloader")
    print("=" * 60)
    print(f"\n📍 Region: Sri Lanka")
    print(f"   Latitude:  {LAT_MIN}° to {LAT_MAX}°")
    print(f"   Longitude: {LNG_MIN}° to {LNG_MAX}°")
    print(f"\n🔍 Zoom levels: {ZOOM_MIN} to {ZOOM_MAX}")
    print(f"   Level 7:  Country overview")
    print(f"   Level 10: City/province level")
    print(f"   Level 15: Street level detail")

    # Calculate total tiles
    total_tiles = calculate_tiles_needed()
    print(f"\n📦 Estimated tiles to download: ~{total_tiles:,}")
    print(f"   Estimated size: ~{(total_tiles * 15 / 1024):.1f} MB")
    print(f"   Estimated time: ~{(total_tiles * DELAY_BETWEEN_REQUESTS / 3600):.1f} hours")

    print("\n⚠️  IMPORTANT: OpenStreetMap Tile Usage Policy")
    print("   - This script is rate-limited to respect OSM servers")
    print("   - For production, consider using a tile cache service")
    print("   - See: https://operations.osmfoundation.org/policies/tiles/")

    # Ask for confirmation
    print("\n" + "=" * 60)
    response = input("Proceed with download? (yes/no): ").strip().lower()
    if response not in ["yes", "y"]:
        print("❌ Download cancelled.")
        return

    # Create output directory
    Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

    # Download tiles
    print("\n🚀 Starting download...")
    start_time = time.time()
    downloaded = 0
    skipped = 0
    failed = 0

    for zoom in range(ZOOM_MIN, ZOOM_MAX + 1):
        print(f"\n📂 Zoom level {zoom}:")

        x_min, y_min = lat_lng_to_tile(LAT_MAX, LNG_MIN, zoom)
        x_max, y_max = lat_lng_to_tile(LAT_MIN, LNG_MAX, zoom)

        tiles_in_zoom = (x_max - x_min + 1) * (y_max - y_min + 1)
        print(f"   Tiles in this level: {tiles_in_zoom}")

        zoom_start = time.time()

        for x in range(x_min, x_max + 1):
            for y in range(y_min, y_max + 1):
                output_file = Path(OUTPUT_DIR) / str(zoom) / str(x) / f"{y}.png"

                if output_file.exists():
                    skipped += 1
                else:
                    if download_tile(zoom, x, y):
                        downloaded += 1
                    else:
                        failed += 1

                    # Rate limiting
                    time.sleep(DELAY_BETWEEN_REQUESTS)

                # Progress indicator
                total_processed = downloaded + skipped + failed
                if total_processed % 50 == 0:
                    elapsed = time.time() - start_time
                    rate = total_processed / elapsed if elapsed > 0 else 0
                    print(f"   Progress: {total_processed:,}/{total_tiles:,} "
                          f"({rate:.1f} tiles/sec)")

        zoom_time = time.time() - zoom_start
        print(f"   ✅ Completed zoom {zoom} in {zoom_time:.1f} seconds")

    # Summary
    elapsed_time = time.time() - start_time
    print("\n" + "=" * 60)
    print("✅ DOWNLOAD COMPLETE!")
    print("=" * 60)
    print(f"\n📊 Summary:")
    print(f"   Downloaded: {downloaded:,} tiles")
    print(f"   Skipped (already existed): {skipped:,} tiles")
    print(f"   Failed: {failed:,} tiles")
    print(f"   Total time: {elapsed_time / 60:.1f} minutes")

    # Calculate total size
    total_size = 0
    for root, dirs, files in os.walk(OUTPUT_DIR):
        for file in files:
            file_path = os.path.join(root, file)
            total_size += os.path.getsize(file_path)

    print(f"   Total size: {total_size / (1024 * 1024):.1f} MB")

    print("\n📝 Next steps:")
    print("   1. Verify tiles are in assets/map_tiles/{z}/{x}/{y}.png")
    print("   2. Test offline maps in the app")
    print("   3. Consider compressing tiles to reduce APK size")
    print("")


if __name__ == "__main__":
    main()
