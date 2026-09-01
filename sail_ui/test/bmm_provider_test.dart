import 'dart:async';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;
import 'package:sail_ui/sail_ui.dart';

// Bidding runs in the backend. The provider only reflects what the stream says
// and turns bidding on and off, so that is all these cover.

class _FakeBmmRPC implements OrchestratorBmmRPC {
  final _controller = StreamController<bmmpb.WatchResponse>.broadcast();
  int startCalls = 0;
  int stopCalls = 0;
  int manualBids = 0;
  int? lastMaxBid;
  String? lastWalletId;
  Object? throwOnStart;

  void emit(bmmpb.WatchResponse state) => _controller.add(state);

  @override
  Stream<bmmpb.WatchResponse> watch(BinaryType sidechain) => _controller.stream;

  @override
  Future<void> start({
    required BinaryType sidechain,
    required int maxBidSats,
    String? walletId,
  }) async {
    if (throwOnStart != null) {
      throw throwOnStart!;
    }
    startCalls++;
    lastMaxBid = maxBidSats;
    lastWalletId = walletId;
  }

  @override
  Future<void> stop(BinaryType sidechain) async => stopCalls++;

  @override
  Future<bmmpb.CreateBidResponse> createBid({
    required BinaryType sidechain,
    required int bidSats,
    String? walletId,
    String? replaceTxid,
  }) async {
    manualBids++;
    return bmmpb.CreateBidResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSidechainRPC implements SidechainRPC {
  @override
  BinaryType binaryType = BinaryType.BINARY_TYPE_THUNDER;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletData _wallet(
  String id,
  String name, {
  BinaryType type = BinaryType.BINARY_TYPE_BITCOIND,
  bool watchOnly = false,
}) {
  return WalletData(
    isWatchOnly: watchOnly,
    version: 1,
    master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
    l1: L1Wallet(mnemonic: ''),
    sidechains: const [],
    id: id,
    name: name,
    gradient: WalletGradient.fromWalletId(id),
    createdAt: DateTime(2026),
    walletType: type,
  );
}

bmmpb.Bid _bid({
  required String txid,
  required int sats,
  bool ours = false,
  String state = 'live',
  String replacedBy = '',
  String error = '',
}) {
  return bmmpb.Bid(
    txid: txid,
    criticalHash: 'h-$txid',
    bidSats: Int64(sats),
    isOurs: ours,
    state: state,
    replacedByTxid: replacedBy,
    error: error,
  );
}

void main() {
  late _FakeBmmRPC bmm;

  WalletReaderProvider walletsOf(String activeId) => WalletReaderProvider(Directory.systemTemp)
    ..wallets = [_wallet('main-1', 'Main wallet'), _wallet('spare-1', 'Spare wallet')]
    ..activeWalletId = activeId;

  BMMProvider newProvider({WalletReaderProvider? walletReader}) => BMMProvider(
    sidechainRPC: _FakeSidechainRPC(),
    bmm: bmm,
    walletReader: walletReader ?? walletsOf('main-1'),
    logger: Logger(level: Level.off),
  );

  setUp(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    }
    bmm = _FakeBmmRPC();
  });

  // Core names the floor, so the user sets only the ceiling.
  test('start passes the ceiling the user set', () async {
    final provider = newProvider();
    provider.setMaxBidAmount(0.0005);

    await provider.startBidding();

    expect(bmm.startCalls, 1);
    expect(bmm.lastMaxBid, 50000);
  });

  test('bids spend from the picked wallet, and the active wallet stays put', () async {
    final walletReader = walletsOf('main-1');
    final provider = newProvider(walletReader: walletReader);

    await provider.startBidding();
    expect(bmm.lastWalletId, 'main-1');

    provider.setFundingWalletId('spare-1');
    await provider.startBidding();

    expect(bmm.lastWalletId, 'spare-1');
    expect(walletReader.activeWalletId, 'main-1');
  });

  // A wallet that cannot cover the top bid is worth a warning, not a block.
  test('a balance under the max bid reads as too low', () async {
    final provider = newProvider(walletReader: walletsOf('main-1'));
    provider.setMaxBidAmount(0.0002);

    provider.fundingBalanceSats = 1200;
    expect(provider.fundingBalanceTooLow, isTrue);

    provider.fundingBalanceSats = 40000;
    expect(provider.fundingBalanceTooLow, isFalse);
  });

  // The enforcer takes the M8 as an OP_RETURN payload, so it funds a bid like
  // any other wallet.
  test('the picker offers an enforcer wallet', () async {
    final walletReader = WalletReaderProvider(Directory.systemTemp)
      ..wallets = [
        _wallet('enforcer-1', 'Enforcer', type: BinaryType.BINARY_TYPE_ENFORCER),
        _wallet('core-1', 'Savings'),
      ]
      ..activeWalletId = 'core-1';
    final provider = newProvider(walletReader: walletReader);

    expect(provider.fundingWalletId, 'core-1');

    provider.setFundingWalletId('enforcer-1');
    expect(provider.fundingWalletId, 'enforcer-1');
  });

  // An empty wallet id falls back to the active wallet in the backend, so a
  // bid with no funding wallet must not be sent at all.
  test('bidding stops when no wallet can fund it', () async {
    final walletReader = WalletReaderProvider(Directory.systemTemp)
      ..wallets = [_wallet('watch-1', 'Watcher', watchOnly: true)]
      ..activeWalletId = 'watch-1';
    final provider = newProvider(walletReader: walletReader);

    await provider.startBidding();
    await provider.bidManually(10000);

    expect(bmm.startCalls, 0);
    expect(bmm.manualBids, 0);
    expect(provider.error, BMMProvider.noFundingWallet);
  });

  test('the running loop reports the wallet it spends from', () async {
    final provider = newProvider(walletReader: walletsOf('main-1'));

    bmm.emit(bmmpb.WatchResponse(running: true, walletId: 'spare-1'));
    await Future<void>.delayed(Duration.zero);

    expect(provider.fundingWalletId, 'spare-1');
  });

  test('stop turns bidding off', () async {
    final provider = newProvider();
    await provider.stopBidding();
    expect(bmm.stopCalls, 1);
  });

  test('a failed start surfaces the error instead of throwing', () async {
    final provider = newProvider();
    bmm.throwOnStart = Exception('no wallet');

    await provider.startBidding();

    expect(provider.error, contains('no wallet'));
    expect(bmm.startCalls, 0);
  });

  test('state comes from the stream, not from local bookkeeping', () async {
    final provider = newProvider();
    expect(provider.running, isFalse);

    bmm.emit(
      bmmpb.WatchResponse(
        running: true,
        current: bmmpb.Round(prevMainHash: 'tip-1', blockWorthSats: Int64(24800)),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.running, isTrue);
    expect(provider.current?.prevMainHash, 'tip-1');
  });

  test('current bids merge ours and others, highest first', () async {
    final provider = newProvider();

    bmm.emit(
      bmmpb.WatchResponse(
        current: bmmpb.Round(
          prevMainHash: 'tip-1',
          ourBids: [_bid(txid: 'mine', sats: 22000, ours: true)],
          otherBids: [_bid(txid: 'rival', sats: 18000)],
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final bids = provider.currentBids;
    expect(bids.map((b) => b.txid), ['mine', 'rival']);
    expect(bids.first.isOurs, isTrue);
  });

  // A raise replaces our earlier bid, so only the latest one is live.
  test('liveBid is the bid that has not been replaced', () async {
    final provider = newProvider();

    bmm.emit(
      bmmpb.WatchResponse(
        current: bmmpb.Round(
          prevMainHash: 'tip-1',
          ourBids: [
            _bid(txid: 'first', sats: 10000, ours: true, state: 'replaced', replacedBy: 'second'),
            _bid(txid: 'second', sats: 13000, ours: true),
          ],
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.liveBid?.txid, 'second');
  });

  // The auto-bid loop runs in the backend, so a failure there reaches the user
  // only through the bid it records.
  test('a failed bid reports why it failed', () async {
    final provider = newProvider();

    expect(provider.lastBidError, isNull);

    bmm.emit(
      bmmpb.WatchResponse(
        current: bmmpb.Round(
          prevMainHash: 'tip-1',
          ourBids: [
            _bid(txid: 'first', sats: 10000, ours: true, state: 'failed', error: 'insufficient funds'),
            _bid(txid: 'second', sats: 13000, ours: true, state: 'failed', error: 'wallet is locked'),
          ],
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.lastBidError, 'wallet is locked');
  });

  // A retry that lands after a failed raise means bidding recovered, so the
  // old reason must leave the screen.
  test('a later live bid clears the failure', () async {
    final provider = newProvider();

    bmm.emit(
      bmmpb.WatchResponse(
        current: bmmpb.Round(
          prevMainHash: 'tip-1',
          ourBids: [
            _bid(txid: 'first', sats: 10000, ours: true, state: 'failed', error: 'insufficient funds'),
            _bid(txid: 'second', sats: 13000, ours: true),
          ],
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.lastBidError, isNull);
  });

  // A bid no miner took never confirmed, so it neither cost nor earned.
  test('profit only counts rounds that were won', () async {
    final provider = newProvider();

    bmm.emit(
      bmmpb.WatchResponse(
        history: [
          bmmpb.Round(prevMainHash: 'a', result: 'won', hasProfit: true, profitSats: Int64(2900)),
          bmmpb.Round(prevMainHash: 'b', result: 'lost'),
          bmmpb.Round(prevMainHash: 'c', result: 'skipped'),
        ],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(provider.totalProfitSats, 2900);
    expect(provider.wonCount, 1);
    expect(provider.lostCount, 1);
  });

  test('a manual bid goes straight to the backend', () async {
    final provider = newProvider();
    await provider.bidManually(15000);
    expect(bmm.manualBids, 1);
  });
}
