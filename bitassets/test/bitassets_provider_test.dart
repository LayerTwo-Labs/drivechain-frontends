import 'dart:convert';

import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/rpcs/bitassets_rpc.dart';
import 'package:sidechain_core/settings/client_settings.dart';
import 'package:sidechain_core/settings/hash_plaintext_settings.dart';
import 'package:thirds/blake3.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'mocks/storage_mock.dart';

void main() {
  late MockStore store;
  late BitwindowClientSettings settings;
  late ClientSettings appSettings;
  late _AssetListBitAssetsRPC rpc;

  setUp(() async {
    await GetIt.I.reset();

    final log = Logger(printer: PrettyPrinter(methodCount: 0));
    store = MockStore();
    settings = BitwindowClientSettings(store: store, log: log);
    appSettings = ClientSettings(store: MockStore(), log: log);
    rpc = _AssetListBitAssetsRPC();

    GetIt.I.registerSingleton<BitwindowClientSettings>(settings);
    GetIt.I.registerSingleton<ClientSettings>(appSettings);
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
      HashNameMappingSetting(newValue: {hash: HashMapping(name: name)}),
    );
    await appSettings.setValue(OwnedBitAssetsSetting(newValue: [hash]));

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(provider.entries.single.hash, hash);
    expect(provider.hashNameMapping.value[hash]?.name, name);
    expect(provider.ownedHashes, contains(hash));
  });

  test('saveHashNameMapping merges with persisted mappings', () async {
    final existingName = 'ExistingAsset';
    final existingHash = blake3Hex(utf8.encode(existingName));
    await settings.setValue(
      HashNameMappingSetting(newValue: {existingHash: HashMapping(name: existingName)}),
    );

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await provider.saveHashNameMapping('NewAsset', isMine: true);

    final loaded = await settings.getValue(HashNameMappingSetting());
    final newHash = blake3Hex(utf8.encode('NewAsset'));
    expect(loaded.value[existingHash]?.name, existingName);
    expect(loaded.value[newHash]?.name, 'NewAsset');
    expect(provider.ownedHashes, contains(newHash));
  });

  // An older install kept ownership in the name map, in this app's own store.
  test('an older install keeps the assets it holds', () async {
    final mine = blake3Hex(utf8.encode('MineAsset'));
    final other = blake3Hex(utf8.encode('OtherAsset'));
    await appSettings.store.setString(
      HashNameMappingSetting().key,
      jsonEncode({
        mine: {'name': 'MineAsset', 'isMine': true},
        other: {'name': 'OtherAsset', 'isMine': false},
      }),
    );

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await provider.migrateOwnedHashes();

    final saved = await appSettings.getValue(OwnedBitAssetsSetting());
    expect(saved.value, [mine]);
  });

  test('a second start keeps the owned set the user has', () async {
    await appSettings.setValue(OwnedBitAssetsSetting(newValue: ['kept']));
    await appSettings.store.setString(
      HashNameMappingSetting().key,
      jsonEncode({
        'legacy': {'name': 'LegacyAsset', 'isMine': true},
      }),
    );

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await provider.migrateOwnedHashes();

    final saved = await appSettings.getValue(OwnedBitAssetsSetting());
    expect(saved.value, ['kept']);
  });

  test('a broken legacy map gives no owned hash', () {
    expect(ownedFromLegacyMapping(null), isEmpty);
    expect(ownedFromLegacyMapping('not json'), isEmpty);
    expect(ownedFromLegacyMapping('{}'), isEmpty);
  });

  // The two chains hash the same plaintext to the same value, so a BitName the
  // wallet holds must not mark a BitAsset of that name as held.
  test('a name held on another chain does not mark the asset as held', () async {
    final hash = blake3Hex(utf8.encode('foo'));
    rpc.assets = [BitAssetEntry(sequenceID: 1, hash: hash, details: BitAssetDetails())];
    await settings.setValue(
      HashNameMappingSetting(newValue: {hash: HashMapping(name: 'foo')}),
    );

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(provider.hashNameMapping.value[hash]?.name, 'foo');
    expect(provider.ownedHashes, isEmpty);
  });
}

class _AssetListBitAssetsRPC extends MockBitAssetsRPC {
  List<BitAssetEntry> assets = [];

  @override
  Future<List<BitAssetEntry>> listBitAssets() async => assets;
}
