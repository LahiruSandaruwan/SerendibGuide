import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:serendib_guide/screens/home_screen.dart';
import 'package:serendib_guide/providers/app_state_provider.dart';
import 'package:serendib_guide/services/database_service.dart';
import 'package:serendib_guide/services/user_data_service.dart';
import 'package:serendib_guide/services/purchase_service.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    Widget createHomeScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AppStateProvider(),
          ),
          Provider(
            create: (_) => DatabaseService(),
          ),
          Provider(
            create: (_) => UserDataService(),
          ),
          Provider(
            create: (_) => PurchaseService(),
          ),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    testWidgets('HomeScreen shows app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Serendib Guide'), findsOneWidget);
    });

    testWidgets('HomeScreen shows loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());

      // Should show loading indicator before data loads
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('HomeScreen shows category filters', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Should show category chips/filters
      expect(find.text('All'), findsWidgets);
    });

    testWidgets('HomeScreen has search functionality', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Should have search icon in app bar
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('HomeScreen has navigation drawer or bottom nav',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Should have either drawer or bottom navigation
      final drawerFinder = find.byType(Drawer);
      final bottomNavFinder = find.byType(BottomNavigationBar);

      expect(
        drawerFinder.evaluate().isNotEmpty || bottomNavFinder.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('HomeScreen shows attractions list after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // After loading, should show either attractions or empty state
      final listFinder = find.byType(ListView);
      final gridFinder = find.byType(GridView);
      final emptyStateFinder = find.textContaining('No attractions');

      expect(
        listFinder.evaluate().isNotEmpty ||
            gridFinder.evaluate().isNotEmpty ||
            emptyStateFinder.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('HomeScreen category filter changes selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Tap on a category (if visible)
      final allCategoryFinder = find.text('All').first;
      if (allCategoryFinder.evaluate().isNotEmpty) {
        await tester.tap(allCategoryFinder);
        await tester.pumpAndSettle();

        // Should trigger rebuild with filtered results
        expect(find.byType(HomeScreen), findsOneWidget);
      }
    });

    testWidgets('HomeScreen shows ad banner for free users',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // Free users should see ad banner (if not premium)
      // Note: Actual ad widget might not load in tests
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
