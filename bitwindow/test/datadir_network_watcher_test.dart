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

  /// The oldest records carry a magic no network in hand names, and the newest
  /// ones belong to the running network. The daemon can name one end only.
  void sayUnknownFirst(String firstMagic, String last) {
    response = GetDatadirNetworkResponse(
      mismatch: false,
      firstMagic: firstMagic,
      magic: 'eca5b104',
      detectedId: last,
      detectedName: last,
      selectedId: last,
      selectedName: last,
    );
  }

  /// convertFrom defaults to the detected network. The daemon leaves it empty
  /// when no conversion reaches the running network, and a test says so too.
  void say(String detected, String selected, {bool reads = true, String? convertFrom}) {
    final source = convertFrom ?? detected;
    response = GetDatadirNetworkResponse(
      mismatch: true,
      magic: 'eca5a104',
      detectedId: detected,
      detectedName: detected,
      // One network wrote every record, so both ends name it.
      firstMagic: 'eca5a104',
      firstId: detected,
      firstName: detected,
      selectedId: selected,
      selectedName: selected,
      switchReadsBlocks: reads,
      convertFromId: source,
      convertFromName: source,
    );
  }

  /// A directory a conversion left part way: one network at each end.
  void sayMixed(String first, String last, String selected, {String convertFrom = ''}) {
    response = GetDatadirNetworkResponse(
      mismatch: true,
      mixed: true,
      firstId: first,
      firstName: first,
      firstMagic: 'eca5a104',
      detectedId: last,
      detectedName: last,
      magic: 'eca5b104',
      selectedId: selected,
      selectedName: selected,
      switchReadsBlocks: true,
      convertFromId: convertFrom,
      convertFromName: convertFrom,
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

/// A button by its label. SailButton renders the label twice — one copy holds
/// the width while it loads — so a text finder counts it twice.
Finder _button(String label) => find.byWidgetPredicate((widget) => widget is SailButton && widget.label == label);

NotificationItem _notice(String detected, String selected, {String? first}) => NotificationItem(
  id: 'datadir-network-1',
  title: 't',
  content: 'c',
  dialogType: DialogType.error,
  timestamp: DateTime.utc(2026, 9, 25),
  style: NotificationStyle.modalThenBanner,
  data: {'first': first ?? detected, 'detected': detected, 'selected': selected},
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

  // The text names both networks: the one the blocks belong to, and the one the
  // app runs. A warning that names one of the two says nothing about the fix.
  test('the notice names the network the app runs', () async {
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);
    rpc.answers = true;
    rpc.say('alphanet', 'betanet');
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    expect(await watcher.check(), isTrue);

    final notice = GetIt.I.get<NotificationProvider>().history.single;
    expect(notice.title, 'The blocks on disk are from alphanet');
    expect(notice.content, 'But you are on betanet. Switch to alphanet, or convert the blocks to betanet.');
  });

  // The banner names the repairs the answer allows. A conversion the daemon
  // refuses must not appear in the text either.
  test('the notice offers no conversion the daemon refuses', () async {
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);
    rpc.answers = true;
    rpc.say('betanet', 'alphanet', convertFrom: '');
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    expect(await watcher.check(), isTrue);

    expect(
      GetIt.I.get<NotificationProvider>().history.single.content,
      'But you are on alphanet. Switch to betanet.',
    );
  });

  // An unknown magic at either end is no answer. A check recorded over it bars
  // every later one, and a mixed directory then stays quiet for good.
  test('an unknown oldest end asks again', () async {
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);
    rpc.answers = true;
    rpc.sayUnknownFirst('eca5ff04', 'betanet');

    expect(await watcher.check(), isFalse);
    expect(watcher.watchedKey, isEmpty);

    rpc.sayMixed('alphanet', 'betanet', 'betanet', convertFrom: 'alphanet');

    expect(await watcher.check(), isTrue);
    expect(GetIt.I.get<NotificationProvider>().history, hasLength(1));
  });

  // A conversion can move the oldest records first. The pair of networks then
  // stays as it was, and only the mixed state tells the two apart. An entry that
  // keeps its id keeps text that offers a switch the app can no longer make.
  test('a store that turns mixed earns a new notice', () async {
    final provider = GetIt.I.get<NotificationProvider>();
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);
    rpc.answers = true;
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    rpc.say('alphanet', 'betanet');
    expect(await watcher.check(), isTrue);
    final uniform = provider.history.single.id;

    // The oldest records moved to betanet; the newest ones still say alphanet.
    rpc.sayMixed('betanet', 'alphanet', 'betanet', convertFrom: 'alphanet');
    expect(await watcher.check(), isTrue);

    final mixed = provider.history.single;
    expect(mixed.id, isNot(uniform), reason: 'the old entry holds text that no longer applies');
    expect(mixed.title, 'The block files hold two networks');
    expect(provider.pendingModal, isNotNull, reason: 'the modal opens for the new state');
  });

  // The user's own file names the network, so the app makes neither repair. A
  // banner that offers one opens a dialog with no button.
  test('a private conf offers no repair in the banner', () async {
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);
    rpc.answers = true;
    rpc.say('alphanet', 'betanet');
    conf.hasPrivateBitcoinConf = true;
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    expect(await watcher.check(), isTrue);

    expect(
      GetIt.I.get<NotificationProvider>().history.single.content,
      'But you are on betanet. Open this notice to read what to do.',
    );
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

  /// Opens the repair dialog and hands back the slot the handler writes its
  /// answer into. The dialog is still open when this returns, so the answer
  /// lands once the test presses a button.
  Future<List<bool?>> openRepairs(WidgetTester tester, String detected, String selected, {String? first}) async {
    final answer = <bool?>[null];
    await tester.pumpWidget(
      SailApp(
        dense: false,
        builder: (context) => MaterialApp(
          home: Builder(
            builder: (inner) => TextButton(
              onPressed: () async =>
                  answer[0] = await openDatadirNetworkSwitch(inner, _notice(detected, selected, first: first)),
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
    return answer;
  }

  // Each datadir group keeps its own directory. A switch across groups reads
  // another one, so it leaves these blocks where they are.
  testWidgets('a switch that reads another directory offers no switch', (tester) async {
    rpc.answers = true;
    rpc.say('bitcoin', 'betanet', reads: false);
    conf.networks = [NetworkOption(id: 'bitcoin', displayName: 'Bitcoin', network: 'mainnet')];

    final answer = await openRepairs(tester, 'bitcoin', 'betanet');

    expect(find.textContaining('reads another data directory'), findsOneWidget);
    expect(_button('Switch to bitcoin'), findsNothing);

    await tester.tap(_button('Close'));
    await tester.pumpAndSettle();

    expect(answer[0], isFalse, reason: 'the banner stays while the mismatch stands');
  });

  // The blocks and the app are both on eCash, so the user picks which of the
  // two moves. The text names the network the app runs.
  testWidgets('two eCash networks offer both repairs', (tester) async {
    rpc.answers = true;
    rpc.say('alphanet', 'betanet');
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    await openRepairs(tester, 'alphanet', 'betanet');

    expect(find.text('The blocks on disk are from alphanet'), findsWidgets);
    expect(find.text('But you are on betanet.'), findsWidgets);
    expect(_button('Switch to alphanet'), findsOneWidget);
    expect(_button('Convert the blocks to betanet'), findsOneWidget);
  });

  // A conversion rewinds to the block two eCash forks share. Nothing says where
  // another family parts from eCash, so there is no block to rewind to.
  testWidgets('blocks from another family offer no conversion', (tester) async {
    rpc.answers = true;
    rpc.say('bitcoin', 'betanet', convertFrom: '');
    conf.networks = [
      NetworkOption(id: 'bitcoin', displayName: 'Bitcoin', network: 'mainnet'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    await openRepairs(tester, 'bitcoin', 'betanet');

    expect(_button('Switch to bitcoin'), findsOneWidget);
    expect(_button('Convert the blocks to betanet'), findsNothing);
    expect(find.textContaining('between two eCash networks only'), findsOneWidget);
  });

  // The user's own file names the network, so neither repair is the app's to
  // make. The dialog says so rather than offer a button that fails.
  testWidgets('a private bitcoin.conf offers no repair', (tester) async {
    rpc.answers = true;
    rpc.say('alphanet', 'betanet');
    conf.hasPrivateBitcoinConf = true;
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    await openRepairs(tester, 'alphanet', 'betanet');

    expect(find.textContaining('Your own bitcoin.conf names the network'), findsOneWidget);
    expect(_button('Switch to alphanet'), findsNothing);
    expect(_button('Convert the blocks to betanet'), findsNothing);
    expect(_button('Close'), findsOneWidget);
  });

  // A conversion that stopped part way leaves one network at each end. Either
  // network reads one half of the directory, so the only repair finishes the job.
  testWidgets('a half converted store offers the conversion only', (tester) async {
    rpc.answers = true;
    rpc.sayMixed('alphanet', 'betanet', 'betanet', convertFrom: 'alphanet');
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    await openRepairs(tester, 'betanet', 'betanet', first: 'alphanet');

    expect(find.text('The block files hold two networks'), findsWidgets);
    expect(find.text('But you are on betanet.'), findsWidgets);
    expect(_button('Finish the conversion to betanet'), findsOneWidget);
    expect(_button('Switch to betanet'), findsNothing);
    expect(find.textContaining('A conversion stopped part way'), findsOneWidget);
  });

  // Neither half belongs to the network the app runs, so no single conversion
  // reaches it. The dialog says so rather than offer a button that fails.
  testWidgets('a store with two foreign halves offers no repair', (tester) async {
    rpc.answers = true;
    rpc.sayMixed('alphanet', 'betanet', 'drynet4');
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
      NetworkOption(id: 'drynet4', displayName: 'Drynet4', network: 'ecash'),
    ];

    await openRepairs(tester, 'betanet', 'drynet4', first: 'alphanet');

    expect(_button('Finish the conversion to drynet4'), findsNothing);
    expect(_button('Switch to betanet'), findsNothing);
    expect(find.textContaining('no conversion reaches it'), findsOneWidget);
  });

  // The notice text carries the state: a half converted store reads as one, not
  // as a plain move between two networks.
  test('the notice names a half converted store', () async {
    final watcher = DatadirNetworkWatcher();
    addTearDown(watcher.dispose);
    rpc.answers = true;
    rpc.sayMixed('alphanet', 'betanet', 'betanet', convertFrom: 'alphanet');

    expect(await watcher.check(), isTrue);

    final notice = GetIt.I.get<NotificationProvider>().history.single;
    expect(notice.title, 'The block files hold two networks');
    expect(notice.content, 'But you are on betanet. A conversion stopped part way. Finish it to betanet.');
  });

  // A conversion moves a chain forward only. Betanet blocks while the app runs
  // alphanet therefore offer no conversion, and the daemon says so.
  testWidgets('a backward conversion offers no button', (tester) async {
    rpc.answers = true;
    rpc.say('betanet', 'alphanet', convertFrom: '');
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    await openRepairs(tester, 'betanet', 'alphanet');

    expect(_button('Switch to betanet'), findsOneWidget);
    expect(_button('Convert the blocks to alphanet'), findsNothing);
    expect(find.textContaining('moves a chain forward only'), findsOneWidget);
  });

  // A cancelled repair leaves the banner on screen, so the mismatch stays
  // visible until the user acts on it.
  testWidgets('a cancelled dialog leaves the notice', (tester) async {
    rpc.answers = true;
    rpc.say('alphanet', 'betanet');
    conf.networks = [
      NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
      NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
    ];

    final answer = await openRepairs(tester, 'alphanet', 'betanet');
    await tester.tap(_button('Close'));
    await tester.pumpAndSettle();

    expect(_button('Switch to alphanet'), findsNothing);
    expect(answer[0], isFalse);
  });
}
