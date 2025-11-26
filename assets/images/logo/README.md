# Logo Assets Directory

This directory should contain the following branding assets:

## Required Files

### App Icon
- **`icon.png`** - 512x512 PNG with transparency
  - Used for Play Store listing
  - Base for adaptive icon generation
  - Design: Simple, recognizable Sri Lankan symbol
  - Colors: Use brand colors (Deep Ocean Blue #1565C0, Tropical Green #2E7D32)

### Adaptive Icon
- **`icon_foreground.png`** - 512x512 PNG with transparency
  - Foreground layer for Android adaptive icon
  - Should be centered with safe zone consideration
  - Background color set in pubspec.yaml: #1565C0

### Splash Screens
- **`splash.png`** - 1080x1920 or similar (portrait)
  - Main splash screen image
  - Keep design simple and centered

- **`splash_android12.png`** - 1080x1920 (portrait)
  - Android 12+ splash screen variant
  - Material You compliance

## Design Guidelines

### Brand Identity
- **Primary Color**: Deep Ocean Blue (#1565C0)
- **Secondary Color**: Tropical Green (#2E7D32)
- **Accent Color**: Sunset Orange (#F57C00)

### Icon Design Tips
1. Keep it simple - must be recognizable at 48x48 pixels
2. Avoid text - use symbolic representation
3. Consider using:
   - Lotus flower (Sri Lankan national flower)
   - Dagoba/Stupa silhouette
   - Elephant outline
   - Island shape
   - Palm tree
4. Test on both light and dark backgrounds
5. Ensure it stands out among other app icons

### Splash Screen Tips
1. Center the logo with ample padding
2. Use brand colors for background
3. Keep design minimal - loads before app initializes
4. Consider adding tagline: "Discover the Island of Serendipity"

## Generation Commands

After adding the assets, run:

```bash
# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screens
flutter pub run flutter_native_splash:create
```

## Temporary Placeholder

For development purposes, you can use Flutter's default icon until final designs are ready.

## Design Tools

Free tools for creating app assets:
- **Figma** - https://figma.com (professional, free tier)
- **Canva** - https://canva.com (templates available)
- **GIMP** - https://gimp.org (free Photoshop alternative)
- **Inkscape** - https://inkscape.org (vector graphics)

Online icon generators:
- **App Icon Generator** - https://appicon.co
- **MakeAppIcon** - https://makeappicon.com
- **Icon Kitchen** - https://icon.kitchen

## Current Status

⚠️ **PLACEHOLDER ONLY** - Final branding assets needed before launch

---

Last Updated: 2025-11-26
