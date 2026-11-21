import 'package:bitassets/pages/tabs/amm_page.dart';
import 'package:bitassets/pages/tabs/asset_explorer_page.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _Rpc implements BitAssetsRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Assets extends ChangeNotifier implements BitAssetsProvider {
  @override
  List<BitAssetEntry> get entries => [];

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Notifications extends ChangeNotifier implements NotificationProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, Widget child, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  await tester.binding.setSurfaceSize(Size(phone ? 390 : 1200, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() async {
    await registerTestDependencies();
    GetIt.I.registerSingleton<BitAssetsRPC>(_Rpc());
    GetIt.I.registerSingleton<BitAssetsProvider>(_Assets());
    GetIt.I.registerSingleton<NotificationProvider>(_Notifications());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('a phone lists the asset counts in one panel', (tester) async {
    await _pump(
      tester,
      const AssetExplorerStats(total: 5, favorites: 1, withEncryption: 3, withSigning: 2),
      phone: true,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SailStatList), findsOneWidget);
    expect(find.byType(SailStatRow), findsNWidgets(4));
  });

  testWidgets('the desktop keeps the asset count cards', (tester) async {
    await _pump(
      tester,
      const AssetExplorerStats(total: 5, favorites: 1, withEncryption: 3, withSigning: 2),
      phone: false,
    );

    expect(find.byType(SailStatList), findsNothing);
    expect(find.text('Total Assets'), findsOneWidget);
  });

  testWidgets('a phone swaps with the normal full-width primary button', (tester) async {
    await _pump(tester, const AmmTabPage(), phone: true);

    expect(tester.takeException(), isNull);
    final swap = find.widgetWithText(SailButton, 'Swap').first;
    expect(tester.widget<SailButton>(swap).variant, ButtonVariant.primary);
    expect(tester.getSize(swap).height, greaterThan(24));
    expect(tester.getSize(swap).width, greaterThan(300));
  });

  testWidgets('the desktop keeps the tall swap bar', (tester) async {
    await _pump(tester, const AmmTabPage(), phone: false);

    expect(find.widgetWithText(SailButton, 'Swap'), findsNothing);
    expect(find.text('Swap'), findsWidgets);
  });
}
