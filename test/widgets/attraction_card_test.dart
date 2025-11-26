import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serendib_guide/widgets/attraction_card.dart';
import 'package:serendib_guide/models/attraction.dart';
import 'package:serendib_guide/models/category.dart';
import 'package:serendib_guide/models/province.dart';
import 'package:serendib_guide/models/difficulty.dart';

void main() {
  group('AttractionCard Widget Tests', () {
    late Attraction testAttraction;

    setUp(() {
      testAttraction = Attraction(
        id: 1,
        nameEn: 'Sigiriya Rock Fortress',
        nameSi: 'සීගිරිය',
        nameTa: 'சிகிரியா',
        category: Category.ancientSites,
        province: Province.central,
        descriptionEn: 'Ancient rock fortress and palace ruin',
        descriptionSi: null,
        descriptionTa: null,
        latitude: 7.9571,
        longitude: 80.7603,
        entryFee: 'USD 30',
        openingHours: '7:00 AM - 5:30 PM',
        bestTime: 'Early morning',
        duration: '3-4 hours',
        difficulty: Difficulty.moderate,
        tags: 'unesco,historical,photography',
        images: 'sigiriya_1.jpg,sigiriya_2.jpg,sigiriya_3.jpg,sigiriya_4.jpg',
        isPremium: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('AttractionCard displays attraction name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionCard(
              attraction: testAttraction,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sigiriya Rock Fortress'), findsOneWidget);
    });

    testWidgets('AttractionCard displays category', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionCard(
              attraction: testAttraction,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Ancient'), findsWidgets);
    });

    testWidgets('AttractionCard responds to tap', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionCard(
              attraction: testAttraction,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AttractionCard));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('AttractionCard shows premium badge when isPremium is true',
        (WidgetTester tester) async {
      final premiumAttraction = testAttraction.copyWith(isPremium: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionCard(
              attraction: premiumAttraction,
              onTap: () {},
            ),
          ),
        ),
      );

      // Look for premium indicator (could be icon, badge, or text)
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.stars,
        ),
        findsOneWidget,
      );
    });

    testWidgets('AttractionCard displays favorite icon when isFavorite is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionCard(
              attraction: testAttraction,
              isFavorite: true,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('AttractionCard displays favorite border icon when not favorite',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionCard(
              attraction: testAttraction,
              isFavorite: false,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('AttractionCard favorite icon toggle works',
        (WidgetTester tester) async {
      bool favoriteToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttractionCard(
              attraction: testAttraction,
              isFavorite: false,
              onTap: () {},
              onFavoriteToggle: () {
                favoriteToggled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(favoriteToggled, isTrue);
    });
  });
}
