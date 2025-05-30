import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/settings/client_settings.dart';
import 'package:sail_ui/settings/hash_plaintext_settings.dart';

class BitnamesProvider extends ChangeNotifier {
  BitnamesRPC get rpc => GetIt.I.get<BitnamesRPC>();
  ClientSettings get clientSettings => GetIt.I.get<ClientSettings>();

  List<BitnameEntry> entries = [];
  bool initialized = false;
  bool _isFetching = false;
  Timer? _retryTimer;

  HashNameMappingSetting hashNameMapping = HashNameMappingSetting();

  BitnamesProvider() {
    rpc.addListener(fetch);
    fetch();
    _startRetryTimer();
  }

  /// Save a new hash-name mapping
  Future<void> saveHashNameMapping(String hash, String name) async {
    hashNameMapping = hashNameMapping.addMapping(hash, name);
    await clientSettings.setValue(hashNameMapping);
    notifyListeners();
  }

  /// Get friendly name for a hash
  String? getFriendlyName(String hash) {
    return hashNameMapping.nameFromHash(hash);
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

    try {
      final newEntries = await rpc.listBitNames();
      const newInitialized = true;

      if (!_listEquals(entries, newEntries) || newInitialized != initialized) {
        entries = newEntries;
        initialized = newInitialized;
        notifyListeners();
      }
    } finally {
      _isFetching = false;
    }
  }

  bool _listEquals(List<BitnameEntry> a, List<BitnameEntry> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].hash != b[i].hash || a[i].plaintextName != b[i].plaintextName) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    rpc.removeListener(fetch);
    super.dispose();
  }
}
