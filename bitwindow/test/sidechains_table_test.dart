import 'dart:io';
import 'dart:ui' as ui;

import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:bitwindow/sol/sol_wallet.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:stacked/stacked.dart';

import 'test_utils.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  String ecashNetworkId = '';

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

  void addChain(int slot, String title) {
    sidechains = List.of(sidechains);
    sidechains[slot] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: title, slot: slot, balanceSatoshi: Int64.ZERO),
      [],
      [],
    );
    notifyListeners();
  }

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

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final family in ['Inter', 'IBMPlexMono']) {
      await (FontLoader(family)..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'))).load();
    }
  });

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

  Future<void> pumpTable(WidgetTester tester, {bool narrow = false, bool ecash = false}) async {
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(
      ViewModelBuilder<SidechainsViewModel>.reactive(
        viewModelBuilder: () => SidechainsViewModel(),
        builder: (context, model, child) {
          Widget table = narrow
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: SidechainsList(smallVersion: false)),
                    SizedBox(width: 8),
                    Expanded(flex: 4, child: SizedBox()),
                  ],
                )
              : const SidechainsList(smallVersion: false);
          if (ecash) {
            table = SailTheme(
              data: SailThemeData.lightTheme(SailColorScheme.black, false, SailFontValues.inter, SailThemeStyle.ecash),
              child: table,
            );
          }
          return narrow || ecash
              ? RepaintBoundary(key: const ValueKey('sidechains-table-screen'), child: table)
              : table;
        },
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

  testWidgets('SOL offers an enabled Deposit, because it starts no binary', (tester) async {
    setUpChain(_thunder());
    final conf = GetIt.I.get<BitcoinConfProvider>() as _Conf;
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;
    conf.ecashNetworkId = 'betanet';
    final sidechains = GetIt.I.get<SidechainProvider>() as _Sidechains;
    // SOL is the one row, so the Deposit button of the table is its own.
    sidechains.sidechains[9] = null;
    sidechains.sidechains[solSidechainSlot] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: solSidechainTitle, slot: solSidechainSlot),
      [],
      [],
    );
    await pumpTable(tester);

    final deposit = _buttonWidget(tester, 'Deposit');
    expect(deposit.disabled, isFalse);
    expect(
      find.ancestor(of: _button('Deposit'), matching: find.byType(SailTooltip)),
      findsNothing,
      reason: 'a SOL deposit needs no running binary, so no tooltip says to start one',
    );
  });

  testWidgets('a slot change drops a deposit address of another slot', (tester) async {
    setUpChain(_thunder());
    await registerTestDependencies();
    final model = SidechainsViewModel();
    addTearDown(model.dispose);

    model.toggleSelection(solSidechainSlot);
    model.addressController.text = formatDepositAddress('abc', solSidechainSlot);
    // The backend reads the slot out of the address, so a left over address
    // would send the coins to slot 8 under another chain's name.
    model.toggleSelection(9);
    expect(model.addressController.text, isEmpty);
  });

  testWidgets('a slot change keeps an address that names that slot', (tester) async {
    setUpChain(_thunder());
    await registerTestDependencies();
    final model = SidechainsViewModel();
    addTearDown(model.dispose);

    final address = formatDepositAddress('abc', 9);
    model.addressController.text = address;
    model.toggleSelection(9);
    expect(model.addressController.text, address);
  });

  testWidgets('a SOL address goes when slot 8 stops being SOL', (tester) async {
    setUpChain(_thunder());
    await registerTestDependencies();
    final conf = GetIt.I.get<BitcoinConfProvider>() as _Conf;
    conf.network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;
    conf.ecashNetworkId = 'betanet';
    final sidechains = GetIt.I.get<SidechainProvider>() as _Sidechains;
    sidechains.sidechains[solSidechainSlot] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: solSidechainTitle, slot: solSidechainSlot),
      [],
      [],
    );
    final model = SidechainsViewModel();
    addTearDown(model.dispose);

    model.toggleSelection(solSidechainSlot);
    model.addressController.text = formatDepositAddress('abc', solSidechainSlot);

    // A network switch can leave another chain on slot 8. The number stays the
    // same, so only the identity tells the two apart.
    sidechains.sidechains[solSidechainSlot] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: 'Something else', slot: solSidechainSlot),
      [],
      [],
    );
    model.toggleSelection(solSidechainSlot);
    model.toggleSelection(solSidechainSlot);
    expect(model.addressController.text, isEmpty);
  });

  testWidgets('a slot change keeps an unformatted address', (tester) async {
    setUpChain(_thunder());
    await registerTestDependencies();
    final model = SidechainsViewModel();
    addTearDown(model.dispose);

    model.toggleSelection(solSidechainSlot);
    model.addressController.text = 'a raw address';
    model.toggleSelection(9);
    expect(model.addressController.text, 'a raw address');
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
    // Nothing runs yet, so the bar keeps the place of the button.
    expect(_button('Stop'), findsNothing);
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

  for (final (phase, label) in [
    (MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_HEADERS, 'Fetching mainchain headers'),
    (MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_WRITING, 'Writing mainchain headers'),
    (MainchainSyncPhase.MAINCHAIN_SYNC_PHASE_STATE, 'Syncing mainchain state'),
  ]) {
    testWidgets('a running chain in a mainchain phase shows "$label" and its percent', (tester) async {
      setUpChain(_thunder());
      thunderRPC.setConnected(true);
      sync.sidechains = {
        SidechainType.SIDECHAIN_TYPE_THUNDER: SyncInfo(
          progressCurrent: 412000,
          progressGoal: 997070,
          lastBlockAt: null,
          mainchainSyncPhase: phase,
          mainchainTipHeight: 997070,
        ),
      };
      await pumpTable(tester);

      expect(tester.takeException(), isNull);
      expect(find.text(label), findsOneWidget);
      expect(find.text('41.3%'), findsOneWidget);
      // A sync must not take the place of Stop: the chain's own window may be
      // closed, and then the table is the only way to stop the node.
      expect(_button('Stop'), findsOneWidget);
      expect(
        tester.getRect(_button('Stop')).right,
        lessThanOrEqualTo(tester.getRect(find.byType(MainchainSyncStatus)).left),
      );
      expect(
        tester.getRect(find.byType(MainchainSyncStatus)).right,
        lessThanOrEqualTo(tester.getRect(_button('Deposit')).left),
      );
    });
  }

  testWidgets('a running chain without a mainchain phase keeps the block count bar', (tester) async {
    setUpChain(_thunder());
    thunderRPC.setConnected(true);
    sync.sidechains = {
      SidechainType.SIDECHAIN_TYPE_THUNDER: SyncInfo(progressCurrent: 100, progressGoal: 294, lastBlockAt: null),
    };
    await pumpTable(tester);

    expect(find.byType(MainchainSyncStatus), findsNothing);
    expect(find.text('34%'), findsOneWidget);
    expect(_button('Stop'), findsOneWidget);
  });

  // A slot number is three characters at most, so the gap to the name was the
  // table's default minimum, not the content.
  testWidgets('the widest slot keeps Slot narrow and Name right after it', (tester) async {
    setUpChain(_thunder());
    GetIt.I.get<SidechainProvider>().sidechains[255] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: 'CoinShift', slot: 255, balanceSatoshi: Int64(5000000)),
      [],
      [],
    );
    await pumpTable(tester);

    final slot = tester.getRect(_cell('255'));
    final name = tester.getRect(_cell('CoinShift'));
    expect(slot.width, lessThanOrEqualTo(_headerWidth('Slot') + 25));
    expect(name.left - slot.right, lessThanOrEqualTo(8));
  });

  testWidgets('the widest name and balance stay on one line', (tester) async {
    setUpChain(_thunder());
    GetIt.I.get<SidechainProvider>().sidechains[9] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: 'Truthcoin', slot: 9, balanceSatoshi: Int64(11502555423)),
      [],
      [],
    );
    thunderRPC.wallet = (115.02555423, 0.0);
    thunderRPC.setConnected(true);
    await balances.fetch();
    await pumpTable(tester);

    final balance = GetIt.I.get<FormatterProvider>().formatBTC(115.02555423);
    _expectOneUncutLine(tester, _cell('Truthcoin'), 'Truthcoin');
    _expectOneUncutLine(tester, _cell(balance), balance);
  });

  for (final ecash in [false, true]) {
    for (final large in [false, true]) {
      testWidgets('the narrow table keeps full names, eCash: $ecash, large: $large', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = large ? 2 : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        setUpChain(_thunder());
        thunderRPC.setConnected(true);
        final chains = GetIt.I.get<SidechainProvider>() as _Sidechains;
        const name = 'A sidechain with a complete and unusually long public name for every user';
        chains.addChain(128, name);
        await pumpTable(tester, narrow: true, ecash: ecash);
        tester.widget<SailToggle>(find.byType(SailToggle)).onChanged(false);
        await tester.state<SailAppState>(find.byType(SailApp)).loadFontScale(large ? 2 : 1);
        await tester.pumpAndSettle();
        final table = find.byType(SailTable);
        final state = tester.state(table);
        final card = tester.getRect(find.byType(SailCard));
        final toggle = tester.getRect(find.byType(SailToggle));
        final button = tester.getRect(_button('Add / Remove'));
        for (final bounds in [toggle, button]) {
          expect(bounds.left, greaterThanOrEqualTo(card.left + SailStyleValues.padding16));
          expect(bounds.right, lessThanOrEqualTo(card.right - SailStyleValues.padding16));
          expect(bounds.bottom, lessThan(tester.getRect(table).top));
        }
        final buttonText = find.descendant(of: _button('Add / Remove'), matching: find.byType(Text)).last;
        final paragraph = tester.renderObject<RenderParagraph>(buttonText);
        expect(paragraph.textScaler.scale(12), large ? (ecash ? 48 : 24) : 12);
        expect(paragraph.getTransformTo(null).entry(0, 0), closeTo(1, 0.001));
        expect(tester.getSize(find.text('Sidechains')).width, greaterThan(0));
        if (ecash && large) {
          expect(button.top, greaterThan(toggle.bottom));
        }
        expect(tester.widget<SailTable>(table).rowCount, 256);
        final vertical = find.descendant(
          of: table,
          matching: find.byWidgetPredicate(
            (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
          ),
        );
        tester.state<ScrollableState>(vertical).position.jumpTo(128 * tester.widget<SailTable>(table).cellHeight);
        await tester.pumpAndSettle();
        _expectFullName(tester, name);
        final width = tester.getSize(_cell(name)).width;
        final horizontal = find.descendant(
          of: table,
          matching: find.byWidgetPredicate(
            (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.right,
          ),
        );
        expect(tester.state<ScrollableState>(horizontal).position.maxScrollExtent, greaterThan(0));
        if (large) {
          expect(width, greaterThan(tester.getSize(horizontal).width));
        }

        final handle = find
            .descendant(
              of: table,
              matching: find.byWidgetPredicate(
                (widget) => widget is MouseRegion && widget.cursor == SystemMouseCursors.resizeLeftRight,
              ),
            )
            .at(1);
        await tester.ensureVisible(handle);
        await tester.pumpAndSettle();
        await tester.drag(handle, const Offset(-2000, 0));
        await tester.pumpAndSettle();
        expect(tester.getSize(_cell(name)).width, closeTo(width, 0.01));
        _expectFullName(tester, name);

        const longer = '$name with more words after the table appears';
        chains.addChain(129, longer);
        await tester.pumpAndSettle();
        expect(tester.widget<SailTable>(table).rowCount, 256);
        expect(tester.state(table), same(state));
        _expectFullName(tester, name);
        _expectFullName(tester, longer);
        expect(tester.getSize(_cell(longer)).width, greaterThan(width));
        expect(tester.takeException(), isNull);
        await _captureTable(tester, 'names-${ecash ? 'ecash' : 'default'}-${large ? '4x' : '1x'}');
        if (!ecash && !large && const String.fromEnvironment('SIDECHAIN_TABLE_SCREEN_DIR').isNotEmpty) {
          await tester.binding.setSurfaceSize(const Size(2600, 720));
          await tester.pumpAndSettle();
          tester.state<ScrollableState>(horizontal).position.jumpTo(0);
          await tester.pumpAndSettle();
          await _captureTable(tester, 'full-longest-name');
          await tester.binding.setSurfaceSize(const Size(1200, 720));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('the narrow desktop table keeps each ECX amount on one line', (tester) async {
    setUpChain(_thunder());
    GetIt.I.get<BitcoinConfProvider>().network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;
    GetIt.I.get<SidechainProvider>().sidechains[9] = SidechainOverview(
      ListSidechainsResponse_Sidechain(title: 'Truthcoin', slot: 9, balanceSatoshi: Int64(11502555423)),
      [],
      [],
    );
    thunderRPC.wallet = (115.02555423, 1.0);
    thunderRPC.setConnected(true);
    await balances.fetch();
    await pumpTable(tester, narrow: true, ecash: true);
    await _captureTable(tester, 'active');

    for (final header in ['Slot', 'Name']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(header));
      expect(paragraph.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: header.length)), hasLength(1));
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(tester.getSize(find.text(header)).width, greaterThan(0));
    }
    final amount = GetIt.I.get<FormatterProvider>().formatBTC(115.02555423);
    expect(amount, contains('ECX'));
    for (final match in find.text(amount).evaluate()) {
      final paragraph = match.renderObject! as RenderParagraph;
      expect(paragraph.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: amount.length)), hasLength(1));
      expect(paragraph.didExceedMaxLines, isFalse);
    }
    expect(find.text(amount), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the narrow desktop table keeps actions close to the balances', (tester) async {
    setUpChain(_thunder());
    GetIt.I.get<BitcoinConfProvider>().network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;
    await pumpTable(tester, narrow: true, ecash: true);
    await _captureTable(tester, 'stopped');

    final balance = tester.getRect(_cell('—'));
    final start = tester.getRect(_button('Start'));
    expect(start.left - balance.right, lessThanOrEqualTo(40));
    expect(tester.getRect(_button('Deposit')).right, lessThanOrEqualTo(tester.getRect(find.byType(SailTable)).right));
    expect(tester.takeException(), isNull);
  });

  for (final ecash in [false, true]) {
    for (final action in ['Start', 'Download', 'Stop']) {
      testWidgets('the $action controls keep the 2x text size in the ${ecash ? 'eCash' : 'default'} theme', (
        tester,
      ) async {
        setUpChain(_thunder(downloaded: action != 'Download'));
        thunderRPC.setConnected(action == 'Stop');
        if (ecash) {
          GetIt.I.get<BitcoinConfProvider>().network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;
        }
        await pumpTable(tester, ecash: ecash);
        final tableHeight = tester.getSize(find.byType(SailTable)).height;
        if (ecash) {
          await _captureTable(tester, '${action.toLowerCase()}-1x');
        }
        await tester.state<SailAppState>(find.byType(SailApp)).loadFontScale(2);
        await tester.pumpAndSettle();

        expect(tester.getSize(find.byType(SailTable)).height, tableHeight + 60);
        for (final label in [action, 'Deposit']) {
          final text = find.descendant(of: _button(label), matching: find.byType(Text)).last;
          final paragraph = tester.renderObject<RenderParagraph>(text);
          expect(paragraph.textScaler.scale(12), 24);
          expect(paragraph.getTransformTo(null).entry(0, 0), closeTo(1, 0.001), reason: label);
          expect(
            tester.getRect(_button(label)).bottom,
            lessThanOrEqualTo(tester.getRect(find.byType(SailTable)).bottom),
            reason: label,
          );
        }
        if (ecash) {
          await _captureTable(tester, '${action.toLowerCase()}-2x');
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the empty table keeps its height at the 2x text size', (tester) async {
    setUpChain(_thunder());
    GetIt.I.get<SidechainProvider>().sidechains.fillRange(0, 256, null);
    await pumpTable(tester);
    final tableHeight = tester.getSize(find.byType(SailTable)).height;
    await tester.state<SailAppState>(find.byType(SailApp)).loadFontScale(2);
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(SailTable)).height, tableHeight);
    expect(tester.takeException(), isNull);
  });

  for (final ecash in [false, true]) {
    for (final appScale in [1.5, 2.0]) {
      for (final action in ['Start', 'Download', 'Stop']) {
        testWidgets('the $action controls use OS 2x and app $appScale in the ${ecash ? 'eCash' : 'default'} theme', (
          tester,
        ) async {
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          setUpChain(_thunder(downloaded: action != 'Download'));
          thunderRPC.setConnected(action == 'Stop');
          if (ecash) {
            GetIt.I.get<BitcoinConfProvider>().network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;
          }
          await pumpTable(tester, ecash: ecash);
          final tableHeight = tester.getSize(find.byType(SailTable)).height;
          await tester.state<SailAppState>(find.byType(SailApp)).loadFontScale(appScale);
          await tester.pumpAndSettle();

          final scale = ecash ? 2 * appScale : 2.0;
          for (final label in [action, 'Deposit']) {
            final text = find.descendant(of: _button(label), matching: find.byType(Text)).last;
            final paragraph = tester.renderObject<RenderParagraph>(text);
            expect(MediaQuery.textScalerOf(tester.element(text)).scale(12), 24 * appScale);
            expect(paragraph.textScaler.scale(12), 12 * scale);
            expect(paragraph.getTransformTo(null).entry(0, 0), closeTo(1, 0.001), reason: label);
            expect(
              tester.getRect(_button(label)).bottom,
              lessThanOrEqualTo(tester.getRect(find.byType(SailTable)).bottom),
              reason: label,
            );
          }
          expect(tester.getSize(find.byType(SailTable)).height, tableHeight + 40 * (scale - 2));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final ecash in [false, true]) {
    testWidgets('the full table keeps its visible row and fraction, eCash: $ecash', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = ecash ? 2 : 1;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      setUpChain(_thunder());
      await pumpTable(tester, ecash: ecash);
      tester.widget<SailToggle>(find.byType(SailToggle)).onChanged(false);
      await tester.pumpAndSettle();
      expect(tester.widget<SailTable>(find.byType(SailTable)).rowCount, 256);
      final tableState = tester.state(find.byType(SailTable));
      final scroll = find.descendant(
        of: find.byType(SailTable),
        matching: find.byWidgetPredicate(
          (widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down,
        ),
      );

      (int, double) visibleRow() {
        final top = tester.getRect(scroll).top;
        final cells = find.byWidgetPredicate((widget) => widget is SailTableCell && int.tryParse(widget.value) != null);
        for (final element in cells.evaluate()) {
          final cell = find.byWidget(element.widget);
          final rect = tester.getRect(cell);
          if (rect.top <= top && rect.bottom > top) {
            return (int.parse((element.widget as SailTableCell).value), (top - rect.top) / rect.height);
          }
        }
        throw StateError('The first visible slot is absent.');
      }

      await tester.drag(scroll, const Offset(0, -400));
      await tester.pumpAndSettle();
      final before = visibleRow();
      expect(before.$1, greaterThan(0));
      expect(before.$2, greaterThan(0));
      final app = tester.state<SailAppState>(find.byType(SailApp));
      for (final scale in [2.0, 1.0]) {
        await app.loadFontScale(scale);
        await tester.pumpAndSettle();
        final after = visibleRow();
        expect(after.$1, before.$1, reason: 'The visible row changed from $before to $after.');
        expect(after.$2, closeTo(before.$2, 0.001));
        expect(tester.state(find.byType(SailTable)), same(tableState));
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('the theme change keeps full terminal text and the table state', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    setUpChain(_thunder());
    await pumpTable(tester);
    final app = tester.state<SailAppState>(find.byType(SailApp));
    await app.loadFontScale(2);
    await tester.pumpAndSettle();
    final tableState = tester.state(find.byType(SailTable));
    await app.loadStyle(SailThemeStyle.ecash);
    await tester.pumpAndSettle();

    expect(tester.state(find.byType(SailTable)), same(tableState));
    for (final label in ['Start', 'Deposit']) {
      final text = find.descendant(of: _button(label), matching: find.byType(Text)).last;
      final paragraph = tester.renderObject<RenderParagraph>(text);
      expect(paragraph.textScaler.scale(12), 48);
      expect(paragraph.getTransformTo(null).entry(0, 0), closeTo(1, 0.001), reason: label);
      expect(
        tester.getRect(_button(label)).bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(SailTable)).bottom),
        reason: label,
      );
    }
    expect(tester.takeException(), isNull);
  });

  // Adding confirmed and pending into one figure made the cell disagree with
  // the bottom nav, which shows the two apart.
  testWidgets('Your balance shows the confirmed figure and holds pending in a tooltip', (tester) async {
    setUpChain(_thunder());
    thunderRPC.wallet = (2.01999, 1.0);
    thunderRPC.setConnected(true);
    await balances.fetch();
    await pumpTable(tester);

    final formatter = GetIt.I.get<FormatterProvider>();
    expect(find.text(formatter.formatBTC(2.01999)), findsOneWidget);
    expect(find.text(formatter.formatBTC(3.01999)), findsNothing);
    expect(_tooltip('Pending ${formatter.formatBTC(1.0)}'), findsOneWidget);
  });

  testWidgets('a chain with nothing pending shows one number and no tooltip', (tester) async {
    setUpChain(_thunder());
    thunderRPC.wallet = (2.01999, 0.0);
    thunderRPC.setConnected(true);
    await balances.fetch();
    await pumpTable(tester);

    final formatter = GetIt.I.get<FormatterProvider>();
    expect(find.text(formatter.formatBTC(2.01999)), findsOneWidget);
    expect(_tooltip('Pending ${formatter.formatBTC(0.0)}'), findsNothing);
  });
}

Future<void> _captureTable(WidgetTester tester, String name) async {
  const directory = String.fromEnvironment('SIDECHAIN_TABLE_SCREEN_DIR');
  if (directory.isEmpty) {
    return;
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('sidechains-table-screen')));
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await Directory(directory).create(recursive: true);
      await File('$directory/$name.png').writeAsBytes(bytes.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Finder _tooltip(String message) =>
    find.byWidgetPredicate((widget) => widget is SailTooltip && widget.message == message);

Finder _cell(String value) => find.byWidgetPredicate((widget) => widget is SailTableCell && widget.value == value);

double _textWidth(String text, {bool bold = false}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: SailStyleValues.thirteen.copyWith(fontWeight: bold ? SailStyleValues.boldWeight : null),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

double _headerWidth(String name) => _textWidth(name, bold: true);

void _expectOneUncutLine(WidgetTester tester, Finder cell, String text) {
  for (final match in find.descendant(of: cell, matching: find.text(text)).evaluate()) {
    final paragraph = match.renderObject! as RenderParagraph;
    expect(paragraph.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: text.length)), hasLength(1));
    expect(paragraph.didExceedMaxLines, isFalse);
  }
}

void _expectFullName(WidgetTester tester, String name) {
  final cell = _cell(name);
  final text = find.descendant(of: cell, matching: find.text(name));
  final paragraph = tester.renderObject<RenderParagraph>(text);
  final painter = TextPainter(
    text: paragraph.text,
    textDirection: paragraph.textDirection,
    textScaler: paragraph.textScaler,
    maxLines: 1,
  )..layout();
  final width = painter.width;
  painter.dispose();
  final boxes = paragraph.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: name.length));
  expect(boxes, hasLength(1));
  expect(paragraph.didExceedMaxLines, isFalse);
  expect(boxes.single.right - boxes.single.left, closeTo(width, 1));
  expect(paragraph.overflow, isNot(TextOverflow.ellipsis));
  expect(paragraph.getTransformTo(null).entry(0, 0), closeTo(1, 0.001));
  final widget = tester.widget<SailTableCell>(cell);
  final row = widget.child! as Row;
  final dot = tester.getSize(find.descendant(of: cell, matching: find.byWidget(row.children.first))).width;
  final gap = tester.getSize(find.descendant(of: cell, matching: find.byWidget(row.children[1]))).width;
  expect(dot, 8);
  expect(gap, 8);
  final bounds = tester.getRect(cell);
  final textBounds = tester.getRect(text);
  expect(textBounds.left, closeTo(bounds.left + widget.padding.left + dot + gap, 0.01));
  expect(textBounds.left + boxes.single.right, lessThanOrEqualTo(bounds.right - widget.padding.right + 0.01));
}
