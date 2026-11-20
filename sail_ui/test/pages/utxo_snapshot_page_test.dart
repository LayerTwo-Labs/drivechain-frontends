import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class _FailingSnapshotBinaryProvider extends BinaryProvider {
  _FailingSnapshotBinaryProvider({required super.appDir, required super.binaries}) : super.test();

  @override
  Stream<ApplyUTXOSnapshotResponse> applyUTXOSnapshot({String url = '', String path = '', String sha256 = ''}) {
    return Stream.error(Exception('snapshot file: no such file or directory'));
  }
}

void main() {
  setUp(() async {
    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<Logger>(Logger(level: Level.off));
    getIt.registerSingleton<BinaryProvider>(
      _FailingSnapshotBinaryProvider(appDir: Directory.systemTemp, binaries: [BitcoinCore()]),
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('a failed snapshot does not mark the load step as completed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.darkTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: const UTXOSnapshotPage(filePath: '/tmp/missing.dat'),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(SailButton, 'Load snapshot').first);
    await tester.pumpAndSettle();

    expect(find.text('Snapshot Failed'), findsOneWidget);
    final step = tester.widget<ProgressStepTile>(find.byType(ProgressStepTile));
    expect(step.isCompleted, isFalse);
    expect(step.isActive, isFalse);
    expect(step.duration, isNull);
  });
}
