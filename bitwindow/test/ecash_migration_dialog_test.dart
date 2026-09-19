import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bitwindow/widgets/ecash_migration_dialog.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as pb;

import 'test_utils.dart';

pb.ECashMigrationStatus _status({
  String jobId = '',
  String fromId = 'alphanet',
  String toId = 'betanet',
  String phase = 'preview',
  bool active = false,
  bool complete = false,
  String error = '',
  String syncState = '',
  int recordsDone = 0,
}) => pb.ECashMigrationStatus(
  jobId: jobId,
  fromId: fromId,
  toId: toId,
  phase: phase,
  dataDir: '/test/ecash',
  commonHeight: Int64(900000),
  commonHash: 'ab' * 32,
  sourceMagic: 'eca5a104',
  targetMagic: 'eca5b104',
  blockFiles: Int64(12),
  undoFiles: Int64(11),
  recordsDone: Int64(recordsDone),
  recordsTotal: Int64(100),
  running: active,
  complete: complete,
  error: error,
  syncState: syncState,
);

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.events);

  final List<String> events;
  pb.ECashMigrationStatus saved = pb.ECashMigrationStatus();
  pb.ECashMigrationStatus preview = _status();
  pb.ECashMigrationStatus started = _status(jobId: 'job-1', phase: 'prepare', active: true);
  Object? statusError;
  Object? previewError;
  Object? startError;
  Completer<pb.PreviewECashMigrationResponse>? previewWait;
  int statusReads = 0;
  final List<({String fromId, String toId})> previews = [];
  final List<({String fromId, String toId})> starts = [];

  @override
  Future<pb.GetECashMigrationStatusResponse> getECashMigrationStatus() async {
    events.add('status');
    statusReads++;
    if (statusError case final error?) {
      throw error;
    }
    return pb.GetECashMigrationStatusResponse(status: saved);
  }

  @override
  Future<pb.PreviewECashMigrationResponse> previewECashMigration({
    required String fromId,
    required String toId,
  }) async {
    events.add('preview');
    previews.add((fromId: fromId, toId: toId));
    if (previewError case final error?) {
      throw error;
    }
    if (previewWait case final wait?) {
      return wait.future;
    }
    return pb.PreviewECashMigrationResponse(status: preview);
  }

  @override
  Future<pb.StartECashMigrationResponse> startECashMigration({
    required String fromId,
    required String toId,
  }) async {
    events.add('start');
    starts.add((fromId: fromId, toId: toId));
    if (startError case final error?) {
      throw error;
    }
    saved = started;
    return pb.StartECashMigrationResponse(status: saved);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  _FakeConf(this.events);

  final List<String> events;
  final List<({BitcoinNetwork network, String networkId, String dataDir})> selections = [];
  Object? updateError;

  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  String ecashNetworkId = 'alphanet';

  @override
  Future<void> updateNetwork(BitcoinNetwork newNetwork, {String dataDir = '', String networkId = ''}) async {
    events.add('select');
    selections.add((network: newNetwork, networkId: networkId, dataDir: dataDir));
    if (updateError case final error?) {
      throw error;
    }
    network = newNetwork;
    ecashNetworkId = networkId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNetworkState implements NetworkScoped {
  _FakeNetworkState(this.events);

  final List<String> events;
  Completer<void>? clearWait;
  int clears = 0;

  @override
  Future<void> onNetworkChanged() async {
    events.add('clear');
    clears++;
    if (clearWait case final wait?) {
      await wait.future;
    }
    events.add('clear done');
  }
}

Finder _button(String label) => find.byWidgetPredicate((widget) => widget is SailButton && widget.label == label);

void _expectFullText(WidgetTester tester, String value) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: find.text(value), matching: find.byType(RichText)),
  );
  expect(paragraph.didExceedMaxLines, isFalse, reason: value);
}

