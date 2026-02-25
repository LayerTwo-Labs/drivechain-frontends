import 'dart:async';

import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/settings/price_alerts_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class PriceAlertProvider extends ChangeNotifier {
  final ClientSettings _settings = GetIt.I.get<ClientSettings>();
  final NotificationProvider _notificationProvider = GetIt.I.get<NotificationProvider>();
  final BitAssetsProvider _bitAssetsProvider = GetIt.I.get<BitAssetsProvider>();
  final AssetAnalyticsProvider _analyticsProvider = GetIt.I.get<AssetAnalyticsProvider>();
  final BitAssetsRPC _rpc = GetIt.I.get<BitAssetsRPC>();

  List<PriceAlert> _alerts = [];
  Timer? _monitorTimer;
  int _currentBlock = 0;

  PriceAlertProvider() {
    _loadAlerts();
    _startMonitoring();
  }

  List<PriceAlert> get alerts => _alerts;

  List<PriceAlert> getAlertsForAuction(String auctionId) {
    return _alerts.where((a) => a.auctionId == auctionId).toList();
  }

  bool hasAlertForAuction(String auctionId) {
    return _alerts.any((a) => a.auctionId == auctionId && a.enabled);
  }

  Future<void> _loadAlerts() async {
    final setting = await _settings.getValue(PriceAlertsSetting());
    _alerts = setting.value;
    notifyListeners();
  }

  Future<void> _saveAlerts() async {
    await _settings.setValue(PriceAlertsSetting(newValue: _alerts));
  }

  Future<void> addAlert(PriceAlert alert) async {
    _alerts = List<PriceAlert>.from(_alerts)..add(alert);
    await _saveAlerts();
    notifyListeners();
  }

  Future<void> removeAlert(String auctionId) async {
    _alerts = _alerts.where((a) => a.auctionId != auctionId).toList();
    await _saveAlerts();
    notifyListeners();
  }

  Future<void> toggleAlert(String auctionId) async {
    final index = _alerts.indexWhere((a) => a.auctionId == auctionId);
    if (index != -1) {
      final alert = _alerts[index];
      _alerts = List<PriceAlert>.from(_alerts)..[index] = alert.copyWith(enabled: !alert.enabled);
      await _saveAlerts();
      notifyListeners();
    }
  }

  Future<void> updateAlert(PriceAlert updatedAlert) async {
    final index = _alerts.indexWhere((a) => a.auctionId == updatedAlert.auctionId);
    if (index != -1) {
      _alerts = List<PriceAlert>.from(_alerts)..[index] = updatedAlert;
      await _saveAlerts();
      notifyListeners();
    }
  }

  void _startMonitoring() {
    _monitorTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkAlerts());
  }

  Future<void> _checkAlerts() async {
    try {
      _currentBlock = await _rpc.getBlockCount();
    } catch (_) {
      return;
    }

    final auctions = _bitAssetsProvider.auctions;
    final alertsToRemove = <String>[];

    for (final alert in _alerts) {
      if (!alert.enabled) continue;

      final auction = auctions.where((a) => a.id == alert.auctionId).firstOrNull;
      if (auction == null) continue;

      final status = _analyticsProvider.getAuctionStatus(auction, _currentBlock);
      if (status != 'Active') {
        if (status == 'Ended') {
          alertsToRemove.add(alert.auctionId);
        }
        continue;
      }

      final currentPrice = _analyticsProvider.calculateCurrentPrice(auction, _currentBlock);

      bool shouldTrigger = false;
      if (alert.alertWhenBelow && currentPrice <= alert.targetPrice) {
        shouldTrigger = true;
      } else if (!alert.alertWhenBelow && currentPrice >= alert.targetPrice) {
        shouldTrigger = true;
      }

      if (shouldTrigger) {
        _notificationProvider.add(
          title: 'Price Alert Triggered',
          content:
              'Auction ${alert.auctionId.substring(0, 12)}... price is now $currentPrice sats (target: ${alert.alertWhenBelow ? "below" : "above"} ${alert.targetPrice})',
          dialogType: DialogType.info,
        );
        alertsToRemove.add(alert.auctionId);
      }
    }

    if (alertsToRemove.isNotEmpty) {
      for (final id in alertsToRemove) {
        await removeAlert(id);
      }
    }
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }
}
