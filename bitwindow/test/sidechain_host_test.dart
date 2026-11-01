import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitassets/bitassets_module.dart';
import 'package:bitwindow/pages/sidechain_host_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:bitwindow/sidechains/hosted_chains.dart';
import 'package:bitwindow/sidechains/hosted_modules.dart';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:thunder/thunder_module.dart';

import 'test_utils.dart';

class _BitAssetsRPC extends BitAssetsRPC {
  _BitAssetsRPC() : super(binaryType: BinaryType.BINARY_TYPE_BITASSETS);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Slots extends ChangeNotifier implements SidechainProvider {
  @override
  List<SidechainOverview?> sidechains = List.filled(256, null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Window extends ChangeNotifier implements WindowProvider {
  @override
  final Directory appDir;

  _Window(this.appDir);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The host route of BitWindow, with a text in place of each tab page.
class _HostRouter extends AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/',
      page: SidechainsRoute.page,
      initial: true,
      children: [
        AutoRoute(
          path: '',
          page: PageInfo(SidechainSlotsRoute.name, builder: (_) => const Text('slot table')),
          initial: true,
        ),
        AutoRoute(
          path: ':chain',
          page: SidechainHostRoute.page,
          children: [
            for (final name in {
              for (final module in hostedModules)
                for (final route in shellTabRoutes(module)) route.routeName,
            })
              AutoRoute(
                page: PageInfo(name, builder: (_) => Text('page $name')),
                initial: name == SidechainHomepageRoute.name,
              ),
          ],
        ),
      ],
    ),
  ];
}

AutoRoute _route(List<AutoRoute> routes, String name) => routes.firstWhere((route) => route.name == name);

List<String> _textsInOrder(WidgetTester tester, List<String> labels) {
  final found = [
    for (final label in labels.toSet())
      for (final element in find.text(label).evaluate()) (label, tester.getTopLeft(find.byWidget(element.widget)).dx),
  ]..sort((a, b) => a.$2.compareTo(b.$2));
  return [for (final (label, _) in found) label];
}

void main() {
  const thunderTabs = ['Parent Chain', 'Explorer', 'BMM', 'Overview', 'Console', 'Settings'];
  const bitAssetsTabs = [
    'Parent Chain',
    'Explorer',
    'BMM',
    'Home',
    'BitAssets',
    'Messaging',
    'Dutch Auction',
    'AMM',
    'Explorer',
    'Auctions',
    'Console',
    'Settings',
  ];

  group('host route', () {
    final root = _route(AppRouter().routes, RootRoute.name);
    final sidechains = _route(root.children!, SidechainsRoute.name);
    final host = _route(sidechains.children!, SidechainHostRoute.name);
    final hostChildren = {for (final route in host.children!) route.name};

    for (final (module, labels) in [(ThunderModule(), thunderTabs), (BitAssetsModule(), bitAssetsTabs)]) {
      test('${module.appName} has its tabs in order, each a child of the host route', () {
        expect(shellTabLabels(module), labels);
        final routes = shellTabRoutes(module);
        expect(routes, hasLength(labels.length));
        for (final route in routes) {
          expect(hostChildren, contains(route.routeName));
        }
      });
    }

    test('every hosted chain opens by its registry key', () {
      for (final module in hostedModules) {
        expect(hostedModuleByKey(module.chain.registryKey), same(module));
      }
      expect(hostedModuleByKey('bbc'), isNull);
    });
  });

  group('tab row', () {
    tearDown(() => GetIt.I.reset());

    for (final (name, labels) in [('Thunder', thunderTabs), ('BitAssets', bitAssetsTabs)]) {
      testWidgets('$name shows the module tabs in order and selects the tapped one', (tester) async {
        var selected = -1;
        await tester.pumpSailPage(
          ChainTabRow(labels: labels, activeIndex: 3, onSelect: (index) => selected = index),
        );

        expect(_textsInOrder(tester, labels), labels);
        await tester.tap(find.text('BMM'));
        expect(selected, labels.indexOf('BMM'));
      });
    }
  });

  group('sidebar', () {
    tearDown(() => GetIt.I.reset());

    SidechainSidebarEntry entry(SidechainModule module, {required bool running, required String trailing}) =>
        SidechainSidebarEntry(module: module, color: module.chain.color, running: running, trailing: trailing);

    testWidgets('groups running and stopped chains, shows the total and selects the open chain', (tester) async {
      final modules = {for (final module in hostedModules) module.chain.name: module};
      String? opened;
      var allSlots = false;

      await tester.pumpSailPage(
        SizedBox(
          height: 700,
          child: SidechainSidebar(
            entries: [
              entry(modules['Thunder']!, running: true, trailing: '1.01019400 BTC'),
              entry(modules['Truthcoin']!, running: false, trailing: 'Stopped'),
              entry(modules['BitAssets']!, running: true, trailing: '0.11000000 BTC'),
              entry(modules['zSide']!, running: false, trailing: 'Not downloaded'),
            ],
            selected: modules['Thunder']!.chain.registryKey,
            total: '1.12019400 BTC',
            onSelect: (entry) => opened = entry.module.chain.name,
            onAllSlots: () => allSlots = true,
            onAddRemove: () {},
          ),
        ),
      );

      expect(find.text('Sidechain balance'), findsOneWidget);
      expect(find.text('1.12019400 BTC'), findsOneWidget);

      // The first "Stopped" is the group title, the second the state of Truthcoin.
      double top(String text) => tester.getTopLeft(find.text(text).first).dy;
      expect(top('Running'), lessThan(top('Thunder')));
      expect(top('Thunder'), lessThan(top('BitAssets')));
      expect(top('BitAssets'), lessThan(top('Stopped')));
      expect(top('Stopped'), lessThan(top('Truthcoin')));
      expect(top('Truthcoin'), lessThan(top('zSide')));
      expect(find.text('Stopped'), findsNWidgets(2));
      expect(find.text('Not downloaded'), findsOneWidget);

      Container row(String key) => tester.widget<Container>(find.byKey(ValueKey('sidebar_$key')));
      final colors = SailTheme.of(tester.element(find.text('Thunder'))).colors;
      expect((row('thunder').decoration! as BoxDecoration).color, colors.backgroundSecondary);
      expect((row('bitassets').decoration! as BoxDecoration).color, isNull);

      await tester.tap(find.text('BitAssets'));
      expect(opened, 'BitAssets');
      await tester.tap(find.text('All slots'));
      expect(allSlots, isTrue);
    });
  });

  group('host page', () {
    late Directory appDir;

    setUp(() async {
      await GetIt.I.reset();
      appDir = await Directory.systemTemp.createTemp('inapp-host');
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
      GetIt.I.registerSingleton<WindowProvider>(_Window(appDir));
      GetIt.I.registerSingleton<SidechainProvider>(_Slots());
      GetIt.I.registerSingleton<ThunderRPC>(MockThunderRPC());
      GetIt.I.registerSingleton<BitAssetsRPC>(_BitAssetsRPC());
      // ignore: invalid_use_of_visible_for_testing_member
      GetIt.I.registerSingleton<BinaryProvider>(
        BinaryProvider.test(appDir: appDir, binaries: [Thunder(), BitAssets()]),
      );
      GetIt.I.registerSingleton<BalanceProvider>(
        BalanceProvider(connections: [GetIt.I.get<ThunderRPC>(), GetIt.I.get<BitAssetsRPC>()]),
      );
      await registerTestDependencies();
      if (!GetIt.I.isRegistered<NotificationProvider>()) {
        GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
      }
      GetIt.I.registerSingleton<HostedChains>(
        HostedChains(
          binaries: GetIt.I.get<BinaryProvider>(),
          modules: hostedModules,
          applicationDir: appDir,
          log: GetIt.I.get<Logger>(),
          navigatorFor: (module) => HostChainNavigator(module.chain),
        ),
      );
    });

    tearDown(() async {
      await GetIt.I.reset();
      await appDir.delete(recursive: true);
    });

    // The scope reads the conf through real I/O, which a fake clock never runs.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 100 && find.byType(LoadingIndicator).evaluate().isNotEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    Future<_HostRouter> pumpHost(WidgetTester tester) async {
      addTearDown(() => tester.pumpWidget(const SizedBox()));
      await tester.binding.setSurfaceSize(const Size(1440, 1024));
      final router = _HostRouter();
      GetIt.I.registerSingleton<AppRouter>(router);
      await tester.pumpWidget(
        SailApp(
          dense: false,
          builder: (context) => MaterialApp.router(routerConfig: router.config()),
          initMethod: (_) async => (),
          accentColor: SailColorScheme.black,
          log: GetIt.I.get<Logger>(),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('a click on a chain notification opens the chain at its tab', (tester) async {
      await pumpHost(tester);
      expect(find.text('slot table'), findsOneWidget);

      final handler = sidechainTabHandler(
        moduleFor: hostedModuleByKey,
        navigatorFor: (module) => HostChainNavigator(module.chain),
      );
      final item = NotificationItem(
        id: 'deposit-thunder-a:0',
        title: 'Deposit received on Thunder',
        content: '1 BTC',
        dialogType: DialogType.success,
        timestamp: DateTime.utc(2026, 11, 1),
        action: sidechainTabAction,
        data: const {'chain': 'thunder', 'tab': 'ConsoleTabRoute'},
      );
      var opened = false;
      unawaited(handler(tester.element(find.text('slot table')), item).then((value) => opened = value));
      // The navigation and the session read files, which a fake clock never runs.
      for (var i = 0; i < 100 && find.text('page ${ConsoleTabRoute.name}').evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump();
      }
      await settle(tester);

      expect(opened, isTrue);
      expect(GetIt.I.get<SidechainModule>(), isA<ThunderModule>());
      expect(find.text('page ${ConsoleTabRoute.name}'), findsOneWidget);
    });

    testWidgets('a chain opens with its tabs, and a switch swaps the chain scope', (tester) async {
      final router = await pumpHost(tester);
      expect(find.text('slot table'), findsOneWidget);

      await router.navigate(SidechainsRoute(children: [SidechainHostRoute(chain: 'thunder')]));
      await tester.pump();
      await settle(tester);

      expect(GetIt.I.get<SidechainModule>(), isA<ThunderModule>());
      expect(find.text('Thunder'), findsWidgets);
      expect(find.text('Stopped'), findsWidgets);
      expect(find.text('page ${SidechainHomepageRoute.name}'), findsOneWidget);
      for (final label in shellTabLabels(ThunderModule())) {
        expect(find.text(label), findsWidgets);
      }

      await tester.tap(find.text('Console'));
      await tester.pumpAndSettle();
      expect(find.text('page ${ConsoleTabRoute.name}'), findsOneWidget);

      await router.navigate(SidechainsRoute(children: [SidechainHostRoute(chain: 'bitassets')]));
      await tester.pump();
      await settle(tester);

      expect(GetIt.I.get<SidechainModule>(), isA<BitAssetsModule>());
      expect(GetIt.I.get<SidechainRPC>(), same(GetIt.I.get<BitAssetsRPC>()));
      expect(GetIt.I.hasScope('sidechain-thunder'), isFalse);
      expect(find.text('Dutch Auction'), findsOneWidget);

      await tester.tap(find.text('All slots'));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      expect(find.text('slot table'), findsOneWidget);
      expect(GetIt.I.isRegistered<SidechainModule>(), isFalse);
    });
  });
}
