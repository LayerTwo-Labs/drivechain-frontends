import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/providers/price_alert_provider.dart';
import 'package:bitassets/settings/price_alerts_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'mocks/storage_mock.dart';

void main() {
  late PriceAlertProvider provider;
  late MockStore mockStore;

  setUp(() async {
    // Reset GetIt
    await GetIt.I.reset();

    mockStore = MockStore();
    final log = Logger(printer: PrettyPrinter(methodCount: 0));

    GetIt.I.registerLazySingleton<Logger>(() => log);
    GetIt.I.registerLazySingleton<ClientSettings>(
      () => ClientSettings(store: mockStore, log: log),
    );
    GetIt.I.registerLazySingleton<NotificationProvider>(
      () => NotificationProvider(),
    );
    GetIt.I.registerLazySingleton<BitAssetsRPC>(
      () => MockBitAssetsRPC(),
    );
    GetIt.I.registerLazySingleton<BitAssetsProvider>(
      () => BitAssetsProvider(),
    );
    GetIt.I.registerLazySingleton<AssetAnalyticsProvider>(
      () => AssetAnalyticsProvider(),
    );

    provider = PriceAlertProvider();
    // Wait for initial load
    await Future.delayed(const Duration(milliseconds: 50));
  });

  tearDown(() async {
    provider.dispose();
    await GetIt.I.reset();
  });

  group('PriceAlertProvider', () {
    test('initializes with empty alerts', () {
      expect(provider.alerts, isEmpty);
    });

    test('addAlert adds alert to list', () async {
      final alert = PriceAlert(
        auctionId: 'auction1',
        assetId: 'asset1',
        targetPrice: 1000,
        alertWhenBelow: true,
        enabled: true,
        createdAt: DateTime.now(),
      );

      await provider.addAlert(alert);

      expect(provider.alerts.length, 1);
      expect(provider.alerts.first.auctionId, 'auction1');
    });

    test('removeAlert removes alert from list', () async {
      final alert = PriceAlert(
        auctionId: 'auction1',
        assetId: 'asset1',
        targetPrice: 1000,
        alertWhenBelow: true,
        enabled: true,
        createdAt: DateTime.now(),
      );

      await provider.addAlert(alert);
      expect(provider.alerts.length, 1);

      await provider.removeAlert('auction1');
      expect(provider.alerts.length, 0);
    });

    test('getAlertsForAuction returns matching alerts', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction2',
          assetId: 'asset2',
          targetPrice: 2000,
          alertWhenBelow: false,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      final alerts = provider.getAlertsForAuction('auction1');
      expect(alerts.length, 1);
      expect(alerts.first.auctionId, 'auction1');
    });

    test('hasAlertForAuction returns true for enabled alert', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      expect(provider.hasAlertForAuction('auction1'), true);
    });

    test('hasAlertForAuction returns false for disabled alert', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: false,
          createdAt: DateTime.now(),
        ),
      );

      expect(provider.hasAlertForAuction('auction1'), false);
    });

    test('hasAlertForAuction returns false for non-existing auction', () {
      expect(provider.hasAlertForAuction('nonexistent'), false);
    });

    test('toggleAlert toggles enabled state', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      expect(provider.alerts.first.enabled, true);

      await provider.toggleAlert('auction1');
      expect(provider.alerts.first.enabled, false);

      await provider.toggleAlert('auction1');
      expect(provider.alerts.first.enabled, true);
    });

    test('updateAlert updates existing alert', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      final updatedAlert = PriceAlert(
        auctionId: 'auction1',
        assetId: 'asset1',
        targetPrice: 2000,
        alertWhenBelow: false,
        enabled: true,
        createdAt: DateTime.now(),
      );

      await provider.updateAlert(updatedAlert);

      expect(provider.alerts.length, 1);
      expect(provider.alerts.first.targetPrice, 2000);
      expect(provider.alerts.first.alertWhenBelow, false);
    });

    test('notifies listeners on add', () async {
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      expect(notified, true);
    });

    test('notifies listeners on remove', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.removeAlert('auction1');
      expect(notified, true);
    });

    test('notifies listeners on toggle', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.toggleAlert('auction1');
      expect(notified, true);
    });

    test('persists alerts to storage', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );

      // Create new provider to test persistence
      final newProvider = PriceAlertProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(newProvider.alerts.length, 1);
      expect(newProvider.alerts.first.auctionId, 'auction1');

      newProvider.dispose();
    });

    test('multiple alerts work correctly', () async {
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction2',
          assetId: 'asset2',
          targetPrice: 2000,
          alertWhenBelow: false,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      );
      await provider.addAlert(
        PriceAlert(
          auctionId: 'auction3',
          assetId: 'asset3',
          targetPrice: 3000,
          alertWhenBelow: true,
          enabled: false,
          createdAt: DateTime.now(),
        ),
      );

      expect(provider.alerts.length, 3);
      expect(provider.hasAlertForAuction('auction1'), true);
      expect(provider.hasAlertForAuction('auction2'), true);
      expect(provider.hasAlertForAuction('auction3'), false); // disabled
    });
  });
}
