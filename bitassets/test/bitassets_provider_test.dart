import 'dart:convert';

import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/providers/sync_provider.dart';
import 'package:sidechain_core/rpcs/bitassets_rpc.dart';
import 'package:sidechain_core/rpcs/thunder_utxo.dart';
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

  // The release before this one wrote the flag to the shared store.
  test('an install of the last release keeps the assets it holds', () async {
    final mine = blake3Hex(utf8.encode('SharedAsset'));
    await store.setString(
      HashNameMappingSetting().key,
      jsonEncode({
        mine: {'name': 'SharedAsset', 'isMine': true},
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

  // A node that receives an asset holds a coin of it, and never a setting that
  // says the user registered the asset.
  test('an asset another node sends reads as held, with its amount', () async {
    final hash = blake3Hex(utf8.encode('SentAsset'));
    rpc.assets = [BitAssetEntry(sequenceID: 1, hash: hash, details: BitAssetDetails())];
    rpc.utxos = [assetCoin(hash, 4000000), assetCoin(hash, 3000000)];

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(provider.ownedHashes, contains(hash));
    expect(provider.ownedAmounts[hash], 7000000);
  });

  test('an asset the wallet registered stays held with no coin of it', () async {
    final hash = blake3Hex(utf8.encode('RegisteredAsset'));
    rpc.assets = [BitAssetEntry(sequenceID: 1, hash: hash, details: BitAssetDetails())];
    await appSettings.setValue(OwnedBitAssetsSetting(newValue: [hash]));

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(provider.ownedHashes, contains(hash));
    expect(provider.ownedAmounts[hash], isNull);
  });

  // A coin of a received asset must never reach the settings. The asset would
  // stay in the list with a zero amount after the user sends the coin away.
  test('a received asset never joins the registered assets', () async {
    final received = blake3Hex(utf8.encode('ReceivedAsset'));
    rpc.utxos = [assetCoin(received, 10)];

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await provider.saveHashNameMapping('MyAsset', isMine: true);

    final saved = await appSettings.getValue(OwnedBitAssetsSetting());
    expect(saved.value, [blake3Hex(utf8.encode('MyAsset'))]);
    expect(provider.ownedHashes, contains(received));
  });

  test('a new block reads the coins of the wallet again', () async {
    final hash = blake3Hex(utf8.encode('MinedAsset'));
    final sync = SyncProvider(startTimer: false);
    GetIt.I.registerSingleton<SyncProvider>(sync);
    rpc.assets = [BitAssetEntry(sequenceID: 1, hash: hash, details: BitAssetDetails())];

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(provider.ownedHashes, isEmpty);

    rpc.utxos = [assetCoin(hash, 250)];
    sync.maybeFireNewBlock(1);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(provider.ownedAmounts[hash], 250);
  });

  test('a failed coin read keeps the assets of the last read', () async {
    final hash = blake3Hex(utf8.encode('HeldAsset'));
    rpc.assets = [BitAssetEntry(sequenceID: 1, hash: hash, details: BitAssetDetails())];
    rpc.utxos = [assetCoin(hash, 100)];

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(provider.ownedHashes, contains(hash));

    rpc.utxoError = 'node unavailable';
    await provider.fetch();

    expect(provider.ownedHashes, contains(hash));
    expect(provider.ownedAmounts[hash], 100);
  });

  // The node starts with the app, so the first coin read often fails.
  test('a failed first coin read keeps the retry timer', () async {
    rpc.assets = [BitAssetEntry(sequenceID: 1, hash: 'aa', details: BitAssetDetails())];
    rpc.utxoError = 'node unavailable';

    final provider = BitAssetsProvider();
    addTearDown(provider.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(provider.initialized, isTrue);
    expect(provider.walletRead, isFalse);

    rpc.utxoError = null;
    await provider.fetch();

    expect(provider.walletRead, isTrue);
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
  List<SidechainUTXO> utxos = [];
  String? utxoError;

  @override
  Future<List<BitAssetEntry>> listBitAssets() async => assets;

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    final error = utxoError;
    if (error != null) {
      throw Exception(error);
    }
    return utxos;
  }
}

BitAssetsUTXO assetCoin(String hash, int amount) => BitAssetsUTXO.fromJson({
  'outpoint': {
    'Regular': {'txid': 'aa', 'vout': 0},
  },
  'output': {
    'address': 'mine',
    'content': {
      'BitAsset': [hash, amount],
    },
  },
});
