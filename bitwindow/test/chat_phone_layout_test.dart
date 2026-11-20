import 'dart:convert';

import 'package:bitwindow/pages/chat_page.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:thirds/blake3.dart';

import 'mocks/store_mock.dart';
import 'test_utils.dart';

class _BitnamesRPC extends MockBitnamesRPC {
  @override
  Future<List<BitnameEntry>> listBitNames() async => [
    BitnameEntry(
      hash: blake3Hex(utf8.encode('alice')),
      plaintextName: 'alice',
      details: BitnameDetails(seqId: '1', encryptionPubkey: 'bn-enc1alice'),
    ),
  ];
}

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  bool get networkSupportsSidechains => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpChat(WidgetTester tester, {required bool phone, required bool connected}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  final log = Logger();
  final store = MockStore();
  GetIt.I.registerSingleton<Logger>(log);
  GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: store, log: log));
  GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: store, log: log));
  GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
  final rpc = _BitnamesRPC()..setConnected(connected);
  GetIt.I.registerSingleton<BitnamesRPC>(rpc);
  GetIt.I.registerSingleton<BalanceProvider>(BalanceProvider(connections: [rpc]));
  GetIt.I.registerSingleton<ChatProvider>(ChatProvider());

  await tester.pumpSailPage(const ChatPage());
  await tester.pump();
}

Finder _addContact() => find.widgetWithText(SailButton, 'Add Contact');

Finder _chatsCard() =>
    find.ancestor(of: find.text('You pay a name to reach it. They keep the postage.'), matching: find.byType(SailCard));

void main() {
  tearDown(() async {
    GetIt.I.get<ChatProvider>().stopPolling();
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone Add Contact is a small outline button in the Chats card header', (tester) async {
    await _pumpChat(tester, phone: true, connected: true);

    expect(tester.takeException(), isNull);
    expect(_addContact(), findsOneWidget);
    expect(find.descendant(of: _chatsCard(), matching: _addContact()), findsOneWidget);
    final button = tester.widget<SailButton>(_addContact());
    expect(button.variant, ButtonVariant.outline);
    expect(button.small, isTrue);
    expect(tester.getTopLeft(_addContact()).dy, lessThan(tester.getTopLeft(find.text('Chats')).dy + 8));

    final identityBar = tester.getRect(find.text('Chatting as:'));
    final register = tester.getRect(find.text('Deposit to BitNames'));
    expect(register.center.dy, closeTo(identityBar.center.dy, 4));
  });

  testWidgets('on desktop Add Contact stays in the identity bar', (tester) async {
    await _pumpChat(tester, phone: false, connected: true);

    expect(_addContact(), findsOneWidget);
    expect(find.descendant(of: _chatsCard(), matching: _addContact()), findsNothing);
    expect(tester.widget<SailButton>(_addContact()).variant, ButtonVariant.secondary);
  });

  for (final phone in [true, false]) {
    testWidgets('the matched Add Contact row tint, phone: $phone', (tester) async {
      await _pumpChat(tester, phone: phone, connected: true);
      await tester.pumpAndSettle();
      await tester.tap(_addContact());
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(EditableText).last, 'alice');
      await tester.pump(const Duration(seconds: 1));

      final row = find.ancestor(of: find.text('alice'), matching: find.byType(Container)).first;
      final color = (tester.widget<Container>(row).decoration! as BoxDecoration).color;
      final theme = SailTheme.of(tester.element(row));
      expect(color, phone ? theme.colors.primary.withAlpha(30) : theme.colors.success.withValues(alpha: 0.1));
    });
  }

  testWidgets('on a phone the BitNames required steps sit at the left', (tester) async {
    await _pumpChat(tester, phone: true, connected: false);

    final heading = tester.getRect(find.text('BitNames sidechain is not connected'));
    final steps = tester.getRect(find.textContaining('To use the Chat feature'));
    expect(steps.left, closeTo(heading.left, 1));
    final icon = find.descendant(
      of: find.byKey(const ValueKey('chat-bitnames-required')),
      matching: find.byWidgetPredicate((w) => w.runtimeType.toString() == 'SvgPicture'),
    );
    expect(tester.getRect(icon).left, closeTo(heading.left, 1));
    expect(tester.widget<Text>(find.textContaining('To use the Chat feature')).textAlign, TextAlign.start);
  });
}
