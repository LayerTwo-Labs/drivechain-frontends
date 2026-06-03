import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';
import 'package:sail_ui/settings/client_settings.dart';
import 'package:sail_ui/settings/hash_plaintext_settings.dart';
import 'package:thirds/blake3.dart';

class BitAssetsProvider extends ChangeNotifier {
  BitAssetsRPC get rpc => GetIt.I.get<BitAssetsRPC>();
  ClientSettings get clientSettings => GetIt.I.get<ClientSettings>();

  List<BitAssetEntry> entries = [];
  List<DutchAuctionEntry> auctions = [];
  bool initialized = false;
  bool _isFetching = false;
  bool _isLoadingAuctions = true;
  Timer? _retryTimer;
  HashNameMappingSetting hashNameMapping = HashNameMappingSetting();

  BitAssetsProvider() {
    rpc.addListener(fetch);
    fetch();
    _startRetryTimer();
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
    if (_isFetching) return;
    _isFetching = true;

    List<BitAssetEntry>? newEntries;
    List<DutchAuctionEntry>? newAuctions;
    HashNameMappingSetting? newHashNameMapping;
    bool newInitialized = initialized;

    try {
      final loaded = await clientSettings.getValue(HashNameMappingSetting());
      newHashNameMapping = HashNameMappingSetting(newValue: loaded.value);
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
      notifyListeners();
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
      if (other == null || other.name != entry.value.name || other.isMine != entry.value.isMine) {
        return false;
      }
    }

    return true;
  }

  bool get isLoadingAuctions => _isLoadingAuctions;

  /// Save a new hash-name mapping
  Future<void> saveHashNameMapping(String name, {bool isMine = false}) async {
    final hash = blake3Hex(utf8.encode(name));
    final current = await clientSettings.getValue(HashNameMappingSetting());
    final newMappings = Map<String, HashMapping>.from(current.value);
    newMappings[hash] = HashMapping(name: name, isMine: isMine);
    hashNameMapping = HashNameMappingSetting(newValue: newMappings);
    await clientSettings.setValue(hashNameMapping);
    notifyListeners();
    await fetch(); // refetch to set the name in the list
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    rpc.removeListener(fetch);
    super.dispose();
  }
}
