import 'dart:convert';
import 'package:sail_ui/models/wallet_gradient.dart';

/// Lightweight wallet metadata for wallet list and selection
/// Contains only essential information without full wallet data
class WalletMetadata {
  final String id;
  final String name;
  final WalletGradient gradient;
  final DateTime createdAt;
  final DateTime lastUsed;

  WalletMetadata({
    required this.id,
    required this.name,
    required this.gradient,
    required this.createdAt,
    required this.lastUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gradient': gradient.toJson(),
      'created_at': createdAt.toIso8601String(),
      'last_used': lastUsed.toIso8601String(),
    };
  }

  factory WalletMetadata.fromJson(Map<String, dynamic> json) {
    return WalletMetadata(
      id: json['id'] as String,
      name: json['name'] as String,
      gradient: json['gradient'] != null
          ? WalletGradient.fromJson(json['gradient'] as Map<String, dynamic>)
          : WalletGradient.fromWalletId(json['id'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUsed: DateTime.parse(json['last_used'] as String),
    );
  }

  factory WalletMetadata.fromWalletData(
    String id,
    String name,
    WalletGradient gradient,
    DateTime createdAt,
  ) {
    return WalletMetadata(
      id: id,
      name: name,
      gradient: gradient,
      createdAt: createdAt,
      lastUsed: DateTime.now(),
    );
  }

  WalletMetadata copyWith({
    String? name,
    WalletGradient? gradient,
    DateTime? lastUsed,
  }) {
    return WalletMetadata(
      id: id,
      name: name ?? this.name,
      gradient: gradient ?? this.gradient,
      createdAt: createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory WalletMetadata.fromJsonString(String jsonString) {
    return WalletMetadata.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}

/// List of wallet metadata
class WalletMetadataList {
  final List<WalletMetadata> wallets;

  WalletMetadataList({required this.wallets});

  Map<String, dynamic> toJson() {
    return {
      'wallets': wallets.map((w) => w.toJson()).toList(),
    };
  }

  factory WalletMetadataList.fromJson(Map<String, dynamic> json) {
    return WalletMetadataList(
      wallets: (json['wallets'] as List<dynamic>?)
              ?.map((w) => WalletMetadata.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory WalletMetadataList.fromJsonString(String jsonString) {
    return WalletMetadataList.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
