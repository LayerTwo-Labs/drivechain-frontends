import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitnames/pages/tabs/reserve_register_page.dart';
import 'package:bitnames/providers/bitnames_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:thirds/blake3.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'test_utils.dart';

class _ListRPC extends MockBitnamesRPC {
  Completer<List<BitnameEntry>> reply = Completer<List<BitnameEntry>>();
  int calls = 0;
  final List<String> reserved = [];
  List<SidechainUTXO> utxos = [];

  @override
  Future<List<BitnameEntry>> listBitNames() {
    calls++;
    return reply.future;
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async => utxos;

  @override
  Future<String> reserveBitName(String name) async {
    reserved.add(name);
    return 'reserve-txid';
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

  testWidgets('a failed list refresh keeps the Reserve success', (tester) async {
    await tester.pumpSailPage(const BitnamesTabPage());
    final entry = BitnameEntry(
      hash: 'a' * 64,
      details: BitnameDetails(seqId: '1739-0029'),
    );
    rpc.reply.complete([entry]);
    await tester.pump();

    final nameField = find.byWidgetPredicate(
      (widget) => widget is SailTextField && widget.hintText == 'Enter name to reserve',
    );
    await tester.enterText(find.descendant(of: nameField, matching: find.byType(EditableText)), 'alice');
    final reserveButton = find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Reserve');
    await tester.ensureVisible(reserveButton);
    rpc.reply = Completer<List<BitnameEntry>>();
    final callsBeforeReserve = rpc.calls;

    await tester.tap(reserveButton);
    await tester.pump();
    expect(rpc.reserved, ['alice']);
    expect(rpc.calls, callsBeforeReserve + 1);

    rpc.reply.completeError(StateError('The node cannot decode the Bitnames database.'));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    final reserveCard = find.byWidgetPredicate((widget) => widget is SailCard && widget.title == 'Reserve');
    expect(tester.widget<SailCard>(reserveCard).error, isNull);
    expect(rpc.reserved, ['alice']);
    expect(rpc.calls, callsBeforeReserve + 2);
    expect(provider.entries, [entry]);
    expect(provider.error, contains('The node cannot decode the Bitnames database.'));
    expect(provider.hashNameMapping.value.values.single.name, 'alice');
    expect(tester.widget<SailTextField>(nameField).controller.text, isEmpty);
    expect(tester.widget<SailButton>(reserveButton).loading, isFalse);
    expect(find.textContaining('The node cannot decode the Bitnames database.'), findsWidgets);
    final notification = GetIt.I.get<NotificationProvider>().history.single;
    expect(notification.dialogType, DialogType.success);
    expect(notification.content, contains('reserve-txid'));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });

  test('a connection change can read the list after an error', () async {
    rpc.reply.completeError(StateError('The node is offline.'));
    await Future<void>.delayed(Duration.zero);
    expect(provider.error, contains('The node is offline.'));

    rpc.reply = Completer<List<BitnameEntry>>();
    rpc.setConnected(true);
    await Future<void>.delayed(Duration.zero);
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

  test('a new provider reads saved names', () async {
    rpc.reply.complete([]);
    await Future<void>.delayed(Duration.zero);
    final hash = 'a' * 64;
    await HashNameMappingSetting.settings.setValue(
      HashNameMappingSetting(newValue: {hash: HashMapping(name: 'alice')}),
    );
    provider.dispose();
    await GetIt.I.unregister<BitnamesProvider>();
    rpc.reply = Completer<List<BitnameEntry>>();
    provider = BitnamesProvider();
    GetIt.I.registerSingleton<BitnamesProvider>(provider);
    rpc.reply.complete([
      BitnameEntry(
        hash: hash,
        details: BitnameDetails(seqId: '1739-0029'),
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.getFriendlyName(hash), 'alice');
  });

  test('Your Bitnames lists the names that the wallet coins hold', () async {
    final owned = 'a' * 64;
    final reservedHere = 'b' * 64;
    final heldElsewhere = 'c' * 64;
    await HashNameMappingSetting.settings.setValue(
      HashNameMappingSetting(newValue: {heldElsewhere: HashMapping(name: 'btcapsule', isMine: true)}),
    );
    rpc.utxos = [
      bitnameCoin({'BitName': owned}),
      bitnameCoin({'BitNameReservation': reservedHere}),
      bitnameCoin({'BitcoinSats': 1000}),
    ];
    rpc.reply.complete([
      for (final hash in [owned, reservedHere, heldElsewhere])
        BitnameEntry(
          hash: hash,
          details: BitnameDetails(seqId: '1739-0029'),
        ),
    ]);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final model = BitnamesViewModel();
    expect(model.myEntries.map((entry) => entry.hash), [owned]);
    await Future<void>.delayed(Duration.zero);
    model.dispose();
  });

  test('a search with capital letters finds and saves the name as typed', () async {
    final hash = blake3Hex(utf8.encode('eCashr'));
    rpc.reply.complete([
      BitnameEntry(
        hash: hash,
        details: BitnameDetails(seqId: '1739-0329'),
      ),
      BitnameEntry(
        hash: blake3Hex(utf8.encode('ecash')),
        details: BitnameDetails(seqId: '1739-0129'),
      ),
    ]);
    await Future<void>.delayed(Duration.zero);
    final model = BitnamesViewModel();
    rpc.reply = Completer<List<BitnameEntry>>()
      ..complete([
        BitnameEntry(
          hash: hash,
          plaintextName: 'eCashr',
          details: BitnameDetails(seqId: '1739-0329'),
        ),
      ]);

    model.searchController.text = ' eCashr ';
    expect(model.entries.map((entry) => entry.hash), [hash]);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final saved = await HashNameMappingSetting.settings.getValue(HashNameMappingSetting());
    expect(saved.value[hash]?.name, 'eCashr');
    model.searchController.text = 'ECASH';
    expect(model.entries.map((entry) => entry.hash), [hash]);
    model.dispose();
  });

  test('a name save keeps the stored names', () async {
    rpc.reply.complete([]);
    await Future<void>.delayed(Duration.zero);
    final hash = 'a' * 64;
    final settings = HashNameMappingSetting.settings;
    await settings.setValue(
      HashNameMappingSetting(newValue: {hash: HashMapping(name: 'alice')}),
    );

    await provider.saveHashNameMapping('bob');

    final saved = await settings.getValue(HashNameMappingSetting());
    expect(saved.value, hasLength(2));
    expect(saved.value[hash]?.name, 'alice');
    expect(saved.value[blake3Hex(utf8.encode('bob'))]?.name, 'bob');
  });

  test('two concurrent name saves keep both names', () async {
    rpc.reply.complete([]);
    await Future<void>.delayed(Duration.zero);
    final directory = await Directory.systemTemp.createTemp('bitnames-name-save-');
    addTearDown(() => directory.delete(recursive: true));
    final log = HashNameMappingSetting.settings.log;
    await GetIt.I.unregister<BitwindowClientSettings>();
    final settings = BitwindowClientSettings(store: FileStorage.fromDirectory(directory), log: log);
    GetIt.I.registerSingleton<BitwindowClientSettings>(settings);
    final oldHash = 'c' * 64;
    await settings.setValue(
      HashNameMappingSetting(newValue: {oldHash: HashMapping(name: 'carol')}),
    );

    await Future.wait([
      provider.saveHashNameMapping('alice'),
      provider.saveHashNameMapping('bob'),
    ]);

    final saved = await BitwindowClientSettings(
      store: FileStorage.fromDirectory(directory),
      log: log,
    ).getValue(HashNameMappingSetting());
    expect(saved.value.values.map((entry) => entry.name), unorderedEquals(['carol', 'alice', 'bob']));
    expect(saved.value[oldHash]?.name, 'carol');
    expect(provider.hashNameMapping.toJson(), HashNameMappingSetting(newValue: saved.value).toJson());
  });
}

BitnamesUTXO bitnameCoin(Map<String, dynamic> content) => BitnamesUTXO.fromJson({
  'outpoint': {
    'Regular': {'txid': 'aa', 'vout': 0},
  },
  'output': {'address': 'mine', 'content': content},
});
