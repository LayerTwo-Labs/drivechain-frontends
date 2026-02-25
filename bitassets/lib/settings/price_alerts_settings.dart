import 'dart:convert';

import 'package:sail_ui/sail_ui.dart';

class PriceAlert {
  final String auctionId;
  final String assetId;
  final int targetPrice;
  final bool alertWhenBelow;
  final bool enabled;
  final DateTime createdAt;

  PriceAlert({
    required this.auctionId,
    required this.assetId,
    required this.targetPrice,
    required this.alertWhenBelow,
    required this.enabled,
    required this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      auctionId: json['auctionId'] as String,
      assetId: json['assetId'] as String,
      targetPrice: json['targetPrice'] as int,
      alertWhenBelow: json['alertWhenBelow'] as bool,
      enabled: json['enabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auctionId': auctionId,
      'assetId': assetId,
      'targetPrice': targetPrice,
      'alertWhenBelow': alertWhenBelow,
      'enabled': enabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PriceAlert copyWith({
    String? auctionId,
    String? assetId,
    int? targetPrice,
    bool? alertWhenBelow,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return PriceAlert(
      auctionId: auctionId ?? this.auctionId,
      assetId: assetId ?? this.assetId,
      targetPrice: targetPrice ?? this.targetPrice,
      alertWhenBelow: alertWhenBelow ?? this.alertWhenBelow,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PriceAlertsSetting extends SettingValue<List<PriceAlert>> {
  PriceAlertsSetting({super.newValue});

  @override
  String get key => 'price_alerts';

  @override
  List<PriceAlert> defaultValue() => [];

  @override
  List<PriceAlert>? fromJson(String jsonString) {
    try {
      final list = jsonDecode(jsonString) as List;
      return list.map((e) => PriceAlert.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  String toJson() {
    return jsonEncode(value.map((e) => e.toJson()).toList());
  }

  @override
  SettingValue<List<PriceAlert>> withValue([List<PriceAlert>? value]) {
    return PriceAlertsSetting(newValue: value);
  }
}
