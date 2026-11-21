import 'package:bitwindow/pages/sidechain_proposal_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _FakeSidechains extends ChangeNotifier implements SidechainProvider {
  @override
  List<SidechainProposal> sidechainProposals = [];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUp(() {
    if (!GetIt.I.isRegistered<SidechainProvider>()) {
      GetIt.I.registerSingleton<SidechainProvider>(_FakeSidechains());
    }
  });

  testWidgets('the proposal form renders', (tester) async {
    await tester.pumpSailPage(const SidechainProposalView());

    expect(tester.takeException(), isNull);
    expect(find.text('Required'), findsOneWidget);
  });

  group('field errors', () {
    late _FakeSidechains sidechains;

    setUp(() {
      GetIt.I.allowReassignment = true;
      sidechains = _FakeSidechains()..sidechainProposals = [SidechainProposal(slot: 9, title: 'Thunder')];
      GetIt.I.registerSingleton<SidechainProvider>(sidechains);
    });

    Finder field(String label) => find.descendant(
      of: find.byWidgetPredicate((w) => w is SailTextFormField && w.label == label),
      matching: find.byType(TextField),
    );

    Future<void> submit(WidgetTester tester) async {
      await tester.tap(find.text('Propose Sidechain'));
      await tester.pumpAndSettle();
    }

    testWidgets('a submit shows why the form is not valid', (tester) async {
      await tester.pumpSailPage(const SidechainProposalView());

      await tester.enterText(field('Slot #'), '9');
      await tester.enterText(field('Release tarball hash (256 bits)'), 'abcd');
      await submit(tester);

      expect(find.text('Slot 9 already has a pending proposal'), findsOneWidget);
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Hash must be 256 bits long'), findsOneWidget);
    });

    testWidgets('the slot error shows in full', (tester) async {
      await tester.pumpSailPage(const SidechainProposalView());

      await tester.enterText(field('Slot #'), '9');
      await submit(tester);

      final error = tester.renderObject<RenderParagraph>(find.text('Slot 9 already has a pending proposal'));
      expect(error.didExceedMaxLines, isFalse);
    });

    testWidgets('an error goes away when the user corrects the field', (tester) async {
      await tester.pumpSailPage(const SidechainProposalView());

      await tester.enterText(field('Slot #'), '256');
      await submit(tester);
      expect(find.text('Slot must be between 0 and 255'), findsOneWidget);

      await tester.enterText(field('Slot #'), '1');
      await tester.pumpAndSettle();
      expect(find.text('Slot must be between 0 and 255'), findsNothing);
    });

    testWidgets('the BBC values show no error', (tester) async {
      await tester.pumpSailPage(const SidechainProposalView());

      await tester.enterText(field('Slot #'), '1');
      await tester.enterText(field('Title'), 'Big Block Covenant');
      await tester.enterText(field('Description'), 'Covenant sidechain: CTV, CAT, CSFS, APO, CCV');
      await tester.enterText(
        field('Release tarball hash (256 bits)'),
        '22d122c47aa4978e4db85313038aac323b89baf34745484be885b5b45da008b6',
      );
      await tester.enterText(field('Build commit hash (160 bits)'), '835269a5de15113dd78418917128da0c48c8904d');
      await tester.pumpAndSettle();

      final state = tester.state<FormState>(find.byType(Form));
      expect(state.validate(), isTrue);
    });
  });
}
