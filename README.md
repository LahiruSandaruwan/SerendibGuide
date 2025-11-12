# Serendib Guide - Sri Lanka Travel App

**Complete offline travel guide for Sri Lanka** featuring 300+ curated attractions, offline maps, trip planning, and essential travel information.

![App Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue)
![Platform](https://img.shields.io/badge/Platform-Android-green)

## 🌴 About

Serendib Guide is a comprehensive offline-first travel app for Sri Lanka, designed for international tourists, Sri Lankan diaspora, and local travelers. The app works 100% offline after initial download, featuring locally-curated authentic content that differentiates it from generic apps.

**"Serendib"** is the ancient Arabic name for Sri Lanka, meaning "Island of Serendipity."

### Key Features

- ✅ **300+ Curated Attractions** across 9 provinces and 9 categories
- ✅ **100% Offline Functionality** - No internet required after installation
- ✅ **Multi-Language Support** - English, Sinhala (සිංහල), Tamil (தமிழ்)
- ✅ **Offline Maps** - OpenStreetMap integration
- ✅ **Trip Planning** - Create and manage custom itineraries
- ✅ **Favorites System** - Save attractions for quick access
- ✅ **Train & Bus Routes** - Complete public transport information
- ✅ **Emergency Contacts** - Tourist police, ambulance, hospitals, embassies
- ✅ **Travel Tips** - Cultural etiquette, currency, visa info
- ✅ **Freemium Model** - Free with ads, Premium unlock ($14.99)

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── attraction.dart       # Attraction model with locale support
│   ├── trip.dart            # Trip/itinerary model
│   ├── category.dart        # Category enum
│   ├── province.dart        # Province enum
│   └── difficulty.dart      # Difficulty enum
├── screens/                 # UI screens (to be implemented)
│   ├── home_screen.dart
│   ├── attraction_detail_screen.dart
│   ├── map_screen.dart
│   ├── trip_planner_screen.dart
│   ├── favorites_screen.dart
│   ├── search_screen.dart
│   ├── info_screen.dart
│   ├── settings_screen.dart
│   └── premium_screen.dart
├── widgets/                 # Reusable widgets (to be implemented)
│   ├── attraction_card.dart
│   ├── category_chip.dart
│   ├── image_gallery_widget.dart
│   ├── ad_banner_widget.dart
│   └── empty_state_widget.dart
├── services/               # Business logic & data access
│   ├── database_service.dart      # Read attractions DB
│   ├── user_data_service.dart     # Read/write user data
│   ├── admob_service.dart         # Ad management
│   └── purchase_service.dart      # In-app purchases
├── providers/              # State management
│   └── app_state_provider.dart    # Global app state
├── utils/                  # Utilities & constants
│   ├── constants.dart             # App-wide constants
│   └── helpers.dart               # Utility functions
└── l10n/                   # Localization (to be implemented)
    ├── app_en.arb
    ├── app_si.arb
    └── app_ta.arb

assets/
├── images/
│   ├── logo/               # App icon & branding
│   ├── attractions/        # 1200 attraction photos (300 × 4)
│   └── illustrations/      # Empty states, onboarding
├── data/
│   ├── attractions.json    # Source data for database
│   ├── routes.json         # Train/bus schedules
│   └── travel_info.json    # Emergency contacts, tips
├── database/
│   └── attractions.db      # Pre-populated SQLite database
└── map_tiles/              # Offline OpenStreetMap tiles
    └── {z}/{x}/{y}.png
```

### Database Architecture

#### attractions.db (Read-Only, Bundled)
Pre-populated database bundled with the APK containing all attraction data.

**Schema:**
```sql
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
  tags TEXT,                -- Comma-separated
  images TEXT NOT NULL,     -- Comma-separated (4 filenames)
  is_premium INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_category ON attractions(category);
CREATE INDEX idx_province ON attractions(province);
CREATE INDEX idx_premium ON attractions(is_premium);
CREATE INDEX idx_tags ON attractions(tags);
```

#### user_data.db (Read-Write, Runtime)
Created at runtime to store user preferences and data.

**Schema:**
```sql
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  attraction_id INTEGER NOT NULL UNIQUE,
  added_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE trips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  attraction_ids TEXT NOT NULL,  -- JSON array of IDs
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

### State Management

Uses **Provider** pattern with `AppStateProvider` managing:
- Locale/language selection
- Premium status
- Category/province filters
- Favorites cache
- Ad impression tracking
- Dark mode preference

### Key Design Decisions

1. **Local SQLite Only** - Zero backend infrastructure, zero monthly costs
2. **Offline-First** - All features work without internet
3. **Freemium Model** - Free tier (100 attractions) with AdMob, Premium unlock removes ads and unlocks all 300+ attractions
4. **Multi-Language** - English as base, Sinhala and Tamil translations
5. **Material Design 3** - Modern, consistent UI following Flutter best practices

## 🎨 Brand Identity

- **Primary Color**: Deep Ocean Blue `#1565C0`
- **Secondary Color**: Tropical Green `#2E7D32`
- **Accent Color**: Sunset Orange `#F57C00`
- **Background**: Clean White `#FAFAFA`
- **Text**: Dark Grey `#212121`
- **Typography**: Roboto (300/400/500/700)

## 📦 Dependencies

Core dependencies (defined in `pubspec.yaml`):

```yaml
dependencies:
  # Database
  sqflite: ^2.3.0
  path_provider: ^2.1.1

  # Maps
  flutter_map: ^6.0.0
  latlong2: ^0.9.0

  # State Management
  provider: ^6.1.1

  # Monetization
  google_mobile_ads: ^4.0.0
  in_app_purchase: ^3.1.11

  # UI & Utils
  cached_network_image: ^3.3.0
  photo_view: ^0.14.0
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.1
  share_plus: ^7.2.1
  package_info_plus: ^5.0.1
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.16 or higher
- Dart SDK 3.2 or higher
- Android Studio or VS Code with Flutter extensions
- Android SDK (API 21-34)

### Setup Instructions

1. **Clone the repository**
```bash
git clone <repository-url>
cd SerendibGuide
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate localization files** (when l10n files are ready)
```bash
flutter gen-l10n
```

4. **Create the attractions database**
   - Prepare `attractions.json` with 300+ attractions
   - Run database population script (to be created)
   - Copy `attractions.db` to `assets/database/`

5. **Download offline map tiles** (optional for testing)
   - Use MOBAC (Mobile Atlas Creator) or Python script
   - Zoom levels 7-15 for Sri Lanka bounds
   - Organize as `assets/map_tiles/{z}/{x}/{y}.png`

6. **Run the app**
```bash
flutter run
```

### Configuration

**AdMob Setup:**
- Replace test ad unit IDs in `lib/utils/constants.dart`
- Update with production IDs before release

**In-App Purchase Setup:**
- Create product in Google Play Console: `premium_unlock` at $14.99
- Configure merchant account

**Android Configuration:**
- Update `android/app/build.gradle` with signing configuration
- Generate keystore: `keytool -genkey -v -keystore android/keystore.jks ...`
- Create `android/key.properties` (do not commit!)

## 📝 Development Status

### ✅ Completed (Foundation)

- [x] Project structure and folder organization
- [x] Database architecture design
- [x] Data models (Attraction, Trip, Category, Province, Difficulty)
- [x] DatabaseService (attractions CRUD operations)
- [x] UserDataService (favorites, trips, settings)
- [x] AdMobService (banner & interstitial ads)
- [x] PurchaseService (in-app purchase flow)
- [x] AppStateProvider (global state management)
- [x] Main app setup with theming and providers
- [x] Constants and helper utilities
- [x] Haversine distance calculation for nearby attractions

### 🚧 In Progress

- [ ] Localization files (app_en.arb, app_si.arb, app_ta.arb)
- [ ] UI screens implementation
- [ ] Reusable widgets
- [ ] Sample attractions data

### 📋 To Do

- [ ] HomeScreen with category filters
- [ ] AttractionDetailScreen with image gallery
- [ ] MapScreen with offline tiles and markers
- [ ] TripPlannerScreen with drag-to-reorder
- [ ] FavoritesScreen with grid layout
- [ ] SearchDelegate with filters
- [ ] InfoScreen with 5 tabs
- [ ] SettingsScreen
- [ ] PremiumScreen with purchase flow
- [ ] Attraction content curation (300+ attractions)
- [ ] Photo collection and compression (1200 images)
- [ ] Offline map tile preparation
- [ ] Professional Sinhala and Tamil translations
- [ ] Android build configuration
- [ ] App icon and splash screen
- [ ] Comprehensive testing
- [ ] Play Store assets (screenshots, descriptions)
- [ ] Launch and marketing

## 🎯 Freemium Model

### Free Tier
- 100 attractions accessible
- AdMob banner ads on home screen
- Interstitial ads every 5 attraction views
- Up to 20 favorites
- Up to 3 trips
- English only

### Premium ($14.99 one-time)
- All 300+ attractions unlocked
- Zero advertisements
- All 3 languages (English, සිංහල, தமிழ්)
- Unlimited favorites and trips
- Priority support

## 📱 Target Specifications

- **Package Name**: `com.serendibguide.srilanka`
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Expected APK Size**: 100-120 MB
- **Languages**: English, Sinhala, Tamil
- **Orientation**: Portrait (primary)

## 🔐 Privacy & Security

- **No user accounts required** - Fully anonymous usage
- **No personal data collection** - Only anonymous analytics
- **No backend servers** - All data stored locally
- **AdMob and IAP** - Use Google Play Services (privacy policy required)
- **Open source** - Transparent codebase

## 🛠️ Development Guidelines

### Code Style
- Follow Dart official style guide
- Use meaningful variable names
- Keep functions under 50 lines
- Use `const` constructors wherever possible
- Implement proper null safety

### Git Workflow
- Feature branches: `feature/feature-name`
- Commit messages: `feat:`, `fix:`, `docs:`, `refactor:`
- Regular commits with clear descriptions

### Testing Strategy
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- Manual testing on multiple devices (low/mid/high-end)

## 📊 Success Metrics

### Launch Targets (Month 1)
- 1,000+ downloads
- 4.2+ star rating
- <1% crash rate
- First premium purchases

### 6-Month Goals
- 15,000+ downloads
- 2,000+ DAU
- $2,500+ monthly revenue
- 4.3+ star rating
- Featured in "Travel & Local" category

## 📞 Support & Contact

- **Email**: support@serendibguide.com
- **Website**: https://serendibguide.com (to be created)
- **Privacy Policy**: https://serendibguide.com/privacy
- **Terms of Service**: https://serendibguide.com/terms

## 📄 License

[To be determined - Recommend open source license like MIT or Apache 2.0]

## 🙏 Acknowledgments

- OpenStreetMap contributors for map data
- Sri Lanka Tourism Development Authority for content
- Flutter and Dart communities
- All beta testers and early users

---

**Built with ❤️ for travelers exploring the beautiful island of Sri Lanka 🇱🇰**

*Last Updated: 2025-11-12*
