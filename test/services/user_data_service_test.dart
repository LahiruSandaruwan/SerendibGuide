import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:serendib_guide/services/user_data_service.dart';
import 'package:serendib_guide/models/trip.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('UserDataService', () {
    late UserDataService userDataService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      userDataService = UserDataService();
    });

    test('UserDataService is a singleton', () {
      final instance1 = UserDataService();
      final instance2 = UserDataService();
      expect(instance1, equals(instance2));
    });

    group('Favorites', () {
      test('addFavorite adds attraction to favorites', () async {
        const attractionId = 1;
        final result = await userDataService.addFavorite(attractionId);
        expect(result, isTrue);

        final favorites = await userDataService.getFavoriteIds();
        expect(favorites, contains(attractionId));
      });

      test('removeFavorite removes attraction from favorites', () async {
        const attractionId = 1;

        // Add first
        await userDataService.addFavorite(attractionId);

        // Then remove
        final result = await userDataService.removeFavorite(attractionId);
        expect(result, isTrue);

        final favorites = await userDataService.getFavoriteIds();
        expect(favorites, isNot(contains(attractionId)));
      });

      test('isFavorite returns true for favorited attraction', () async {
        const attractionId = 1;
        await userDataService.addFavorite(attractionId);

        final isFav = await userDataService.isFavorite(attractionId);
        expect(isFav, isTrue);
      });

      test('isFavorite returns false for non-favorited attraction', () async {
        const attractionId = 999;
        final isFav = await userDataService.isFavorite(attractionId);
        expect(isFav, isFalse);
      });

      test('getFavoriteIds returns all favorite IDs', () async {
        await userDataService.addFavorite(1);
        await userDataService.addFavorite(2);
        await userDataService.addFavorite(3);

        final favorites = await userDataService.getFavoriteIds();
        expect(favorites.length, equals(3));
        expect(favorites, containsAll([1, 2, 3]));
      });

      test('cannot add duplicate favorite', () async {
        const attractionId = 1;

        await userDataService.addFavorite(attractionId);
        await userDataService.addFavorite(attractionId); // Try to add again

        final favorites = await userDataService.getFavoriteIds();
        expect(favorites.where((id) => id == attractionId).length, equals(1));
      });

      test('clearFavorites removes all favorites', () async {
        await userDataService.addFavorite(1);
        await userDataService.addFavorite(2);
        await userDataService.addFavorite(3);

        await userDataService.clearFavorites();

        final favorites = await userDataService.getFavoriteIds();
        expect(favorites, isEmpty);
      });
    });

    group('Trips', () {
      test('saveTrip creates new trip', () async {
        final trip = Trip(
          id: null,
          name: 'Test Trip',
          attractionIds: [1, 2, 3],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedTrip = await userDataService.saveTrip(trip);
        expect(savedTrip.id, isNotNull);
        expect(savedTrip.name, equals('Test Trip'));
        expect(savedTrip.attractionIds, equals([1, 2, 3]));
      });

      test('saveTrip updates existing trip', () async {
        // Create trip
        final trip = Trip(
          id: null,
          name: 'Original Name',
          attractionIds: [1, 2],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedTrip = await userDataService.saveTrip(trip);

        // Update trip
        final updatedTrip = savedTrip.copyWith(
          name: 'Updated Name',
          attractionIds: [1, 2, 3, 4],
        );

        final result = await userDataService.saveTrip(updatedTrip);
        expect(result.id, equals(savedTrip.id));
        expect(result.name, equals('Updated Name'));
        expect(result.attractionIds.length, equals(4));
      });

      test('getTrip returns trip by ID', () async {
        final trip = Trip(
          id: null,
          name: 'Test Trip',
          attractionIds: [1, 2, 3],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedTrip = await userDataService.saveTrip(trip);
        final retrievedTrip = await userDataService.getTrip(savedTrip.id!);

        expect(retrievedTrip, isNotNull);
        expect(retrievedTrip!.id, equals(savedTrip.id));
        expect(retrievedTrip.name, equals('Test Trip'));
      });

      test('getTrip returns null for non-existent ID', () async {
        final trip = await userDataService.getTrip(999999);
        expect(trip, isNull);
      });

      test('getAllTrips returns all trips', () async {
        await userDataService.saveTrip(Trip(
          id: null,
          name: 'Trip 1',
          attractionIds: [1],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        await userDataService.saveTrip(Trip(
          id: null,
          name: 'Trip 2',
          attractionIds: [2],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        final trips = await userDataService.getAllTrips();
        expect(trips.length, greaterThanOrEqualTo(2));
      });

      test('deleteTrip removes trip', () async {
        final trip = await userDataService.saveTrip(Trip(
          id: null,
          name: 'To Delete',
          attractionIds: [1],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        await userDataService.deleteTrip(trip.id!);

        final retrievedTrip = await userDataService.getTrip(trip.id!);
        expect(retrievedTrip, isNull);
      });
    });

    group('Settings', () {
      test('saveSetting stores setting value', () async {
        await userDataService.saveSetting('test_key', 'test_value');
        final value = await userDataService.getSetting('test_key');
        expect(value, equals('test_value'));
      });

      test('getSetting returns null for non-existent key', () async {
        final value = await userDataService.getSetting('non_existent_key');
        expect(value, isNull);
      });

      test('saveSetting overwrites existing value', () async {
        await userDataService.saveSetting('key', 'value1');
        await userDataService.saveSetting('key', 'value2');

        final value = await userDataService.getSetting('key');
        expect(value, equals('value2'));
      });

      test('deleteSetting removes setting', () async {
        await userDataService.saveSetting('key', 'value');
        await userDataService.deleteSetting('key');

        final value = await userDataService.getSetting('key');
        expect(value, isNull);
      });
    });

    group('Statistics', () {
      test('incrementVisitCount increases count', () async {
        const attractionId = 1;

        await userDataService.incrementVisitCount(attractionId);
        await userDataService.incrementVisitCount(attractionId);

        final count = await userDataService.getVisitCount(attractionId);
        expect(count, equals(2));
      });

      test('getVisitCount returns 0 for never visited attraction', () async {
        final count = await userDataService.getVisitCount(999);
        expect(count, equals(0));
      });

      test('getMostVisited returns attractions ordered by visit count', () async {
        await userDataService.incrementVisitCount(1);
        await userDataService.incrementVisitCount(1);
        await userDataService.incrementVisitCount(1);

        await userDataService.incrementVisitCount(2);
        await userDataService.incrementVisitCount(2);

        await userDataService.incrementVisitCount(3);

        final mostVisited = await userDataService.getMostVisited(limit: 3);
        expect(mostVisited.length, lessThanOrEqualTo(3));

        // First attraction should have highest count
        if (mostVisited.isNotEmpty) {
          expect(mostVisited.first['attraction_id'], equals(1));
          expect(mostVisited.first['visit_count'], equals(3));
        }
      });
    });

    group('Free Tier Limits', () {
      test('cannot exceed free favorites limit', () async {
        // Try to add 21 favorites (limit is 20)
        for (int i = 1; i <= 21; i++) {
          await userDataService.addFavorite(i);
        }

        final favorites = await userDataService.getFavoriteIds();
        // Should enforce limit of 20 for free users
        expect(favorites.length, lessThanOrEqualTo(20));
      });

      test('cannot exceed free trips limit', () async {
        // Try to create 4 trips (limit is 3)
        for (int i = 1; i <= 4; i++) {
          await userDataService.saveTrip(Trip(
            id: null,
            name: 'Trip $i',
            attractionIds: [i],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }

        final trips = await userDataService.getAllTrips();
        // Should enforce limit of 3 for free users
        expect(trips.length, lessThanOrEqualTo(3));
      });
    });
  });
}
