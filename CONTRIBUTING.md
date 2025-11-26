# Contributing to Serendib Guide

Thank you for your interest in contributing to Serendib Guide! This document provides guidelines and information for contributors.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Code Style Guidelines](#code-style-guidelines)
5. [Testing Requirements](#testing-requirements)
6. [Pull Request Process](#pull-request-process)
7. [Adding Attractions](#adding-attractions)
8. [Localization](#localization)

---

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a welcoming environment for all contributors
- Report unacceptable behavior to the project maintainers

---

## Getting Started

### Prerequisites

- Flutter SDK 3.16 or higher
- Dart SDK 3.2 or higher
- Android Studio or VS Code with Flutter extensions
- Git

### Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/SerendibGuide.git
cd SerendibGuide

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/SerendibGuide.git
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

---

## Development Workflow

### 1. Create a Feature Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Follow the code style guidelines below
- Write tests for new functionality
- Update documentation as needed
- Keep commits focused and atomic

### 3. Test Your Changes

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run static analysis
flutter analyze

# Format code
dart format lib/ test/
```

### 4. Commit Your Changes

```bash
git add .
git commit -m "feat: Add your feature description"
```

Use conventional commit prefixes:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Code style (formatting, missing semi-colons, etc.)
- `refactor:` - Code restructuring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## Code Style Guidelines

### Dart Style

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// Good
class AttractionCard extends StatelessWidget {
  const AttractionCard({
    super.key,
    required this.attraction,
    this.onTap,
  });

  final Attraction attraction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(attraction.nameEn),
        onTap: onTap,
      ),
    );
  }
}
```

### Key Principles

1. **Use `const` wherever possible**
   ```dart
   const SizedBox(height: 16)  // Good
   SizedBox(height: 16)         // Avoid
   ```

2. **Prefer final over var**
   ```dart
   final attraction = widget.attraction;  // Good
   var attraction = widget.attraction;    // Avoid
   ```

3. **Keep functions small** (< 50 lines)
   ```dart
   // Split large functions into smaller ones
   Widget _buildHeader() { ... }
   Widget _buildBody() { ... }
   Widget _buildFooter() { ... }
   ```

4. **Meaningful variable names**
   ```dart
   final attractionCount = attractions.length;  // Good
   final x = attractions.length;                // Bad
   ```

5. **Add documentation comments**
   ```dart
   /// Calculates the distance between two geographic points using the Haversine formula.
   ///
   /// Returns the distance in kilometers.
   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
     // Implementation
   }
   ```

---

## Testing Requirements

### Unit Tests

All new services and utilities must have unit tests:

```dart
// test/services/my_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:serendib_guide/services/my_service.dart';

void main() {
  group('MyService', () {
    late MyService service;

    setUp(() {
      service = MyService();
    });

    test('should do something', () {
      final result = service.doSomething();
      expect(result, equals(expectedValue));
    });
  });
}
```

### Widget Tests

New widgets should have widget tests:

```dart
// test/widgets/my_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serendib_guide/widgets/my_widget.dart';

void main() {
  testWidgets('MyWidget displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MyWidget(),
        ),
      ),
    );

    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

### Test Coverage Goals

- Services: 80%+ coverage
- Widgets: 70%+ coverage
- Models: 90%+ coverage (mostly serialization tests)

---

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] `flutter analyze` passes with no errors
- [ ] `dart format` applied
- [ ] No merge conflicts with main branch

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows project style
- [ ] Self-reviewed code
- [ ] Commented complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally
```

### Review Process

1. Automated checks must pass (tests, linting)
2. At least one maintainer approval required
3. Address all review comments
4. Squash commits if requested
5. Maintainer will merge when ready

---

## Adding Attractions

To add new attractions to the database:

### 1. Edit attractions.json

Add your attraction to `assets/data/attractions.json`:

```json
{
  "id": 999,
  "name_en": "Attraction Name",
  "name_si": "ආකර්ෂණීය ස්ථානය",
  "name_ta": "ஈர்ப்பு",
  "category": "Beaches",
  "province": "Southern",
  "description_en": "Detailed description...",
  "description_si": "සවිස්තරාත්මක විස්තරය...",
  "description_ta": "விரிவான விவரம்...",
  "latitude": 6.1234,
  "longitude": 80.5678,
  "entry_fee": "USD 10 or Free",
  "opening_hours": "9:00 AM - 5:00 PM",
  "best_time": "November to April",
  "duration": "2-3 hours",
  "difficulty": "Easy",
  "tags": "beach,swimming,family-friendly",
  "images": "attraction_1.jpg,attraction_2.jpg,attraction_3.jpg,attraction_4.jpg",
  "is_premium": 0
}
```

### 2. Add Images

Place 4 high-quality images in `assets/images/attractions/`:
- Format: JPG
- Size: Max 1200px width
- Quality: 85%
- Names: `attractionname_1.jpg` through `attractionname_4.jpg`

### 3. Populate Database

```bash
dart run scripts/populate_database.dart
```

### 4. Test

```bash
flutter run
# Verify attraction appears and displays correctly
```

---

## Localization

### Adding New Strings

1. Add to `lib/l10n/app_en.arb`:
   ```json
   "newString": "New String",
   "@newString": {
     "description": "Description of what this string is for"
   }
   ```

2. Add Sinhala translation to `lib/l10n/app_si.arb`:
   ```json
   "newString": "නව නූල"
   ```

3. Add Tamil translation to `lib/l10n/app_ta.arb`:
   ```json
   "newString": "புதிய சரம்"
   ```

4. Generate localization classes:
   ```bash
   flutter gen-l10n
   ```

5. Use in code:
   ```dart
   Text(AppLocalizations.of(context)!.newString)
   ```

---

## Questions?

- Check [CLAUDE.md](CLAUDE.md) for architecture guidance
- Review [docs/](docs/) for detailed documentation
- Create an issue for questions
- Join discussions on GitHub

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing to Serendib Guide! 🌴🇱🇰**
