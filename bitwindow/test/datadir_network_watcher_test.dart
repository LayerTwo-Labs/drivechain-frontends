import 'package:bitwindow/widgets/datadir_network_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/store_mock.dart';

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  String ecashNetworkId = 'betanet';

  @override
  BitcoinConfig? currentConfig;

  @override
  String? get detectedDataDir => '/home/u/.bitcoin';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeOrchestrator implements OrchestratorRPC {
  bool answers = false;
  int calls = 0;
  GetDatadirNetworkResponse response = GetDatadirNetworkResponse(mismatch: false);

  void sayUnknown(String magic) {
    response = GetDatadirNetworkResponse(mismatch: false, magic: magic);
  }

  void say(String detected, String selected) {
    response = GetDatadirNetworkResponse(
      mismatch: true,
      detectedId: detected,
      detectedName: detected,
      selectedId: selected,
      selectedName: selected,
    );
  }

  @override
  Future<GetDatadirNetworkResponse> getDatadirNetwork() async {
    calls++;
    if (!answers) {
      throw Exception('the daemon is down');
    }
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late _FakeOrchestrator rpc;
  late _FakeConf conf;

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger(level: Level.warning);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
    rpc = _FakeOrchestrator();
    conf = _FakeConf();
    GetIt.I.registerSingleton<OrchestratorRPC>(rpc);
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  // The key says which config the last answer describes. A key recorded over a
  // failed call bars every later check, and the warning never comes.
  test('a daemon that answers nothing records no key', () async {
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);

    expect(await watcher.check(), isFalse);
    expect(watcher.watchedKey, isEmpty);
    expect(rpc.calls, greaterThan(0));

    rpc.answers = true;

    expect(await watcher.check(), isTrue);
    expect(watcher.watchedKey, datadirWatchKey(conf));
  });

  // The published catalog names the networks that came after this build, and
  // it lands after the start. A magic no network in hand names is no answer.
  test('a magic no network names asks again', () async {
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);
    rpc.answers = true;
    rpc.sayUnknown('abcdabcd');

    expect(await watcher.check(), isFalse);
    expect(watcher.watchedKey, isEmpty);

    rpc.say('betanet', 'alphanet');

    expect(await watcher.check(), isTrue);
    expect(GetIt.I.get<NotificationProvider>().history, hasLength(1));
  });

  // The user crosses a banner out while the mismatch stands. A move to another
  // pair and back is a new state, so it warns again rather than stay quiet.
  test('a dismissed pair that comes back warns again', () async {
    final provider = GetIt.I.get<NotificationProvider>();
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);
    rpc.answers = true;

    rpc.say('betanet', 'alphanet');
    expect(await watcher.check(), isTrue);
    final first = provider.history.single.id;
    await provider.markRead(first);

    rpc.say('bitcoin', 'alphanet');
    expect(await watcher.check(), isTrue);
    expect(provider.history.map((n) => n.id), isNot(contains(first)));

    rpc.say('betanet', 'alphanet');
    expect(await watcher.check(), isTrue);

    expect(provider.history.single.id, isNot(first));
    expect(provider.pendingModal, isNotNull, reason: 'the modal opens for the new warning');
  });
}
