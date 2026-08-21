import 'dart:io';

import 'package:bitwindow/providers/psbt_draft_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/gen/walletpsbt/v1/walletpsbt.pb.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';

class _FlakyListAPI extends MockWalletPsbtAPI {
  bool working = false;

  @override
  Future<List<PsbtDraft>> listDrafts(String walletId) {
    if (!working) {
      throw WalletPsbtException('daemon is not up yet');
    }
    return super.listDrafts(walletId);
  }
}

class _FlakyAPI extends MockAPI {
  _FlakyAPI() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _FlakyListAPI _flakyWalletpsbt = _FlakyListAPI();

  @override
  _FlakyListAPI get walletpsbt => _flakyWalletpsbt;
}

class _SlowSaveAPI extends MockWalletPsbtAPI {
  Duration nextSaveDelay = Duration.zero;

  @override
  Future<PsbtDraft> saveDraft(PsbtDraft draft) async {
    final delay = nextSaveDelay;
    nextSaveDelay = Duration.zero;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return super.saveDraft(draft);
  }
}

class _SlowAPI extends MockAPI {
  _SlowAPI() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _SlowSaveAPI _slowWalletpsbt = _SlowSaveAPI();

  @override
  _SlowSaveAPI get walletpsbt => _slowWalletpsbt;
}

class _FakeWalletRPC implements OrchestratorWalletRPC {
  @override
  Future<wmpb.MultisigPsbtStatusResponse> multisigPsbtStatus({
    required String walletId,
    required String psbtBase64,
  }) async {
    return wmpb.MultisigPsbtStatusResponse(
      threshold: 2,
      signatures: 0,
      finalizable: false,
      cosignerSigned: [false, false, false],
    );
  }

  // A real combine merges signatures; the tests only track which blobs
  // took part, so the fake joins them.
  @override
  Future<String> combinePsbt({required List<String> psbtsBase64}) async {
    return psbtsBase64.toSet().join('+');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final _FakeWalletRPC wallet = _FakeWalletRPC();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestWalletReader extends WalletReaderProvider {
  _TestWalletReader() : super(Directory.systemTemp);

  void setActive(String? id) {
    activeWalletId = id;
    notifyListeners();
  }
}

void main() {
  late _TestWalletReader walletReader;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerLazySingleton<Logger>(() => Logger());
    GetIt.I.registerSingleton<BitwindowRPC>(MockAPI(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD));
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    walletReader = _TestWalletReader();
    GetIt.I.registerSingleton<WalletReaderProvider>(walletReader);
    walletReader.setActive('wallet-1');
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('a draft survives a provider reload', () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    final saved = await provider.create('cHNidP8B', walletId: 'wallet-1');
    expect(saved.id, isNotEmpty);

    final reloaded = PsbtDraftProvider();
    await reloaded.fetch();

    expect(reloaded.drafts, hasLength(1));
    expect(reloaded.drafts.first.id, saved.id);
    expect(reloaded.drafts.first.psbtBase64, 'cHNidP8B');
  });

  test('a network swap clears the drafts until the new network loads', () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    await provider.create('cHNidP8B', walletId: 'wallet-1');
    expect(provider.drafts, hasLength(1));

    // The wallet reader clears first in a swap; no wallet is active yet.
    walletReader.setActive(null);
    await provider.onNetworkChanged();

    expect(provider.drafts, isEmpty);
    expect(provider.statuses, isEmpty);

    // The reader reseeds the wallet before or after this clear — a reload
    // must find the drafts again either way.
    walletReader.setActive('wallet-1');
    await provider.fetch();
    expect(provider.drafts, hasLength(1));
  });

