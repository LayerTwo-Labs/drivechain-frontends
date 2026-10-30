import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

class _ModuleWithTabs extends SidechainModule {
  @override
  Sidechain get chain => Thunder();

  @override
  String get appName => 'Thunder';

  @override
  List<ShellTab> get tabs => const [
    ShellTab(label: 'Swaps', route: NamedRoute('SwapsTabRoute')),
    ShellTab(label: 'Markets', route: NamedRoute('MarketsTabRoute')),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('the home page shows the common tabs and the module tabs in order', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 600));
    final module = _ModuleWithTabs();
    final routes = shellTabRoutes(module);
    late TabsRouter tabs;

    final router = RootStackRouter.build(
      routes: [
        NamedRouteDef(
          name: 'HomeRoute',
          initial: true,
          builder: (context, data) => AutoTabsRouter(
            routes: routes,
            builder: (context, child) {
              tabs = AutoTabsRouter.of(context);
              return Column(
                children: [
                  TopNav(routes: shellTopNavRoutes(module, tabs.setActiveIndex)),
                  Expanded(child: child),
                ],
              );
            },
          ),
          children: [
            for (final route in routes) NamedRouteDef(name: route.routeName, builder: (_, _) => const SizedBox()),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: MaterialApp.router(routerConfig: router.config()),
      ),
    );
    await tester.pumpAndSettle();

    expect(routes.map((r) => r.routeName), [
      'ParentChainRoute',
      'ExplorerRoute',
      'BmmRoute',
      'SidechainHomepageRoute',
      'SwapsTabRoute',
      'MarketsTabRoute',
      'ConsoleTabRoute',
      'SidechainSettingsRoute',
    ]);

    final shown = tester.widgetList<QtTab>(find.byType(QtTab)).map((tab) => tab.label ?? tab.icon?.name).toList();
    expect(shown, ['Parent Chain', 'Explorer', 'BMM', 'Overview', 'Swaps', 'Markets', 'Console', 'settings']);

    final labels = ['Parent Chain', 'Explorer', 'BMM', 'Overview', 'Swaps', 'Markets', 'Console'];
    for (final (index, label) in labels.indexed) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(tabs.activeIndex, index, reason: label);
    }

    await tester.tap(find.byType(QtTab).last);
    await tester.pumpAndSettle();
    expect(tabs.activeIndex, routes.length - 1);
  });
}
