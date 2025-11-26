# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Serendib Guide is an **offline-first Flutter travel app** for Sri Lanka featuring 300+ curated attractions. The app uses a freemium model (100 free attractions with ads, $14.99 premium unlock) and works 100% offline after installation.

**Key Differentiators:**
- Zero backend infrastructure (local SQLite only)
- Bundled read-only attractions database + runtime user data database
- Integration with 100% free APIs (no API keys required): Open-Meteo weather, OpenStreetMap/Overpass, LibreTranslate, Wikipedia, Nager.Date holidays
- Material Design 3 with custom brand colors (Deep Ocean Blue, Tropical Green, Sunset Orange)

## Development Commands

### Build & Run
```bash
# Install dependencies
flutter pub get

# Run in debug mode (default device)
flutter run

# Run on specific device
flutter run -d <device-id>

# Build APK for release
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle --release
```

### Code Quality
```bash
# Run linter (uses flutter_lints)
flutter analyze

# Format all Dart files
dart format lib/ test/

# Fix auto-fixable lint issues
dart fix --apply
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart

# Run tests in watch mode (requires external tool)
# Note: Standard Flutter doesn't have built-in watch mode
```

### Localization (when ready)
```bash
# Generate localization files from .arb files
flutter gen-l10n
```

### Device Management
```bash
# List connected devices
flutter devices

# Clear build cache if needed
flutter clean && flutter pub get
```

## Architecture

### Dual Database System

This app uses **two separate SQLite databases**:

1. **`attractions.db` (Read-Only, Bundled)**
   - Pre-populated with 300+ attractions
   - Copied from `assets/database/` on first launch
   - Opened in `readOnly: true` mode to prevent write attempts
   - Schema: attractions table with multilingual fields (name_en, name_si, name_ta, etc.)
   - Service: [DatabaseService](lib/services/database_service.dart)

2. **`user_data.db` (Read-Write, Runtime)**
   - Created at runtime in app documents directory
   - Stores user-specific data: favorites, trips, settings
   - Schema: favorites, trips, app_settings tables
   - Service: [UserDataService](lib/services/user_data_service.dart)

**Critical:** Never attempt to write to `attractions.db`. All user modifications go to `user_data.db`.

### State Management

Uses **Provider** pattern with `AppStateProvider` as the single source of truth for:
- Current locale (en/si/ta)
- Premium status
- Filters (category, province)
- Favorites cache (synced with user_data.db)
- Ad impression counter
- Dark mode preference
- Loading states

All services are provided via `Provider` at app root in [main.dart](lib/main.dart:30-49).

### Service Layer Architecture

Services are organized by responsibility:

**Core Services:**
- [DatabaseService](lib/services/database_service.dart) - Attractions CRUD (read-only)
- [UserDataService](lib/services/user_data_service.dart) - User data CRUD (favorites, trips, settings)
- [AdMobService](lib/services/admob_service.dart) - Banner/interstitial ads
- [PurchaseService](lib/services/purchase_service.dart) - In-app purchase flow

**Free API Integrations (No API keys required):**
- [WeatherService](lib/services/weather_service.dart) - Open-Meteo API
- [NearbyPlacesService](lib/services/nearby_places_service.dart) - OpenStreetMap Overpass API
- [CurrencyService](lib/services/currency_service.dart) - ExchangeRate-API
- [SunTimesService](lib/services/sun_times_service.dart) - Sunrise-Sunset API
- [TranslationService](lib/services/translation_service.dart) - LibreTranslate API
- [WikipediaService](lib/services/wikipedia_service.dart) - Wikipedia API
- [HolidayService](lib/services/holiday_service.dart) - Nager.Date API
- [AirQualityService](lib/services/air_quality_service.dart) - Open-Meteo Air Quality API
- [MoonPhaseService](lib/services/moon_phase_service.dart) - Astronomy API
- [CountryInfoService](lib/services/country_info_service.dart) - REST Countries API

**Gamification:**
- [AchievementService](lib/services/achievement_service.dart) - User achievements system
- [ItineraryGeneratorService](lib/services/itinerary_generator_service.dart) - AI-style trip suggestions

### Models

All data models are in [lib/models/](lib/models/):
- [Attraction](lib/models/attraction.dart) - Main attraction with multilingual support
- [Trip](lib/models/trip.dart) - User itinerary/trip
- [Category](lib/models/category.dart) - Enum: Temple, Beach, Wildlife, etc.
- [Province](lib/models/province.dart) - Enum: Western, Central, Southern, etc.
- [Difficulty](lib/models/difficulty.dart) - Enum: Easy, Moderate, Challenging

Free API response models: Weather, Place, Currency, Holiday, etc.

### Key Design Patterns

1. **Singleton Services**: DatabaseService, UserDataService use singleton pattern
2. **Factory Constructors**: Models use `.fromJson()` and `.fromOpenMeteo()` etc. for API parsing
3. **Null Safety**: Strict null safety throughout (SDK >=3.2.0)
4. **Immutable Models**: Models use final fields, copyWith for updates
5. **Async/Await**: All database and API calls are async
6. **Error Handling**: Services use try-catch with print statements for debugging

## Freemium Model Implementation

**Free Tier Limits** (defined in [constants.dart](lib/utils/constants.dart:68-74)):
- 100 attractions accessible
- 20 favorites limit
- 3 trips limit
- Banner ads on home screen
- Interstitial ads every 5 attraction views

**Premium Unlock ($14.99)**:
- Unlocks all 300+ attractions
- Removes all ads
- Unlimited favorites and trips
- Managed via `PurchaseService` and `AppStateProvider.isPremium`

