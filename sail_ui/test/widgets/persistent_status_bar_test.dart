import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// BinaryProvider double that exposes setters for the exact fields the
/// PersistentStatusBar inspects (isConnected / isInitializing / isStopping /
/// connectionError) and records calls to [start].
class _FakeBinaryProvider extends BinaryProvider {
  final Map<BinaryType, bool> _connected = {};
  final Map<BinaryType, bool> _initializing = {};
  final Map<BinaryType, bool> _stopping = {};
  final Map<BinaryType, String?> _errors = {};
  final List<BinaryType> startedTypes = [];

  _FakeBinaryProvider({required super.appDir, required super.binaries}) : super.test();

  void setState(
    BinaryType type, {
    bool connected = false,
    bool initializing = false,
    bool stopping = false,
    String? error,
  }) {
    _connected[type] = connected;
    _initializing[type] = initializing;
    _stopping[type] = stopping;
    _errors[type] = error;
    notifyListeners();
  }

  @override
  bool isConnected(Binary binary) => _connected[binary.type] ?? false;

  @override
  bool isInitializing(Binary binary) => _initializing[binary.type] ?? false;

  @override
  bool isStopping(Binary binary) => _stopping[binary.type] ?? false;

  @override
  String? connectionError(Binary binary) => _errors[binary.type];

  @override
  Future<void> start(Binary binary) async {
    startedTypes.add(binary.type);
  }

  @override
  Future<void> stop(Binary binary, {bool skipDownstream = false}) async {}
}

class _MockStore implements KeyValueStore {
  final _db = <String, String>{};

  @override
  Future<String?> getString(String key) async => _db[key];

  @override
  Future<void> setString(String key, String value) async {
    _db[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _db.remove(key);
  }
}

void main() {
  late _FakeBinaryProvider binaryProvider;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    final getIt = GetIt.instance;
    await getIt.reset();

    final log = Logger(level: Level.off);
    getIt.registerSingleton<Logger>(log);

    getIt.registerSingleton<ClientSettings>(ClientSettings(store: _MockStore(), log: log));
    getIt.registerSingleton<BitwindowClientSettings>(
      BitwindowClientSettings(store: _MockStore(), log: log),
    );
    getIt.registerSingleton<SettingsProvider>(await SettingsProvider.create());

    binaryProvider = _FakeBinaryProvider(
      appDir: Directory.systemTemp,
      binaries: [Orchestratord(), BitWindow()],
    );
    getIt.registerSingleton<BinaryProvider>(binaryProvider);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(
          SailColorScheme.orange,
          true,
          SailFontValues.inter,
        ),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('collapses to shrink when both daemons are healthy', (tester) async {
    binaryProvider.setState(BinaryType.orchestratord, connected: true);
    binaryProvider.setState(BinaryType.bitWindow, connected: true);

    await tester.pumpWidget(wrap(const PersistentStatusBar()));
    await tester.pump();

    expect(find.text('Restart'), findsNothing);
    expect(find.byIcon(Icons.error_outline), findsNothing);
    final size = tester.getSize(find.byType(PersistentStatusBar));
    expect(size.height, 0);
  });

  testWidgets('collapses to shrink while a daemon is initializing', (tester) async {
    binaryProvider.setState(BinaryType.orchestratord, initializing: true, error: 'boot error');
    binaryProvider.setState(BinaryType.bitWindow, connected: true);

    await tester.pumpWidget(wrap(const PersistentStatusBar()));
    await tester.pump();

    expect(find.text('Restart'), findsNothing);
    final size = tester.getSize(find.byType(PersistentStatusBar));
    expect(size.height, 0);
  });

  testWidgets('shows error banner only when a daemon has a terminal error', (tester) async {
    binaryProvider.setState(BinaryType.orchestratord, error: 'connection refused');
    binaryProvider.setState(BinaryType.bitWindow, connected: true);

    await tester.pumpWidget(wrap(const PersistentStatusBar()));
    await tester.pump();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Orchestratord'), findsOneWidget);
    // SailButton renders its label twice (visual shadow layer), so accept widgets.
    expect(find.text('Restart'), findsWidgets);
  });

  testWidgets('tapping Restart calls BinaryProvider.start for every broken daemon', (tester) async {
    binaryProvider.setState(BinaryType.orchestratord, error: 'down');
    binaryProvider.setState(BinaryType.bitWindow, error: 'down');

    await tester.pumpWidget(wrap(const PersistentStatusBar()));
    await tester.pump();

    await tester.tap(find.byType(SailButton));
    await tester.pumpAndSettle();

    expect(
      binaryProvider.startedTypes,
      containsAll(<BinaryType>[BinaryType.orchestratord, BinaryType.bitWindow]),
    );
  });

  testWidgets('mounts cleanly as Scaffold.bottomNavigationBar under MaterialApp.builder (crash regression)', (
    tester,
  ) async {
    // Regression for crash on launch: the bitwindow main.dart composition is
    //   MaterialApp.router(builder: (_, child) => Scaffold(
    //     body: child, bottomNavigationBar: PersistentStatusBar()))
    // The bar must render with no "No Material widget"/"No Overlay widget"/
    // unbounded-constraints errors regardless of daemon state.
    binaryProvider.setState(BinaryType.orchestratord, error: 'down');
    binaryProvider.setState(BinaryType.bitWindow, error: 'down');

    tester.view.physicalSize = const Size(4000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(
          SailColorScheme.orange,
          true,
          SailFontValues.inter,
        ),
        child: MaterialApp(
          builder: (context, child) => Scaffold(
            body: child ?? const SizedBox.shrink(),
            bottomNavigationBar: const PersistentStatusBar(),
          ),
          home: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pump();

    final errors = <String>[];
    dynamic err = tester.takeException();
    while (err != null) {
      errors.add(err.toString());
      err = tester.takeException();
    }
    final joined = errors.join('\n');
    expect(joined, isNot(contains('No Material widget')));
    expect(joined, isNot(contains('No Overlay widget')));
    expect(joined, isNot(contains('requires bounded constraints')));
    expect(find.byType(PersistentStatusBar), findsOneWidget);
  });
}
