import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

final _proposals = [
  SidechainProposal(
    slot: 9,
    title: 'Zeta',
    description: 'Second',
    voteCount: 1,
    proposalAge: 30,
    proposalHeight: 1204,
    dataHash: 'bb',
  ),
  SidechainProposal(
    slot: 7,
    title: 'Alpha',
    description: 'First',
    voteCount: 4,
    proposalAge: 10,
    proposalHeight: 1180,
    dataHash: 'aa',
  ),
];

void main() {
  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
  });

  tearDown(() => GetIt.I.reset());

  Future<void> pumpTable(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 600));
    await tester.pumpSailPage(
      SizedBox(
        width: 1500,
        height: 500,
        child: PendingSidechainProposalsTable(proposals: [..._proposals], activeSlots: const {9}),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<String> shownTitles(WidgetTester tester) => tester
      .widgetList<SailTableCell>(find.byType(SailTableCell))
      .map((cell) => cell.value)
      .where((v) => v == 'Alpha' || v == 'Zeta')
      .toList();

  testWidgets('shows the title, the description and the replacement', (tester) async {
    await pumpTable(tester);

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('shows the proposal height under Height', (tester) async {
    await pumpTable(tester);

    expect(find.text('Fails'), findsNothing);
    expect(find.text('Height'), findsOneWidget);
    expect(find.text('1204'), findsOneWidget);
    expect(find.text('1180'), findsOneWidget);
  });

  testWidgets('sorts the rows by slot at first', (tester) async {
    await pumpTable(tester);

    expect(shownTitles(tester), ['Alpha', 'Zeta']);
  });

  testWidgets('a tap on Age sorts the rows by age', (tester) async {
    await pumpTable(tester);

    await tester.tap(find.text('Age'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Age'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(shownTitles(tester), ['Zeta', 'Alpha']);
  });

  testWidgets('a tap on each header sorts without an error', (tester) async {
    await pumpTable(tester);

    for (final header in ['Vote', 'SC #', 'Replacement', 'Title', 'Description', 'Age', 'Height', 'Hash']) {
      await tester.tap(find.text(header));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: header);
    }
  });
}