  test('a swap after the wallet reseed still reloads the drafts', () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    await provider.create('cHNidP8B', walletId: 'wallet-1');

    // The reader already reseeded the same wallet id, so it notifies no
    // more. The clear itself must reload.
    await provider.onNetworkChanged();

    expect(provider.drafts, hasLength(1));
  });

  test("two wallets never see each other's drafts", () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    await provider.create('draft-of-wallet-1', walletId: 'wallet-1');

    walletReader.setActive('wallet-2');
    await provider.fetch();
    expect(provider.drafts, isEmpty);

    await provider.create('draft-of-wallet-2', walletId: 'wallet-2');
    expect(provider.drafts, hasLength(1));
    expect(provider.drafts.first.psbtBase64, 'draft-of-wallet-2');

    walletReader.setActive('wallet-1');
    await provider.fetch();
    expect(provider.drafts, hasLength(1));
    expect(provider.drafts.first.psbtBase64, 'draft-of-wallet-1');
  });

  test('an updated PSBT merges into the draft in place', () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    final saved = await provider.create('before', walletId: 'wallet-1');

    await provider.updatePsbt(saved.id, 'after');

    expect(provider.drafts, hasLength(1));
    expect(provider.drafts.first.psbtBase64, 'before+after');
  });

  test('two overlapped signatures both survive', () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    final saved = await provider.create('base', walletId: 'wallet-1');

    // Both sign operations start from the same base PSBT; the second
    // write must merge, not overwrite the first signature.
    final first = provider.updatePsbt(saved.id, 'sig1');
    final second = provider.updatePsbt(saved.id, 'sig2');
    await Future.wait([first, second]);

    expect(provider.drafts.first.psbtBase64, contains('sig1'));
    expect(provider.drafts.first.psbtBase64, contains('sig2'));
  });

  test('a rename persists on the draft', () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    final saved = await provider.create('cHNidP8B', walletId: 'wallet-1');

    await provider.rename(saved.id, 'Rent for August');

    final reloaded = PsbtDraftProvider();
    await reloaded.fetch();
    expect(reloaded.drafts.first.label, 'Rent for August');
  });

  test('a rename during a slow signature write keeps both fields', () async {
    final slow = _SlowAPI();
    GetIt.I.unregister<BitwindowRPC>();
    GetIt.I.registerSingleton<BitwindowRPC>(slow);

    final provider = PsbtDraftProvider();
    await provider.fetch();
    final saved = await provider.create('unsigned', walletId: 'wallet-1');

    slow.walletpsbt.nextSaveDelay = const Duration(milliseconds: 50);
    final sign = provider.updatePsbt(saved.id, 'signed');
    final rename = provider.rename(saved.id, 'Rent for August');
    await Future.wait([sign, rename]);

    expect(provider.drafts.first.psbtBase64, contains('signed'));
    expect(provider.drafts.first.label, 'Rent for August');
  });

  test('a signature landing after a delete does not resurrect the draft', () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    final saved = await provider.create('base', walletId: 'wallet-1');

    await provider.delete(saved.id);

    await expectLater(provider.updatePsbt(saved.id, 'late-signature'), throwsStateError);
    await provider.fetch();
    expect(provider.drafts, isEmpty);
  });

  test('a failed startup fetch retries until the daemon answers', () {
    fakeAsync((async) {
      final flaky = _FlakyAPI();
      flaky.walletpsbt.drafts['abc123'] = PsbtDraft(
        id: 'abc123',
        walletId: 'wallet-1',
        psbtBase64: 'cHNidP8B',
      );
      GetIt.I.unregister<BitwindowRPC>();
      GetIt.I.registerSingleton<BitwindowRPC>(flaky);

      final provider = PsbtDraftProvider();
      async.flushMicrotasks();
      expect(provider.modelError, isNotNull);
      expect(provider.drafts, isEmpty);

      flaky.walletpsbt.working = true;
      async.elapse(const Duration(seconds: 11));

      expect(provider.modelError, isNull);
      expect(provider.drafts, hasLength(1));
    });
  });

  test('a delete removes the draft', () async {
    final provider = PsbtDraftProvider();
    await provider.fetch();
    final saved = await provider.create('cHNidP8B', walletId: 'wallet-1');

    await provider.delete(saved.id);

    expect(provider.drafts, isEmpty);
  });
}
