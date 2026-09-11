import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

SyncInfo syncing(MainchainSyncPhase phase, double done, {double total = 997070, int tip = 997070}) => SyncInfo(
  progressCurrent: done,
  progressGoal: total,
  lastBlockAt: null,
  mainchainSyncPhase: phase,
  mainchainTipHeight: tip,
);

const headers = MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_HEADERS;
const state = MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_STATE;
const writing = MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_WRITING;
const other = MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_OTHER;

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 350, child: child),
        ),
      ),
    ),
  );

  double barFill(WidgetTester tester) =>
      tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor!;

  testWidgets('the headers phase shows its label, percent, counts and max height', (tester) async {
    await tester.pumpWidget(wrap(BlockStatus(name: 'Thunder', syncInfo: syncing(headers, 412000))));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Fetching mainchain headers'), findsOneWidget);
    expect(find.text('41.3%'), findsOneWidget);
    expect(find.text('412,000 / 997,070 headers'), findsOneWidget);
    expect(find.text('Max height 997,070'), findsOneWidget);
    expect(find.byType(ProgressBar), findsNothing);
  });

  testWidgets('the state phase shows its label, percent, counts and max height', (tester) async {
    await tester.pumpWidget(wrap(BlockStatus(name: 'Thunder', syncInfo: syncing(state, 310))));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Syncing mainchain state'), findsOneWidget);
    expect(find.text('0.0%'), findsOneWidget);
    expect(find.text('310 / 997,070 blocks'), findsOneWidget);
    expect(find.text('Max height 997,070'), findsOneWidget);
  });

  testWidgets('the writing phase shows its label, percent, counts and max height', (tester) async {
    await tester.pumpWidget(wrap(BlockStatus(name: 'Thunder', syncInfo: syncing(writing, 500000))));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Writing mainchain headers'), findsOneWidget);
    expect(find.text('50.1%'), findsOneWidget);
    expect(find.text('500,000 / 997,070 headers'), findsOneWidget);
    expect(find.text('Max height 997,070'), findsOneWidget);
  });

  testWidgets('a phase this build does not name shows a plain mainchain bar', (tester) async {
    await tester.pumpWidget(wrap(BlockStatus(name: 'Thunder', syncInfo: syncing(other, 1000))));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Syncing mainchain'), findsOneWidget);
    expect(find.text('0.1%'), findsOneWidget);
    expect(find.text('1,000 / 997,070'), findsOneWidget);
    expect(find.text('Max height 997,070'), findsOneWidget);
  });

  testWidgets('a phase one item short of its total does not read as done', (tester) async {
    await tester.pumpWidget(wrap(BlockStatus(name: 'Thunder', syncInfo: syncing(headers, 997069))));
    await tester.pumpAndSettle();

    expect(find.text('99.9%'), findsOneWidget);
  });

  testWidgets('the compact loader keeps the counts and max height in its tooltip', (tester) async {
    await tester.pumpWidget(
      wrap(ChainLoader(name: 'Thunder', syncInfo: syncing(headers, 412000), justPercent: true, expanded: false)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Fetching mainchain headers'), findsOneWidget);
    expect(find.text('41.3%'), findsOneWidget);
    expect(find.byTooltip('Fetching mainchain headers\n412,000 / 997,070 headers\nMax height 997,070'), findsOneWidget);
  });

  testWidgets('a new phase starts its bar at zero, not at the last phase fill', (tester) async {
    await tester.pumpWidget(wrap(BlockStatus(name: 'Thunder', syncInfo: syncing(headers, 997070))));
    await tester.pumpAndSettle();
    expect(barFill(tester), 1.0);

    await tester.pumpWidget(wrap(BlockStatus(name: 'Thunder', syncInfo: syncing(state, 310))));
    await tester.pump(const Duration(milliseconds: 100));

    expect(barFill(tester), lessThan(0.01));
  });

  testWidgets('a node without the phase keeps the block count bar', (tester) async {
    await tester.pumpWidget(
      wrap(
        BlockStatus(
          name: 'Thunder',
          syncInfo: SyncInfo(progressCurrent: 0, progressGoal: 294, lastBlockAt: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProgressBar), findsOneWidget);
    expect(find.byType(MainchainSyncStatus), findsNothing);
  });

  test('a node in a phase is not synced, even at the phase total', () {
    expect(syncing(headers, 997070).isSynced, isFalse);
  });
}
