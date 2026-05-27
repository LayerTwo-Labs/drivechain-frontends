import 'dart:io';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

class _FakeWalletRPC extends OrchestratorWalletRPC {
  _FakeWalletRPC()
    : super.fromTransports(
        unary: connect.Transport(
          baseUrl: 'http://127.0.0.1:1',
          codec: const ProtoCodec(),
          httpClient: createHttpClient(),
        ),
        stream: connect.Transport(
          baseUrl: 'http://127.0.0.1:1',
          codec: const ProtoCodec(),
          httpClient: createHttpClient(),
        ),
      );

  int unlockCalls = 0;
  int listCalls = 0;
  int statusCalls = 0;
  List<wmpb.WalletMetadata> walletsToReturn = const [];
  String activeWalletIdToReturn = '';
  bool hasWalletToReturn = true;

  @override
  Future<wmpb.UnlockWalletResponse> unlockWallet(String password) async {
    unlockCalls++;
    return wmpb.UnlockWalletResponse();
  }

  @override
  Future<wmpb.ListWalletsResponse> listWallets() async {
    listCalls++;
    return wmpb.ListWalletsResponse(
      wallets: walletsToReturn,
      activeWalletId: activeWalletIdToReturn,
    );
  }

  @override
  Future<wmpb.GetWalletStatusResponse> getWalletStatus() async {
    statusCalls++;
    return wmpb.GetWalletStatusResponse(hasWallet: hasWalletToReturn);
  }
}

class _FakeOrchestratorRPC extends OrchestratorRPC {
  _FakeOrchestratorRPC(this._fake) : super(host: '127.0.0.1', port: 1);

  final _FakeWalletRPC _fake;

  @override
  // ignore: overridden_fields
  late final OrchestratorWalletRPC wallet = _fake;
}

