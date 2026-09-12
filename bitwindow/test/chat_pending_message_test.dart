import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';

import 'mocks/store_mock.dart';

void main() {
  costTests();
  unknownSenderTests();
  conversationTests();
  readStateTests();
  identityTests();
  group('a message that waits in the mempool', () {
    test('carries the pending flag through json', () {
      final pending = ChatMessage(
        id: 'aa:0',
        content: 'hei',
        senderPubkey: 'bn-enc1a',
        recipientPubkey: 'bn-enc1b',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1757680000000),
        isOutgoing: false,
        isPending: true,
      );

      final read = ChatMessage.fromJson(pending.toJson());
      expect(read.isPending, isTrue);
      expect(read.content, 'hei');
    });

    test('reads as settled when no flag is stored', () {
      final read = ChatMessage.fromJson({
        'id': 'aa:0',
        'content': 'hei',
        'sender_pubkey': 'bn-enc1a',
        'recipient_pubkey': 'bn-enc1b',
        'is_outgoing': false,
      });
      expect(read.isPending, isFalse);
    });

    // A block settles the message the mempool already showed.
    test('settles without losing its content', () {
      final pending = ChatMessage(
        id: 'aa:0',
        content: 'hei',
        senderPubkey: 'bn-enc1a',
        recipientPubkey: 'bn-enc1b',
        timestamp: DateTime.now(),
        isOutgoing: false,
        valueSats: 1000,
        isPending: true,
      );

      final settled = pending.copyWith(isPending: false);
      expect(settled.isPending, isFalse);
      expect(settled.content, 'hei');
      expect(settled.valueSats, 1000);
      expect(settled.id, pending.id);
    });
  });
}

void identityTests() {
  group('the selected chat identity', () {
    late ChatProvider provider;
    late BalanceProvider balance;
    late MockBitnamesRPC rpc;

    setUp(() {
      GetIt.I.registerSingleton<Logger>(Logger());
      GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: GetIt.I.get<Logger>()));
      rpc = MockBitnamesRPC();
      GetIt.I.registerSingleton<BitnamesRPC>(rpc);
      balance = BalanceProvider(connections: [rpc]);
      GetIt.I.registerSingleton<BalanceProvider>(balance);
      provider = ChatProvider();
    });

    tearDown(() async {
      provider.dispose();
      balance.dispose();
      rpc.dispose();
      await GetIt.I.reset();
    });

    test('shows only the mail for that identity', () {
      final contact = ChatContact(
        id: 'contact',
        name: 'Contact',
        encryptionPubkey: 'contact-key',
        address: 'contact-address',
      );
      provider.selectContact(contact);
      provider.messages.addAll([
        for (final key in ['first-key', 'second-key'])
          ChatMessage(
            id: key,
            content: key,
            senderPubkey: contact.address,
            recipientPubkey: key,
            timestamp: DateTime.fromMillisecondsSinceEpoch(0),
            isOutgoing: false,
          ),
      ]);

      provider.selectIdentity(
        BitnameEntry(
          hash: 'first',
          details: BitnameDetails(seqId: '1', encryptionPubkey: 'first-key'),
        ),
      );
      expect(provider.currentConversation.map((message) => message.id), ['first-key']);

      provider.selectIdentity(
        BitnameEntry(
          hash: 'second',
          details: BitnameDetails(seqId: '2', encryptionPubkey: 'second-key'),
        ),
      );
      expect(provider.currentConversation.map((message) => message.id), ['second-key']);
    });
  });
}

void costTests() {
  group('what a message costs', () {
    // The reader keeps the postage, and the network takes the fee. A sender
    // sees both before pressing Send.
    test('adds the network fee to the postage', () {
      expect(ChatProvider.defaultPostageSats, 1000);
      expect(ChatProvider.networkFeeSats, 100);
    });

    test('an outgoing message keeps the postage it paid', () {
      final sent = ChatMessage(
        id: 'tx:0',
        content: 'hei',
        senderPubkey: 'bn-enc1a',
        recipientPubkey: 'bn-enc1b',
        timestamp: DateTime.now(),
        isOutgoing: true,
        valueSats: ChatProvider.defaultPostageSats,
        isPending: true,
      );

      expect(sent.valueSats, 1000);
      expect(sent.isPending, isTrue, reason: 'a block has to settle it first');
      expect(sent.copyWith(isPending: false).valueSats, 1000);
    });
  });
}

void readStateTests() {
  ChatMessage incoming({required String id, bool read = false}) => ChatMessage(
    id: id,
    content: 'hei',
    senderPubkey: 'bn-enc1sender',
    recipientPubkey: 'bn-enc1me',
    timestamp: DateTime.fromMillisecondsSinceEpoch(1757680000000),
    isOutgoing: false,
    read: read,
  );

  group('the read state', () {
    // The bell history stores a notification this way, and a chat message
    // follows the same shape.
    test('a new message reads as unread', () {
      expect(incoming(id: 'a:0').read, isFalse);
    });

    test('survives a restart through json', () {
      final stored = incoming(id: 'a:0', read: true);
      expect(ChatMessage.fromJson(stored.toJson()).read, isTrue);
    });

    test('an older stored message with no flag reads as unread', () {
      final read = ChatMessage.fromJson({
        'id': 'a:0',
        'content': 'hei',
        'sender_pubkey': 'bn-enc1sender',
        'recipient_pubkey': 'bn-enc1me',
        'is_outgoing': false,
      });
      expect(read.read, isFalse);
    });

    test('marking read keeps everything else', () {
      final before = incoming(id: 'a:0');
      final after = before.copyWith(read: true);
      expect(after.read, isTrue);
      expect(after.id, before.id);
      expect(after.content, before.content);
      expect(after.isPending, before.isPending);
    });
  });
}

void conversationTests() {
  group('a conversation', () {
    // An arrived message names its sender by address, because the chain holds
    // no encryption key. The thread has to match that.
    test('holds a message that names its sender by address', () {
      final arrived = ChatMessage(
        id: 'a:0',
        content: 'hei',
        senderPubkey: '3U7uB5WkWrWxsdtqdrbgsZ6Y4FXt',
        recipientPubkey: 'bn-enc1me',
        timestamp: DateTime.now(),
        isOutgoing: false,
      );

      // The contact carries the same address, and a different encryption key.
      const contactAddress = '3U7uB5WkWrWxsdtqdrbgsZ6Y4FXt';
      const contactKey = 'bn-enc1them';
      expect(arrived.senderPubkey == contactKey, isFalse, reason: 'the old match fails');
      expect(arrived.senderPubkey == contactAddress, isTrue, reason: 'the address match works');
    });
  });
}

void unknownSenderTests() {
  group('a sender who reached me first', () {
    // The chain carries no encryption key, so an arrived message names only
    // an address. A reply to it pays them and reaches no inbox.
    test('reads as a contact with no key', () {
      final unknown = ChatContact(
        id: '3U7uB5WkWrWxsdtqdrbgsZ6Y4FXt',
        name: '3U7uB5WkWrWxsdtqdrbgsZ6Y4FXt',
        encryptionPubkey: '',
        address: '3U7uB5WkWrWxsdtqdrbgsZ6Y4FXt',
        lastMessage: 'hei',
      );

      expect(unknown.encryptionPubkey, isEmpty, reason: 'a send has to refuse this');
      expect(unknown.address, isNotEmpty, reason: 'the thread still shows the message');
      expect(ChatContact.fromJson(unknown.toJson()).encryptionPubkey, isEmpty);
    });
  });
}
