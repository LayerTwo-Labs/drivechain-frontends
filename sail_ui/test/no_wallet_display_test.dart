import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/providers/price_provider.dart';

class _Balance extends ChangeNotifier implements BalanceProvider {
  @override
  double balance = 1.5;

  @override
  double pendingBalance = 0;

  @override
  double maturingBalance = 0;

  @override
  bool initialized = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Price extends ChangeNotifier implements PriceProvider {
  @override
  double? toUsd(double amount) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(Widget child) => SailTheme(
  data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
  child: MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

wmpb.WatchWalletDataResponse _frame({required bool hasWallet}) => wmpb.WatchWalletDataResponse(
  state: hasWallet ? wmpb.WalletState.WALLET_STATE_UNLOCKED : wmpb.WalletState.WALLET_STATE_NO_WALLET,
  activeWalletId: hasWallet ? 'w1' : '',
  wallets: hasWallet ? [wmpb.WalletMetadata(id: 'w1', name: 'Main')] : const [],
);

void main() {
  late WalletReaderProvider reader;

  setUp(() {
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BalanceProvider>(_Balance());
    GetIt.I.registerSingleton<PriceProvider>(_Price());
    reader = WalletReaderProvider(Directory.systemTemp);
    GetIt.I.registerSingleton<WalletReaderProvider>(reader);
  });

  tearDown(() async => GetIt.I.reset());

  test('an unread wallet state is not a missing wallet', () {
    expect(reader.hasNoWallet, isFalse);
    reader.applyWatchFrame(_frame(hasWallet: false));
    expect(reader.hasNoWallet, isTrue);
  });

  testWidgets('the status bar reads No wallet in place of the balance', (tester) async {
    reader.applyWatchFrame(_frame(hasWallet: false));
    await tester.pumpWidget(_host(const BottomNavBalance()));
    await tester.pump();

    expect(find.text('No wallet'), findsOneWidget);
    expect(find.byType(BalanceDisplay), findsNothing);

    reader.applyWatchFrame(_frame(hasWallet: true));
    await tester.pump();

    expect(find.text('No wallet'), findsNothing);
    expect(find.byType(BalanceDisplay), findsOneWidget);
  });

  group('wallet dropdown', () {
    Widget dropdown({required bool withActions, List<String> created = const []}) => _host(
      WalletDropdown(
        currentWallet: null,
        availableWallets: const [],
        onWalletSelected: (_) {},
        onCreateWallet: () => created.add('create'),
        noWalletActions: withActions
            ? (onGenerate: () => created.add('generate'), onImportDescriptor: () => created.add('import'))
            : null,
      ),
    );

    testWidgets('reads No wallet and offers generate and import', (tester) async {
      final calls = <String>[];
      await tester.pumpWidget(dropdown(withActions: true, created: calls));
      await tester.pumpAndSettle();

      final label = tester.widget<Text>(find.text('No wallet'));
      final theme = SailTheme.of(tester.element(find.text('No wallet')));
      expect(label.style?.color, theme.colors.textSecondary);

      await tester.tap(find.byType(WalletDropdown));
      await tester.pumpAndSettle();
      expect(find.text('Create new wallet'), findsNothing);

      await tester.tap(find.text('Import descriptor'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(WalletDropdown));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Generate wallet'));
      await tester.pumpAndSettle();

      expect(calls, ['import', 'generate']);
    });

    testWidgets('without the actions keeps Create new wallet', (tester) async {
      await tester.pumpWidget(dropdown(withActions: false));
      await tester.pumpAndSettle();

      expect(find.text('No wallet'), findsNothing);
      await tester.tap(find.byType(WalletDropdown));
      await tester.pumpAndSettle();
      expect(find.text('Create new wallet'), findsOneWidget);
      expect(find.text('Generate wallet'), findsNothing);
    });
  });
}