**Ad Configuration**:
- Test ad unit IDs in [constants.dart](lib/utils/constants.dart:52-56)
- **MUST replace with production IDs before release**
- Ad impression tracking in `AppStateProvider`

## Brand Colors & Theme

Primary colors defined in [constants.dart](lib/utils/constants.dart:11-26):
- **Primary**: Deep Ocean Blue `#1565C0`
- **Secondary**: Tropical Green `#2E7D32`
- **Accent**: Sunset Orange `#F57C00`
- **Background**: Clean White `#FAFAFA`
- **Text**: Dark Grey `#212121`

Theme setup in [main.dart](lib/main.dart:96-186) with Material Design 3 support.

## Maps & Offline Functionality

Uses **flutter_map** with OpenStreetMap tiles:
- Offline tiles stored in `assets/map_tiles/{z}/{x}/{y}.png`
- Sri Lanka bounds: lat 5.9-9.9, lng 79.5-82.0
- Default center: 7.8731°N, 80.7718°E (center of Sri Lanka)
- Zoom levels 7-15

Nearby attractions calculated using **Haversine formula** in [helpers.dart](lib/utils/helpers.dart).

## Important Constants & Limits

See [lib/utils/constants.dart](lib/utils/constants.dart) for all values:
- Database names: `attractions.db`, `user_data.db`
- Map configuration: Sri Lanka bounds, zoom levels
- Search configuration: min length 2, debounce 300ms
- Nearby radius: 10km default
- Image quality: 85%, max width 1200px
- In-app purchase product ID: `premium_unlock`

## Localization

Three languages supported (code in [constants.dart](lib/utils/constants.dart)):
- English (`en`) - Primary
- Sinhala (`si`) - සිංහල
- Tamil (`ta`) - தமிழ்

ARB files location: `lib/l10n/` (to be implemented)
- `app_en.arb`
- `app_si.arb`
- `app_ta.arb`

After creating/updating ARB files, run `flutter gen-l10n` to generate localization code.

## Free API Integration Pattern

All API integrations follow this pattern:
1. No API keys required (zero cost)
2. HTTP client using `package:http`
3. 10-second timeout for requests
4. Proper error handling with try-catch
5. JSON parsing to strongly-typed models
6. Debug print statements for monitoring
7. Models have `fromJson()` or custom factory constructors

Example: [WeatherService](lib/services/weather_service.dart:8-86)

When adding new free APIs, follow the same pattern and add service to `lib/services/`.

## Android Configuration

**Package Name**: `com.serendibguide.srilanka`
**Min SDK**: 21 (Android 5.0)
**Target SDK**: 34 (Android 14)

Build configuration in `android/app/build.gradle`.

For release builds, configure signing:
1. Generate keystore: `keytool -genkey -v -keystore android/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias serendibguide`
2. Create `android/key.properties` (excluded from git)
3. Update `android/app/build.gradle` with signing config

## Git Commit Conventions

Use conventional commit prefixes:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `refactor:` - Code restructuring without behavior change
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples from recent commits:
- `feat: Add Phase 1 Free APIs - Weather, Currency & Sun Times`
- `feat: Add Nearby Places feature with 100% free OpenStreetMap API`
- `fix: Improve image loading with better placeholder handling`

## Code Style Conventions

Following Dart official style guide (enforced by `flutter_lints`):
- Use `const` constructors wherever possible
- Prefer `final` for immutable variables
- Null safety: use `!` sparingly, prefer `?.` and `??`
- Keep functions under 50 lines
- Meaningful variable names (no `x`, `y`, `temp`)
- Services use descriptive print statements with emojis (e.g., `🌤️  Fetching weather...`)

## Common Gotchas

1. **Database Mode**: Never write to `attractions.db` (read-only). Always write to `user_data.db`.
2. **API Keys**: All current APIs are free and require NO keys. Don't add paid API dependencies.
3. **AdMob IDs**: Current IDs are TEST IDs. Must replace before production release.
4. **Premium Status**: Check `AppStateProvider.isPremium` before showing premium content.
5. **Offline First**: All features must work without internet after initial install.
6. **Image Assets**: Attraction images must be local assets in `assets/images/attractions/`.
7. **Flutter Version**: Requires Flutter 3.16+ and Dart 3.2+ for null safety features.

## Testing Strategy

Test locations:
- Widget tests: `test/widget_test.dart`
- Unit tests for models and services (to be expanded)

Focus areas for testing:
- Database operations (read-only vs read-write)
- Free/Premium feature gating
- Favorites and trips CRUD
- Ad display logic
- API service error handling
- Haversine distance calculations

## Project Status

**Current Phase**: Active development with core features complete

**Completed**:
- ✅ Dual database architecture
- ✅ All data models
- ✅ Core services (database, user data, ads, purchases)
- ✅ State management with Provider
- ✅ Theme and localization setup
- ✅ Multiple free API integrations (weather, places, currency, translation, etc.)
- ✅ Offline maps configuration

**In Progress**:
- UI screens implementation (home, detail, map, etc.)
- Reusable widgets
- Localization ARB files
- Content curation (300+ attractions)

**To Do**:
- Complete UI implementation
- Photo collection (1200 images: 300 attractions × 4 photos)
- Offline map tiles preparation
- Professional translations (Sinhala, Tamil)
- Android signing and release configuration
- Play Store assets and launch

## Expected APK Size

Target: 100-120 MB (including offline maps and 1200 attraction images)

Optimize by:
- Image compression (quality: 85%, max width: 1200px)
- Map tile selection (zoom 7-15 only)
- Removing unused dependencies
- Using `--split-per-abi` for app bundles
