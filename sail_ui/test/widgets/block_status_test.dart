// Behind a UTXO snapshot Core reports the tip long before it verifies the
// blocks below it, so one bar reads 100% while the node is 61% done. The card
// draws a bar per sync the daemon reports.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

SyncInfo info({
  double current = 996466,
  double goal = 996466,
  int verified = 0,
  int verifiedGoal = 0,
}) => SyncInfo(
  progressCurrent: current,
  progressGoal: goal,
  lastBlockAt: null,
  verifiedBlocks: verified,
  verifiedGoal: verifiedGoal,
);

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 900, child: child),
        ),
      ),
    ),
  );

  group('rowsFor', () {
    test('a plain node reports the chain tip alone', () {
      final rows = BlockStatus.rowsFor(info());

      expect(rows.map((r) => r.label), ['Blocks']);
      expect(rows.single.current, 996466);
    });

    test('a node behind a snapshot adds the verified height', () {
      final rows = BlockStatus.rowsFor(info(verified: 796524, verifiedGoal: 880000));

      expect(rows.map((r) => r.label), ['Blocks', 'Verified']);
      expect(rows[1].current, 796524);
    });

    // Verification finishes at the snapshot base, not the chain tip. Against
    // headers the bar would read 90% at the moment Core is done.
    test('the verified row counts towards the snapshot base, not the tip', () {
      final rows = BlockStatus.rowsFor(info(verified: 880000, verifiedGoal: 880000));

      expect(rows[0].goal, 996466);
      expect(rows[1].goal, 880000);
      expect(rows[1].current, rows[1].goal);
    });

    test('a verified height with no goal adds no row', () {
      expect(BlockStatus.rowsFor(info(verified: 796524)).length, 1);
    });

    test('a zero height adds no row', () {
      expect(BlockStatus.rowsFor(info(verified: 0)).length, 1);
    });
  });

  group('sizing', () {
    test('one bar carries no label column', () {
      expect(progressBlockWidth(1), progressBarWidth);
    });

    test('two bars make room for the label column', () {
      expect(progressBlockWidth(2), syncLabelWidth + SailStyleValues.padding08 + progressBarWidth);
    });

    test('a null sync info still holds one row', () {
      expect(syncRowCount(null), 1);
    });

    test('a snapshot node holds two rows', () {
      expect(syncRowCount(info(verified: 796524, verifiedGoal: 880000)), 2);
    });
  });

  testWidgets('a synced node draws its height as text, not a bar', (tester) async {
    await tester.pumpWidget(wrap(BlockStatus(name: 'Bitcoin Core', syncInfo: info())));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(ProgressBar), findsNothing);
    expect(find.text('Blocks'), findsNothing);
  });

  testWidgets('a node behind a snapshot draws both bars with labels', (tester) async {
    await tester.pumpWidget(
      wrap(BlockStatus(name: 'Bitcoin Core', syncInfo: info(verified: 796524, verifiedGoal: 880000))),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(ProgressBar), findsNWidgets(2));
    expect(find.text('Blocks'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
  });

  group('allSyncsComplete', () {
    test('a plain node at the tip is complete', () {
      expect(info().allSyncsComplete, isTrue);
    });

    test('a snapshot node at the tip is not complete until it verifies', () {
      final snapshot = info(verified: 796524, verifiedGoal: 880000);

      expect(snapshot.isSynced, isTrue);
      expect(snapshot.allSyncsComplete, isFalse);
    });

    test('a snapshot node that reached the snapshot base is complete', () {
      expect(info(verified: 880000, verifiedGoal: 880000).allSyncsComplete, isTrue);
    });
  });
}
