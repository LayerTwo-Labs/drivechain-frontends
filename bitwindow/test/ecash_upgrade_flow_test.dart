import 'dart:async';

import 'package:bitwindow/pages/settings/network_swap_page.dart';
import 'package:bitwindow/pages/settings/settings_network.dart';
import 'package:bitwindow/widgets/ecash_migration_dialog.dart';
import 'package:bitwindow/widgets/ecash_upgrade_banner.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
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
  bool active = false,
  bool complete = false,
  String error = '',
}) => pb.ECashMigrationStatus(
  jobId: jobId,
  fromId: fromId,
  toId: toId,
  phase: complete ? 'complete' : 'convert',
  dataDir: '/test/ecash',
  commonHeight: Int64(900000),
  blockFiles: Int64(12),
  undoFiles: Int64(11),
  recordsDone: Int64(20),
  recordsTotal: Int64(100),
  running: active,
  complete: complete,
  error: error,
  syncState: complete ? 'syncing' : '',
);

class _FakeOrchestrator implements OrchestratorRPC {
  final List<String> calls = [];
  Object? statusError;
  pb.ECashMigrationStatus saved = pb.ECashMigrationStatus();
  pb.GetPendingNetworkGenerationResponse pending = pb.GetPendingNetworkGenerationResponse(
    currentNetworkId: 'alphanet',
    pendingNetworkId: 'betanet',
  );

  @override
  Future<pb.GetECashMigrationStatusResponse> getECashMigrationStatus() async {
    calls.add('status');
    if (statusError case final error?) {
      throw error;
    }
    return pb.GetECashMigrationStatusResponse(status: saved);
  }

  @override
  Future<pb.GetPendingNetworkGenerationResponse> getPendingNetworkGeneration() async {
    calls.add('pending');
    return pending;
  }

  @override
  Future<pb.PreviewECashMigrationResponse> previewECashMigration({required String fromId, required String toId}) async {
    calls.add('preview:$fromId:$toId');
    return pb.PreviewECashMigrationResponse(
      status: _status(fromId: fromId, toId: toId),
    );
  }

  @override
  Future<pb.StartECashMigrationResponse> startECashMigration({required String fromId, required String toId}) async {
    calls.add('start:$fromId:$toId');
    saved = _status(jobId: 'job-1', active: true);
    return pb.StartECashMigrationResponse(status: saved);
  }

  @override
  Future<pb.ConfirmPendingNetworkGenerationResponse> confirmPendingNetworkGeneration() async {
    calls.add('legacy confirm');
    throw StateError('The migration must use the migration RPC.');
  }