WalletData _wallet({
  required String id,
  required BinaryType type,
  String l1 = '',
  List<SidechainWallet> sidechains = const [],
  String? walletTypeRaw,
  String masterMnemonic = '',
}) {
  return WalletData(
    version: 1,
    master: MasterWallet(mnemonic: masterMnemonic, seedHex: '', masterKey: '', chainCode: ''),
    l1: L1Wallet(mnemonic: l1),
    sidechains: sidechains,
    id: id,
    name: id,
    gradient: WalletGradient.fromWalletId(id),
    createdAt: DateTime.utc(2026, 1, 1),
    walletType: type,
    walletTypeRaw: walletTypeRaw ?? type.name,
  );
}

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    }
  });

  test('getL1Mnemonic reads from enforcer wallet, not the active one', () {
    final provider = WalletReaderProvider(Directory.systemTemp);
    provider.wallets = [
      _wallet(id: 'enf', type: BinaryType.BINARY_TYPE_ENFORCER, l1: 'enforcer-l1-mnemonic'),
      _wallet(id: 'core', type: BinaryType.BINARY_TYPE_BITCOIND, l1: 'core-l1-mnemonic'),
    ];
    provider.activeWalletId = 'core';

    expect(provider.activeWallet?.id, 'core');
    expect(provider.enforcerWallet?.id, 'enf');
    expect(provider.getL1Mnemonic(), 'enforcer-l1-mnemonic');
  });

  test('getSidechainMnemonic reads from enforcer wallet, not the active one', () {
    final provider = WalletReaderProvider(Directory.systemTemp);
    provider.wallets = [
      _wallet(
        id: 'enf',
        type: BinaryType.BINARY_TYPE_ENFORCER,
        sidechains: [
          SidechainWallet(slot: 9, name: 'Thunder', mnemonic: 'thunder-starter'),
          SidechainWallet(slot: 5, name: 'BitNames', mnemonic: 'bitnames-starter'),
        ],
      ),
      _wallet(
        id: 'core',
        type: BinaryType.BINARY_TYPE_BITCOIND,
        sidechains: [
          SidechainWallet(slot: 9, name: 'Thunder', mnemonic: 'core-thunder'),
        ],
      ),
    ];
    provider.activeWalletId = 'core';

    expect(provider.getSidechainMnemonic(9), 'thunder-starter');
    expect(provider.getSidechainMnemonic(5), 'bitnames-starter');
    expect(provider.getSidechainMnemonic(99), isNull);
  });

  test('getL1Mnemonic returns null when enforcer wallet absent', () {
    final provider = WalletReaderProvider(Directory.systemTemp);
    provider.wallets = [
      _wallet(id: 'core', type: BinaryType.BINARY_TYPE_BITCOIND, l1: 'core-l1'),
    ];
    provider.activeWalletId = 'core';

    expect(provider.enforcerWallet, isNull);
    expect(provider.getL1Mnemonic(), isNull);
  });

  test('unlockWallet seeds wallets and notifies listeners on success', () async {
    // Regression for #1737: PasswordGuard reads `isWalletUnlocked`
    // (wallets.isNotEmpty) when UnlockWalletRoute pops. Before the fix
    // unlockWallet only awaited the RPC and never repopulated state, so
    // the watch-stream lag left wallets empty and the post-pop navigation
    // was rejected — user landed on a blank screen.
    final fake = _FakeWalletRPC()
      ..walletsToReturn = [
        wmpb.WalletMetadata(id: 'core-1', name: 'Core', walletType: 'bitcoind'),
      ]
      ..activeWalletIdToReturn = 'core-1';
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestratorRPC(fake));
    addTearDown(() => GetIt.I.unregister<OrchestratorRPC>());

    final provider = WalletReaderProvider(Directory.systemTemp);
    expect(provider.isWalletUnlocked, isFalse);

    var notifications = 0;
    provider.addListener(() => notifications++);

    final ok = await provider.unlockWallet('hunter2');

    expect(ok, isTrue);
    expect(fake.unlockCalls, 1);
    expect(fake.listCalls, 1, reason: 'must eagerly seed via listWallets');
    expect(fake.statusCalls, 1);
    expect(provider.wallets, hasLength(1));
    expect(provider.activeWalletId, 'core-1');
    expect(provider.isWalletUnlocked, isTrue, reason: 'PasswordGuard checks this — must be true after unlock');
    expect(notifications, greaterThanOrEqualTo(1), reason: 'listeners must fire so guards re-evaluate');
    expect(provider.unlockedPassword, 'hunter2');
  });

  test('unlockWallet does not report success until wallet state is loaded', () async {
    final fake = _FakeWalletRPC();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestratorRPC(fake));
    addTearDown(() => GetIt.I.unregister<OrchestratorRPC>());

    final provider = WalletReaderProvider(Directory.systemTemp)..unlockStateWait = const Duration(milliseconds: 1);

    final ok = await provider.unlockWallet('hunter2');

    expect(ok, isFalse);
    expect(fake.unlockCalls, 1);
    expect(fake.listCalls, 1);
    expect(fake.statusCalls, 1);
    expect(provider.isWalletUnlocked, isFalse);
    expect(provider.wallets, isEmpty);
    expect(provider.unlockedPassword, isNull);
  });

  test('walletBinaryTypeFromProto maps orchestrator wallet_type strings', () {
    expect(walletBinaryTypeFromProto('enforcer'), BinaryType.BINARY_TYPE_ENFORCER);
    expect(walletBinaryTypeFromProto('bitcoinCore'), BinaryType.BINARY_TYPE_BITCOIND);
    expect(walletBinaryTypeFromProto('bitcoind'), BinaryType.BINARY_TYPE_BITCOIND);
    expect(walletBinaryTypeFromProto('watchOnly'), BinaryType.BINARY_TYPE_BITCOIND);
    expect(walletBinaryTypeFromProto('unknown'), BinaryType.BINARY_TYPE_BITCOIND);
  });

  test('isWatchOnly is driven by raw proto walletType, not BinaryType', () {
    // The proto's "watchOnly" string has no BinaryType counterpart, so the
    // enum field gets a junk fallback. The raw string is the only signal
    // the receive-tab can trust to swap the indefinite BIP47 spinner for
    // the "not available" message.
    final watchOnly = _wallet(
      id: 'wo',
      type: BinaryType.BINARY_TYPE_ENFORCER, // junk fallback the proto parser produces
      walletTypeRaw: 'watchOnly',
    );
    final hot = _wallet(
      id: 'hot',
      type: BinaryType.BINARY_TYPE_ENFORCER,
      walletTypeRaw: 'enforcer',
    );
    expect(watchOnly.isWatchOnly, isTrue);
    expect(hot.isWatchOnly, isFalse);
  });
}
