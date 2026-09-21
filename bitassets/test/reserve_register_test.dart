import 'dart:convert';

import 'package:bitassets/pages/tabs/reserve_register_page.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thirds/blake3.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'mocks/storage_mock.dart';

class _ListBitAssetsRPC extends MockBitAssetsRPC {
  List<BitAssetEntry> assets = [];
  final List<String> reserved = [];
  bool failList = false;
  int listCalls = 0;

  @override
  Future<List<BitAssetEntry>> listBitAssets() async {
    listCalls++;
    if (failList) {
      throw Exception('node unavailable');
    }
    return assets;
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async => [];

  @override
  Future<String> reserveBitAsset(String assetId) async {
    reserved.add(assetId);
    return 'txid';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late BitwindowClientSettings settings;
  late _ListBitAssetsRPC rpc;

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger();
    settings = BitwindowClientSettings(store: MockStore(), log: log);
    rpc = _ListBitAssetsRPC();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<BitwindowClientSettings>(settings);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    GetIt.I.registerSingleton<BitAssetsRPC>(rpc);
    GetIt.I.registerSingleton<BitAssetsProvider>(BitAssetsProvider());
    GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('a search for the plaintext of an unnamed asset saves its name', () async {
    final hash = blake3Hex(utf8.encode('ECX'));
    rpc.assets = [BitAssetEntry(sequenceID: 0, hash: hash, details: BitAssetDetails())];
    final model = BitAssetsViewModel();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    model.searchController.text = 'ECX';

    expect(model.entries.single.hash, hash);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final saved = await settings.getValue(HashNameMappingSetting());
    expect(saved.value[hash]?.name, 'ECX');
  });

  // A save notifies the view, and the rebuild reads the list again.
  test('a search saves the name of an asset one time', () async {
    final hash = blake3Hex(utf8.encode('ECX'));
    rpc.assets = [BitAssetEntry(sequenceID: 0, hash: hash, details: BitAssetDetails())];
    final model = BitAssetsViewModel();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    rpc.failList = true;
    rpc.listCalls = 0;

    model.searchController.text = 'ECX';
    model.entries;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    model.entries;
    model.entries;
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(rpc.listCalls, 1);
  });

  test('a search matches the saved name of an asset', () async {
    final hash = blake3Hex(utf8.encode('Gold'));
    rpc.assets = [BitAssetEntry(sequenceID: 0, hash: hash, plaintextName: 'Gold', details: BitAssetDetails())];
    final model = BitAssetsViewModel();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    model.searchController.text = 'gol';

    expect(model.entries.single.hash, hash);
  });

  // The node reserves a name with no input and no fee.
  testWidgets('a wallet with no coins can reserve a name', (tester) async {
    final model = BitAssetsViewModel();
    model.reserveNameController.text = 'NewAsset';

    await tester.pumpWidget(const SizedBox.shrink());
    await model.reserveBitname(tester.element(find.byType(SizedBox)));

    expect(model.reserveError, isNull);
    expect(rpc.reserved, ['NewAsset']);
  });
}
