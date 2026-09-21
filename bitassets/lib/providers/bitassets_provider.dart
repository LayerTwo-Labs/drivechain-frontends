import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/providers/sync_provider.dart';
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

  /// The amount of each BitAsset that the wallet holds, keyed by the asset hash.
  Map<String, int> ownedAmounts = {};

  /// The assets this install registered. A coin of another asset never joins
  /// this set, so the settings keep the registrations alone.
  Set<String> _registeredHashes = {};

  /// The assets the wallet coins name. A failed read keeps the last set.
  Set<String> _walletHashes = {};

  /// True after the node answers one read of the wallet coins.
  bool walletRead = false;

  BitAssetsProvider() {
    rpc.addListener(fetch);
    if (GetIt.I.isRegistered<SyncProvider>()) {
      GetIt.I.get<SyncProvider>().onNewBlock(_onNewBlock);
    }
    unawaited(_start());
    _startRetryTimer();
  }

  void _onNewBlock(int height) => unawaited(fetch());

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
      // The release before this one wrote the flag to the shared store, and
      // the one before that to this app's own store.
      final key = HashNameMappingSetting().key;
      final owned = {
        ...ownedFromLegacyMapping(await store.getString(key)),
        ...ownedFromLegacyMapping(await nameSettings.store.getString(key)),
      };
      await appSettings.setValue(OwnedBitAssetsSetting(newValue: owned.toList()));
    } catch (e) {
      // A settings read failure leaves the old map in place for the next start.
    }
  }

  void _startRetryTimer() {
    if (Environment.isInTest) return;

    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (entries.isNotEmpty && initialized && walletRead) {
        timer.cancel();
        _startPollTimer();
        return;
      }
      fetch();
    });
  }

  /// A coin in the mempool fires no block event, and the sidechain mines a
  /// block after the mainchain event that this provider listens to.
  void _startPollTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());
  }

  Future<void> fetch() async {
    if (_isFetching || _disposed) return;
    _isFetching = true;

    List<BitAssetEntry>? newEntries;
    List<DutchAuctionEntry>? newAuctions;
    HashNameMappingSetting? newHashNameMapping;
    Map<String, int> newOwnedAmounts = ownedAmounts;
    bool newInitialized = initialized;

    try {
      final loaded = await nameSettings.getValue(HashNameMappingSetting());
      newHashNameMapping = HashNameMappingSetting(newValue: loaded.value);
      final owned = await appSettings.getValue(OwnedBitAssetsSetting());
      _registeredHashes = owned.value.toSet();
    } catch (e) {
      // Keep the in-memory mapping if settings are unavailable.
    }

    // The coins the wallet holds name every asset it owns, and a coin from
    // another node counts the same as a coin this node registered.
    try {
      final utxos = await rpc.listUTXOs();
      newOwnedAmounts = bitAssetAmounts(utxos);
      _walletHashes = {...newOwnedAmounts.keys, ...controlledBitAssets(utxos)};
      walletRead = true;
    } catch (e) {
      // Keep the assets of the last read if the node is unavailable.
    }

    final newOwnedHashes = {..._registeredHashes, ..._walletHashes};

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

    if (_dataHasChanged(newEntries, newAuctions, newHashNameMapping, newOwnedHashes, newOwnedAmounts, newInitialized)) {
      if (newHashNameMapping != null) {
        hashNameMapping = newHashNameMapping;
      }
      ownedHashes = newOwnedHashes;
      ownedAmounts = newOwnedAmounts;
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
    Set<String> newOwnedHashes,
    Map<String, int> newOwnedAmounts,
    bool newInitialized,
  ) {
    if (newInitialized != initialized) {
      return true;
    }

    if (!setEquals(ownedHashes, newOwnedHashes) || !mapEquals(ownedAmounts, newOwnedAmounts)) {
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
    final saved = await nameSettings.mergeValue(
      HashNameMappingSetting(),
      (current) => {...current, hash: HashMapping(name: name)},
    );
    hashNameMapping = HashNameMappingSetting(newValue: saved.value);
    if (isMine) {
      _registeredHashes = {..._registeredHashes, hash};
      ownedHashes = {...ownedHashes, hash};
      await appSettings.setValue(OwnedBitAssetsSetting(newValue: _registeredHashes.toList()));
    }
    notifyListeners();
    await fetch(); // refetch to set the name in the list
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    if (GetIt.I.isRegistered<SyncProvider>()) {
      GetIt.I.get<SyncProvider>().offNewBlock(_onNewBlock);
    }
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
