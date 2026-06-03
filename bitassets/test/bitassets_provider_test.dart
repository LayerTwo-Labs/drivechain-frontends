import 'dart:convert';

import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';
import 'package:sail_ui/settings/client_settings.dart';
import 'package:sail_ui/settings/hash_plaintext_settings.dart';
import 'package:thirds/blake3.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'mocks/storage_mock.dart';

void main() {
  late MockStore store;
  late ClientSettings settings;
  late _AssetListBitAssetsRPC rpc;

  setUp(() async {
    await GetIt.I.reset();

    store = MockStore();
    settings = ClientSettings(
      store: store,
      log: Logger(printer: PrettyPrinter(methodCount: 0)),
    );
    rpc = _AssetListBitAssetsRPC();

    GetIt.I.registerSingleton<ClientSettings>(settings);
    GetIt.I.registerSingleton<BitAssetsRPC>(rpc);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('hydrates persisted owned asset mappings on startup fetch', () async {
    final name = 'RebootAsset';
    final hash = blake3Hex(utf8.encode(name));
    rpc.assets = [
      BitAssetEntry(
        sequenceID: 1,
        hash: hash,
        details: BitAssetDetails(),
      ),
    ];
    await settings.setValue(
      HashNameMappingSetting(
        newValue: {
          hash: HashMapping(name: name, isMine: true),
        },
      ),
    );

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(provider.entries.single.hash, hash);
    expect(provider.hashNameMapping.value[hash]?.name, name);
    expect(provider.hashNameMapping.value[hash]?.isMine, isTrue);
  });

  test('saveHashNameMapping merges with persisted mappings', () async {
    final existingName = 'ExistingAsset';
    final existingHash = blake3Hex(utf8.encode(existingName));
    await settings.setValue(
      HashNameMappingSetting(
        newValue: {
          existingHash: HashMapping(name: existingName, isMine: true),
        },
      ),
    );

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await provider.saveHashNameMapping('NewAsset', isMine: true);

    final loaded = await settings.getValue(HashNameMappingSetting());
    final newHash = blake3Hex(utf8.encode('NewAsset'));
    expect(loaded.value[existingHash]?.isMine, isTrue);
    expect(loaded.value[newHash]?.isMine, isTrue);
  });
}

class _AssetListBitAssetsRPC extends MockBitAssetsRPC {
  List<BitAssetEntry> assets = [];

  @override
  Future<List<BitAssetEntry>> listBitAssets() async => assets;
}
