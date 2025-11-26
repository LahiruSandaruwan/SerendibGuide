# Release Configuration Guide

Complete guide for configuring Serendib Guide for production release on Google Play Store.

## Table of Contents

1. [Android Signing Configuration](#android-signing-configuration)
2. [AdMob Production Setup](#admob-production-setup)
3. [In-App Purchase Setup](#in-app-purchase-setup)
4. [Build Configuration](#build-configuration)
5. [Pre-Release Checklist](#pre-release-checklist)

---

## 1. Android Signing Configuration

### Generate Release Keystore

```bash
# Navigate to android directory
cd android

# Generate keystore (valid for 10,000 days)
keytool -genkey -v \
  -keystore keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias serendibguide

# You'll be prompted for:
# - Keystore password (SAVE THIS SECURELY!)
# - Key password (SAVE THIS SECURELY!)
# - Your name/organization details
```

**⚠️ CRITICAL: Backup your keystore and passwords!**
- Store `keystore.jks` in a secure location (NOT in git)
- Save passwords in a password manager
- Losing your keystore means you can't update the app

### Create key.properties

Create `android/key.properties` (this file is git-ignored):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=serendibguide
storeFile=keystore.jks
```

### Update build.gradle

Edit `android/app/build.gradle`:

```gradle
// Add before 'android {' block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Verify Signing

```bash
# Build signed APK
flutter build apk --release

# Verify signature
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk

# Should show your certificate details
```

---

## 2. AdMob Production Setup

### Create AdMob Account

1. Go to [AdMob Console](https://apps.admob.com/)
2. Sign in with your Google account
3. Create a new app:
   - **App name**: Serendib Guide
   - **Platform**: Android
   - **Package name**: `com.serendibguide.srilanka`

### Create Ad Units

Create two ad units:

#### Banner Ad Unit
- **Format**: Banner
- **Name**: Home Screen Banner
- **Ad unit ID**: Copy this ID (e.g., `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`)

#### Interstitial Ad Unit
- **Format**: Interstitial
- **Name**: Attraction Detail Interstitial
- **Ad unit ID**: Copy this ID

### Update Constants

Edit `lib/utils/constants.dart`:

```dart
// Replace TEST IDs with your production IDs
static const String bannerAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String interstitialAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ';
```

### Update AndroidManifest.xml

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- Add your AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~AAAAAAAAAA"/>

        <!-- ... rest of manifest ... -->
    </application>
</manifest>
```

### Test Ads

Before releasing:
1. Build release APK with production IDs
2. Install on test device
3. Verify ads load correctly
4. Check ad impression tracking

---

## 3. In-App Purchase Setup

### Google Play Console Configuration

1. **Create App in Play Console**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create application
   - Package name: `com.serendibguide.srilanka`

2. **Setup Merchant Account**
   - Link a Google merchant account
   - Required for processing payments
   - Verify tax information

3. **Create In-App Product**
   - Navigate to: Monetization → Products → In-app products
   - Click "Create product"
   - **Product ID**: `premium_unlock` (must match constants.dart)
   - **Name**: Premium Unlock
   - **Description**: Unlock all 300+ attractions, remove ads, and get unlimited favorites and trips
   - **Price**: $14.99 USD (set prices for all countries)
   - **Status**: Active

### License Key (Optional)

For additional security, add license key to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.play.billingclient.version"
    android:value="5.0.0" />
```

### Test Purchases

1. Add test accounts in Play Console
2. Build and upload to internal testing track
3. Test purchase flow with test account
4. Verify premium unlock works correctly

---

## 4. Build Configuration

### App Version

Update `pubspec.yaml` before each release:

```yaml
version: 1.0.0+1  # Format: major.minor.patch+buildNumber
```

- First release: `1.0.0+1`
- Bug fix: `1.0.1+2`
- Minor update: `1.1.0+3`
- Major update: `2.0.0+4`

### Build Release APK

```bash
# Clean build
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (Recommended for Play Store)

```bash
# Build app bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

**App Bundle Benefits:**
- Smaller download size (Play Store generates optimized APKs)
- Automatic APK splitting by ABI
- Better user experience

### ProGuard Configuration

Create `android/app/proguard-rules.pro`:

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Sqflite
-keep class com.tekartik.sqflite.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }

# In-App Purchase
-keep class com.android.billingclient.** { *; }
```

---

## 5. Pre-Release Checklist

### Code Checklist

- [ ] All TODO comments resolved
- [ ] Test mode disabled (no debug prints in production)
- [ ] Production AdMob IDs configured
- [ ] Database contains 100+ free attractions, 200+ premium
- [ ] All images optimized and compressed
- [ ] Offline maps included (if using)
- [ ] Localization complete (English, Sinhala, Tamil)
- [ ] No hardcoded test data

### Testing Checklist

- [ ] All screens load without errors
- [ ] Database queries work correctly
- [ ] Ads display properly
- [ ] Premium purchase flow works
- [ ] Premium features unlock correctly
- [ ] Restore purchases works
- [ ] Offline functionality works
- [ ] Maps display correctly
- [ ] All three languages work
- [ ] Dark mode works
- [ ] Tested on multiple devices (low/mid/high-end)
- [ ] Tested on multiple Android versions (API 21-34)

### Build Checklist

- [ ] Signed with release keystore
- [ ] ProGuard enabled
- [ ] Version number incremented
- [ ] APK/AAB size acceptable (<120MB)
- [ ] No security warnings in Play Console
- [ ] Crash-free rate >99% in internal testing

### Play Store Checklist

- [ ] App screenshots (8+ screenshots)
- [ ] Feature graphic (1024x500)
- [ ] App icon (512x512)
- [ ] Short description (<80 chars)
- [ ] Full description (<4000 chars)
- [ ] Privacy policy URL live
- [ ] Terms of service URL live
- [ ] Content rating questionnaire completed
- [ ] Store listing reviewed
- [ ] Internal testing completed
- [ ] Closed testing completed (optional)

### Legal & Compliance

- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] Google Play Developer Program Policies compliant
- [ ] Content rating appropriate
- [ ] Copyright notices in place
- [ ] Third-party licenses acknowledged

---

## Quick Reference

### Common Commands

```bash
# Build release APK
flutter build apk --release

# Build app bundle
flutter build appbundle --release

# Install release build
flutter install --release

# Analyze code
flutter analyze

# Run tests
flutter test

# Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Verify signing
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

### Important Files

- `android/keystore.jks` - Release signing key (BACKUP!)
- `android/key.properties` - Keystore credentials (GIT-IGNORED)
- `android/app/build.gradle` - Build configuration
- `android/app/proguard-rules.pro` - Code obfuscation rules
- `lib/utils/constants.dart` - AdMob IDs and configuration

### Support Resources

- [Flutter Release Documentation](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [AdMob Help Center](https://support.google.com/admob)
- [In-App Purchase Documentation](https://developer.android.com/google/play/billing)

---

**Last Updated**: 2025-11-26
