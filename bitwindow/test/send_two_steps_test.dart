import 'dart:async';

import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:bitwindow/widgets/grouped_address.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletpsbt/v1/walletpsbt.pb.dart';

import 'test_utils.dart';

void main() {
  group('buildSignAndSave', () {
    late List<String> saved;
    late List<String> discarded;
    late bool canceled;

    setUp(() {
      saved = [];
      discarded = [];
      canceled = false;
    });

    Future<PsbtDraft> save(String psbt) async {
      saved.add(psbt);
      return PsbtDraft(id: 'draft-${saved.length}', psbtBase64: psbt);
    }

    Future<void> discard(String id) async => discarded.add(id);

    test('signs the PSBT before the save', () async {
      final draft = await buildSignAndSave(
        build: () async => 'unsigned',
        sign: (psbt) async => '$psbt+signed',
        save: save,
        discard: discard,
        canceled: () => canceled,
      );

      expect(draft?.psbtBase64, 'unsigned+signed');
      expect(saved, ['unsigned+signed']);
    });

    test('saves a multisig PSBT with no signature', () async {
      await buildSignAndSave(
        build: () async => 'unsigned',
        sign: null,
        save: save,
        discard: discard,
        canceled: () => canceled,
      );

      expect(saved, ['unsigned']);
    });

    test('a cancel during a slow build saves nothing', () async {
      final build = Completer<String?>();
      final result = buildSignAndSave(
        build: () => build.future,
        sign: (psbt) async => psbt,
        save: save,
        discard: discard,
        canceled: () => canceled,
      );

      canceled = true;
      build.complete('late');

      expect(await result, isNull);
      expect(saved, isEmpty);
    });

    test('a cancel during the save discards the draft again', () async {
      final draft = await buildSignAndSave(
        build: () async => 'unsigned',
        sign: null,
        save: (psbt) async {
          canceled = true;
          return save(psbt);
        },
        discard: discard,
        canceled: () => canceled,
      );

      expect(draft, isNull);
      expect(discarded, ['draft-1']);
    });
  });

  group('SendActions', () {
    Finder button(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

    Future<int> pumpActions(WidgetTester tester, {required bool creating, bool sendsNow = false}) async {
      var cancels = 0;
      await tester.pumpSailPage(
        SendActions(
          creating: creating,
          sendsNow: sendsNow,
          onCreate: () async {},
          onCancel: () => cancels++,
          onClear: () async {},
          onAirgap: () async {},
          deviceType: null,
          onDevice: () async {},
        ),
      );
      await tester.pump();
      await tester.tap(button(creating ? 'Cancel' : 'Clear All'));
      await tester.pump();
      return cancels;
    }

    testWidgets('an idle form offers Create Transaction and Clear All', (tester) async {
      final cancels = await pumpActions(tester, creating: false);

      expect(button('Create Transaction'), findsOneWidget);
      expect(tester.widget<SailButton>(button('Create Transaction')).disabled, isFalse);
      expect(button('Clear All'), findsOneWidget);
      expect(button('Cancel'), findsNothing);
      expect(cancels, 0);
    });

    testWidgets('a build reads Creating… and Cancel stops it', (tester) async {
      final cancels = await pumpActions(tester, creating: true);

      final create = tester.widget<SailButton>(button('Create Transaction'));
      expect(create.disabled, isTrue);
      expect(create.loading, isTrue);
      expect(find.text('Creating…'), findsWidgets);
      expect(find.textContaining('Broadcasting'), findsNothing);
      expect(button('Clear All'), findsNothing);
      expect(cancels, 1);
    });

    testWidgets('a send to a payment code reads Send', (tester) async {
      await pumpActions(tester, creating: false, sendsNow: true);

      expect(button('Send'), findsOneWidget);
      expect(button('Create Transaction'), findsNothing);
    });
  });

  test('automatic selection skips a frozen coin and a locked coin', () {
    UnspentOutput coin(String output) => UnspentOutput(output: output, valueSats: Int64(1000));
    final free = coin('aa:0');

    expect(
      SendPageViewModel.spendableAmong([free, coin('bb:0'), coin('cc:1')], {'bb:0', 'cc:1'}),
      [free],
    );
  });

  test('MAX leaves out the coins of saved transactions', () {
    UnspentOutput coin(String output, int sats) => UnspentOutput(output: output, valueSats: Int64(sats));

    expect(
      SendPageViewModel.lockedSats([coin('aa:0', 1000), coin('bb:0', 250), coin('cc:0', 40)], {'bb:0', 'cc:0'}),
      290,
    );
  });

  test('isPaymentCode names a BIP47 code and nothing else', () {
    const code =
        'PM8TJTLJbPRGxSbc8EJi42Wrr6QbNSaSSVJ5Y3E4pbCYiTHUskHg13935Ubb7q8tx9GVbh2UuRnBc3WSyJHhUrw8KhprKnn9eDznYGieTzFcwQRya4GA';
    expect(isPaymentCode(code), isTrue);
    expect(isPaymentCode('bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'), isFalse);
    expect(isPaymentCode(''), isFalse);
  });

  group('addressGroups', () {
    test('keeps the eCash prefix in the first group', () {
      expect(addressGroups('ecash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a'), [
        'ecash:qpm2q',
        'sznhk',
        's23z7',
        '629mm',
        's6s4c',
        'wef74',
        'vcwvy',
        '22gdx',
        '6a',
      ]);
    });

    test('keeps the bech32 prefix in the first group', () {
      expect(addressGroups('bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'), [
        'bc1qar0s',
        'rrr7x',
        'fkvy5',
        'l643l',
        'ydnw9',
        're59g',
        'tzzwf',
        '5mdq',
      ]);
      expect(addressGroups('tb1qpayment'), ['tb1qpaym', 'ent']);
    });

    test('splits an address with no prefix from its first character', () {
      expect(addressGroups('1BoatSLRHtKNngkdXEeobR76b53LETtpyT'), [
        '1Boat',
        'SLRHt',
        'KNngk',
        'dXEeo',
        'bR76b',
        '53LET',
        'tpyT',
      ]);
    });

    test('an empty address has no groups', () {
      expect(addressGroups(''), isEmpty);
    });
  });
}
