import 'package:bitwindow/main.dart';
import 'package:fake_async/fake_async.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _FakeWallet implements OrchestratorWalletRPC {
  wmpb.NodeMode mode = wmpb.NodeMode.NODE_MODE_UNSPECIFIED;
  int writes = 0;
  int failures = 1;
  int readFailures = 0;
  int statusFailures = 0;
  wmpb.WalletState state = wmpb.WalletState.WALLET_STATE_NO_WALLET;

  @override
  Future<wmpb.GetNodeModeResponse> getNodeMode() async {
    if (readFailures > 0) {
      readFailures--;
      throw Exception('connection refused');
    }
    return wmpb.GetNodeModeResponse(mode: mode, lightModeAvailable: true);
  }

  @override
  Future<wmpb.GetWalletStatusResponse> getWalletStatus() async {
    if (statusFailures > 0) {
      statusFailures--;
      throw Exception('connection refused');
    }
    return wmpb.GetWalletStatusResponse(state: state);
  }

  @override
  Future<void> setNodeMode(wmpb.NodeMode next) async {
    writes++;
    if (failures > 0) {
      failures--;
      throw Exception('node mode file is read-only');
    }
    mode = next;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final _FakeWallet wallet = _FakeWallet();

  final List<String> streams = [];

  @override
  Stream<StreamLogsResponse> streamLogs(String name, {int tail = 0, String runId = '', Int64? afterSequence}) {
    streams.add(name);
    return const Stream<StreamLogsResponse>.empty();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeState extends ChangeNotifier implements BackendStateProvider {
  int watches = 0;

  @override
  bool orchestratorAnswered = false;

  @override
  bool orchestratorReachable = false;

  @override
  void startWatching() => watches++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  Future<bool> hasWallet() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotifications extends ChangeNotifier implements NotificationProvider {
  final List<String> titles = [];

  @override
  void add({
    required String title,
    required String content,
    required DialogType dialogType,
    List<NotificationLink> links = const [],
    Future<void> Function()? onPressed,
    NotificationStyle style = NotificationStyle.toast,
    String action = '',
    Map<String, String> data = const {},
    String? id,
  }) => titles.add(title);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeOrchestrator orchestrator;
  late _FakeState state;
  late _FakeNotifications notifications;
  late Logger log;

  setUp(() async {
    await GetIt.I.reset();
    forgetBinaryLogStreams();
    log = Logger(level: Level.off);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..localBuildsAvailable = true);
    GetIt.I.registerSingleton<WalletReaderProvider>(_FakeReader());
    notifications = _FakeNotifications();
    GetIt.I.registerSingleton<NotificationProvider>(notifications);
    state = _FakeState();
  });

  tearDown(() async {
    forgetBinaryLogStreams();
    await GetIt.I.reset();
  });

  test('a failed first boot mode write keeps the watch and tries again', () {
    fakeAsync((async) {
      var done = false;
      startBackendsForMode(
        orchestrator: orchestrator,
        backendState: state,
        orchestratorReady: true,
        log: log,
      ).then((_) => done = true);
      async.flushMicrotasks();

      expect(done, isTrue, reason: 'a failed write does not hold the boot');
      expect(state.watches, 1);
      expect(orchestrator.streams, ['bitcoind', 'enforcer']);
      expect(orchestrator.wallet.writes, 1);
      expect(notifications.titles, ['Could not switch']);
      expect(GetIt.I.get<NodeModeProvider>().needsChoice, isTrue);

      async.elapse(firstBootModeRetry);
      async.flushMicrotasks();

      expect(orchestrator.wallet.writes, 2);
      expect(GetIt.I.get<NodeModeProvider>().isLight, isTrue);
      expect(state.watches, 1);
    });
  });

  test('a failed first mode read is tried again', () {
    fakeAsync((async) {
      orchestrator.wallet
        ..failures = 0
        ..readFailures = 1;
      startBackendsForMode(orchestrator: orchestrator, backendState: state, orchestratorReady: true, log: log);
      async.flushMicrotasks();
      expect(GetIt.I.get<NodeModeProvider>().loaded, isFalse);

      async.elapse(firstBootModeRetry);
      async.flushMicrotasks();

      expect(GetIt.I.get<NodeModeProvider>().isLight, isTrue);
    });
  });

  test('an unread wallet status never records light for an existing install', () {
    fakeAsync((async) {
      orchestrator.wallet
        ..failures = 0
        ..statusFailures = 1
        ..state = wmpb.WalletState.WALLET_STATE_UNLOCKED;
      startBackendsForMode(orchestrator: orchestrator, backendState: state, orchestratorReady: true, log: log);
      async.flushMicrotasks();
      expect(orchestrator.wallet.writes, 0);

      async.elapse(firstBootModeRetry);
      async.flushMicrotasks();

      expect(orchestrator.wallet.mode, wmpb.NodeMode.NODE_MODE_FULL);
    });
  });

  test('a backend that answers after the readiness wait still gets its boot', () {
    fakeAsync((async) {
      orchestrator.wallet.failures = 0;
      startBackendsForMode(orchestrator: orchestrator, backendState: state, orchestratorReady: false, log: log);
      async.flushMicrotasks();
      expect(GetIt.I.get<NodeModeProvider>().loaded, isFalse);
      expect(state.watches, 1);

      state
        ..orchestratorAnswered = true
        ..orchestratorReachable = true
        ..notifyListeners();
      async.flushMicrotasks();

      expect(GetIt.I.get<NodeModeProvider>().isLight, isTrue);
      expect(orchestrator.wallet.writes, 1);

      state.notifyListeners();
      async.flushMicrotasks();
      expect(orchestrator.wallet.writes, 1, reason: 'the late boot runs once');
    });
  });
}
