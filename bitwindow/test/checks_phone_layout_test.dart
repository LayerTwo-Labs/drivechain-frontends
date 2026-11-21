import 'package:bitwindow/pages/wallet/wallet_checks.dart';
import 'package:bitwindow/providers/check_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;

import 'test_utils.dart';

const _address = 'bcrt1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';

class _FakeCheckProvider extends ChangeNotifier implements CheckProvider {
  @override
  final List<bwpb.Cheque> checks = [
    bwpb.Cheque(
      id: Int64(1),
      address: _address,
      expectedAmountSats: Int64(1000000),
      createdAt: Timestamp.fromDateTime(DateTime(2026, 11, 20, 9, 14)),
    ),
    bwpb.Cheque(
      id: Int64(2),
      address: _address,
      expectedAmountSats: Int64(2500000),
      actualAmountSats: Int64(2500000),
      funded: true,
      fundedTxids: ['ab' * 32],
      createdAt: Timestamp.fromDateTime(DateTime(2026, 11, 18, 16, 2)),
    ),
  ];

  @override
  bool get isLoading => false;

  @override
  String? modelError;

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  GetIt.I.registerSingleton<CheckProvider>(_FakeCheckProvider());
  await tester.pumpSailPage(const ChecksTab());
  if (phone) {
    await tester.binding.setSurfaceSize(const Size(390, 844));
  }
  await tester.pump();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone each check is a two-line row with its actions at the right', (tester) async {
    await _pump(tester, phone: true);
    expect(tester.takeException(), isNull);
    expect(find.byType(SailTable), findsNothing);

    final date = tester.getRect(find.text(formatChequeDate(Timestamp.fromDateTime(DateTime(2026, 11, 20, 9, 14)))));
    final awaiting = tester.getRect(find.text('Awaiting funding'));
    expect(awaiting.top, greaterThan(date.bottom - 1));
    expect(awaiting.left, date.left);

    expect(find.text('0.02500000 ${activeTicker.symbol}'), findsOneWidget);
    final fund = tester.getRect(find.text('Fund Check'));
    expect(fund.left, greaterThan(date.right));
    expect(find.text('View Details'), findsOneWidget);
  });

  testWidgets('on a phone the check buttons sit on their own line under the title', (tester) async {
    await _pump(tester, phone: true);

    final title = tester.getRect(find.text('Your Checks'));
    final cash = tester.getRect(find.widgetWithText(SailButton, 'Cash Check'));
    final create = tester.getRect(find.widgetWithText(SailButton, 'Create New Check'));
    expect(cash.top, greaterThan(title.bottom));
    expect(cash.left, title.left);
    expect(create.left, greaterThan(cash.right));
    expect(create.center.dy, closeTo(cash.center.dy, 1));
  });

  testWidgets('the desktop keeps the checks table', (tester) async {
    await _pump(tester, phone: false);

    expect(find.byType(SailTable), findsOneWidget);
    expect(find.text('Awaiting funding'), findsNothing);
    expect(find.text('Unfunded'), findsOneWidget);
  });
}
