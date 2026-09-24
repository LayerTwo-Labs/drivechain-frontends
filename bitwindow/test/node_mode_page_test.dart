import 'dart:async';

import 'package:bitwindow/pages/welcome/node_mode_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

// A backend that does not answer is not a user who did not pick. The page waits
// and replaces the silent backend, and it asks the user for nothing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeWallet wallet;
  late int picked;
  late int restarts;
  Object? restartError;
  String? blocker;

  Future<void> pumpPage(WidgetTester tester, {int pollsBetweenRestarts = 15}) async {
    picked = 0;
    restarts = 0;
    restartError = null;
    blocker = null;
    await tester.pumpSailPage(
      NodeModePage(
        onModePicked: () => picked++,
        pollsBetweenRestarts: pollsBetweenRestarts,
        restartBackend: () async {
          restarts++;
          if (restartError != null) {
            throw restartError!;
          }
          return blocker;
        },
      ),
    );
  }

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    wallet = _FakeWallet();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(wallet));
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider());
  });

  tearDown(() async => GetIt.I.reset());

  testWidgets('waits while the backend does not answer, and asks nothing', (tester) async {
    await pumpPage(tester);

    expect(find.text(backendWait), findsOneWidget);
    expect(find.byType(SailButton), findsNothing);
    expect(find.text('Light'), findsNothing);
    expect(find.text('Full node'), findsNothing);
  });

  testWidgets('asks the question once the backend says the mode is unpicked', (tester) async {
    await pumpPage(tester);
    wallet.up = true;

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Full node'), findsOneWidget);
    expect(picked, 0);
  });

  testWidgets('accepts the Bitcoin light wallet without an enforcer', (tester) async {
    await pumpPage(tester);
    wallet.up = true;
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Your Bitcoin wallet uses Electrum. No Bitcoin Core download.'), findsOneWidget);
    await tester.tap(find.byType(SailButton));
    await tester.pumpAndSettle();

    expect(wallet.mode, wmpb.NodeMode.NODE_MODE_LIGHT);
    expect(picked, 1);
  });

  testWidgets('moves on when the backend reports the mode the user already picked', (tester) async {
    await pumpPage(tester);
    wallet.up = true;
    wallet.mode = wmpb.NodeMode.NODE_MODE_FULL;

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(picked, 1);
    expect(find.text('Light'), findsNothing);
  });

  // A backend that accepts the socket and never answers used to collect one
  // more read every two seconds.
  testWidgets('starts one read at a time', (tester) async {
    wallet.hang = true;
    await pumpPage(tester);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    expect(wallet.reads, 1);

    wallet.release();
    await tester.pump();
  });

  testWidgets('replaces a silent backend by itself', (tester) async {
    await pumpPage(tester);

    expect(restarts, 1);
  });

  testWidgets('gives a new backend time before it replaces one again', (tester) async {
    await pumpPage(tester);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    expect(restarts, 1);
  });

  testWidgets('replaces the backend again once the wait runs out', (tester) async {
    await pumpPage(tester, pollsBetweenRestarts: 1);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(restarts, 1);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(restarts, 2);
  });

  testWidgets('the page stops the restarts once the backend answers', (tester) async {
    await pumpPage(tester, pollsBetweenRestarts: 0);
    wallet.up = true;

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(restarts, 1);
    expect(find.text('Light'), findsOneWidget);
  });

  testWidgets('names the program that holds the port', (tester) async {
    await pumpPage(tester, pollsBetweenRestarts: 0);
    blocker = '127.0.0.1:8080 answers, but not as drivechaind.';

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text(blocker!), findsOneWidget);
  });

  testWidgets('shows a failed restart', (tester) async {
    await pumpPage(tester, pollsBetweenRestarts: 0);
    restartError = StateError('no bitwindowd binary');

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('BitWindow cannot reach the local backend. Bad state: no bitwindowd binary'), findsOneWidget);
  });
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this._wallet);

  final OrchestratorWalletRPC _wallet;

  @override
  OrchestratorWalletRPC get wallet => _wallet;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWallet implements OrchestratorWalletRPC {
  bool up = false;
  bool hang = false;
  wmpb.NodeMode mode = wmpb.NodeMode.NODE_MODE_UNSPECIFIED;
  int reads = 0;

  final Completer<void> _held = Completer<void>();

  void release() {
    if (!_held.isCompleted) {
      _held.complete();
    }
  }

  @override
  Future<wmpb.GetNodeModeResponse> getNodeMode() async {
    reads++;
    if (hang) {
      await _held.future;
    }
    if (!up) {
      throw Exception('connection refused');
    }
    return wmpb.GetNodeModeResponse(mode: mode, lightModeAvailable: true);
  }

  @override
  Future<void> setNodeMode(wmpb.NodeMode next) async {
    mode = next;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
