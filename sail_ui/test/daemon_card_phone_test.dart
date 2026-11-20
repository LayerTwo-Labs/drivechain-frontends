import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class _Daemon extends ChangeNotifier implements DaemonState {
  @override
  final Binary binary = Enforcer();

  @override
  bool get connected => false;

  @override
  bool get initializingBinary => false;

  @override
  bool get stoppingBinary => false;

  @override
  String? get connectionError => null;

  @override
  String? get startupError => null;
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [BitcoinCore(), Enforcer()]),
    );
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  Future<void> pumpCard(WidgetTester tester, double width) async {
    await tester.binding.setSurfaceSize(Size(width, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: DaemonConnectionCard(
                connection: _Daemon(),
                syncInfo: null,
                infoMessage: null,
                remoteBadge: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a phone puts the status on a grey line under the daemon name', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pumpCard(tester, 390);

    expect(tester.takeException(), isNull);
    expect(find.byType(DaemonStatusBlock), findsNothing);
    final name = tester.getRect(find.text(Enforcer().name));
    final status = tester.getRect(find.text('Not connected'));
    expect(status.top, greaterThan(name.bottom - 1));
    expect(status.left, name.left);
  });

  testWidgets('the desktop keeps the status block under the head', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pumpCard(tester, 1000);

    expect(find.byType(DaemonStatusBlock), findsOneWidget);
  });
}
