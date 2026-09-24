import 'dart:io';

import 'package:bitwindow/widgets/starters_tab.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

const _mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  bool get networkSupportsSidechains => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? get activeWalletId => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletWriter extends ChangeNotifier implements WalletWriterProvider {
  @override
  Future<Map<String, dynamic>?> loadMasterStarter() async => {'name': 'Master', 'mnemonic': _mnemonic};

  @override
  Future<String?> getL1Starter() async => null;

  @override
  Future<String?> getSidechainStarter(int sidechainSlot) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final copied = <String>[];

  setUp(() async {
    await GetIt.I.reset();
    copied.clear();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    GetIt.I.registerSingleton<WalletWriterProvider>(_WalletWriter());
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [BitcoinCore()]),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpStarters(WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(const StartersTab());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapCopy(WidgetTester tester) async {
    await tester.tap(find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.iconCopy));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapInDialog(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('copy shows the seed warning and copies nothing on cancel', (tester) async {
    await pumpStarters(tester);

    await tapCopy(tester);

    expect(find.byType(RevealSeedWarningDialog), findsOneWidget);
    expect(copied, isEmpty);

    await tapInDialog(tester, find.widgetWithText(SailButton, 'Cancel').last);
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(RevealSeedWarningDialog), findsNothing);
    expect(copied, isEmpty);
  });

  testWidgets('copy puts the mnemonic on the clipboard after the user accepts', (tester) async {
    await pumpStarters(tester);

    await tapCopy(tester);
    expect(copied, isEmpty);

    await tapInDialog(tester, find.text('I understand that anyone with this seed phrase can steal my funds'));
    await tapInDialog(tester, find.text('I have verified this is a secure, private environment'));
    await tapInDialog(tester, find.widgetWithText(SailButton, 'Copy Seed Phrase').last);
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(RevealSeedWarningDialog), findsNothing);
    expect(copied, [_mnemonic]);

    await tester.pump(const Duration(seconds: 5));
  });
}
