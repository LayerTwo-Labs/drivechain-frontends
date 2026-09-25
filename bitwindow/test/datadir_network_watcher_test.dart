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
  bool hasPrivateBitcoinConf = false;

  @override
  List<NetworkOption> networks = [];

  @override
  List<NetworkOption> get networkOptions => networks;

  @override
  String? get detectedDataDir => '/home/u/.bitcoin';

  @override
  BitcoinNetwork networkFromOption(NetworkOption option) => switch (option.network) {
    'mainnet' => BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
    'ecash' => BitcoinNetwork.BITCOIN_NETWORK_ECASH,
    'signet' => BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
    _ => BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
  };

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

  void say(String detected, String selected, {bool reads = true}) {
    response = GetDatadirNetworkResponse(
      mismatch: true,
      detectedId: detected,
      detectedName: detected,
      selectedId: selected,
      selectedName: selected,
      switchReadsBlocks: reads,
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

NotificationItem _notice(String detected, String selected) => NotificationItem(
  id: 'datadir-network-1',
  title: 't',
  content: 'c',
  dialogType: DialogType.error,
  timestamp: DateTime.utc(2026, 9, 25),
  style: NotificationStyle.modalThenBanner,
  data: {'detected': detected, 'selected': selected},
);

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

  // Each datadir group keeps its own directory. A switch across groups reads
  // another one, so it leaves these blocks where they are.
  testWidgets('a switch that reads another directory refuses', (tester) async {
    rpc.answers = true;
    rpc.say('bitcoin', 'betanet', reads: false);
    conf.networks = [NetworkOption(id: 'bitcoin', displayName: 'Bitcoin', network: 'mainnet')];

    bool? result;
    await tester.pumpWidget(
      SailApp(
        dense: false,
        builder: (context) => MaterialApp(
          home: Builder(
            builder: (inner) => TextButton(
              onPressed: () async => result = await openDatadirNetworkSwitch(inner, _notice('bitcoin', 'betanet')),
              child: const Text('go'),
            ),
          ),
        ),
        initMethod: (_) async => (),
        accentColor: SailColorScheme.black,
        log: GetIt.I.get<Logger>(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.textContaining('reads another data directory'), findsOneWidget);

    // The toast keeps a timer, and the test frame refuses a pending one.
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  });
}
