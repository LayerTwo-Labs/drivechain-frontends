import 'package:bitassets/providers/favorites_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/storage_mock.dart';

void main() {
  late FavoritesProvider provider;
  late MockStore mockStore;

  setUp(() async {
    // Reset GetIt
    await GetIt.I.reset();

    mockStore = MockStore();
    final log = Logger(printer: PrettyPrinter(methodCount: 0));

    GetIt.I.registerLazySingleton<ClientSettings>(
      () => ClientSettings(store: mockStore, log: log),
    );

    provider = FavoritesProvider();
    // Wait for initial load
    await Future.delayed(const Duration(milliseconds: 50));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('FavoritesProvider', () {
    test('initializes with empty favorites', () {
      expect(provider.favorites, isEmpty);
    });

    test('isFavorite returns false for non-favorite', () {
      expect(provider.isFavorite('hash1'), false);
    });

    test('toggleFavorite adds favorite', () async {
      await provider.toggleFavorite('hash1');
      expect(provider.isFavorite('hash1'), true);
      expect(provider.favorites.length, 1);
    });

    test('toggleFavorite removes existing favorite', () async {
      await provider.toggleFavorite('hash1');
      expect(provider.isFavorite('hash1'), true);

      await provider.toggleFavorite('hash1');
      expect(provider.isFavorite('hash1'), false);
      expect(provider.favorites.length, 0);
    });

    test('addFavorite adds new favorite', () async {
      await provider.addFavorite('hash1');
      expect(provider.isFavorite('hash1'), true);
    });

    test('addFavorite does not duplicate existing favorite', () async {
      await provider.addFavorite('hash1');
      await provider.addFavorite('hash1');
      expect(provider.favorites.length, 1);
    });

    test('removeFavorite removes existing favorite', () async {
      await provider.addFavorite('hash1');
      await provider.removeFavorite('hash1');
      expect(provider.isFavorite('hash1'), false);
    });

    test('removeFavorite does nothing for non-existing favorite', () async {
      await provider.removeFavorite('nonexistent');
      expect(provider.favorites.length, 0);
    });

    test('clearFavorites removes all favorites', () async {
      await provider.addFavorite('hash1');
      await provider.addFavorite('hash2');
      await provider.addFavorite('hash3');
      expect(provider.favorites.length, 3);

      await provider.clearFavorites();
      expect(provider.favorites.length, 0);
    });

    test('multiple favorites work correctly', () async {
      await provider.addFavorite('hash1');
      await provider.addFavorite('hash2');
      await provider.addFavorite('hash3');

      expect(provider.isFavorite('hash1'), true);
      expect(provider.isFavorite('hash2'), true);
      expect(provider.isFavorite('hash3'), true);
      expect(provider.isFavorite('hash4'), false);
    });

    test('notifies listeners on add', () async {
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.addFavorite('hash1');
      expect(notified, true);
    });

    test('notifies listeners on remove', () async {
      await provider.addFavorite('hash1');

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.removeFavorite('hash1');
      expect(notified, true);
    });

    test('notifies listeners on toggle', () async {
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.toggleFavorite('hash1');
      expect(notifyCount, 1);

      await provider.toggleFavorite('hash1');
      expect(notifyCount, 2);
    });

    test('notifies listeners on clear', () async {
      await provider.addFavorite('hash1');

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.clearFavorites();
      expect(notified, true);
    });

    test('persists favorites to storage', () async {
      await provider.addFavorite('hash1');
      await provider.addFavorite('hash2');

      // Create new provider to test persistence
      final newProvider = FavoritesProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(newProvider.isFavorite('hash1'), true);
      expect(newProvider.isFavorite('hash2'), true);
    });
  });
}
