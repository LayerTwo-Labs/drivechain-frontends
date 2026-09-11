import 'dart:io';

import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:stacked/stacked.dart';

import 'test_utils.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  String? get detectedDataDir => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Sidechains extends ChangeNotifier implements SidechainProvider {
  @override
  List<SidechainOverview?> sidechains = List.filled(256, null);

  @override
  String? error;

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallet extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? get activeWalletId => null;

  @override
  String? resolveFundingWalletId(String? walletId) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions implements TransactionProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Binaries extends BinaryProvider {
  final updated = <Binary>[];

  // ignore: invalid_use_of_visible_for_testing_member
  _Binaries(List<Binary> binaries) : super.test(appDir: Directory.systemTemp, binaries: binaries);

  @override
  Future<void> update(Binary binary) async {
    updated.add(binary);
  }
}

class _Downloads extends DownloadProvider {
  final progress = <BinaryType, DownloadProgress>{};

  _Downloads() : super(startTimer: false);

  @override
  DownloadProgress? statusFor(BinaryType binary) => progress[binary];
}

class _ThunderRPC extends MockThunderRPC {
  (double, double) wallet = (0, 0);

  @override
  Future<(double, double)> balance() async => wallet;
}

class _CoinShiftRPC extends MockCoinShiftRPC {
  (double, double) wallet = (0, 0);

  @override
  Future<(double, double)> balance() async => wallet;
}

Thunder _thunder({bool downloaded = true, bool updateAvailable = false}) {
  final base = Thunder();
  return base.copyWith(
    metadata: base.metadata.copyWith(
      remoteTimestamp: updateAvailable ? DateTime(2026, 2) : null,
      downloadedTimestamp: downloaded ? DateTime(2026, 1) : null,
      binaryPath: downloaded ? File('/tmp/thunder') : null,
      updateable: true,
    ),
  );
}

Finder _button(String label) => find.byWidgetPredicate((widget) => widget is SailButton && widget.label == label);

SailButton _buttonWidget(WidgetTester tester, String label) => tester.widget<SailButton>(_button(label));

