import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

final _hash = '${'0' * 18}${'1a2f4c6e8b0d' * 4}2f4c6e';

class _Chain extends BlockchainProvider {
  @override
  Future<void> fetch() async {}
}

class _Orchestrator implements OrchestratorRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  await tester.pumpSailPage(const BlockExplorerDialog());
  if (phone) {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
  }
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<OrchestratorRPC>(_Orchestrator());
    await GetIt.I.unregister<BlockchainProvider>();
    GetIt.I.registerSingleton<BlockchainProvider>(
      _Chain()
        ..blocks = [
          for (final height in [921847, 921846])
            Block(
              height: height,
              hash: _hash,
              previousBlockHash: _hash,
              merkleRoot: _hash,
              bits: '1d00ffff',
              blockTime: Timestamp.fromDateTime(DateTime(2026, 11, 1, 9, 42)),
            ),
        ],
    );
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone the search field spans the card with the buttons under it', (tester) async {
    await _pump(tester, phone: true);

    expect(tester.takeException(), isNull);
    final card = tester.getRect(find.byType(SailCard).first);
    final field = tester.getRect(find.byType(SailTextField));
    final search = tester.getRect(find.widgetWithText(SailButton, 'Search'));
    final load = tester.getRect(find.widgetWithText(SailButton, 'Load transaction'));
    expect(field.width, closeTo(card.width - 32 - 2, 2));
    expect(search.top, greaterThan(field.bottom));
    expect(search.left, closeTo(field.left, 1));
    expect(load.center.dy, closeTo(search.center.dy, 1));
  });

  testWidgets('on a phone the blocks stack in full width with their full hashes', (tester) async {
    await _pump(tester, phone: true);

    final newest = tester.getRect(find.text('921847'));
    final older = tester.getRect(find.text('921846'));
    expect(older.top, greaterThan(newest.bottom));
    expect(older.left, newest.left);
    expect(find.text(_hash), findsWidgets);
  });

  testWidgets('the desktop keeps the search row and the side-by-side blocks', (tester) async {
    await _pump(tester, phone: false);

    final field = tester.getRect(find.byType(SailTextField));
    final search = tester.getRect(find.widgetWithText(SailButton, 'Search'));
    expect(search.left, greaterThan(field.right));
    final newest = tester.getRect(find.text('921847'));
    final older = tester.getRect(find.text('921846'));
    expect(older.right, lessThan(newest.left));
  });
}
