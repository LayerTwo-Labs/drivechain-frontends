import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/rpcs/bitnames_rpc.dart';
import 'package:sidechain_core/settings/client_settings.dart';
import 'package:sidechain_core/settings/hash_plaintext_settings.dart';
import 'package:thirds/blake3.dart';

class BitnamesProvider extends ChangeNotifier {
  BitnamesRPC get rpc => GetIt.I.get<BitnamesRPC>();
  ClientSettings get clientSettings => GetIt.I.get<ClientSettings>();

  List<BitnameEntry> entries = [];
  bool initialized = false;
  bool _isFetching = false;
  String? error;

  bool get isLoading => _isFetching && !initialized;

  HashNameMappingSetting hashNameMapping = HashNameMappingSetting();

  BitnamesProvider() {
    rpc.addListener(fetch);
    fetch();
  }

  /// Save a new hash-name mapping
  Future<void> saveHashNameMapping(String name, {bool isMine = false}) async {
    final hash = blake3Hex(utf8.encode(name));
    final saved = await clientSettings.getValue(HashNameMappingSetting());
    final newMappings = Map<String, HashMapping>.from(saved.value);
    newMappings[hash] = HashMapping(name: name, isMine: isMine);
    hashNameMapping = HashNameMappingSetting(newValue: newMappings);
    await clientSettings.setValue(hashNameMapping);
    notifyListeners();
    await fetch(); // refetch to set the name in the list
  }

  /// Get friendly name for a hash
  String? getFriendlyName(String hash) {
    return hashNameMapping.nameFromHash(hash);
  }

  Future<void> fetch() async {
    if (_isFetching) return;
    _isFetching = true;
    error = null;
    notifyListeners();

    try {
      final saved = await clientSettings.getValue(HashNameMappingSetting());
      hashNameMapping = HashNameMappingSetting(newValue: saved.value);
      entries = await rpc.listBitNames();
      initialized = true;
    } catch (err) {
      error = 'Could not load Bitnames: $err';
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    rpc.removeListener(fetch);
    super.dispose();
  }
}
