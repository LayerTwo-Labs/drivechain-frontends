import 'dart:async';

import 'package:bitnames/pages/tabs/reserve_register_page.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'test_utils.dart';

class _ListRPC extends MockBitnamesRPC {
  Completer<List<BitnameEntry>> reply = Completer<List<BitnameEntry>>();
  int calls = 0;

  @override
  Future<List<BitnameEntry>> listBitNames() {
    calls++;
    return reply.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late _ListRPC rpc;
  late BitnamesProvider provider;
  late BalanceProvider balances;

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    rpc = _ListRPC();
    final sidechain = MockSidechainRPC();
    GetIt.I.registerSingleton<BitnamesRPC>(rpc);
    GetIt.I.registerSingleton<SidechainRPC>(sidechain);
    GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
    balances = BalanceProvider(connections: [sidechain]);
    GetIt.I.registerSingleton<BalanceProvider>(balances);
    provider = BitnamesProvider();
    GetIt.I.registerSingleton<BitnamesProvider>(provider);
  });

  tearDown(() async {
    provider.dispose();
    balances.dispose();
    rpc.dispose();
    await GetIt.I.reset();
  });

  testWidgets('a list error stops the skeleton and shows a retry control', (tester) async {
    await tester.pumpSailPage(const BitnamesTabPage());
    expect(find.byType(SailSkeletonizer), findsNWidgets(2));
    expect(tester.widgetList<SailSkeletonizer>(find.byType(SailSkeletonizer)).every((item) => item.enabled), isTrue);

    rpc.reply.completeError(StateError('The node rejected the list request.'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(tester.widgetList<SailSkeletonizer>(find.byType(SailSkeletonizer)).every((item) => !item.enabled), isTrue);
    expect(find.textContaining('The node rejected the list request.'), findsWidgets);
    expect(find.text('Retry'), findsWidgets);
    expect(rpc.calls, 1);

    rpc.reply = Completer<List<BitnameEntry>>();
    await tester.tap(find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Retry').first);
    await tester.pump();
    expect(rpc.calls, 2);

    rpc.reply.complete([
      BitnameEntry(
        hash: 'a' * 64,
        details: BitnameDetails(seqId: '1739-0029'),
      ),
    ]);
    await tester.pump();

    expect(provider.entries, hasLength(1));
    expect(find.text('Retry'), findsNothing);
    expect(find.textContaining('The node rejected the list request.'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an empty list ends the initial load', (tester) async {
    await tester.pumpSailPage(const BitnamesTabPage());
    rpc.reply.complete([]);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(provider.initialized, isTrue);
    expect(provider.entries, isEmpty);
    expect(tester.widgetList<SailSkeletonizer>(find.byType(SailSkeletonizer)).every((item) => !item.enabled), isTrue);
    expect(rpc.calls, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('a connection change can read the list after an error', () async {
    rpc.reply.completeError(StateError('The node is offline.'));
    await Future<void>.delayed(Duration.zero);
    expect(provider.error, contains('The node is offline.'));

    rpc.reply = Completer<List<BitnameEntry>>();
    rpc.setConnected(true);
    expect(rpc.calls, 2);
    rpc.reply.complete([]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.initialized, isTrue);
    expect(provider.error, isNull);
  });

  test('a failed refresh keeps the last list and reports the error', () async {
    final entry = BitnameEntry(
      hash: 'a' * 64,
      details: BitnameDetails(seqId: '1739-0029'),
    );
    rpc.reply.complete([entry]);
    await Future<void>.delayed(Duration.zero);

    rpc.reply = Completer<List<BitnameEntry>>();
    final refresh = provider.fetch();
    rpc.reply.completeError(StateError('The node is offline.'));
    await refresh;

    expect(provider.entries, [entry]);
    expect(provider.error, contains('The node is offline.'));
    expect(provider.isLoading, isFalse);
  });
}
