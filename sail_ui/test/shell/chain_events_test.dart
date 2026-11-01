import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

class _Module extends SidechainModule {
  @override
  Sidechain get chain => Thunder();

  @override
  String get appName => 'Thunder';

  @override
  List<ShellTab> get tabs => const [ShellTab(label: 'Swaps', route: NamedRoute('SwapsTabRoute'))];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Transactions extends ChangeNotifier implements SidechainTransactionsProvider {
  @override
  List<SidechainUTXO> utxos = [];

  @override
  bool utxosLoaded = false;

  void list(List<SidechainUTXO> next) {
    utxos = next;
    utxosLoaded = true;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Navigator implements ChainNavigator {
  final List<PageRouteInfo> opened = [];

  @override
  Future<void> openTab(PageRouteInfo tab) async => opened.add(tab);

  @override
  Future<void> push(PageRouteInfo route) async {}

  @override
  Future<void> pop() async {}
}

SidechainUTXO _deposit(String outpoint, int sats, {bool confirmed = true}) => SidechainUTXO(
  outpoint: outpoint,
  address: 'addr',
  valueSats: sats,
  type: OutpointType.deposit,
  confirmed: confirmed,
);

SidechainUTXO _regular(String outpoint) =>
    SidechainUTXO(outpoint: outpoint, address: 'addr', valueSats: 5, type: OutpointType.regular);

void main() {
  final module = _Module();

  group('DepositWatcher', () {
    late _Transactions transactions;
    late List<ChainEvent> events;
    late DepositWatcher watcher;

    setUp(() {
      transactions = _Transactions();
      events = [];
      watcher = DepositWatcher(
        module: module,
        transactions: transactions,
        formatSats: (sats) => '$sats sats',
        notify: events.add,
      );
    });

    tearDown(() => watcher.dispose());

    test('the deposits of the first list are old, so they send nothing', () {
      transactions.list([_deposit('a:0', 100), _deposit('b:0', 200)]);
      expect(events, isEmpty);
    });

    test('a list that failed sets no baseline', () {
      transactions.notifyListeners();
      transactions.list([_deposit('a:0', 100)]);
      expect(events, isEmpty);
    });

    test('a new deposit sends one event that opens the parent chain tab', () {
      transactions.list([_deposit('a:0', 100)]);
      transactions.list([_deposit('a:0', 100), _deposit('b:0', 2500), _regular('c:0')]);

      expect(events, hasLength(1));
      expect(events.single.id, 'deposit-thunder-b:0');
      expect(events.single.title, 'Deposit received on Thunder');
      expect(events.single.content, '2500 sats is in your Thunder wallet.');
      expect(events.single.tab.routeName, ParentChainRoute.name);
    });

    test('a deposit sends its event when it confirms, one time', () {
      transactions.list([]);
      transactions.list([_deposit('a:0', 100, confirmed: false)]);
      expect(events, isEmpty);

      transactions.list([_deposit('a:0', 100)]);
      transactions.list([_deposit('a:0', 100)]);
      expect(events.map((e) => e.id), ['deposit-thunder-a:0']);
    });
  });

  group('notifications', () {
    late NotificationProvider notifications;
    late _Navigator navigator;

    setUp(() {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
      notifications = NotificationProvider();
      navigator = _Navigator();
    });

    tearDown(() async => GetIt.I.reset());

    const event = ChainEvent(
      id: 'deposit-thunder-b:0',
      title: 'Deposit received on Thunder',
      content: '1 BTC',
      tab: ParentChainRoute(),
    );

    test('a chain event goes in the history with the chain and the tab', () {
      postChainEvent(notifications, module, navigator, event);
      postChainEvent(notifications, module, navigator, event);

      final item = notifications.history.single;
      expect(item.id, 'deposit-thunder-b:0');
      expect(item.action, sidechainTabAction);
      expect(item.data, {'chain': 'thunder', 'tab': ParentChainRoute.name});
    });

    testWidgets('the handler opens the tab that the item names', (tester) async {
      postChainEvent(notifications, module, navigator, event);
      final handler = sidechainTabHandler(
        moduleFor: (key) => key == 'thunder' ? module : null,
        navigatorFor: (_) => navigator,
      );
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );

      expect(await handler(context, notifications.history.single), isTrue);
      expect(navigator.opened.single.routeName, ParentChainRoute.name);

      final other = notifications.history.single.copyWith();
      expect(
        await handler(
          context,
          NotificationItem(
            id: other.id,
            title: other.title,
            content: other.content,
            dialogType: other.dialogType,
            timestamp: other.timestamp,
            action: sidechainTabAction,
            data: const {'chain': 'zside', 'tab': 'ParentChainRoute'},
          ),
        ),
        isFalse,
      );
      await tester.pump(const Duration(seconds: 6));
    });

    test('a tab route resolves by its name, also for a chain tab', () {
      expect(chainTabNamed(module, 'SwapsTabRoute')?.routeName, 'SwapsTabRoute');
      expect(chainTabNamed(module, SidechainSettingsRoute.name)?.routeName, SidechainSettingsRoute.name);
      expect(chainTabNamed(module, 'NoSuchRoute'), isNull);
    });
  });
}
