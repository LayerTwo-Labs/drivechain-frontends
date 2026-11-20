import 'dart:convert';

import 'package:bitwindow/models/chat_models.dart';
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
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  String ecashNetworkId = '';

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
  final settings = ClientSettings(store: store, log: log);
  GetIt.I.registerSingleton<ClientSettings>(settings);
  GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: store, log: log));
  GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
  await tester.runAsync(
    () => settings.setValue(
      ChatContactsSetting(
        newValue: [
          for (final name in ['alice', 'bob'])
            ChatContact(
              id: blake3Hex(utf8.encode(name)),
              name: blake3Hex(utf8.encode(name)),
              plaintextName: name,
              encryptionPubkey: 'bn-enc1$name',
              address: 'addr-$name',
            ),
        ],
      ),
    ),
  );
  final rpc = _BitnamesRPC()..setConnected(connected);
  GetIt.I.registerSingleton<BitnamesRPC>(rpc);
  GetIt.I.registerSingleton<BalanceProvider>(BalanceProvider(connections: [rpc]));
  GetIt.I.registerSingleton<ChatProvider>(ChatProvider());

  if (phone) {
    await loadBundledFonts();
  }
  await tester.pumpSailPage(const ChatPage());
  if (phone) {
    await tester.binding.setSurfaceSize(const Size(390, 800));
  }
  await tester.pump();
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

  testWidgets('on a phone the chat list fills the width and Add Contact sits in its header', (tester) async {
    await _pumpChat(tester, phone: true, connected: true);

    expect(tester.takeException(), isNull);
    expect(find.descendant(of: _chatsCard(), matching: _addContact()), findsOneWidget);
    final button = tester.widget<SailButton>(_addContact());
    expect(button.variant, ButtonVariant.outline);
    expect(button.small, isTrue);

    final identityBar = tester.getRect(find.text('Chatting as:'));
    expect(tester.getRect(find.text('Deposit to BitNames')).center.dy, closeTo(identityBar.center.dy, 4));
    expect(tester.getRect(_chatsCard().first).top, greaterThan(identityBar.bottom));
    expect(tester.getRect(_chatsCard().first).width, greaterThan(300));
    expect(find.text('alice'), findsOneWidget);
    expect(find.text('Type a message...'), findsNothing);
  });

  testWidgets('on a phone a tap on a chat opens it full width and back returns to the list', (tester) async {
    await _pumpChat(tester, phone: true, connected: true);

    await tester.tap(find.text('alice'));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(_chatsCard(), findsNothing);
    expect(find.text('Type a message...'), findsOneWidget);
    expect(tester.getRect(find.byType(SailTextField)).width, greaterThan(150));
    final back = find.byKey(const ValueKey('chat-back'));
    expect(back, findsOneWidget);

    await tester.tap(back);
    await tester.pump();

    expect(_chatsCard(), findsOneWidget);
    expect(find.text('Type a message...'), findsNothing);
  });

  testWidgets('on a phone system back closes the conversation and shows the list', (tester) async {
    await _pumpChat(tester, phone: true, connected: true);
    await tester.tap(find.text('alice'));
    await tester.pump();
    expect(find.text('Type a message...'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pump();

    expect(handled, isTrue);
    expect(find.byType(ChatPage), findsOneWidget);
    expect(_chatsCard(), findsOneWidget);
    expect(find.text('Type a message...'), findsNothing);
  });

  testWidgets('on desktop the list and the conversation stay side by side', (tester) async {
    await _pumpChat(tester, phone: false, connected: true);

    expect(find.descendant(of: _chatsCard(), matching: _addContact()), findsNothing);
    expect(tester.widget<SailButton>(_addContact()).variant, ButtonVariant.secondary);
    expect(find.text('Select a contact to start chatting'), findsOneWidget);

    await tester.tap(find.text('alice'));
    await tester.pump();

    expect(_chatsCard(), findsOneWidget);
    expect(find.text('Type a message...'), findsOneWidget);
    expect(find.byKey(const ValueKey('chat-back')), findsNothing);
  });

  for (final phone in [true, false]) {
    testWidgets('the matched Add Contact row tint, phone: $phone', (tester) async {
      await _pumpChat(tester, phone: phone, connected: true);
      await tester.tap(_addContact());
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(EditableText).last, 'alice');
      await tester.pump(const Duration(seconds: 1));

      final row = find
          .ancestor(
            of: find.descendant(of: find.byType(ListView).last, matching: find.text('alice')),
            matching: find.byType(Container),
          )
          .first;
      final color = (tester.widget<Container>(row).decoration! as BoxDecoration).color;
      expect(tester.takeException(), isNull);
      final theme = SailTheme.of(tester.element(row));
      expect(color, phone ? theme.colors.primary.withAlpha(30) : theme.colors.success.withValues(alpha: 0.1));
    });
  }

  for (final phone in [true, false]) {
    testWidgets('the Add Contact rows show the full hash, phone: $phone', (tester) async {
      await _pumpChat(tester, phone: phone, connected: true);
      await tester.tap(_addContact());
      await tester.pump(const Duration(seconds: 1));

      final hash = blake3Hex(utf8.encode('alice'));
      if (phone) {
        expect(tester.takeException(), isNull);
        final text = find.text(hash);
        expect(text, findsOneWidget);
        expect(tester.getSize(text).height, greaterThan(20));
      } else {
        expect(find.text('${hash.substring(0, 32)}...'), findsOneWidget);
      }
    });
  }

  testWidgets('on a phone the BitNames required steps sit at the left', (tester) async {
    await _pumpChat(tester, phone: true, connected: false);

    expect(tester.takeException(), isNull);
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
