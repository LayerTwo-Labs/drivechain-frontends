import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/network_switch_page.dart';
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
    expect(find.text('Save location:'), findsNothing);
    final createButtons = tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Create Backup'));
    expect(createButtons, isNotEmpty);
    expect(createButtons.every((b) => !b.disabled), isTrue, reason: 'a phone needs no save location first');
  });

  testWidgets('on a desktop Backup keeps the 40 px title in the middle', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pump(tester, const BackupWalletPage(), const Size(1200, 800));

    expect(find.byType(SailPanelPage), findsNothing);
    expect(_fontSize(tester, 'Backup your wallet'), 40);
    expect(find.text('Save location:'), findsOneWidget);
    expect(tester.getRect(find.text('Backup your wallet')).center.dx, closeTo(600, 1));
  });

  group('Restore', () {
    setUp(() {
      if (!GetIt.I.isRegistered<Logger>()) {
        GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
      }
    });

    Widget page() => RestoreWalletPage(bootBinaries: (_) async {}, binariesToStop: const []);

    testWidgets('on a phone shows its title in a panel, not 40 px in the middle', (tester) async {
      SailStyleValues.phoneLayoutOverride = true;
      // Wider than a phone: the test font draws each letter as a wide square.
      await _pump(tester, page(), const Size(500, 900));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SailPanelPage), findsOneWidget);
      expect(_fontSize(tester, 'Restore from backup'), 18);
      expect(find.text('Restore selected backup'), findsWidgets);
    });

    testWidgets('on a desktop keeps the 40 px title in the middle', (tester) async {
      SailStyleValues.phoneLayoutOverride = false;
      await _pump(tester, page(), const Size(1200, 900));
      await tester.pumpAndSettle();

      expect(find.byType(SailPanelPage), findsNothing);
      expect(_fontSize(tester, 'Restore from backup'), 40);
    });
  });

  testWidgets('Drivechains Not Enabled on a phone puts the selector and the switch button in one panel', (
    tester,
  ) async {
    var switched = 0;
    await _pump(
      tester,
      Scaffold(
        body: DrivechainsNotEnabledPanel(
          currentNetwork: 'Bitcoin',
          networkSelector: const SizedBox(height: 30, child: Text('Signet (Recommended)')),
          switching: false,
          error: 'Error switching network: refused',
          onSwitch: () async => switched++,
        ),
      ),
      const Size(400, 800),
    );

    expect(tester.takeException(), isNull);
    expect(_fontSize(tester, 'Drivechains Not Enabled'), 18);
    expect(find.textContaining('not enabled on Bitcoin yet'), findsOneWidget);
    final selector = tester.getRect(find.text('Signet (Recommended)'));
    final error = tester.getRect(find.text('Error switching network: refused'));
    final button = tester.getRect(find.text('Switch Network').first);
    expect(error.top, greaterThan(selector.bottom));
    expect(button.top, greaterThan(error.bottom));
    expect(button.left, lessThan(60));

    await tester.tap(find.text('Switch Network').first);
    await tester.pump();
    expect(switched, 1);
  });

  testWidgets('Confirm Deletion on a phone puts the status, the files and the buttons in one panel', (tester) async {
    await _pump(
      tester,
      Scaffold(
        body: ResetConfirmationPanel(
          title: 'Confirm Deletion',
          icon: const SizedBox(width: 32, height: 32),
          status: const Text('The following 2 items will be deleted:'),
          list: const Text('bitwindow/settings.json'),
          buttons: [
            SailButton(label: 'Cancel', onPressed: () async {}),
            SailButton(label: 'Delete 2', variant: ButtonVariant.destructive, onPressed: () async {}),
          ],
        ),
      ),
      const Size(400, 800),
    );

    expect(tester.takeException(), isNull);
    expect(_fontSize(tester, 'Confirm Deletion'), 18);
    final status = tester.getRect(find.text('The following 2 items will be deleted:'));
    final files = tester.getRect(find.text('bitwindow/settings.json'));
    final delete = tester.getRect(find.text('Delete 2').first);
    expect(status.left, lessThan(60));
    expect(files.top, greaterThan(status.bottom));
    expect(delete.top, greaterThan(files.bottom));
    expect(delete.right, greaterThan(300));
  });
}
