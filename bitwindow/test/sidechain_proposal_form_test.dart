import 'package:bitwindow/pages/sidechain_proposal_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/drivechain/v1/drivechain.pb.dart';

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

  // Regression: the submit button read isFormValid during build, and that
  // getter called FormState.validate(), which calls setState() on the Form.
  // The page then failed to render with "setState() or markNeedsBuild()
  // called during build".
  testWidgets('the proposal form renders', (tester) async {
    await tester.pumpSailPage(const SidechainProposalView());

    expect(tester.takeException(), isNull);
    expect(find.text('Required'), findsOneWidget);
  });

  group('isFormValid', () {
    late SidechainProposalViewModel model;

    setUp(() {
      GetIt.I.allowReassignment = true;
      GetIt.I.registerSingleton<SidechainProvider>(_FakeSidechains());
      model = SidechainProposalViewModel();
    });

    tearDown(() => model.dispose());

    test('an empty form is not valid', () {
      expect(model.isFormValid, isFalse);
    });

    test('a slot and a title are sufficient', () {
      model.slotController.text = '1';
      model.titleController.text = 'Big Block Covenant';
      expect(model.isFormValid, isTrue);
    });

    test('a slot above 255 is not valid', () {
      model.slotController.text = '256';
      model.titleController.text = 'Big Block Covenant';
      expect(model.isFormValid, isFalse);
    });

    test('a short tarball hash is not valid', () {
      model.slotController.text = '1';
      model.titleController.text = 'Big Block Covenant';
      model.tarballHashController.text = 'abcd';
      expect(model.isFormValid, isFalse);
    });

    test('the BBC values are valid', () {
      model.slotController.text = '1';
      model.titleController.text = 'Big Block Covenant';
      model.descriptionController.text = 'Covenant sidechain: CTV, CAT, CSFS, APO, CCV';
      model.tarballHashController.text = '22d122c47aa4978e4db85313038aac323b89baf34745484be885b5b45da008b6';
      model.commitHashController.text = '835269a5de15113dd78418917128da0c48c8904d';
      expect(model.isFormValid, isTrue);
    });
  });
}
