import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;
import 'package:sidechain_core/mocks/mocks.dart';

class _Explorer extends Fake implements OrchestratorExplorerRPC {
  int overviews = 0;

  @override
  Future<pb.GetOverviewResponse> getOverview(String chain) async {
    overviews++;
    return pb.GetOverviewResponse();
  }
}

class _Store implements KeyValueStore {
  final _values = <String, String>{};

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> update(String key, String Function(String? current) change) async {
    await setString(key, change(await getString(key)));
  }
}

class _Orchestrator extends Fake implements OrchestratorRPC {
  @override
  final OrchestratorExplorerRPC explorer;

  _Orchestrator(this.explorer);
}

void main() {
  late _Explorer explorer;

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger(level: Level.off);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: _Store(), log: log));
    GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: _Store(), log: log));
    GetIt.I.registerSingleton<SettingsProvider>(await SettingsProvider.create());
    GetIt.I.registerSingleton<BinaryProvider>(MockBinaryProvider());
    GetIt.I.registerSingleton<SidechainRPC>(MockThunderRPC());
    explorer = _Explorer();
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator(explorer));
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('a hidden explorer stops its refresh, and reads at once when it shows again', (tester) async {
    final shown = ValueNotifier(true);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: child!,
        ),
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: shown,
            builder: (context, enabled, _) => TickerMode(enabled: enabled, child: const ChainExplorerTab()),
          ),
        ),
      ),
    );
    expect(explorer.overviews, 1);
    await tester.pump(explorerRefreshInterval);
    expect(explorer.overviews, 2);

    shown.value = false;
    await tester.pump();
    await tester.pump(explorerRefreshInterval * 5);
    expect(explorer.overviews, 2);

    shown.value = true;
    await tester.pump();
    expect(explorer.overviews, 3);

    await tester.pumpWidget(const SizedBox());
  });
}