  @override
  Future<pb.ShutdownResponse> shutdown({bool onlyIfLast = false}) async {
    calls.add('shutdown');
    throw StateError('The migration must keep the daemon active.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  final List<String> calls = [];
  bool localBackends = true;
  bool hasChainData = true;
  String? chainId;
  Object? updateError;

  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  String ecashNetworkId = 'alphanet';

  @override
  bool get hasPrivateBitcoinConf => false;

  @override
  String? get detectedDataDir => '/test/ecash';

  @override
  String get currentNetworkOptionId => switch (network) {
    BitcoinNetwork.BITCOIN_NETWORK_MAINNET => 'mainnet',
    BitcoinNetwork.BITCOIN_NETWORK_SIGNET => 'signet',
    BitcoinNetwork.BITCOIN_NETWORK_REGTEST => 'regtest',
    _ => ecashNetworkId,
  };

  @override
  List<NetworkOption> get networkOptions => [
    NetworkOption(id: 'mainnet', displayName: 'Mainnet', network: 'mainnet'),
    NetworkOption(id: 'signet', displayName: 'Signet', network: 'signet'),
    NetworkOption(id: 'regtest', displayName: 'Regtest', network: 'regtest'),
    NetworkOption(id: 'alphanet', displayName: 'Alphanet', network: 'ecash'),
    NetworkOption(id: 'betanet', displayName: 'Betanet', network: 'ecash'),
  ];

  @override
  NetworkOption? optionById(String id) => networkOptions.where((option) => option.id == id).firstOrNull;

  @override
  BitcoinNetwork networkFromOption(NetworkOption option) => switch (option.network) {
    'mainnet' => BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
    'signet' => BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
    'regtest' => BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
    _ => BitcoinNetwork.BITCOIN_NETWORK_ECASH,
  };

  @override
  Future<List<NetworkOption>> takeNewNetworks() async => [];

  @override
  Future<NetworkChangePlan> prepareNetworkChange({
    BitcoinNetwork? targetNetwork,
    String walletId = '',
    String networkId = '',
  }) async {
    calls.add('prepare:$networkId');
    return NetworkChangePlan(needsLocalBackends: localBackends);
  }

  @override
  Future<String?> resolveNetworkChangePlan(
    BuildContext context,
    NetworkChangePlan plan,
    BitcoinNetwork targetNetwork,
  ) async {
    calls.add('resolve');
    return '';
  }

  @override
  Future<PlanECashSwitchResponse> planECashSwitch(String toId) async {
    calls.add('plan:$toId');
    return PlanECashSwitchResponse(
      fromId: ecashNetworkId,
      toId: toId,
      needsRollback: true,
      rewindHeight: 900000,
      hasChainData: hasChainData,
      chainId: chainId ?? ecashNetworkId,
    );
  }

  @override
  Future<void> updateNetwork(BitcoinNetwork newNetwork, {String dataDir = '', String networkId = ''}) async {
    calls.add('select:$networkId');
    if (updateError case final error?) {
      throw error;
    }
    network = newNetwork;
    ecashNetworkId = networkId;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNetworkState implements NetworkScoped {
  int clears = 0;
  Completer<void>? clearWait;

  @override
  Future<void> onNetworkChanged() async {
    clears++;
    if (clearWait case final wait?) {
      await wait.future;
    }
  }
}

class _FakeVariants extends ChangeNotifier implements CoreVariantProvider {
  @override
  bool get isVisible => false;

  @override
  Future<void> refresh() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeElectrum extends ChangeNotifier implements ElectrumServerProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTor extends ChangeNotifier implements TorConfigProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? get activeWalletId => null;

  @override
  WalletData? get activeWallet => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBinaryProvider extends ChangeNotifier implements BinaryProvider {
  int stops = 0;

  @override
  Future<GetSnapshotStatusResponse> getSnapshotStatus() async => GetSnapshotStatusResponse();

  @override
  Future<void> stop(Binary binary, {bool skipDownstream = false}) async {
    stops++;
    throw StateError('The migration must keep the backend active.');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Finder _button(String label) => find.byWidgetPredicate((widget) => widget is SailButton && widget.label == label);

Future<void> _flush(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeOrchestrator rpc;
  late _FakeConf conf;
  late _FakeBinaryProvider binaries;
  late NotificationProvider notices;
  late _FakeNetworkState networkState;

  setUp(() async {
    await GetIt.I.reset();
    NetworkScopedRegistry.clearRegistrations();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    rpc = _FakeOrchestrator();
    conf = _FakeConf();
    binaries = _FakeBinaryProvider();
    notices = NotificationProvider();
    networkState = NetworkScopedRegistry.enrol(_FakeNetworkState());
    GetIt.I.registerSingleton<OrchestratorRPC>(rpc);
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
    GetIt.I.registerSingleton<BinaryProvider>(binaries);
    GetIt.I.registerSingleton<NotificationProvider>(notices);
    GetIt.I.registerSingleton<NotificationActions>(const NotificationActions({ecashUpgradeAction: openECashUpgrade}));
    GetIt.I.registerSingleton<CoreVariantProvider>(_FakeVariants());
    GetIt.I.registerSingleton<ElectrumServerProvider>(_FakeElectrum());
    GetIt.I.registerSingleton<TorConfigProvider>(_FakeTor());
    GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
  });

  tearDown(() async {
    NetworkScopedRegistry.clearRegistrations();
    await GetIt.I.reset();
  });

  Future<ECashUpgradeWatcher> showBanner(WidgetTester tester) async {
    await tester.pumpSailPage(const Align(alignment: Alignment.topCenter, child: NotificationBanner()));
    final watcher = ECashUpgradeWatcher();
    addTearDown(watcher.dispose);
    await _flush(tester);
    return watcher;
  }

  void expectNoLegacyCalls() {
    expect(rpc.calls, isNot(contains('legacy confirm')));
    expect(rpc.calls, isNot(contains('shutdown')));
    expect(binaries.stops, 0);
  }

  for (final network in [
    BitcoinNetwork.BITCOIN_NETWORK_MAINNET,
    BitcoinNetwork.BITCOIN_NETWORK_SIGNET,
    BitcoinNetwork.BITCOIN_NETWORK_REGTEST,
  ]) {
    for (final entry in ['selector', 'banner']) {
      testWidgets('the $entry opens retained alphanet data from ${network.name} before migration', (tester) async {
        conf.network = network;
        conf.ecashNetworkId = 'betanet';
        conf.chainId = 'alphanet';
        networkState.clearWait = Completer<void>();
        ECashUpgradeWatcher? watcher;
        if (entry == 'selector') {
          rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'betanet');
          await tester.pumpSailPage(const SettingsNetwork());
          await _flush(tester);
          await tester.tap(find.byType(SailDropdownButton<String>));
          await _flush(tester);
          await tester.tap(find.text('Betanet'));
        } else {
          rpc.pending = pb.GetPendingNetworkGenerationResponse(
            currentNetworkId: 'betanet',
            pendingNetworkId: 'betanet',
          );
          watcher = await showBanner(tester);
          await tester.tap(find.text('betanet is out'));
        }
        await _flush(tester);

        expect(find.byType(ECashMigrationDialog), findsOneWidget);
        expect(_button('Open alphanet'), findsOneWidget);
        expect(find.byType(NetworkSwapPage), findsNothing);
        expect(rpc.calls.where((call) => call.startsWith('preview:') || call.startsWith('start:')), isEmpty);
        expect(conf.calls.where((call) => call.startsWith('select:')), isEmpty);
        expect(networkState.clears, 0);
        expect(conf.network, network);

        await tester.tap(_button('Open alphanet'));
        await _flush(tester);

        expect(conf.calls.where((call) => call.startsWith('select:')), ['select:alphanet']);
        expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_ECASH);
        expect(networkState.clears, 1);
        expect(rpc.calls.where((call) => call.startsWith('preview:') || call.startsWith('start:')), isEmpty);
        networkState.clearWait!.complete();
        await _flush(tester);

        expect(find.text('Preview migration'), findsOneWidget);
        expect(rpc.calls.where((call) => call.startsWith('preview:')), ['preview:alphanet:betanet']);
        expect(rpc.calls.where((call) => call.startsWith('start:')), isEmpty);
        await tester.tap(_button('Start migration'));
        await _flush(tester);

        expect(rpc.calls.where((call) => call.startsWith('start:')), ['start:alphanet:betanet']);
        expect(conf.calls.where((call) => call.startsWith('select:')), ['select:alphanet']);
        expectNoLegacyCalls();
        watcher?.dispose();
        await tester.tap(_button('Close'));
        await _flush(tester);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets('the banner keeps the source step after a source switch error', (tester) async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_MAINNET;
    conf.ecashNetworkId = 'betanet';
    conf.chainId = 'alphanet';
    conf.updateError = StateError('The source config is not available');
    final watcher = await showBanner(tester);
    await tester.tap(find.text('betanet is out'));
    await _flush(tester);
    await tester.tap(_button('Open alphanet'));
    await _flush(tester);

    expect(find.textContaining('The source config is not available'), findsOneWidget);
    expect(_button('Open alphanet'), findsOneWidget);
    expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_MAINNET);
    expect(networkState.clears, 0);
    expect(rpc.calls.where((call) => call.startsWith('preview:') || call.startsWith('start:')), isEmpty);
    conf.updateError = null;
    await tester.tap(_button('Open alphanet'));
    await _flush(tester);

    expect(conf.calls.where((call) => call.startsWith('select:')), ['select:alphanet', 'select:alphanet']);
    expect(networkState.clears, 1);
    expect(rpc.calls.where((call) => call.startsWith('preview:')), ['preview:alphanet:betanet']);
    expect(rpc.calls.where((call) => call.startsWith('start:')), isEmpty);
    expectNoLegacyCalls();
    watcher.dispose();
    await tester.tap(_button('Close'));
    await _flush(tester);
  });

  testWidgets('the completed migration banner opens its target from another active network', (tester) async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
    conf.ecashNetworkId = 'betanet';
    conf.chainId = 'betanet';
    rpc.saved = _status(jobId: 'job-1', complete: true);
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'betanet');
    final watcher = await showBanner(tester);
    await tester.tap(find.text('Migration to betanet complete'));
    await _flush(tester);

    expect(_button('Open betanet'), findsOneWidget);
    expect(_button('Open alphanet'), findsNothing);
    expect(conf.calls.where((call) => call.startsWith('select:')), isEmpty);
    await tester.tap(_button('Open betanet'));
    await _flush(tester);

    expect(conf.calls.where((call) => call.startsWith('select:')), ['select:betanet']);
    expect(networkState.clears, 1);
    expect(find.byType(ECashMigrationDialog), findsNothing);
    expect(rpc.calls.where((call) => call.startsWith('preview:') || call.startsWith('start:')), isEmpty);
    expectNoLegacyCalls();
    watcher.dispose();
  });

  testWidgets('the selector uses a normal switch when retained files already match the target', (tester) async {
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_MAINNET;
    conf.ecashNetworkId = 'betanet';
    conf.chainId = 'betanet';
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'betanet');
    await tester.pumpSailPage(const SettingsNetwork());
    await _flush(tester);
    await tester.tap(find.byType(SailDropdownButton<String>));
    await _flush(tester);
    await tester.tap(find.text('Betanet'));
    await _flush(tester);

    expect(find.byType(NetworkSwapPage), findsOneWidget);
    expect(find.byType(ECashMigrationDialog), findsNothing);
    expect(rpc.calls.where((call) => call.startsWith('preview:') || call.startsWith('start:')), isEmpty);
    expect(conf.calls.where((call) => call.startsWith('select:')), isEmpty);
    expectNoLegacyCalls();
    await tester.tap(_button('Cancel'));
    await _flush(tester);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the upgrade banner opens the migration preview and starts the daemon job', (tester) async {
    final watcher = await showBanner(tester);
    expect(find.text('betanet is out'), findsOneWidget);

    await tester.tap(find.text('betanet is out'));
    await _flush(tester);
    expect(find.byType(ECashMigrationDialog), findsOneWidget);
    expect(find.text('Preview migration'), findsOneWidget);
    expect(rpc.calls, contains('preview:alphanet:betanet'));

    await tester.tap(_button('Start migration'));
    await _flush(tester);
    expect(rpc.calls, contains('start:alphanet:betanet'));
    expect(find.text('Migration to betanet'), findsOneWidget);
    expectNoLegacyCalls();
    watcher.dispose();
    await tester.tap(_button('Close'));
    await _flush(tester);
  });

  testWidgets('a saved incomplete job opens without a published target', (tester) async {
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'betanet');
    rpc.saved = _status(jobId: 'job-1', error: 'Core stopped.');
    final watcher = await showBanner(tester);

    await tester.tap(find.text('Resume migration to betanet'));
    await _flush(tester);
    expect(find.byType(ECashMigrationDialog), findsOneWidget);
    expect(_button('Resume migration'), findsOneWidget);
    expect(rpc.calls, isNot(contains('pending')));
    expect(rpc.calls.where((call) => call.startsWith('preview:')), isEmpty);
    expectNoLegacyCalls();
    watcher.dispose();
    await tester.tap(_button('Close'));
    await _flush(tester);
  });

  testWidgets('the ECX selector opens preview instead of the network swap page', (tester) async {
    await tester.pumpSailPage(const SettingsNetwork());
    await _flush(tester);
    await tester.tap(find.byType(SailDropdownButton<String>));
    await _flush(tester);
    await tester.tap(find.text('Betanet'));
    await _flush(tester);

    expect(find.byType(ECashMigrationDialog), findsOneWidget);
    expect(find.text('Preview migration'), findsOneWidget);
    expect(find.byType(NetworkSwapPage), findsNothing);
    expect(conf.calls, ['prepare:betanet', 'resolve', 'plan:betanet']);
    expect(rpc.calls, contains('preview:alphanet:betanet'));
    expectNoLegacyCalls();
    await tester.tap(_button('Close'));
    await _flush(tester);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the watcher clears a status error after an empty status response', (tester) async {
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'alphanet');
    rpc.statusError = StateError('The status request failed.');
    final watcher = await showBanner(tester);
    final errorId = notices.activeBanner!.id;
    expect(find.text('Migration status unavailable'), findsOneWidget);
    expect(notices.history.single.read, isFalse);

    rpc.statusError = null;
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);

    expect(notices.history.single.id, errorId);
    expect(notices.history.single.read, isTrue);
    expect(notices.activeBanner, isNull);
    expect(find.text('Migration status unavailable'), findsNothing);
    watcher.dispose();
  });

  testWidgets('the watcher shows a later status error once after status recovery', (tester) async {
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'alphanet');
    rpc.statusError = StateError('The status request failed.');
    final watcher = await showBanner(tester);
    final firstId = notices.activeBanner!.id;

    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(notices.history, hasLength(1));
    expect(notices.activeBanner?.id, firstId);

    await notices.markRead(firstId);
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(notices.history, hasLength(1));
    expect(notices.activeBanner, isNull);

    rpc.statusError = null;
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    rpc.statusError = StateError('The next status request failed.');
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);

    expect(find.text('Migration status unavailable'), findsOneWidget);
    expect(notices.history, hasLength(2));
    expect(notices.history.singleWhere((notice) => notice.id == firstId).read, isTrue);
    final nextId = notices.activeBanner!.id;
    expect(nextId, isNot(firstId));
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(notices.history, hasLength(2));
    expect(notices.activeBanner?.id, nextId);
    watcher.dispose();
  });

  testWidgets('the watcher clears the saved fixed status error ID after an empty status response', (tester) async {
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'alphanet');
    notices.add(
      id: 'ecash-migration-status-error',
      title: 'Migration status unavailable',
      content: 'The status request failed.',
      dialogType: DialogType.error,
      style: NotificationStyle.banner,
      action: ecashUpgradeAction,
    );

    final watcher = await showBanner(tester);

    expect(notices.history.single.id, 'ecash-migration-status-error');
    expect(notices.history.single.read, isTrue);
    expect(notices.activeBanner, isNull);
    expect(find.text('Migration status unavailable'), findsNothing);
    watcher.dispose();
  });

  testWidgets('the watcher keeps migration and newer upgrade notices after status recovery', (tester) async {
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'betanet', pendingNetworkId: 'gammanet');
    final watcher = await showBanner(tester);
    final upgradeId = notices.activeBanner!.id;
    rpc.saved = _status(jobId: 'job-1', active: true);
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    final migrationId = notices.activeBanner!.id;

    rpc.statusError = StateError('The status request failed.');
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    final errorId = notices.activeBanner!.id;
    expect(find.text('Migration status unavailable'), findsOneWidget);
    rpc.statusError = null;
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);

    expect(notices.history.singleWhere((notice) => notice.id == errorId).read, isTrue);
    expect(notices.history.singleWhere((notice) => notice.id == migrationId).read, isFalse);
    expect(notices.history.singleWhere((notice) => notice.id == upgradeId).read, isFalse);
    expect(notices.history.where((notice) => !notice.read), hasLength(2));
    expect(find.text('Migration to betanet in progress'), findsOneWidget);
    watcher.dispose();
  });

  testWidgets('the watcher keeps migration state after target selection', (tester) async {
    final watcher = await showBanner(tester);
    expect(notices.activeBanner?.title, 'betanet is out');
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'betanet');
    conf.ecashNetworkId = 'betanet';
    rpc.saved = _status(jobId: 'job-1', active: true);

    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(find.text('Migration to betanet in progress'), findsOneWidget);
    expect(notices.history.singleWhere((notice) => notice.id == 'ecash-upgrade-betanet').read, isTrue);

    rpc.saved = _status(jobId: 'job-1', error: 'Core stopped.');
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(find.text('Resume migration to betanet'), findsOneWidget);
    expect(notices.activeBanner?.dialogType, DialogType.error);

    rpc.saved = _status(jobId: 'job-1', complete: true);
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(find.text('Migration to betanet complete'), findsOneWidget);
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(find.text('Migration to betanet complete'), findsOneWidget);
    expect(notices.history.where((notice) => !notice.read), hasLength(1));
    watcher.dispose();
  });

  testWidgets('the watcher restores the progress banner after resume', (tester) async {
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'betanet');
    rpc.saved = _status(jobId: 'job-1', active: true);
    final watcher = await showBanner(tester);
    expect(find.text('Migration to betanet in progress'), findsOneWidget);

    rpc.saved = _status(jobId: 'job-1', error: 'Core stopped.');
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(find.text('Resume migration to betanet'), findsOneWidget);

    rpc.saved = _status(jobId: 'job-1', active: true);
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(find.text('Migration to betanet in progress'), findsOneWidget);
    expect(notices.history.where((notice) => !notice.read), hasLength(1));

    rpc.saved = _status(jobId: 'job-1', error: 'Core stopped again.');
    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(find.text('Resume migration to betanet'), findsOneWidget);
    expect(notices.activeBanner?.dialogType, DialogType.error);
    expect(notices.history.where((notice) => !notice.read), hasLength(1));
    watcher.dispose();
  });

  testWidgets('a future upgrade stays available after a completed migration', (tester) async {
    conf.ecashNetworkId = 'betanet';
    rpc.saved = _status(jobId: 'job-1', complete: true);
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'betanet', pendingNetworkId: 'gammanet');
    final watcher = await showBanner(tester);
    expect(find.text('gammanet is out'), findsOneWidget);

    await tester.pump(const Duration(seconds: 15));
    await _flush(tester);
    expect(find.text('gammanet is out'), findsOneWidget);
    await tester.tap(find.text('gammanet is out'));
    await _flush(tester);
    expect(find.text('Preview migration'), findsOneWidget);
    expect(find.text('betanet → gammanet'), findsOneWidget);
    expect(rpc.calls, contains('preview:betanet:gammanet'));
    expectNoLegacyCalls();
    watcher.dispose();
    await tester.tap(_button('Close'));
    await _flush(tester);
  });

  testWidgets('settings shows an empty state when no upgrade or saved job exists', (tester) async {
    rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'alphanet');
    await tester.pumpSailPage(const SettingsNetwork());
    await _flush(tester);

    await tester.tap(_button('Open'));
    await _flush(tester);
    expect(find.text('No network upgrade or saved migration is available.'), findsOneWidget);
    expect(find.byType(ECashMigrationDialog), findsNothing);
    expect(_button('Start migration'), findsNothing);
    expectNoLegacyCalls();
    await tester.tap(_button('Close'));
    await _flush(tester);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final test in [
    (name: 'empty data', localBackends: true, hasChainData: false),
    (name: 'light mode', localBackends: false, hasChainData: true),
  ]) {
    testWidgets('the selector uses the normal switch for ${test.name}', (tester) async {
      conf.localBackends = test.localBackends;
      conf.hasChainData = test.hasChainData;
      rpc.pending = pb.GetPendingNetworkGenerationResponse(currentNetworkId: 'alphanet');
      await tester.pumpSailPage(const SettingsNetwork());
      await _flush(tester);
      await tester.tap(find.byType(SailDropdownButton<String>));
      await _flush(tester);
      await tester.tap(find.text('Betanet'));
      await _flush(tester);

      expect(find.byType(ECashMigrationDialog), findsNothing);
      await tester.tap(_button('Switch to betanet'));
      await _flush(tester);
      expect(find.byType(NetworkSwapPage), findsOneWidget);
      expect(rpc.calls.where((call) => call.startsWith('preview:') || call.startsWith('start:')), isEmpty);
      expectNoLegacyCalls();
      await tester.tap(_button('Cancel'));
      await _flush(tester);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the banner uses the normal switch for ${test.name}', (tester) async {
      conf.localBackends = test.localBackends;
      conf.hasChainData = test.hasChainData;
      final watcher = await showBanner(tester);
      await tester.tap(find.text('betanet is out'));
      await _flush(tester);

      expect(find.byType(ECashUpgradeDialog), findsOneWidget);
      expect(find.byType(ECashMigrationDialog), findsNothing);
      expect(_button('Switch to betanet'), findsOneWidget);
      expect(rpc.calls.where((call) => call.startsWith('preview:') || call.startsWith('start:')), isEmpty);
      expectNoLegacyCalls();
      watcher.dispose();
      await tester.tap(_button('Cancel'));
      await _flush(tester);
    });
  }
}
