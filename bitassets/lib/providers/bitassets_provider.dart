import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';
import 'package:sail_ui/settings/client_settings.dart';
import 'package:sail_ui/settings/hash_plaintext_settings.dart';

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
    bool newInitialized = initialized;

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

    if (_dataHasChanged(newEntries, newAuctions, newInitialized)) {
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

    return false;
  }

  bool get isLoadingAuctions => _isLoadingAuctions;

  /// Save a new hash-name mapping
  Future<void> saveHashNameMapping(String hash, String name) async {
    hashNameMapping = hashNameMapping.addMapping(hash, name);
    await clientSettings.setValue(hashNameMapping);
    notifyListeners();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    rpc.removeListener(fetch);
    super.dispose();
  }
}
