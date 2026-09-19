import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/rpcs/bitassets_rpc.dart';
import 'package:sidechain_core/settings/client_settings.dart';
import 'package:sidechain_core/settings/hash_plaintext_settings.dart';
import 'package:thirds/blake3.dart';

class BitAssetsProvider extends ChangeNotifier {
  BitAssetsRPC get rpc => GetIt.I.get<BitAssetsRPC>();
  BitwindowClientSettings get nameSettings => HashNameMappingSetting.settings;
  ClientSettings get appSettings => GetIt.I.get<ClientSettings>();

  List<BitAssetEntry> entries = [];
  List<DutchAuctionEntry> auctions = [];
  bool initialized = false;
  bool _isFetching = false;
  bool _disposed = false;
  bool _isLoadingAuctions = true;
  Timer? _retryTimer;
  HashNameMappingSetting hashNameMapping = HashNameMappingSetting();
  Set<String> ownedHashes = {};

  BitAssetsProvider() {
    rpc.addListener(fetch);
    unawaited(_start());
    _startRetryTimer();
  }

  Future<void> _start() async {
    await migrateOwnedHashes();
    await fetch();
  }

  /// Takes the owned hashes an older install kept in its own name map. The
  /// shared map carries names alone, so ownership moves to a key of this app.
  Future<void> migrateOwnedHashes() async {
    final store = appSettings.store;
    try {
      if (await store.getString(OwnedBitAssetsSetting().key) != null) {
        return;
      }
      final owned = ownedFromLegacyMapping(await store.getString(HashNameMappingSetting().key));
      await appSettings.setValue(OwnedBitAssetsSetting(newValue: owned));
    } catch (e) {
      // A settings read failure leaves the old map in place for the next start.
    }
  }

  void _startRetryTimer() {
    if (Environment.isInTest) return;

    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (entries.isNotEmpty && initialized) {
        timer.cancel();
        _retryTimer = null;
        return;
      }
      fetch();
    });
  }

  Future<void> fetch() async {
    if (_isFetching || _disposed) return;
    _isFetching = true;

    List<BitAssetEntry>? newEntries;
    List<DutchAuctionEntry>? newAuctions;
    HashNameMappingSetting? newHashNameMapping;
    bool newInitialized = initialized;

    try {
      final loaded = await nameSettings.getValue(HashNameMappingSetting());
      newHashNameMapping = HashNameMappingSetting(newValue: loaded.value);
      final owned = await appSettings.getValue(OwnedBitAssetsSetting());
      ownedHashes = owned.value.toSet();
    } catch (e) {
      // Keep the in-memory mapping if settings are unavailable.
    }

    // Try to fetch BitAssets
    try {
      newEntries = await rpc.listBitAssets();
      newInitialized = true;
    } catch (e) {
      // Handle BitAssets error independently
    }

    // Try to fetch Dutch Auctions
    try {
      newAuctions = await rpc.dutchAuctions();
    } catch (e) {
      // Handle auction error independently
    }

    if (_dataHasChanged(newEntries, newAuctions, newHashNameMapping, newInitialized)) {
      if (newHashNameMapping != null) {
        hashNameMapping = newHashNameMapping;
      }
      if (newEntries != null) {
        entries = newEntries;
        initialized = newInitialized;
      }
      if (newAuctions != null) {
        auctions = newAuctions;
        _isLoadingAuctions = false;
      }
      if (!_disposed) {
        notifyListeners();
      }
    }

    _isFetching = false;
  }

  bool _dataHasChanged(
    List<BitAssetEntry>? newEntries,
    List<DutchAuctionEntry>? newAuctions,
    HashNameMappingSetting? newHashNameMapping,
    bool newInitialized,
  ) {
    if (newInitialized != initialized) {
      return true;
    }

    if (newEntries != null && !listEquals(entries, newEntries)) {
      return true;
    }

    if (newAuctions != null && !listEquals(auctions, newAuctions)) {
      return true;
    }

    if (newHashNameMapping != null && !_hashNameMappingsEqual(hashNameMapping.value, newHashNameMapping.value)) {
      return true;
    }

    return false;
  }

  bool _hashNameMappingsEqual(
    Map<String, HashMapping> left,
    Map<String, HashMapping> right,
  ) {
    if (left.length != right.length) {
      return false;
    }

    for (final entry in left.entries) {
      final other = right[entry.key];
      if (other == null || other.name != entry.value.name) {
        return false;
      }
    }

    return true;
  }

  bool get isLoadingAuctions => _isLoadingAuctions;

  /// Save a new hash-name mapping
  Future<void> saveHashNameMapping(String name, {bool isMine = false}) async {
    final hash = blake3Hex(utf8.encode(name));
    final current = await nameSettings.getValue(HashNameMappingSetting());
    final newMappings = Map<String, HashMapping>.from(current.value);
    newMappings[hash] = HashMapping(name: name);
    hashNameMapping = HashNameMappingSetting(newValue: newMappings);
    await nameSettings.setValue(hashNameMapping);
    if (isMine) {
      ownedHashes = {...ownedHashes, hash};
      await appSettings.setValue(OwnedBitAssetsSetting(newValue: ownedHashes.toList()));
    }
    notifyListeners();
    await fetch(); // refetch to set the name in the list
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    rpc.removeListener(fetch);
    super.dispose();
  }
}

/// The BitAsset hashes this wallet holds. The name mapping is shared with the
/// other apps, and the same plaintext hashes to the same value on every chain.
class OwnedBitAssetsSetting extends SettingValue<List<String>> {
  OwnedBitAssetsSetting({super.newValue});

  @override
  String get key => 'owned_bitasset_hashes';

  @override
  List<String> defaultValue() => [];

  @override
  String toJson() => jsonEncode(value);

  @override
  List<String>? fromJson(String jsonString) {
    try {
      return (jsonDecode(jsonString) as List<dynamic>).cast<String>();
    } catch (e) {
      return null;
    }
  }

  @override
  SettingValue<List<String>> withValue([List<String>? value]) {
    return OwnedBitAssetsSetting(newValue: value);
  }
}

/// The hashes that an older name map marks as held by this wallet.
List<String> ownedFromLegacyMapping(String? json) {
  if (json == null) {
    return [];
  }
  try {
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return [
      for (final entry in decoded.entries)
        if ((entry.value as Map<String, dynamic>)['isMine'] == true) entry.key,
    ];
  } catch (e) {
    return [];
  }
}
