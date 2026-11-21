import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/services/boot_snapshot.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _Router extends Fake implements RootStackRouter {}

class _DownTransport implements connect.Transport {
  @override
  Future<connect.UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    I input, [
    connect.CallOptions? options,
  ]) => throw connect.ConnectException(connect.Code.unavailable, 'down');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletMetadata _wallet(String id) => WalletMetadata(
  id: id,
  name: 'Wallet $id',
  gradient: WalletGradient.fromWalletId(id),
  createdAt: DateTime.utc(2026, 1, 2),
  lastUsed: DateTime.utc(2026, 1, 2),
);

BootSnapshot _snapshot({
  wmpb.NodeMode mode = wmpb.NodeMode.NODE_MODE_FULL,
  List<WalletMetadata>? wallets,
  bool encrypted = false,
}) => BootSnapshot(
  config: GetBitcoinConfigResponse(
    network: 'regtest',
    rpcPort: 18443,
    configContent: 'rpcpassword=secret',
    rpcUser: '__cookie__',
    rpcPassword: 'secret',
  ),
  networks: [NetworkOption(id: 'regtest', network: 'regtest', displayName: 'Regtest', isCurrent: true)],
  nodeMode: wmpb.GetNodeModeResponse(mode: mode, lightModeAvailable: true),
  wallets: wallets ?? [_wallet('a')],
  activeWalletId: 'a',
  encrypted: encrypted,
);

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('boot_snapshot_test');
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
  });

  tearDown(() async {
    NetworkScopedRegistry.clearRegistrations();
    await GetIt.I.reset();
    await dir.delete(recursive: true);
  });

  test('a saved snapshot reads back without the conf text and credentials', () {
    BootSnapshot.file(dir).writeAsStringSync(_snapshot().encode());

    final read = BootSnapshot.read(dir)!;
    expect(read.config.network, 'regtest');
    expect(read.config.configContent, isEmpty);
    expect(read.config.rpcUser, isEmpty);
    expect(read.config.rpcPassword, isEmpty);
    expect(read.config.rpcPort, 18443);
    expect(read.networks.single.displayName, 'Regtest');
    expect(read.nodeMode.mode, wmpb.NodeMode.NODE_MODE_FULL);
    expect(read.wallets.single.name, 'Wallet a');
    expect(read.activeWalletId, 'a');
    expect(read.encode(), _snapshot().encode());
  });

  test('no file reads as no snapshot', () {
    expect(BootSnapshot.read(dir), isNull);
  });

  test('only a picked mode and a wallet with no password show the root at once', () {
    expect(_snapshot().showsRootAtOnce, isTrue);
    expect(_snapshot(encrypted: true).showsRootAtOnce, isFalse);
    expect(_snapshot(wallets: []).showsRootAtOnce, isFalse);
    expect(_snapshot(mode: wmpb.NodeMode.NODE_MODE_UNSPECIFIED).showsRootAtOnce, isFalse);
  });

  test('the writer saves only the backend state, and only when it changes', () async {
    final conf = await BitcoinConfProvider.withTransport(_Router(), _DownTransport());
    final nodeMode = NodeModeProvider();
    final walletReader = WalletReaderProvider(dir);
    final writer = BootSnapshotWriter(
      appDir: dir,
      conf: conf,
      nodeMode: nodeMode,
      walletReader: walletReader,
      log: GetIt.I.get<Logger>(),
    )..start();

    final unlocked = wmpb.WatchWalletDataResponse(
      state: wmpb.WalletState.WALLET_STATE_UNLOCKED,
      activeWalletId: 'a',
      wallets: [wmpb.WalletMetadata(id: 'a', name: 'Wallet a', createdAt: '2026-01-02T00:00:00.000Z')],
    );
    walletReader.applyWatchFrame(unlocked);
    await writer.flush();
    expect(BootSnapshot.file(dir).existsSync(), isFalse);

    conf.backendConfig = GetBitcoinConfigResponse(network: 'regtest');
    nodeMode.restore(wmpb.GetNodeModeResponse(mode: wmpb.NodeMode.NODE_MODE_FULL));
    nodeMode.loaded = true;
    walletReader.applyWatchFrame(unlocked.deepCopy()..encrypted = true);
    await writer.flush();

    final saved = BootSnapshot.read(dir)!;
    expect(saved.wallets.single.id, 'a');
    expect(saved.encrypted, isTrue);
    expect(saved.showsRootAtOnce, isFalse);

    BootSnapshot.file(dir).deleteSync();
    walletReader.applyWatchFrame(
      unlocked.deepCopy()
        ..encrypted = true
        ..confirmedSats = 5,
    );
    await writer.flush();
    expect(BootSnapshot.file(dir).existsSync(), isFalse);
    conf.dispose();
  });
}
