import 'package:bitwindow/pages/wallet/timestamp_detail_page.dart';
import 'package:bitwindow/providers/timestamp_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

const _hash = 'f3a1c09e5b7d2468ace013579bdf2468ace013579bdf2468ace013579bdf2468';
const _txid = '9c2e7b14d0a85f36e1b4c7d2a09f8e6b5c3d1a2f4e6b8c0d2f4a6c8e0b2d4f61';

class _FakeTimestampProvider extends ChangeNotifier implements TimestampProvider {
  @override
  List<FileTimestamp> timestamps = [
    FileTimestamp(
      id: Int64(7),
      filename: 'contract.pdf',
      fileHash: _hash,
      txid: _txid,
      blockHeight: Int64(214882),
      status: 'confirmed',
      confirmations: 12,
      confirmedAt: Timestamp.fromDateTime(DateTime(2026, 11, 20, 9, 14)),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  GetIt.I.registerSingleton<TimestampProvider>(_FakeTimestampProvider());
  await tester.pumpSailPage(const TimestampDetailPage(timestampId: 7));
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

  testWidgets('on a phone the details are label and value rows in one panel', (tester) async {
    await _pump(tester, phone: true);

    expect(tester.takeException(), isNull);
    expect(find.descendant(of: find.byType(SailCard), matching: find.text('Timestamp Details')), findsOneWidget);

    final label = tester.getRect(find.text('Filename'));
    final value = tester.getRect(find.text('contract.pdf'));
    expect(value.left, greaterThan(label.right));
    expect(value.center.dy, closeTo(label.center.dy, 1));
  });

  testWidgets('on a phone a hash shows in full under its label, with the copy icon on the label line', (tester) async {
    await _pump(tester, phone: true);

    for (final (label, value) in [('File Hash', _hash), ('Transaction ID', _txid)]) {
      final labelRect = tester.getRect(find.text(label));
      final valueRect = tester.getRect(find.text(value));
      final row = find.ancestor(of: find.text(label), matching: find.byType(SailStackedValueRow));
      final copy = tester.getRect(find.descendant(of: row, matching: find.byType(SailButton)));
      expect(valueRect.top, greaterThan(labelRect.bottom));
      expect(valueRect.left, labelRect.left);
      expect(copy.center.dy, closeTo(labelRect.center.dy, 4));
      expect(copy.left, greaterThanOrEqualTo(labelRect.right));
    }
  });

  testWidgets('on a phone Close sits at the right inside the panel, under the rows', (tester) async {
    await _pump(tester, phone: true);

    final panel = tester.getRect(find.byType(SailCard));
    final close = tester.getRect(find.widgetWithText(SailButton, 'Close'));
    expect(close.top, greaterThan(tester.getRect(find.text('Block Height')).bottom));
    expect(close.bottom, lessThan(panel.bottom));
    expect(close.right, closeTo(panel.right - 16 - 1, 1));
  });

  testWidgets('the desktop keeps the page title and the 150 px label column', (tester) async {
    await _pump(tester, phone: false);

    expect(find.byType(SailValueRow), findsNothing);
    expect(find.byType(InfoRow), findsWidgets);
    expect(find.byType(CopyRow), findsNWidgets(2));
  });
}
