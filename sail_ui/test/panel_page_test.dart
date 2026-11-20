import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Future<void> _pump(WidgetTester tester, Widget page, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: child ?? const SizedBox(),
      ),
      home: page,
    ),
  );
}

double _fontSize(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!.fontSize!;

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('a panel page puts an 18 px title at the left of one panel, then the body and the actions', (
    tester,
  ) async {
    await _pump(
      tester,
      const Scaffold(
        body: SailPanelPage(
          title: 'Restore from backup',
          subtitle: 'Restore your wallet',
          actions: Text('actions'),
          children: [Text('body')],
        ),
      ),
      const Size(400, 800),
    );

    expect(tester.takeException(), isNull);
    expect(_fontSize(tester, 'Restore from backup'), 18);
    final title = tester.getRect(find.text('Restore from backup'));
    expect(title.left, 12 + 16);
    final panel = tester.getRect(find.byType(DecoratedBox).first);
    expect(panel.left, 12);
    expect(panel.right, 400 - 12);
    expect(tester.getRect(find.text('Restore your wallet')).top, greaterThan(title.bottom));
    expect(tester.getRect(find.text('body')).top, greaterThan(title.bottom));
    expect(tester.getRect(find.text('actions')).top, greaterThan(tester.getRect(find.text('body')).bottom));
    expect(tester.getRect(find.text('actions')).bottom, lessThan(panel.bottom));
  });

  testWidgets('on a phone Backup shows its title in a panel, not 40 px in the middle', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pump(tester, const BackupWalletPage(), const Size(400, 800));

    expect(tester.takeException(), isNull);
    expect(find.byType(SailPanelPage), findsOneWidget);
    expect(_fontSize(tester, 'Backup your wallet'), 18);
    expect(tester.getRect(find.text('Backup your wallet')).left, lessThan(40));
    expect(find.text('Create Backup'), findsWidgets);
  });

  testWidgets('on a desktop Backup keeps the 40 px title in the middle', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pump(tester, const BackupWalletPage(), const Size(1200, 800));

    expect(find.byType(SailPanelPage), findsNothing);
    expect(_fontSize(tester, 'Backup your wallet'), 40);
    expect(tester.getRect(find.text('Backup your wallet')).center.dx, closeTo(600, 1));
  });
}
