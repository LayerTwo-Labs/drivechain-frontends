import 'dart:async';

import 'package:bitwindow/pages/welcome/node_mode_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

// A backend that does not answer is not a user who did not pick. The page used
// to ask the first-run question and then print the raw socket error.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeWallet wallet;
  late int picked;

  Future<void> pumpPage(WidgetTester tester) async {
    picked = 0;
    await tester.pumpSailPage(NodeModePage(onModePicked: () => picked++));
  }

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    wallet = _FakeWallet();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(wallet));
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider());
  });

  tearDown(() async => GetIt.I.reset());

  testWidgets('holds the question while the backend does not answer', (tester) async {
    await pumpPage(tester);

    expect(find.text('BitWindow cannot reach the local backend.'), findsOneWidget);
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

  testWidgets('reads again when the user taps the button', (tester) async {
    await pumpPage(tester);
    final before = wallet.reads;

    await tester.tap(find.byType(SailButton));
    await tester.pump();

    expect(wallet.reads, greaterThan(before));
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
