import 'dart:convert';

import 'package:bitassets/settings/amm_settings.dart';
import 'package:bitassets/settings/favorites_settings.dart';
import 'package:bitassets/settings/price_alerts_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SlippageToleranceSetting', () {
    test('has correct key', () {
      final setting = SlippageToleranceSetting();
      expect(setting.key, 'amm_slippage_tolerance');
    });

    test('has correct default value', () {
      final setting = SlippageToleranceSetting();
      expect(setting.defaultValue(), 0.5);
    });

    test('value returns default when no value set', () {
      final setting = SlippageToleranceSetting();
      expect(setting.value, 0.5);
    });

    test('value returns set value', () {
      final setting = SlippageToleranceSetting(newValue: 1.0);
      expect(setting.value, 1.0);
    });

    test('toJson serializes value correctly', () {
      final setting = SlippageToleranceSetting(newValue: 2.5);
      expect(setting.toJson(), '2.5');
    });

    test('fromJson deserializes valid value', () {
      final setting = SlippageToleranceSetting();
      expect(setting.fromJson('1.5'), 1.5);
    });

    test('fromJson returns null for invalid value', () {
      final setting = SlippageToleranceSetting();
      expect(setting.fromJson('invalid'), null);
    });

    test('withValue creates new instance with value', () {
      final setting = SlippageToleranceSetting();
      final newSetting = setting.withValue(3.0);
      expect(newSetting.value, 3.0);
      expect(setting.value, 0.5); // original unchanged
    });

    test('withValue with null uses default', () {
      final setting = SlippageToleranceSetting();
      final newSetting = setting.withValue(null);
      expect(newSetting.value, 0.5);
    });
  });

  group('FavoriteAssetsSetting', () {
    test('has correct key', () {
      final setting = FavoriteAssetsSetting();
      expect(setting.key, 'favorite_assets');
    });

    test('has correct default value', () {
      final setting = FavoriteAssetsSetting();
      expect(setting.defaultValue(), <String>{});
    });

    test('value returns empty set when no value set', () {
      final setting = FavoriteAssetsSetting();
      expect(setting.value, <String>{});
    });

    test('value returns set value', () {
      final setting = FavoriteAssetsSetting(newValue: {'hash1', 'hash2'});
      expect(setting.value, {'hash1', 'hash2'});
    });

    test('toJson serializes value correctly', () {
      final setting = FavoriteAssetsSetting(newValue: {'hash1', 'hash2'});
      final json = setting.toJson();
      final decoded = jsonDecode(json) as List;
      expect(decoded.toSet(), {'hash1', 'hash2'});
    });

    test('fromJson deserializes valid value', () {
      final setting = FavoriteAssetsSetting();
      final result = setting.fromJson('["hash1", "hash2"]');
      expect(result, {'hash1', 'hash2'});
    });

    test('fromJson returns null for invalid value', () {
      final setting = FavoriteAssetsSetting();
      expect(setting.fromJson('invalid'), null);
    });

    test('withValue creates new instance with value', () {
      final setting = FavoriteAssetsSetting();
      final newSetting = setting.withValue({'newHash'});
      expect(newSetting.value, {'newHash'});
      expect(setting.value, <String>{}); // original unchanged
    });

    test('handles empty set serialization', () {
      final setting = FavoriteAssetsSetting(newValue: {});
      expect(setting.toJson(), '[]');
    });
  });

  group('PriceAlert', () {
    test('creates from constructor', () {
      final alert = PriceAlert(
        auctionId: 'auction1',
        assetId: 'asset1',
        targetPrice: 1000,
        alertWhenBelow: true,
        enabled: true,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(alert.auctionId, 'auction1');
      expect(alert.assetId, 'asset1');
      expect(alert.targetPrice, 1000);
      expect(alert.alertWhenBelow, true);
      expect(alert.enabled, true);
      expect(alert.createdAt, DateTime(2024, 1, 1));
    });

    test('toJson serializes correctly', () {
      final alert = PriceAlert(
        auctionId: 'auction1',
        assetId: 'asset1',
        targetPrice: 1000,
        alertWhenBelow: true,
        enabled: true,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = alert.toJson();
      expect(json['auctionId'], 'auction1');
      expect(json['assetId'], 'asset1');
      expect(json['targetPrice'], 1000);
      expect(json['alertWhenBelow'], true);
      expect(json['enabled'], true);
      expect(json['createdAt'], '2024-01-01T12:00:00.000');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'auctionId': 'auction1',
        'assetId': 'asset1',
        'targetPrice': 1000,
        'alertWhenBelow': false,
        'enabled': true,
        'createdAt': '2024-01-01T12:00:00.000',
      };

      final alert = PriceAlert.fromJson(json);
      expect(alert.auctionId, 'auction1');
      expect(alert.assetId, 'asset1');
      expect(alert.targetPrice, 1000);
      expect(alert.alertWhenBelow, false);
      expect(alert.enabled, true);
      expect(alert.createdAt, DateTime(2024, 1, 1, 12, 0, 0));
    });

    test('copyWith creates new instance with updated values', () {
      final alert = PriceAlert(
        auctionId: 'auction1',
        assetId: 'asset1',
        targetPrice: 1000,
        alertWhenBelow: true,
        enabled: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = alert.copyWith(
        targetPrice: 2000,
        enabled: false,
      );

      expect(updated.auctionId, 'auction1'); // unchanged
      expect(updated.assetId, 'asset1'); // unchanged
      expect(updated.targetPrice, 2000); // changed
      expect(updated.alertWhenBelow, true); // unchanged
      expect(updated.enabled, false); // changed
      expect(updated.createdAt, DateTime(2024, 1, 1)); // unchanged
    });

    test('copyWith with no args returns identical values', () {
      final alert = PriceAlert(
        auctionId: 'auction1',
        assetId: 'asset1',
        targetPrice: 1000,
        alertWhenBelow: true,
        enabled: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final copy = alert.copyWith();

      expect(copy.auctionId, alert.auctionId);
      expect(copy.assetId, alert.assetId);
      expect(copy.targetPrice, alert.targetPrice);
      expect(copy.alertWhenBelow, alert.alertWhenBelow);
      expect(copy.enabled, alert.enabled);
      expect(copy.createdAt, alert.createdAt);
    });
  });

  group('PriceAlertsSetting', () {
    test('has correct key', () {
      final setting = PriceAlertsSetting();
      expect(setting.key, 'price_alerts');
    });

    test('has correct default value', () {
      final setting = PriceAlertsSetting();
      expect(setting.defaultValue(), <PriceAlert>[]);
    });

    test('value returns empty list when no value set', () {
      final setting = PriceAlertsSetting();
      expect(setting.value, <PriceAlert>[]);
    });

    test('toJson serializes list correctly', () {
      final alerts = [
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      final setting = PriceAlertsSetting(newValue: alerts);
      final json = setting.toJson();
      final decoded = jsonDecode(json) as List;
      expect(decoded.length, 1);
      expect(decoded[0]['auctionId'], 'auction1');
    });

    test('fromJson deserializes list correctly', () {
      final setting = PriceAlertsSetting();
      final json = '''[{
        "auctionId": "auction1",
        "assetId": "asset1",
        "targetPrice": 1000,
        "alertWhenBelow": true,
        "enabled": true,
        "createdAt": "2024-01-01T00:00:00.000"
      }]''';

      final result = setting.fromJson(json);
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].auctionId, 'auction1');
    });

    test('fromJson returns null for invalid json', () {
      final setting = PriceAlertsSetting();
      expect(setting.fromJson('invalid'), null);
    });

    test('withValue creates new instance with value', () {
      final setting = PriceAlertsSetting();
      final alerts = [
        PriceAlert(
          auctionId: 'auction1',
          assetId: 'asset1',
          targetPrice: 1000,
          alertWhenBelow: true,
          enabled: true,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      final newSetting = setting.withValue(alerts);
      expect(newSetting.value.length, 1);
      expect(setting.value.length, 0); // original unchanged
    });
  });
}