void main() {
  late _ThunderRPC thunderRPC;
  late _CoinShiftRPC coinShiftRPC;
  late _Downloads downloads;
  late BalanceProvider balances;
  late SyncProvider sync;

  _Binaries setUpChain(Thunder thunder) {
    final binaries = _Binaries([thunder]);
    GetIt.I.registerSingleton<BinaryProvider>(binaries);
    return binaries;
  }

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    sync = SyncProvider(startTimer: false);
    thunderRPC = _ThunderRPC();
    downloads = _Downloads();
    final sidechains = _Sidechains();
    sidechains.sidechains[9] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: 'Thunder', slot: 9, balanceSatoshi: Int64(11000000)),
      [],
      [],
    );
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<SyncProvider>(sync);
    GetIt.I.registerSingleton<SidechainProvider>(sidechains);
    GetIt.I.registerSingleton<WalletReaderProvider>(_Wallet());
    GetIt.I.registerSingleton<TransactionProvider>(_Transactions());
    GetIt.I.registerSingleton<LogProvider>(LogProvider());
    GetIt.I.registerSingleton<DownloadProvider>(downloads);
    GetIt.I.registerSingleton<ThunderRPC>(thunderRPC);
    coinShiftRPC = _CoinShiftRPC();
    GetIt.I.registerSingleton<CoinShiftRPC>(coinShiftRPC);
    balances = BalanceProvider(connections: [thunderRPC, coinShiftRPC]);
    GetIt.I.registerSingleton<BalanceProvider>(balances);
  });

  tearDown(() async {
    sync.dispose();
    await GetIt.I.reset();
  });

  Future<void> pumpTable(WidgetTester tester) async {
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(
      ViewModelBuilder<SidechainsViewModel>.reactive(
        viewModelBuilder: () => SidechainsViewModel(),
        builder: (context, model, child) => const SidechainsList(smallVersion: false),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a downloaded chain offers a primary Start and a disabled outline Deposit', (tester) async {
    setUpChain(_thunder());
    await pumpTable(tester);

    expect(_buttonWidget(tester, 'Start').variant, ButtonVariant.primary);
    final deposit = _buttonWidget(tester, 'Deposit');
    expect(deposit.variant, ButtonVariant.outline);
    expect(deposit.disabled, isTrue);
    expect(
      find.ancestor(of: _button('Deposit'), matching: find.byType(SailTooltip)),
      findsOneWidget,
    );
    expect(find.byType(ProgressBar), findsNothing);
  });

  testWidgets('a stopped chain shows a dash for Your balance', (tester) async {
    setUpChain(_thunder());
    await pumpTable(tester);

    expect(find.text('Your balance'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('a running chain offers an outline Stop and shows Your balance', (tester) async {
    setUpChain(_thunder());
    thunderRPC.wallet = (4.1, 0.0);
    thunderRPC.setConnected(true);
    await balances.fetch();
    await pumpTable(tester);

    expect(_buttonWidget(tester, 'Stop').variant, ButtonVariant.outline);
    expect(_buttonWidget(tester, 'Deposit').disabled, isFalse);
    expect(find.text(GetIt.I.get<FormatterProvider>().formatBTC(4.1)), findsOneWidget);
    expect(find.text('—'), findsNothing);
  });

  testWidgets('a running CoinShift shows its balance, not a dash', (tester) async {
    final coinShift = CoinShift();
    GetIt.I.registerSingleton<BinaryProvider>(
      _Binaries([
        _thunder(),
        coinShift.copyWith(
          metadata: coinShift.metadata.copyWith(
            remoteTimestamp: null,
            downloadedTimestamp: DateTime(2026, 1),
            binaryPath: File('/tmp/coinshift'),
            updateable: true,
          ),
        ),
      ]),
    );
    GetIt.I.get<SidechainProvider>().sidechains[255] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: 'CoinShift', slot: 255, balanceSatoshi: Int64(5000000)),
      [],
      [],
    );
    coinShiftRPC.wallet = (0.25, 0.0);
    coinShiftRPC.setConnected(true);
    await balances.fetch();
    await pumpTable(tester);

    expect(find.text(GetIt.I.get<FormatterProvider>().formatBTC(0.25)), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('a chain that is not downloaded offers a primary Download', (tester) async {
    setUpChain(_thunder(downloaded: false));
    await pumpTable(tester);

    expect(_buttonWidget(tester, 'Download').variant, ButtonVariant.primary);
    expect(_button('Start'), findsNothing);
  });

  testWidgets('a download in progress shows its percent in place of the button', (tester) async {
    setUpChain(_thunder(downloaded: false));
    downloads.progress[BinaryType.BINARY_TYPE_THUNDER] = const DownloadProgress(
      binary: BinaryType.BINARY_TYPE_THUNDER,
      mbDownloaded: 62,
      mbTotal: 100,
    );
    await pumpTable(tester);

    expect(find.text('62%'), findsOneWidget);
    expect(find.text('Updating'), findsNothing);
    expect(_button('Download'), findsNothing);
  });

  testWidgets('an update puts a primary Update before an outline Start', (tester) async {
    final binaries = setUpChain(_thunder(updateAvailable: true));
    await pumpTable(tester);

    final update = _buttonWidget(tester, 'Update');
    expect(update.variant, ButtonVariant.primary);
    expect(update.icon, SailSVGAsset.circleArrowUp);
    expect(_buttonWidget(tester, 'Start').variant, ButtonVariant.outline);
    expect(tester.getTopLeft(_button('Update')).dx, lessThan(tester.getTopLeft(_button('Start')).dx));

    await tester.tap(_button('Update'));
    await tester.pump(kDoubleTapTimeout);
    await tester.pumpAndSettle();
    expect(binaries.updated.single.type, BinaryType.BINARY_TYPE_THUNDER);
  });

  testWidgets('an update in progress shows Updating and a percent in place of the buttons', (tester) async {
    setUpChain(_thunder(updateAvailable: true));
    downloads.progress[BinaryType.BINARY_TYPE_THUNDER] = const DownloadProgress(
      binary: BinaryType.BINARY_TYPE_THUNDER,
      mbDownloaded: 45,
      mbTotal: 100,
    );
    await pumpTable(tester);

    expect(find.text('Updating'), findsOneWidget);
    expect(find.text('45%'), findsOneWidget);
    expect(_button('Update'), findsNothing);
    expect(_button('Start'), findsNothing);
  });

  testWidgets('a header tap changes neither the row order nor the headers', (tester) async {
    setUpChain(_thunder());
    GetIt.I.get<SidechainProvider>().sidechains[2] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: 'BitNames', slot: 2, balanceSatoshi: Int64(99000000)),
      [],
      [],
    );
    await pumpTable(tester);

    for (final header in ['Slot', 'Name', 'Sidechain Balance', 'Your balance']) {
      await tester.tap(find.text(header));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('2')).dy, lessThan(tester.getTopLeft(find.text('9')).dy));
      expect(
        tester.widgetList<SailTableHeaderCell>(find.byType(SailTableHeaderCell)).any((cell) => cell.isSorted),
        isFalse,
      );
    }
  });

  testWidgets('the slot shows its number with no colon', (tester) async {
    setUpChain(_thunder());
    await pumpTable(tester);

    expect(find.text('9'), findsOneWidget);
    expect(find.text('9:'), findsNothing);
  });

  testWidgets('Add / Remove sits in the card head, next to the toggle', (tester) async {
    setUpChain(_thunder());
    await pumpTable(tester);

    final addRemove = _buttonWidget(tester, 'Add / Remove');
    expect(addRemove.variant, ButtonVariant.outline);
    final head = tester.getRect(find.text('Show only filled slots'));
    final button = tester.getRect(_button('Add / Remove'));
    expect(button.left, greaterThan(head.right));
    expect(button.bottom, lessThan(tester.getTopLeft(find.text('Slot')).dy));
  });

  test('progressPercent never reads 100% before the goal', () {
    expect(progressPercent(45, 100), '45%');
    expect(progressPercent(999, 1000), '99%');
    expect(progressPercent(100, 100), '100%');
    expect(progressPercent(5, 0), '—');
  });
}
