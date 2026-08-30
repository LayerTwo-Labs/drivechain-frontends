import 'dart:async';

import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'mocks/api_mock.dart';

/// Holds each metadata read open, so a test can order two of them.
class _GatedWallet extends MockWalletAPI {
  final List<Completer<Map<String, UTXOMetadata>>> reads = [];

  @override
  Future<Map<String, UTXOMetadata>> getUTXOMetadata(List<String> outpoints) {
    final completer = Completer<Map<String, UTXOMetadata>>();
    reads.add(completer);
    return completer.future;
  }
}

class _GatedBitwindow extends MockAPI {
  final _GatedWallet gatedWallet = _GatedWallet();

  _GatedBitwindow() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  @override
  WalletAPI get wallet => gatedWallet;
}

void main() {
  late _GatedBitwindow bitwindow;
  late CoinSelectionProvider provider;

  setUp(() async {
    await GetIt.I.reset();
    bitwindow = _GatedBitwindow();
    GetIt.I.registerSingleton<Logger>(Logger());
    GetIt.I.registerSingleton<BitwindowRPC>(bitwindow);
    provider = CoinSelectionProvider();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  // A read already in flight may have started before the caller's write, so
  // joining it would install metadata from before that write.
  test('refresh waits for the read in flight and then reads again', () async {
    // The constructor starts the first read. It stays open.
    expect(bitwindow.gatedWallet.reads, hasLength(1));

    var done = false;
    unawaited(provider.refresh().then((_) => done = true));
    await Future<void>.delayed(Duration.zero);

    expect(done, isFalse, reason: 'refresh waits for the open read');
    expect(bitwindow.gatedWallet.reads, hasLength(1), reason: 'refresh starts no second read yet');

    bitwindow.gatedWallet.reads[0].complete({});
    await Future<void>.delayed(Duration.zero);

    expect(bitwindow.gatedWallet.reads, hasLength(2), reason: 'refresh starts its own read');
    expect(done, isFalse);

    bitwindow.gatedWallet.reads[1].complete({});
    await Future<void>.delayed(Duration.zero);

    expect(done, isTrue);
  });

  // A caller uses refresh as a barrier after a write. A read that failed
  // leaves the cache stale, so the caller must not go on believing it fresh.
  test('refresh throws when the read fails', () async {
    bitwindow.gatedWallet.reads[0].complete({});
    await Future<void>.delayed(Duration.zero);

    final pending = provider.refresh();
    await Future<void>.delayed(Duration.zero);
    bitwindow.gatedWallet.reads.last.completeError(Exception('the database is closed'));

    await expectLater(pending, throwsA(isA<Exception>()));
  });

  test('fetch stays quiet when the read fails', () async {
    bitwindow.gatedWallet.reads[0].complete({});
    await Future<void>.delayed(Duration.zero);

    final pending = provider.fetch();
    await Future<void>.delayed(Duration.zero);
    bitwindow.gatedWallet.reads.last.completeError(Exception('the database is closed'));

    await pending;
    expect(provider.error, contains('the database is closed'));
  });

  test('fetch joins the read in flight instead of starting another', () async {
    expect(bitwindow.gatedWallet.reads, hasLength(1));

    unawaited(provider.fetch());
    await Future<void>.delayed(Duration.zero);

    expect(bitwindow.gatedWallet.reads, hasLength(1));

    bitwindow.gatedWallet.reads[0].complete({});
    await Future<void>.delayed(Duration.zero);
  });
}
