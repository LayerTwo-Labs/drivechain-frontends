import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;
import 'package:fixnum/fixnum.dart';

class _Bmm extends ChangeNotifier implements BMMProvider {
  @override
  double maxBidAmount = 0.0002;

  @override
  int get suggestedBidSats => 188;

  @override
  bool running = true;

  @override
  String? get fundingWalletId => 'w1';

  @override
  bool get fundingBalanceTooLow => false;

  @override
  bmmpb.Bid? get liveBid => bmmpb.Bid(bidSats: Int64(8000), criticalHash: 'a' * 64);

  @override
  bmmpb.Round? get current => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallets extends ChangeNotifier implements WalletReaderProvider {
  @override
  List<WalletData> fundingWallets() => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late BMMViewModel model;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<WalletReaderProvider>(_Wallets());
    GetIt.I.registerSingleton<SyncProvider>(
      SyncProvider(startTimer: false)
        ..mainchainSyncInfo = SyncInfo(progressCurrent: 42, progressGoal: 42, lastBlockAt: null)
        ..enforcerSyncInfo = SyncInfo(progressCurrent: 42, progressGoal: 42, lastBlockAt: null),
    );
    model = BMMViewModel(provider: _Bmm());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    model.dispose();
    await GetIt.I.reset();
  });

  Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
    await tester.binding.setSurfaceSize(Size(width, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pumpSlot(WidgetTester tester, double width) => pumpAt(tester, width, BMMCurrentSlot(viewModel: model));

  testWidgets('a phone lists the slot figures as rows, the miner wait as a line under the head', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pumpSlot(tester, 390);

    expect(tester.takeException(), isNull);
    expect(find.byType(SailStatList), findsOneWidget);
    final head = tester.getRect(find.text('Current slot'));
    final hint = tester.getRect(find.textContaining('Waiting for a miner'));
    final worth = tester.getRect(find.text('Block worth'));
    final bid = tester.getRect(find.text('Your bid'));
    expect(hint.top, greaterThan(head.bottom - 1));
    expect(hint.left, head.left);
    expect(worth.top, greaterThan(hint.bottom));
    expect(bid.top, greaterThan(worth.bottom));
    expect(tester.getRect(find.text(model.satsLabel(8000))).right, greaterThan(300));
  });

  testWidgets('the desktop keeps the figures side by side and the wait at the right of the head', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pumpSlot(tester, 1100);

    expect(find.byType(SailStatList), findsNothing);
    final head = tester.getRect(find.text('Current slot'));
    final hint = tester.getRect(find.textContaining('Waiting for a miner'));
    expect(hint.left, greaterThan(head.right));
    expect(tester.getRect(find.text('Your bid')).top, tester.getRect(find.text('Block worth')).top);
  });

  testWidgets('a phone stacks the bid controls with full-width buttons', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pumpAt(tester, 390, BMMControls(viewModel: model));

    expect(tester.takeException(), isNull);
    final stop = tester.getRect(find.byType(SailButton).first);
    final wallet = tester.getRect(find.text('Wallet:'));
    final minBid = tester.getRect(find.text('Min bid:'));
    final maxBid = tester.getRect(find.text('Max bid:'));
    final manual = tester.getRect(find.widgetWithText(SailButton, 'Bid manually').first);
    expect(stop.width, 390);
    expect(manual.width, 390);
    expect(wallet.top, greaterThan(stop.bottom));
    expect(minBid.top, greaterThan(wallet.bottom));
    expect(maxBid.top, greaterThan(minBid.bottom));
    expect(manual.top, greaterThan(maxBid.bottom));
  });

  testWidgets('the desktop keeps the bid controls on one row', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pumpAt(tester, 1800, BMMControls(viewModel: model));

    expect(tester.takeException(), isNull);
    expect(tester.getCenter(find.text('Min bid:')).dy, closeTo(tester.getCenter(find.text('Wallet:')).dy, 1));
  });
}
