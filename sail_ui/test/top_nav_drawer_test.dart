import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _tabs = ['Overview', 'Wallet', 'Sidechains', 'Learn', 'Console', 'Chat', 'Mining'];

Future<void> _pumpDrawer(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = RootStackRouter.build(
    routes: [
      NamedRouteDef(
        name: 'HomeRoute',
        initial: true,
        builder: (context, data) => AutoTabsRouter(
          routes: [
            for (final tab in [..._tabs, 'Settings']) NamedRoute('${tab}Route'),
          ],
          builder: (context, child) => Scaffold(
            drawer: TopNavDrawer(
              routes: [
                for (final tab in _tabs) TopNavRoute(label: tab),
                const TopNavRoute(icon: SailSVGAsset.settings, drawerLabel: 'Settings'),
              ],
            ),
            body: child,
          ),
        ),
        children: [
          for (final tab in [..._tabs, 'Settings'])
            NamedRouteDef(name: '${tab}Route', builder: (_, _) => const SizedBox()),
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
  await tester.pump();
  tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the drawer fits a landscape phone and scrolls to Settings', (tester) async {
    await _pumpDrawer(tester, const Size(800, 360));

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Settings'), 100);
    expect(find.text('Settings').hitTestable(), findsOneWidget);
  });

  testWidgets('the drawer keeps Settings at the bottom on a portrait phone', (tester) async {
    await _pumpDrawer(tester, const Size(412, 900));

    expect(tester.takeException(), isNull);
    final settings = tester.getRect(find.text('Settings'));
    final chat = tester.getRect(find.text('Chat'));
    expect(settings.top - chat.bottom, greaterThan(200));
  });
}
