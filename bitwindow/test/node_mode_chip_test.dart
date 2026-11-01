import 'dart:async';
import 'dart:io';

import 'package:bitwindow/widgets/node_mode_chip.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  bool hasPrivateBitcoinConf = false;

  bool dataDir = false;
  Completer<void>? saveGate;

  @override
  Future<void> updateDataDir(String? dataDir, {required BitcoinNetwork forNetwork}) async {
    await saveGate?.future;
    this.dataDir = dataDir != null;
  }

  @override
  Future<void> commitNetworkChange(BitcoinNetwork newNetwork) async {}

  @override
  bool get mustSelectDatadir => !dataDir;

  @override
  bool hasDataDirFor(BitcoinNetwork network) => dataDir;

  @override
  Future<void> loadConfig({bool isFirst = false, bool userInitiated = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePicker extends FilePickerPlatform {
  _FakePicker(this.path);

  final String path;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => path;
}

class _FakeWallet implements OrchestratorWalletRPC {
  final List<wmpb.NodeMode> selections = [];

  @override
  Future<void> setNodeMode(wmpb.NodeMode next) async => selections.add(next);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final _FakeWallet wallet = _FakeWallet();

  final List<String> starts = [];

  @override
  Future<orch_pb.StartWithL1Response> startWithL1(
    String target, {
    List<String>? targetArgs,
    Map<String, String>? targetEnv,
    List<String>? coreArgs,
    List<String>? enforcerArgs,
    bool immediate = false,
    bool forceBackend = false,
  }) async {
    starts.add(target);
    return orch_pb.StartWithL1Response();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(Widget child) => SailTheme(
  data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
  child: MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  late _FakeConf conf;
  late _FakeOrchestrator orchestrator;
  late NodeModeProvider nodeMode;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    conf = _FakeConf();
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
    orchestrator = _FakeOrchestrator();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
    nodeMode = NodeModeProvider()
      ..mode = wmpb.NodeMode.NODE_MODE_LIGHT
      ..localBuildsAvailable = true;
    GetIt.I.registerSingleton<NodeModeProvider>(nodeMode);
  });

  tearDown(() async => GetIt.I.reset());

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_host(child));
    await tester.pump();
  }

  testWidgets('the chip names the mode and follows a switch', (tester) async {
    await pump(tester, const NodeModeChip());
    expect(find.text('Light'), findsOneWidget);

    nodeMode.mode = wmpb.NodeMode.NODE_MODE_FULL;
    nodeMode.notifyListeners();
    await tester.pump();
    expect(find.text('Full node'), findsOneWidget);
  });

  testWidgets('a click opens the popover with both mode cards', (tester) async {
    await pump(tester, const NodeModeChip());

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(find.text('Node mode'), findsOneWidget);
    expect(find.byType(NodeModeCard), findsNWidgets(2));

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Node mode'), findsNothing);
  });

  testWidgets('full mode with no data directory asks for one first', (tester) async {
    await pump(tester, NodeModePopover(onDone: () {}));

    await tester.tap(find.text('Full node'));
    await tester.pump();
    expect(find.widgetWithText(SailButton, 'Confirm node mode'), findsWidgets);

    await tester.tap(find.widgetWithText(SailButton, 'Confirm node mode').first);
    await tester.pump();
    await tester.pump();

    expect(find.text('Configure Data Directory'), findsOneWidget);
    expect(find.text('No directory selected'), findsOneWidget);
    final next = tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Continue')).first;
    expect(next.disabled, isTrue);
    expect(orchestrator.wallet.selections, isEmpty);

    await tester.tap(find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.chevronLeft));
    await tester.pump();
    expect(find.text('Node mode'), findsOneWidget);
  });

  testWidgets('full mode with a data directory switches at once', (tester) async {
    conf.dataDir = true;
    var done = 0;
    await pump(tester, NodeModePopover(onDone: () => done++));

    await tester.tap(find.text('Full node'));
    await tester.pump();
    await tester.tap(find.widgetWithText(SailButton, 'Switch to full mode').first);
    await tester.pump();
    await tester.pump();

    expect(orchestrator.wallet.selections, [wmpb.NodeMode.NODE_MODE_FULL]);
    expect(nodeMode.isFull, isTrue);
    expect(done, 1);
  });

  testWidgets('a full mode install with no directory opens on the data directory page', (tester) async {
    nodeMode.mode = wmpb.NodeMode.NODE_MODE_FULL;
    await pump(tester, NodeModePopover(onDone: () {}, dataDirFirst: true));

    expect(find.text('Configure Data Directory'), findsOneWidget);
  });

  testWidgets('a boot request opens the mounted chip on the data directory page', (tester) async {
    nodeMode.mode = wmpb.NodeMode.NODE_MODE_FULL;
    await pump(tester, const NodeModeChip());

    NodeModeChip.open(dataDir: true);
    await tester.pumpAndSettle();
    expect(find.text('Configure Data Directory'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Configure Data Directory'), findsNothing);

    await tester.tap(find.text('Full node'));
    await tester.pumpAndSettle();
    expect(find.text('Node mode'), findsOneWidget, reason: 'a plain click opens the mode cards');

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a full mode install with no directory can still reach the directory page', (tester) async {
    nodeMode.mode = wmpb.NodeMode.NODE_MODE_FULL;
    await pump(tester, NodeModePopover(onDone: () {}));

    final confirm = tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Confirm node mode')).first;
    expect(confirm.disabled, isFalse);

    await tester.tap(find.widgetWithText(SailButton, 'Confirm node mode').first);
    await tester.pump();
    expect(find.text('Configure Data Directory'), findsOneWidget);
  });

  testWidgets('the popover stays inside the window at the right edge', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _host(const Align(alignment: Alignment.bottomRight, child: NodeModeChip())),
    );
    await tester.pump();

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    final popover = tester.getRect(find.byType(NodeModePopover));
    expect(popover.right, lessThanOrEqualTo(800));
    expect(popover.left, greaterThanOrEqualTo(0));

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a click outside does not drop a switch that saves the directory', (tester) async {
    final dir = Directory.systemTemp.createTempSync('node-mode-dir');
    addTearDown(() => dir.deleteSync(recursive: true));
    final previous = FilePickerPlatform.instance;
    FilePickerPlatform.instance = _FakePicker(dir.path);
    addTearDown(() => FilePickerPlatform.instance = previous);

    nodeMode.mode = wmpb.NodeMode.NODE_MODE_FULL;
    await pump(tester, const NodeModeChip());
    NodeModeChip.open(dataDir: true);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(SailButton, 'Browse').first);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    expect(find.text(dir.path), findsOneWidget);

    conf.saveGate = Completer<void>();
    await tester.tap(find.widgetWithText(SailButton, 'Continue').first);
    await tester.pump();

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.text('Configure Data Directory'), findsOneWidget, reason: 'the save holds the popover open');

    await tester.tap(find.text('Full node').first, warnIfMissed: false);
    await tester.pump();
    expect(find.text('Configure Data Directory'), findsOneWidget, reason: 'the chip does not close it either');

    conf.saveGate!.complete();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(orchestrator.wallet.selections, [wmpb.NodeMode.NODE_MODE_FULL]);
    expect(find.text('Configure Data Directory'), findsNothing);
  });
}