Future<void> _flush(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> events;
  late _FakeOrchestrator rpc;
  late _FakeConf conf;
  late _FakeNetworkState networkState;
  late List<bool?> results;

  setUpAll(() async {
    for (final family in ['Inter', 'IBMPlexMono']) {
      await (FontLoader(family)..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'))).load();
    }
  });

  setUp(() async {
    await GetIt.I.reset();
    NetworkScopedRegistry.clearRegistrations();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    events = [];
    results = [];
    rpc = _FakeOrchestrator(events);
    conf = _FakeConf(events);
    networkState = NetworkScopedRegistry.enrol(_FakeNetworkState(events));
    GetIt.I.registerSingleton<OrchestratorRPC>(rpc);
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
  });

  tearDown(() async {
    NetworkScopedRegistry.clearRegistrations();
    await GetIt.I.reset();
  });

  Future<void> openDialog(
    WidgetTester tester, {
    pb.ECashMigrationStatus? initialStatus,
    Size size = const Size(1200, 720),
    double textScale = 1,
    bool ecash = true,
  }) async {
    await tester.pumpSailPage(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showThemedDialog<bool>(
              context: context,
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
                child: RepaintBoundary(
                  key: const ValueKey('ecash-migration-screen'),
                  child: SailTheme(
                    data: ecash
                        ? SailThemeData.lightTheme(
                            SailColorScheme.black,
                            false,
                            SailFontValues.inter,
                            SailThemeStyle.ecash,
                          )
                        : SailTheme.of(context),
                    child: ECashMigrationDialog(fromId: 'alphanet', toId: 'betanet', initialStatus: initialStatus),
                  ),
                ),
              ),
            );
            events.add('closed:$result');
            results.add(result);
          },
          child: const Text('Show migration'),
        ),
      ),
    );
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();
    await tester.tap(find.text('Show migration'));
    await _flush(tester);
  }

  // The dialog scrolls, so a button below the fold has to come into view first.
  Future<void> tapButton(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
  }

  Future<void> closeDialog(WidgetTester tester) async {
    await tapButton(tester, _button('Close'));
    await _flush(tester);
  }

  testWidgets('the wallet preview explains the initial target sync', (tester) async {
    rpc.preview = _status()
      ..walletOnly = true
      ..blockFiles = Int64.ZERO
      ..undoFiles = Int64.ZERO;

    await openDialog(tester);

    expect(find.text('The migration keeps wallet keys.'), findsOneWidget);
    expect(find.text('The target sync starts from the first block.'), findsOneWidget);
    expect(find.text('Rollback block'), findsNothing);
    expect(_button('Start migration'), findsOneWidget);
    expect(rpc.starts, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('the wallet progress omits the chain rollback', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true)
      ..walletOnly = true
      ..blockFiles = Int64.ZERO
      ..undoFiles = Int64.ZERO;

    await openDialog(tester);

    expect(find.text('Roll back to block 900 000'), findsNothing);
    expect(find.text('Write the betanet magic'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(rpc.previews, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('a sync below the fork skips the rollback', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true)
      ..belowFork = true
      ..commonHeight = Int64(850000);

    await openDialog(tester);

    expect(find.text('Skip the rollback'), findsOneWidget);
    expect(find.text('Synced to block'), findsOneWidget);
    expect(find.text(groupDigits(850000)), findsOneWidget);
    expect(find.text('Rollback block'), findsNothing);
    expect(find.textContaining('Roll back to block'), findsNothing);
    await closeDialog(tester);
  });

  for (final network in [
    BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
    BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
    BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
  ]) {
    testWidgets('the source step waits for the user and cache reset from ${network.name}', (tester) async {
      conf.network = network;
      conf.ecashNetworkId = 'betanet';
      networkState.clearWait = Completer<void>();

      await openDialog(tester);

      expect(_button('Open alphanet'), findsOneWidget);
      expect(_button('Start migration'), findsNothing);
      expect(rpc.previews, isEmpty);
      expect(rpc.starts, isEmpty);
      expect(conf.selections, isEmpty);
      expect(networkState.clears, 0);

      await tapButton(tester, _button('Open alphanet'));
      await _flush(tester);

      expect(conf.selections, [(network: BitcoinNetwork.BITCOIN_NETWORK_ECASH, networkId: 'alphanet', dataDir: '')]);
      expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_ECASH);
      expect(networkState.clears, 1);
      expect(rpc.previews, isEmpty);
      expect(rpc.starts, isEmpty);
      expect(results, isEmpty);
      networkState.clearWait!.complete();
      await _flush(tester);

      expect(_button('Start migration'), findsOneWidget);
      expect(rpc.previews, [(fromId: 'alphanet', toId: 'betanet')]);
      expect(events.indexOf('select'), lessThan(events.indexOf('clear')));
      expect(events.indexOf('clear done'), lessThan(events.indexOf('preview')));
      expect(rpc.starts, isEmpty);

      await tapButton(tester, _button('Start migration'));
      await _flush(tester);

      expect(rpc.starts, [(fromId: 'alphanet', toId: 'betanet')]);
      expect(conf.selections, hasLength(1));
      await closeDialog(tester);
    });
  }

  testWidgets('a source switch error permits retry before preview or start', (tester) async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_MAINNET;
    conf.updateError = StateError('The source config is not available');
    await openDialog(tester);

    await tapButton(tester, _button('Open alphanet'));
    await _flush(tester);

    expect(find.textContaining('The source config is not available'), findsOneWidget);
    expect(_button('Open alphanet'), findsOneWidget);
    expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_MAINNET);
    expect(networkState.clears, 0);
    expect(rpc.previews, isEmpty);
    expect(rpc.starts, isEmpty);
    conf.updateError = null;

    await tapButton(tester, _button('Open alphanet'));
    await _flush(tester);

    expect(conf.selections, hasLength(2));
    expect(conf.selections.every((selection) => selection.networkId == 'alphanet'), isTrue);
    expect(networkState.clears, 1);
    expect(rpc.previews, [(fromId: 'alphanet', toId: 'betanet')]);
    expect(rpc.starts, isEmpty);
    expect(_button('Start migration'), findsOneWidget);
    await closeDialog(tester);
  });

  testWidgets('a status read error blocks source selection from another active network', (tester) async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
    rpc.statusError = StateError('The daemon is offline');

    await openDialog(tester);

    expect(find.textContaining('The daemon is offline'), findsOneWidget);
    expect(_button('Refresh status'), findsOneWidget);
    expect(_button('Open alphanet'), findsNothing);
    expect(conf.selections, isEmpty);
    expect(rpc.previews, isEmpty);
    expect(rpc.starts, isEmpty);
    rpc.statusError = null;
    await tapButton(tester, _button('Refresh status'));
    await _flush(tester);

    expect(_button('Open alphanet'), findsOneWidget);
    expect(conf.selections, isEmpty);
    expect(rpc.previews, isEmpty);
    expect(rpc.starts, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('a completed job opens its target directly from another active network', (tester) async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;
    rpc.saved = _status(jobId: 'job-1', phase: 'complete', complete: true);

    await openDialog(tester);

    expect(_button('Open betanet'), findsOneWidget);
    expect(_button('Open alphanet'), findsNothing);
    expect(conf.selections, isEmpty);
    expect(rpc.previews, isEmpty);
    expect(rpc.starts, isEmpty);
    await tapButton(tester, _button('Open betanet'));
    await _flush(tester);

    expect(conf.selections, [(network: BitcoinNetwork.BITCOIN_NETWORK_ECASH, networkId: 'betanet', dataDir: '')]);
    expect(networkState.clears, 1);
    expect(results, [true]);
    expect(rpc.previews, isEmpty);
    expect(rpc.starts, isEmpty);
  });

  testWidgets('the dialog reads the saved status before the preview and waits for start', (tester) async {
    rpc.previewWait = Completer<pb.PreviewECashMigrationResponse>();

    await openDialog(tester);

    expect(events, ['status', 'preview']);
    expect(rpc.previews, [(fromId: 'alphanet', toId: 'betanet')]);
    expect(rpc.starts, isEmpty);
    if (_button('Start migration').evaluate().isNotEmpty) {
      expect(tester.widget<SailButton>(_button('Start migration')).disabled, isTrue);
    }

    rpc.previewWait!.complete(pb.PreviewECashMigrationResponse(status: rpc.preview));
    await _flush(tester);

    expect(_button('Start migration'), findsOneWidget);
    expect(find.textContaining('/test/ecash'), findsOneWidget);
    expect(rpc.starts, isEmpty);
    expect(conf.selections, isEmpty);
    await _capture(tester, 'ecx-preview');

    await tapButton(tester, _button('Start migration'));
    await _flush(tester);

    expect(rpc.starts, [(fromId: 'alphanet', toId: 'betanet')]);
    expect(conf.selections, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('a preview error permits another preview without a start request', (tester) async {
    rpc.previewError = StateError('The common block hash does not match');

    await openDialog(tester);

    expect(find.textContaining('The common block hash does not match'), findsOneWidget);
    expect(_button('Retry preview'), findsOneWidget);
    expect(rpc.starts, isEmpty);
    await _capture(tester, 'ecx-preview-error');

    rpc.previewError = null;
    await tapButton(tester, _button('Retry preview'));
    await _flush(tester);

    expect(rpc.previews, hasLength(2));
    expect(_button('Start migration'), findsOneWidget);
    expect(rpc.starts, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('a status read error permits a refresh before a preview', (tester) async {
    rpc.statusError = StateError('The daemon is offline');

    await openDialog(tester);

    expect(find.textContaining('The daemon is offline'), findsOneWidget);
    expect(_button('Refresh status'), findsOneWidget);
    expect(rpc.previews, isEmpty);
    expect(rpc.starts, isEmpty);

    rpc.statusError = null;
    await tapButton(tester, _button('Refresh status'));
    await _flush(tester);

    expect(rpc.statusReads, 2);
    expect(rpc.previews, hasLength(1));
    expect(_button('Start migration'), findsOneWidget);
    await closeDialog(tester);
  });

  testWidgets('the dialog resumes the saved job without another preview', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', recordsDone: 25, error: 'The daemon stopped');
    rpc.started = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 25);

    await openDialog(tester);

    expect(_button('Resume migration'), findsOneWidget);
    expect(find.textContaining('The daemon stopped'), findsOneWidget);
    expect(rpc.previews, isEmpty);
    await _capture(tester, 'ecx-resume');

    await tapButton(tester, _button('Resume migration'));
    await _flush(tester);

    expect(rpc.starts, [(fromId: 'alphanet', toId: 'betanet')]);
    expect(rpc.previews, isEmpty);
    expect(conf.selections, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('a lost start response reads the saved job before another start request', (tester) async {
    rpc.startError = StateError('The start response did not arrive');
    await openDialog(tester);

    await tapButton(tester, _button('Start migration'));
    await _flush(tester);

    expect(_button('Refresh status'), findsOneWidget);
    expect(rpc.starts, hasLength(1));
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 25);
    await tapButton(tester, _button('Refresh status'));
    await _flush(tester);

    expect(rpc.statusReads, 2);
    expect(rpc.starts, hasLength(1));
    expect(rpc.previews, hasLength(1));
    expect(find.text('25 of 100 records · 25%'), findsOneWidget);
    expect(_button('Start migration'), findsNothing);
    expect(conf.selections, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('an active job reads progress each two seconds', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 25);

    await openDialog(tester);

    expect(rpc.statusReads, 1);
    expect(rpc.previews, isEmpty);
    expect(rpc.starts, isEmpty);
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 75);
    await tester.pump(const Duration(seconds: 2));
    await _flush(tester);

    expect(rpc.statusReads, 2);
    expect(find.text('75 of 100 records · 75%'), findsOneWidget);
    expect(tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value, 0.75);
    expect(find.text('Write the betanet magic'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(conf.selections, isEmpty);
    await _capture(tester, 'ecx-progress');
    await closeDialog(tester);
  });

  testWidgets('a poll error keeps the job and permits a status refresh', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 25);
    await openDialog(tester);
    rpc.statusError = StateError('The daemon is offline');

    await tester.pump(const Duration(seconds: 2));
    await _flush(tester);

    expect(_button('Refresh status'), findsOneWidget);
    expect(find.text('25 of 100 records · 25%'), findsOneWidget);
    final failedReadCount = rpc.statusReads;
    await tester.pump(const Duration(seconds: 5));
    expect(rpc.statusReads, failedReadCount);
    rpc.statusError = null;
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 75);
    await tapButton(tester, _button('Refresh status'));
    await _flush(tester);

    expect(find.text('75 of 100 records · 75%'), findsOneWidget);
    expect(rpc.starts, isEmpty);
    expect(rpc.previews, isEmpty);
    expect(conf.selections, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('close stops status reads and reopen finds the active daemon job', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 25);
    await openDialog(tester);

    await closeDialog(tester);
    final readsAfterClose = rpc.statusReads;
    await tester.pump(const Duration(seconds: 5));

    expect(results, [false]);
    expect(rpc.statusReads, readsAfterClose);
    expect(rpc.saved.running, isTrue);
    expect(conf.selections, isEmpty);
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 75);
    await tester.tap(find.text('Show migration'));
    await _flush(tester);

    expect(rpc.statusReads, readsAfterClose + 1);
    expect(find.textContaining('75'), findsWidgets);
    expect(rpc.starts, isEmpty);
    expect(rpc.previews, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('a saved job for other networks does not complete this migration', (tester) async {
    rpc.saved = _status(jobId: 'other-job', fromId: 'oldernet', toId: 'alphanet', complete: true, phase: 'complete');

    await openDialog(tester);

    expect(rpc.previews, [(fromId: 'alphanet', toId: 'betanet')]);
    expect(_button('Start migration'), findsOneWidget);
    expect(_button('Open betanet'), findsNothing);
    expect(conf.selections, isEmpty);
    expect(results, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('a changed job ID cannot complete the open migration', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 25);
    await openDialog(tester);
    rpc.saved = _status(jobId: 'job-2', phase: 'complete', complete: true);

    await tester.pump(const Duration(seconds: 2));
    await _flush(tester);

    expect(find.textContaining('The migration job changed.'), findsOneWidget);
    expect(_button('Open betanet'), findsNothing);
    expect(_button('Refresh status'), findsOneWidget);
    expect(conf.selections, isEmpty);
    expect(networkState.clears, 0);
    expect(results, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('an initial job must match the current saved job', (tester) async {
    await openDialog(
      tester,
      initialStatus: _status(jobId: 'job-1', phase: 'convert'),
    );

    expect(find.textContaining('The saved migration is unavailable.'), findsOneWidget);
    expect(_button('Start migration'), findsNothing);
    expect(rpc.previews, isEmpty);
    expect(rpc.starts, isEmpty);
    expect(conf.selections, isEmpty);
    await closeDialog(tester);
  });

  testWidgets('a completed migration can open betanet before chain sync completes', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'complete', complete: true, syncState: 'syncing', recordsDone: 100);
    networkState.clearWait = Completer<void>();

    await openDialog(tester);

    expect(_button('Open betanet'), findsOneWidget);
    // The button says the whole story, so a complete job carries no closing line.
    expect(find.textContaining('Local checks passed'), findsNothing);
    expect(conf.selections, isEmpty);
    expect(networkState.clears, 0);
    await _capture(tester, 'ecx-complete');

    await tapButton(tester, _button('Open betanet'));
    await _flush(tester);

    expect(conf.selections, [(network: BitcoinNetwork.BITCOIN_NETWORK_ECASH, networkId: 'betanet', dataDir: '')]);
    expect(networkState.clears, 1);
    expect(results, isEmpty);
    networkState.clearWait!.complete();
    await _flush(tester);

    expect(results, [true]);
    expect(events, ['status', 'select', 'clear', 'clear done', 'closed:true']);
    expect(rpc.starts, isEmpty);
    expect(rpc.previews, isEmpty);
  });

  testWidgets('a local network error keeps the complete job open for another try', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'complete', complete: true);
    conf.updateError = StateError('The local config is not available');
    await openDialog(tester);

    await tapButton(tester, _button('Open betanet'));
    await _flush(tester);

    expect(find.textContaining('The local config is not available'), findsOneWidget);
    expect(results, isEmpty);
    expect(networkState.clears, 0);
    conf.updateError = null;
    await tapButton(tester, _button('Open betanet'));
    await _flush(tester);

    expect(conf.selections, hasLength(2));
    expect(networkState.clears, 1);
    expect(results, [true]);
    expect(rpc.starts, isEmpty);
  });

  testWidgets('the ECX theme shows retained data and migration progress', (tester) async {
    rpc.saved = _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 75);

    await openDialog(tester, ecash: true);

    expect(SailTheme.of(tester.element(find.byType(ECashMigrationDialog))).chrome.terminalStyle, isTrue);
    expect(find.text('75 of 100 records · 75%'), findsOneWidget);
    _expectFullText(
      tester,
      'Hold on for a little while. BitWindow is doing some magic so you don’t have to resync the entire chain.',
    );
    expect(tester.takeException(), isNull);
    await _capture(tester, 'ecx-progress');
    await closeDialog(tester);
  });

  for (final layout in [
    (name: 'preview', saved: null, action: 'Start migration'),
    (
      name: 'active',
      saved: _status(jobId: 'job-1', phase: 'convert', active: true, recordsDone: 75),
      action: 'Close',
    ),
    (
      name: 'complete',
      saved: _status(jobId: 'job-1', phase: 'complete', complete: true, syncState: 'syncing', recordsDone: 100),
      action: 'Open betanet',
    ),
  ]) {
    for (final ecash in [false, true]) {
      testWidgets('the narrow ${layout.name} layout keeps full text and actions with ECX theme $ecash', (tester) async {
        const dataDir = '/test/ECX data/chain files/a-long-directory-name-for-the-saved-alphanet-chain';
        rpc.preview.dataDir = dataDir;
        if (layout.saved case final saved?) {
          rpc.saved = saved..dataDir = dataDir;
        }
        await openDialog(tester, size: const Size(400, 800), textScale: 2, ecash: ecash);

        expect(tester.takeException(), isNull);
        _expectFullText(tester, dataDir);
        if (layout.saved != null) {
          _expectFullText(tester, 'Download the betanet binary');
          _expectFullText(tester, 'Roll back to block 900 000');
          _expectFullText(tester, 'Write the betanet magic');
        }
        final action = _button(layout.action);
        await tester.ensureVisible(action);
        await _flush(tester);

        final bounds = tester.getRect(action);
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(400));
        expect(bounds.bottom, lessThanOrEqualTo(800));
        expect(tester.takeException(), isNull);
        await _capture(tester, '${ecash ? 'ecx' : 'sail'}-narrow-${layout.name}-large-text');
        await closeDialog(tester);
      });
    }
  }
}

Future<void> _capture(WidgetTester tester, String name) async {
  const directory = String.fromEnvironment('ECASH_MIGRATION_SCREEN_DIR');
  if (directory.isEmpty) {
    return;
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('ecash-migration-screen')));
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await Directory(directory).create(recursive: true);
      await File('$directory/$name.png').writeAsBytes(bytes.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}
