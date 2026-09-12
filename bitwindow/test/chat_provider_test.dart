import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/pages/chat_page.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:bitwindow/services/bitnames_message.dart';
import 'package:bitwindow/services/bitnames_secure_store.dart';
import 'package:flutter/foundation.dart';
import 'package:blockchain_utils/bech32/bech32.dart';
import 'package:blockchain_utils/bip/ecc/keys/ed25519_keys.dart';
import 'package:blockchain_utils/signer/ed25519/ed25519.dart';
import 'package:convert/convert.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';

import 'mocks/store_mock.dart';

class _ChatRPC extends MockBitnamesRPC {
  bool online = false;
  Map<String, dynamic> pending = {};
  Map<String, dynamic> settled = {};
  Set<String> mempool = {};
  final Map<String, BitNameData> names = {};
  final Map<String, String> owners = {};
  final Map<String, ConnectException> ownerErrors = {};
  final Map<String, List<int>> keys = {};
  final Map<String, (String, String)> ciphertexts = {};
  final List<({String address, int value, int fee, String? memo})> transfers = [];
  final List<List<dynamic>> checks = [];
  Completer<void>? encryptWait;
  Completer<void>? decryptWait;
  Completer<void>? transferWait;
  bool failPaymail = false;
  bool failPending = false;

  @override
  bool get connected => online;

  BitnameEntry addIdentity(String name, int seed, {String? encryptionKey}) {
    final hash = BitnamesMessage.nameHash(name);
    final bytes = List<int>.filled(32, seed);
    final publicKey = Ed25519PrivateKey.fromBytes(bytes).publicKey.compressed.sublist(1);
    final key = Bech32Encoder.encode('bn-svk', publicKey, encoding: Bech32Encodings.bech32m);
    final address = BitnamesMessage.addressForKey(key);
    names[hash] = BitNameData(encryptionPubkey: encryptionKey ?? 'encryption-$name', paymailFeeSats: 1500);
    owners[hash] = address;
    keys[address] = bytes;
    return BitnameEntry(
      hash: hash,
      plaintextName: name,
      details: BitnameDetails(
        seqId: '$seed',
        encryptionPubkey: names[hash]!.encryptionPubkey,
        paymailFeeSats: names[hash]!.paymailFeeSats,
      ),
    );
  }

  @override
  Future<BitNameData?> getBitNameData(String name) async => names[name];

  @override
  Future<String> getBitNameOwner(String bitname) async {
    if (ownerErrors.containsKey(bitname)) {
      throw ownerErrors[bitname]!;
    }
    final owner = owners[bitname];
    if (owner == null) {
      throw ConnectException(Code.notFound, 'The BitName has no owner');
    }
    return owner;
  }

  @override
  Future<Map<String, String>> signArbitraryMsgAsAddr({required String msg, required String address}) async {
    final seed = keys[address]!;
    final key = Ed25519PrivateKey.fromBytes(seed).publicKey.compressed.sublist(1);
    return {
      'verifying_key': Bech32Encoder.encode('bn-svk', key, encoding: Bech32Encodings.bech32m),
      'signature': hex.encode(Ed25519Signer.fromKeyBytes(seed).sign([255, ...utf8.encode(msg)])),
    };
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    expect(method, 'verify_signature');
    final values = params as List<dynamic>;
    checks.add(values);
    expect(values[2], 'arbitrary');
    final bytes = Bech32Decoder.decode('bn-svk', values[1] as String, encoding: Bech32Encodings.bech32m);
    return Ed25519Verifier.fromKeyBytes(bytes).verify(
      [255, ...utf8.encode(values[3] as String)],
      hex.decode(values[0] as String),
    );
  }

  @override
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) async {
    await encryptWait?.future;
    final ciphertext = hex.encode(utf8.encode('${ciphertexts.length}:$encryptionPubkey'));
    ciphertexts[ciphertext] = (encryptionPubkey, msg);
    return ciphertext;
  }

  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) async {
    await decryptWait?.future;
    final stored = ciphertexts[ciphertext];
    if (stored == null || stored.$1 != encryptionPubkey) {
      throw const FormatException('The key cannot decrypt this memo');
    }
    return stored.$2;
  }

  @override
  Future<PendingPaymail> getPendingPaymail() async {
    if (failPending) {
      throw StateError('The pending RPC failed');
    }
    return PendingPaymail(entries: pending, mempoolTxids: mempool);
  }

  @override
  Future<Map<String, dynamic>> getPaymail() async {
    if (failPaymail) {
      throw StateError('The paymail RPC failed');
    }
    return settled;
  }

  @override
  Future<String> transfer({required String dest, required int value, required int fee, String? memo}) async {
    await transferWait?.future;
    transfers.add((address: dest, value: value, fee: fee, memo: memo));
    final txid = 'tx-${transfers.length}';
    mempool.add(txid);
    return txid;
  }

  Future<Map<String, dynamic>> output(String text, BitnameEntry recipient, {bool hexMemo = false}) async {
    final memo = await encryptMsg(msg: text, encryptionPubkey: recipient.details.encryptionPubkey!);
    return {
      'address': owners[recipient.hash],
      'sender_address': 'untrusted-input-owner',
      'memo': hexMemo ? memo : hex.decode(memo),
      'content': {'BitcoinSats': 1500},
    };
  }
}

class _StorageKey extends ChangeNotifier implements BitnamesStorageKeySource {
  @override
  Future<BitnamesStorageIdentity?> current() async =>
      WalletBitnamesStorageKeySource.derive(masterMnemonic: 'test wallet');
}

class _ChatWallet extends WalletReaderProvider {
  _ChatWallet() : super(Directory.systemTemp);

  void selectWallet(String? id) {
    wallets = id == null
        ? []
        : [
            WalletData(
              version: 1,
              master: MasterWallet(mnemonic: 'wallet $id', seedHex: '', masterKey: '', chainCode: ''),
              l1: L1Wallet(mnemonic: ''),
              sidechains: [],
              isStarter: true,
              id: id,
              name: id,
              gradient: WalletGradient.fromWalletId(id),
              createdAt: DateTime.utc(2026, 1, 1),
              walletType: BinaryType.BINARY_TYPE_BITCOIND,
            ),
          ];
    activeWalletId = id;
    notifyListeners();
  }
}

void main() {
  late _ChatRPC rpc;
  late ChatProvider provider;
  late BalanceProvider balance;
  late BitnameEntry alice;
  late BitnameEntry bob;
  late BitnameEntry carol;

  setUp(() {
    final log = Logger();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    rpc = _ChatRPC();
    alice = rpc.addIdentity('alice', 1);
    bob = rpc.addIdentity('bob', 2);
    carol = rpc.addIdentity('carol', 3);
    GetIt.I.registerSingleton<BitnamesRPC>(rpc);
    balance = BalanceProvider(connections: [rpc]);
    GetIt.I.registerSingleton<BalanceProvider>(balance);
    provider = ChatProvider();
    provider.selectIdentity(bob);
    rpc.online = true;
  });

  tearDown(() async {
    provider.dispose();
    balance.dispose();
    rpc.dispose();
    await GetIt.I.reset();
  });

  Future<BitnamesMessage> signed({BitnameEntry? sender, BitnameEntry? recipient, String text = 'Hello'}) =>
      BitnamesMessage.sign(rpc: rpc, sender: (sender ?? alice).hash, recipient: (recipient ?? bob).hash, text: text);

  Future<void> waitForChat(String text) async {
    if (provider.messages.any((message) => message.content == text)) {
      return;
    }
    final loaded = Completer<void>();
    void check() {
      if (!loaded.isCompleted && provider.messages.any((message) => message.content == text)) {
        loaded.complete();
      }
    }

    provider.addListener(check);
    try {
      await loaded.future.timeout(const Duration(seconds: 3));
    } finally {
      provider.removeListener(check);
    }
  }

  Future<(_ChatWallet, BitnamesSecureStore)> walletChat() async {
    provider.dispose();
    final wallet = _ChatWallet();
    GetIt.I.registerSingleton<WalletReaderProvider>(wallet);
    final store = BitnamesSecureStore(store: MockStore(), keySource: WalletBitnamesStorageKeySource(wallet));
    for (final id in ['A', 'B']) {
      wallet.selectWallet(id);
      await store.load();
      await store.save({
        'messages': [
          ChatMessage(
            id: id,
            content: 'Private $id',
            senderPubkey: bob.details.encryptionPubkey!,
            recipientPubkey: alice.details.encryptionPubkey!,
            senderBitname: bob.hash,
            recipientBitname: alice.hash,
            timestamp: DateTime.utc(2026, 1, 1),
            isOutgoing: true,
          ).toJson(),
        ],
      });
    }
    await GetIt.I.get<ClientSettings>().setValue(
      ChatContactsSetting(
        newValue: [
          ChatContact(
            id: alice.hash,
            name: 'Alice',
            encryptionPubkey: alice.details.encryptionPubkey!,
            address: rpc.owners[alice.hash]!,
            paymailFeeSats: alice.details.paymailFeeSats,
            isManual: true,
          ),
        ],
      ),
    );
    wallet.selectWallet('A');
    provider = ChatProvider(store: store);
    await waitForChat('Private A');
    provider.selectIdentity(bob);
    provider.selectContact(provider.contacts.single);
    await provider.fetchPaymail();
    return (wallet, store);
  }

  for (final action in ['change', 'lock']) {
    test('the composer clears an unsent draft after a wallet $action', () async {
      final (wallet, _) = await walletChat();
      GetIt.I.registerSingleton<ChatProvider>(provider);
      final model = ChatViewModel();
      try {
        model.messageController.text = 'Private draft A';

        wallet.selectWallet(action == 'lock' ? null : 'B');

        final draft = model.messageController.text;
        if (action == 'lock') {
          wallet.selectWallet('B');
        }
        await waitForChat('Private B');
        rpc.online = false;
        model.selectIdentity(bob);
        model.selectContact(provider.contacts.single);
        expect(draft, isEmpty);
        expect(model.messageController.text, isEmpty);
      } finally {
        model.dispose();
      }
    });
  }

  test('the composer keeps the new wallet draft after an old send result', () async {
    final (wallet, _) = await walletChat();
    GetIt.I.registerSingleton<ChatProvider>(provider);
    final model = ChatViewModel();
    rpc.encryptWait = Completer<void>();
    model.messageController.text = 'Private draft A';
    final oldSend = model.sendMessage();
    await Future<void>.delayed(Duration.zero);
    try {
      wallet.selectWallet('B');
      await waitForChat('Private B');
      rpc.online = false;
      model.selectIdentity(bob);
      model.selectContact(provider.contacts.single);
      rpc.online = true;
      rpc.names[alice.hash] = BitNameData(encryptionPubkey: alice.details.encryptionPubkey, paymailFeeSats: 2500);
      model.messageController.text = 'Private draft B';
      await model.sendMessage();
      expect(model.chatError, contains('The postage increased'));
      expect(model.messageController.text, 'Private draft B');
    } finally {
      rpc.encryptWait!.complete();
      await oldSend;
    }
    try {
      expect(model.messageController.text, 'Private draft B');
      expect(rpc.transfers, isEmpty);
    } finally {
      model.dispose();
    }
  });

  test('the composer restores a failed send draft in the same wallet', () async {
    await walletChat();
    GetIt.I.registerSingleton<ChatProvider>(provider);
    final model = ChatViewModel();
    try {
      rpc.names[alice.hash] = BitNameData(encryptionPubkey: alice.details.encryptionPubkey);
      model.messageController.text = 'Private draft A';

      await model.sendMessage();

      expect(model.messageController.text, 'Private draft A');
      expect(model.chatError, contains('The recipient BitName has no inbox'));
      expect(rpc.transfers, isEmpty);
    } finally {
      model.dispose();
    }
  });

  test('a wallet change clears private chat and reloads the selected wallet', () async {
    final (wallet, store) = await walletChat();
    rpc.online = false;

    wallet.selectWallet('B');

    expect(provider.messages, isEmpty);
    expect(provider.contacts, isEmpty);
    expect(provider.selectedContact, isNull);
    expect(provider.selectedIdentity, isNull);
    expect(provider.myIdentities, isEmpty);
    await waitForChat('Private B');
    expect(provider.messages.single.content, 'Private B');
    expect(provider.contacts.single.lastMessage, isNull);
    provider.selectIdentity(bob);
    expect(provider.contacts.single.lastMessage, 'Private B');

    wallet.selectWallet('A');
    await waitForChat('Private A');
    expect(provider.messages.single.content, 'Private A');
    expect(provider.contacts.single.lastMessage, isNull);
    provider.selectIdentity(bob);
    expect(provider.contacts.single.lastMessage, 'Private A');
    rpc.online = true;
    provider.selectContact(provider.contacts.single);
    expect(await provider.sendMessage('More private A'), 'tx-1');
    expect(provider.error, isNull);
    final saved = await store.load();
    expect((saved['messages'] as List<dynamic>).map((message) => message['content']), ['Private A', 'More private A']);
  });

  test('a wallet lock clears private chat until the wallet unlocks', () async {
    final (wallet, _) = await walletChat();

    wallet.selectWallet(null);

    expect(provider.messages, isEmpty);
    expect(provider.contacts, isEmpty);
    expect(provider.selectedContact, isNull);
    expect(provider.selectedIdentity, isNull);
    await provider.fetchIdentities();
    await provider.fetchPaymail();
    expect(provider.messages, isEmpty);
    expect(provider.myIdentities, isEmpty);
    wallet.selectWallet('A');
    await waitForChat('Private A');
    expect(provider.messages.single.content, 'Private A');
  });

  test('a wallet with no chat keeps manual contacts without private previews', () async {
    final (wallet, store) = await walletChat();
    final loaded = Completer<void>();
    void check() {
      if (!loaded.isCompleted && provider.contacts.isNotEmpty && provider.selectedIdentity == null) {
        loaded.complete();
      }
    }

    provider.addListener(check);
    try {
      wallet.selectWallet('C');
      await loaded.future.timeout(const Duration(seconds: 3));
    } finally {
      provider.removeListener(check);
    }
    expect(await store.load(), isEmpty);
    await Future<void>.delayed(Duration.zero);
    expect(provider.messages, isEmpty);
    expect(provider.contacts.single.id, alice.hash);
    expect(provider.contacts.single.isManual, isTrue);
    expect(provider.contacts.single.lastMessage, isNull);
    expect(provider.contacts.single.lastMessageTime, isNull);
  });

  test('an old decrypt operation cannot restore chat after a wallet change', () async {
    final (wallet, _) = await walletChat();
    rpc.pending = {'bob:0': await rpc.output((await signed(text: 'Old private poll')).encode(), bob)};
    rpc.decryptWait = Completer<void>();
    final poll = provider.fetchPaymail();
    await Future<void>.delayed(Duration.zero);
    try {
      wallet.selectWallet('B');
      expect(provider.messages, isEmpty);
      await waitForChat('Private B');
    } finally {
      rpc.decryptWait!.complete();
      await poll;
    }

    expect(provider.messages.single.content, 'Private B');
    expect(provider.contacts.single.lastMessage, isNull);
    expect(provider.selectedContact, isNull);
    expect(provider.selectedIdentity, isNull);
    expect(provider.error, isNull);
  });

  for (final step in ['encrypt', 'transfer']) {
    test('an old $step result cannot restore chat after a wallet change', () async {
      final (wallet, store) = await walletChat();
      final wait = Completer<void>();
      if (step == 'encrypt') {
        rpc.encryptWait = wait;
      } else {
        rpc.transferWait = wait;
      }
      final send = provider.sendMessage('Private send A');
      await Future<void>.delayed(Duration.zero);
      try {
        wallet.selectWallet('B');
        await waitForChat('Private B');
      } finally {
        wait.complete();
      }

      final result = await send;
      expect(provider.messages.map((message) => message.content), ['Private B']);
      expect(result, step == 'encrypt' ? isNull : 'tx-1');
      expect(provider.contacts.single.lastMessage, isNull);
      expect(
        provider.error,
        step == 'encrypt' ? isNull : 'The node accepted the message. The wallet change stopped the local history save.',
      );
      final saved = await store.load();
      expect((saved['messages'] as List<dynamic>).single['content'], 'Private B');
      expect(rpc.transfers, hasLength(step == 'encrypt' ? 0 : 1));
      wallet.selectWallet('A');
      await waitForChat('Private A');
      expect(provider.messages.single.content, 'Private A');
    });
  }

  test('an old transfer result cannot clear the new wallet send state', () async {
    final (wallet, _) = await walletChat();
    rpc.transferWait = Completer<void>();
    final oldSend = provider.sendMessage('Private send A');
    await Future<void>.delayed(Duration.zero);
    wallet.selectWallet('B');
    await waitForChat('Private B');
    provider.selectIdentity(bob);
    provider.selectContact(provider.contacts.single);
    rpc.encryptWait = Completer<void>();
    final newSend = provider.sendMessage('Private send B');
    await Future<void>.delayed(Duration.zero);
    rpc.transferWait!.complete();
    await oldSend;
    try {
      expect(provider.isSending, isTrue);
    } finally {
      rpc.encryptWait!.complete();
      await newSend;
    }
    expect(provider.isSending, isFalse);
    expect(provider.messages.map((message) => message.content), ['Private B', 'Private send B']);
  });

  test('a signed message creates a contact and permits a reply', () async {
    final memo = await signed();
    rpc.pending = {'first:0': await rpc.output(memo.encode(), bob)};
    await provider.fetchPaymail();

    expect(provider.error, isNull);
    expect(provider.messages.single.content, 'Hello');
    expect(provider.messages.single.senderPubkey, alice.details.encryptionPubkey);
    expect(provider.contacts.single.id, alice.hash);
    expect(provider.contacts.single.address, rpc.owners[alice.hash]);
    provider.selectContact(provider.contacts.single);
    expect(provider.currentConversation, hasLength(1));

    expect(await provider.sendMessage('Reply'), 'tx-1');
    final transfer = rpc.transfers.single;
    expect(transfer.address, rpc.owners[alice.hash]);
    expect(transfer.value, 1500);
    expect(transfer.fee, ChatProvider.networkFeeSats);
    final payload = BitnamesMessage.decode(rpc.ciphertexts[transfer.memo]!.$2)!;
    expect(payload.sender, bob.hash);
    expect(payload.recipient, alice.hash);
    expect(payload.text, 'Reply');
    expect(await payload.checkSender(rpc, alice.hash), rpc.owners[bob.hash]);
    expect(provider.currentConversation, hasLength(2));
  });

  test('a confirmed hex memo creates the same known sender', () async {
    final memo = await signed();
    rpc.settled = {'first:0': await rpc.output(memo.encode(), bob, hexMemo: true)};
    await provider.fetchPaymail();

    expect(provider.error, isNull);
    expect(provider.messages.single.isPending, isFalse);
    expect(provider.messages.single.senderPubkey, alice.details.encryptionPubkey);
    expect(provider.contacts.single.encryptionPubkey, alice.details.encryptionPubkey);
  });

  test('a block keeps the message sender and read state', () async {
    final memo = await signed();
    rpc.pending = {'first:0': await rpc.output(memo.encode(), bob)};
    await provider.fetchPaymail();
    await provider.markConversationRead(alice.hash);
    final before = provider.messages.single;
    expect(before.read, isTrue);
    rpc.pending = {};
    rpc.settled = {'first:0': await rpc.output(memo.encode(), bob, hexMemo: true)};
    await provider.fetchPaymail();

    final after = provider.messages.single;
    expect(after.id, before.id);
    expect(after.senderPubkey, before.senderPubkey);
    expect(after.timestamp, before.timestamp);
    expect(after.read, isTrue);
    expect(after.isPending, isFalse);
    expect(rpc.checks, hasLength(1));
  });

  for (final pending in [true, false]) {
    test('new mail in the open conversation is read with pending $pending', () async {
      await provider.addContactFromEntry(alice);
      provider.selectContact(provider.contacts.single);
      final mail = {
        'alice:0': await rpc.output((await signed()).encode(), bob),
        'carol:0': await rpc.output((await signed(sender: carol)).encode(), bob),
      };
      if (pending) {
        rpc.pending = mail;
      } else {
        rpc.settled = mail;
      }

      await provider.fetchPaymail();

      expect(provider.currentConversation.single.read, isTrue);
      expect(provider.unreadCount(alice.hash), 0);
      expect(provider.unreadCount(carol.hash), 1);
    });
  }

  test('a message for a different selected identity stays unread', () async {
    await provider.addContactFromEntry(alice);
    provider.selectContact(provider.contacts.single);
    rpc.pending = {'bob:0': await rpc.output((await signed()).encode(), bob)};
    rpc.decryptWait = Completer<void>();
    final poll = provider.fetchPaymail();
    await Future<void>.delayed(Duration.zero);
    rpc.online = false;
    provider.selectIdentity(carol);
    rpc.decryptWait!.complete();

    await poll;

    expect(provider.currentConversation, isEmpty);
    expect(provider.messages.single.read, isFalse);
  });

  test('an identity change marks the displayed conversation read', () async {
    rpc.settled = {'bob:0': await rpc.output((await signed()).encode(), bob)};
    await provider.fetchPaymail();
    expect(provider.messages.single.read, isFalse);
    rpc.online = false;
    provider.selectIdentity(carol);
    provider.selectContact(provider.contacts.single);
    expect(provider.currentConversation, isEmpty);

    provider.selectIdentity(bob);

    expect(provider.currentConversation.single.read, isTrue);
    expect(provider.unreadCount(alice.hash), 0);
  });

  test('a paymail error keeps the pending message', () async {
    rpc.pending = {'first:0': await rpc.output((await signed()).encode(), bob)};
    await provider.fetchPaymail();
    rpc.pending = {};
    rpc.failPaymail = true;
    await provider.fetchPaymail();
    expect(provider.messages.single.isPending, isTrue);
    expect(provider.error, contains('The paymail RPC failed'));
  });

  test('unsigned text keeps an unknown sender and cannot receive a reply', () async {
    rpc.settled = {'old:0': await rpc.output('Old text', bob, hexMemo: true)};
    await provider.fetchPaymail();
    final contact = provider.contacts.single;
    expect(contact.displayName, 'Unknown sender');
    expect(contact.address, 'unknown');
    expect(contact.encryptionPubkey, isEmpty);
    provider.selectContact(contact);
    expect(provider.currentConversation.single.content, 'Old text');
    expect(await provider.sendMessage('Reply'), isNull);
    expect(rpc.transfers, isEmpty);
  });

  for (final field in ['text', 'sender', 'id']) {
    test('a changed $field cannot name the sender', () async {
      final memo = await signed();
      final data = jsonDecode(memo.encode().substring(BitnamesMessage.prefix.length)) as Map<String, dynamic>;
      data[field] = switch (field) {
        'sender' => carol.hash,
        'id' => '00000000-0000-4000-8000-000000000000',
        _ => 'Changed text',
      };
      rpc.pending = {'bad:0': await rpc.output('${BitnamesMessage.prefix}${jsonEncode(data)}', bob)};
      await provider.fetchPaymail();
      expect(provider.messages, isEmpty);
      expect(provider.contacts, isEmpty);
      expect(provider.error, isNotNull);
    });
  }

  test('a valid signature from a different owner cannot name the sender', () async {
    final memo = await signed();
    rpc.owners[alice.hash] = rpc.owners[carol.hash]!;
    rpc.pending = {'bad:0': await rpc.output(memo.encode(), bob)};
    await provider.fetchPaymail();
    expect(provider.messages, isEmpty);
    expect(provider.error, contains('does not match the BitName owner'));
  });

  test('a signed recipient must match the identity that decrypts the memo', () async {
    final memo = await signed(recipient: carol);
    rpc.pending = {'bad:0': await rpc.output(memo.encode(), bob)};
    await provider.fetchPaymail();
    expect(provider.messages, isEmpty);
    expect(provider.contacts, isEmpty);
  });

  test('unsigned mail with a shared key belongs to the paid identity', () async {
    carol = rpc.addIdentity('carol', 3, encryptionKey: bob.details.encryptionPubkey);
    rpc.settled = {'carol:0': await rpc.output('For Carol', carol)};

    await provider.fetchPaymail();

    expect(provider.messages, isEmpty);
    expect(provider.contacts, isEmpty);
    expect(provider.error, isNull);
    rpc.online = false;
    provider.selectIdentity(carol);
    rpc.online = true;
    await provider.fetchPaymail();
    expect(provider.messages.single.recipientBitname, carol.hash);
    expect(provider.messages.single.content, 'For Carol');
    expect(provider.contacts.single.id, 'unknown');
    provider.selectContact(provider.contacts.single);
    expect(provider.currentConversation.single.content, 'For Carol');
    expect(provider.error, isNull);
  });

  for (final state in ['pending', 'confirmed']) {
    test('signed $state mail cannot pay a different recipient address', () async {
      rpc.names[bob.hash] = BitNameData(encryptionPubkey: bob.details.encryptionPubkey, paymailFeeSats: 5000);
      rpc.names[carol.hash] = BitNameData(encryptionPubkey: carol.details.encryptionPubkey, paymailFeeSats: 1000);
      expect(rpc.owners[bob.hash], isNot(rpc.owners[carol.hash]));
      final output = await rpc.output((await signed()).encode(), bob);
      output['address'] = rpc.owners[carol.hash];
      output['content'] = {'BitcoinSats': 1000};
      if (state == 'pending') {
        rpc.pending = {'wrong:0': output};
      } else {
        rpc.settled = {'wrong:0': output};
      }

      await provider.fetchPaymail();

      expect(provider.messages, isEmpty);
      expect(provider.contacts, isEmpty);
      expect(provider.error, contains('The payment address does not match the recipient BitName owner'));
    });

    test('signed $state mail keeps the lower fee at a shared recipient address', () async {
      rpc.names[bob.hash] = BitNameData(encryptionPubkey: bob.details.encryptionPubkey, paymailFeeSats: 5000);
      rpc.names[carol.hash] = BitNameData(encryptionPubkey: carol.details.encryptionPubkey, paymailFeeSats: 1000);
      rpc.owners[bob.hash] = rpc.owners[carol.hash]!;
      final output = await rpc.output((await signed()).encode(), bob);
      output['content'] = {'BitcoinSats': 1000};
      if (state == 'pending') {
        rpc.pending = {'shared:0': output};
      } else {
        rpc.settled = {'shared:0': output};
      }

      await provider.fetchPaymail();

      expect(provider.messages.single.recipientBitname, bob.hash);
      expect(provider.messages.single.valueSats, 1000);
      expect(provider.contacts.single.id, alice.hash);
      expect(provider.error, isNull);
    });
  }

  test('a copied signed message does not create a second message', () async {
    final memo = await signed();
    rpc.pending = {
      'first:0': await rpc.output(memo.encode(), bob),
      'second:0': await rpc.output(memo.encode(), bob),
    };
    await provider.fetchPaymail();
    expect(provider.messages, hasLength(1));
    expect(provider.contacts, hasLength(1));
  });

  test('a different selected identity cannot change an active send', () async {
    await provider.addContactFromEntry(alice);
    provider.selectContact(provider.contacts.single);
    rpc.encryptWait = Completer<void>();
    final send = provider.sendMessage('Reply');
    await Future<void>.delayed(Duration.zero);
    rpc.online = false;
    provider.selectIdentity(carol);
    provider.selectContact(
      ChatContact(
        id: carol.hash,
        name: 'Carol',
        encryptionPubkey: carol.details.encryptionPubkey!,
        address: rpc.owners[carol.hash]!,
      ),
    );
    rpc.encryptWait!.complete();
    expect(await send, 'tx-1');
    final sent = BitnamesMessage.decode(rpc.ciphertexts[rpc.transfers.single.memo]!.$2)!;
    expect(sent.sender, bob.hash);
    expect(sent.recipient, alice.hash);
    expect(rpc.transfers.single.address, rpc.owners[alice.hash]);
    expect(provider.messages.single.senderPubkey, bob.details.encryptionPubkey);
    expect(provider.contacts.single.lastMessage, isNull);
    provider.selectIdentity(bob);
    expect(provider.contacts.single.lastMessage, 'Reply');
  });

  test('each selected identity reads only its own messages', () async {
    rpc.pending = {
      'bob:0': await rpc.output((await signed(text: 'For Bob')).encode(), bob),
      'carol:0': await rpc.output((await signed(recipient: carol, text: 'For Carol')).encode(), carol),
    };
    await provider.fetchPaymail();
    provider.selectContact(provider.contacts.single);
    expect(provider.currentConversation.single.content, 'For Bob');
    rpc.online = false;
    provider.selectIdentity(carol);
    rpc.online = true;
    await provider.fetchPaymail();
    expect(provider.messages, hasLength(2));
    expect(provider.currentConversation.single.content, 'For Carol');
  });

  for (final direction in ['incoming', 'outgoing']) {
    test('contact previews use the selected identity for $direction mail and restore', () async {
      final key = _StorageKey();
      final store = BitnamesSecureStore(store: MockStore(), keySource: key);
      provider.dispose();
      rpc.online = false;
      provider = ChatProvider(store: store);
      provider.selectIdentity(bob);
      rpc.online = true;
      final contact = (await provider.lookupBitName('alice'))!.copyWith(isManual: true);
      await provider.addContact(contact);
      provider.selectContact(contact);
      if (direction == 'incoming') {
        rpc.settled = {'bob:0': await rpc.output((await signed(text: 'Bob text')).encode(), bob)};
        await provider.fetchPaymail();
      } else {
        expect(await provider.sendMessage('Bob text'), 'tx-1');
      }
      expect(provider.contacts.single.lastMessage, 'Bob text');

      rpc.online = false;
      provider.selectIdentity(carol);
      expect(provider.contacts.single.lastMessage, isNull);
      expect(provider.contacts.single.lastMessageTime, isNull);
      expect(provider.selectedContact!.lastMessage, isNull);
      expect(provider.contacts.single.isManual, isTrue);
      rpc.online = true;
      if (direction == 'incoming') {
        rpc.settled['carol:0'] = await rpc.output((await signed(recipient: carol, text: 'Carol text')).encode(), carol);
        await provider.fetchPaymail();
      } else {
        expect(await provider.sendMessage('Carol text'), 'tx-2');
      }
      expect(provider.contacts.single.lastMessage, 'Carol text');
      expect(provider.selectedContact!.lastMessage, 'Carol text');
      rpc.online = false;
      provider.selectIdentity(bob);
      expect(provider.contacts.single.lastMessage, 'Bob text');
      expect(provider.contacts.single.lastMessageTime, provider.currentConversation.single.timestamp);
      expect(provider.selectedContact!.lastMessage, 'Bob text');

      provider.dispose();
      rpc.online = true;
      provider = ChatProvider(store: store);
      rpc.online = false;
      provider.selectIdentity(bob);
      await waitForChat('Carol text');
      expect(provider.messages, hasLength(2));
      expect(provider.contacts.single.lastMessage, 'Bob text');
      expect(provider.contacts.single.isManual, isTrue);
      provider.selectContact(provider.contacts.single);
      provider.selectIdentity(carol);
      expect(provider.contacts.single.lastMessage, 'Carol text');
      expect(provider.contacts.single.lastMessageTime, provider.currentConversation.single.timestamp);
      key.dispose();
    });
  }

  test('two identities with one key keep separate conversations and read states', () async {
    carol = rpc.addIdentity('carol', 3, encryptionKey: bob.details.encryptionPubkey);
    rpc.pending = {
      'bob:0': await rpc.output((await signed(text: 'For Bob')).encode(), bob),
      'carol:0': await rpc.output((await signed(recipient: carol, text: 'For Carol')).encode(), carol),
    };
    await provider.fetchPaymail();
    await provider.markConversationRead(alice.hash);
    expect(provider.messages.single.content, 'For Bob');
    rpc.online = false;
    provider.selectIdentity(carol);
    rpc.online = true;
    await provider.fetchPaymail();
    expect(provider.unreadCount(alice.hash), 1);
    provider.selectContact(provider.contacts.single);
    expect(provider.currentConversation.single.content, 'For Carol');
    await provider.markConversationRead(alice.hash);
    expect(provider.unreadCount(alice.hash), 0);
    rpc.online = false;
    provider.selectIdentity(bob);
    expect(provider.currentConversation.single.content, 'For Bob');
    expect(provider.currentConversation.single.read, isTrue);
  });

  test('the owner key uses Bech32m and BLAKE3', () {
    final bytes = hex.decode('d75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a');
    final key = Bech32Encoder.encode('bn-svk', bytes, encoding: Bech32Encodings.bech32m);
    expect(BitnamesMessage.addressForKey(key), '2WRXAwiHCW7rvEpkN1nPmFY5hiUC');
    final oldKey = Bech32Encoder.encode('bn-svk', bytes);
    expect(() => BitnamesMessage.addressForKey(oldKey), throwsA(anything));
  });

  test('the saved message keeps its BitName hashes and read state', () async {
    final memo = await signed();
    rpc.pending = {'first:0': await rpc.output(memo.encode(), bob)};
    await provider.fetchPaymail();
    await provider.markConversationRead(alice.hash);
    final stored = ChatMessage.fromJson(provider.messages.single.toJson());
    expect(stored.senderBitname, alice.hash);
    expect(stored.recipientBitname, bob.hash);
    expect(stored.read, isTrue);
    expect(stored.copyWith(isPending: false).senderBitname, alice.hash);
  });

  test('a confirmed RPC error does not hide new pending mail', () async {
    rpc.pending = {'first:0': await rpc.output((await signed()).encode(), bob)};
    rpc.failPaymail = true;
    await provider.fetchPaymail();
    expect(provider.messages.single.content, 'Hello');
    expect(provider.messages.single.isPending, isTrue);
    expect(provider.error, contains('The paymail RPC failed'));
  });

  test('a pending RPC error does not hide confirmed mail', () async {
    rpc.settled = {'first:0': await rpc.output((await signed()).encode(), bob, hexMemo: true)};
    rpc.failPending = true;
    await provider.fetchPaymail();
    expect(provider.messages.single.content, 'Hello');
    expect(provider.messages.single.isPending, isFalse);
    expect(provider.error, contains('The pending RPC failed'));
  });

  test('a rejected signature does not hide valid mail in the same feed', () async {
    final memo = await signed();
    final data = jsonDecode(memo.encode().substring(BitnamesMessage.prefix.length)) as Map<String, dynamic>;
    data['text'] = 'Changed text';
    rpc.pending = {
      'bad:0': await rpc.output('${BitnamesMessage.prefix}${jsonEncode(data)}', bob),
      'good:0': await rpc.output(memo.encode(), bob),
    };
    await provider.fetchPaymail();
    expect(provider.messages.single.content, 'Hello');
    expect(provider.contacts.single.id, alice.hash);
    expect(provider.error, contains('Rejected paymail bad:0'));
  });

  test('a contact from a plain name keeps its sent message', () async {
    final contact = await provider.lookupBitName('alice');
    expect(contact!.id, alice.hash);
    await provider.addContact(contact);
    provider.selectContact(contact);
    expect(await provider.sendMessage('Hello Alice'), 'tx-1');
    expect(provider.currentConversation.single.content, 'Hello Alice');
  });

  test('a self-contact excludes mail with a different sender or recipient', () async {
    final aliceContact = await provider.lookupBitName('alice');
    await provider.addContact(aliceContact!);
    provider.selectContact(aliceContact);
    expect(await provider.sendMessage('Hello Alice'), 'tx-1');
    rpc.settled = {'old:0': await rpc.output('Old text', bob)};
    await provider.fetchPaymail();
    final self = await provider.lookupBitName('bob');
    await provider.addContact(self!);
    provider.selectContact(self);
    expect(provider.currentConversation, isEmpty);
  });

  test('a restart moves old sender attribution and keeps manual contacts', () async {
    final key = _StorageKey();
    final store = BitnamesSecureStore(store: MockStore(), keySource: key);
    final old = ChatMessage(
      id: 'old:0',
      content: 'Old text',
      senderPubkey: 'old-payment-address',
      recipientPubkey: bob.details.encryptionPubkey!,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      isOutgoing: false,
      read: true,
    );
    await store.save({
      'messages': [old.toJson()],
    });
    await provider.addContact(
      ChatContact(
        id: 'old-payment-address',
        name: 'Old address',
        encryptionPubkey: '',
        address: 'old-payment-address',
        lastMessage: old.content,
      ),
    );
    await provider.addContact(
      ChatContact(
        id: alice.hash,
        name: 'Alice',
        encryptionPubkey: alice.details.encryptionPubkey!,
        address: 'old-payment-address',
        lastMessage: old.content,
        isManual: true,
      ),
    );
    provider.dispose();
    provider = ChatProvider(store: store);
    final loaded = Completer<void>();
    provider.addListener(() {
      if (!loaded.isCompleted && provider.contacts.any((c) => c.id == 'unknown')) {
        loaded.complete();
      }
    });
    await loaded.future;
    rpc.online = false;
    provider.selectIdentity(bob);
    final unknown = provider.contacts.singleWhere((c) => c.id == 'unknown');
    provider.selectContact(unknown);
    expect(provider.currentConversation.single.content, 'Old text');
    expect(provider.currentConversation.single.read, isTrue);
    expect(provider.contacts.any((c) => c.id == 'old-payment-address'), isFalse);
    final manual = provider.contacts.singleWhere((c) => c.id == alice.hash);
    expect(manual.isManual, isTrue);
    expect(manual.lastMessage, isNull);
    key.dispose();
  });

  test('a recipient without an inbox cannot receive a transfer', () async {
    final contact = await provider.lookupBitName('alice');
    await provider.addContact(contact!);
    provider.selectContact(contact);
    rpc.names[alice.hash] = BitNameData(encryptionPubkey: alice.details.encryptionPubkey);
    expect(await provider.sendMessage('Hello Alice'), isNull);
    expect(rpc.transfers, isEmpty);
    expect(provider.error, contains('The recipient BitName has no inbox'));
  });

  test('a zero-fee inbox can receive a message', () async {
    final contact = await provider.lookupBitName('alice');
    await provider.addContact(contact!);
    provider.selectContact(contact);
    rpc.names[alice.hash] = BitNameData(encryptionPubkey: alice.details.encryptionPubkey, paymailFeeSats: 0);
    expect(await provider.sendMessage('Hello Alice'), 'tx-1');
    expect(rpc.transfers.single.value, 0);
    expect(provider.messages.single.valueSats, 0);
  });

  test('a postage increase updates the quote before a second Send action', () async {
    final contact = await provider.lookupBitName('alice');
    await provider.addContact(contact!);
    provider.selectContact(contact);
    expect(provider.messageCostSats, 1600);
    rpc.names[alice.hash] = BitNameData(encryptionPubkey: alice.details.encryptionPubkey, paymailFeeSats: 2500);

    final txid = await provider.sendMessage('Hello Alice');

    expect(rpc.transfers, isEmpty);
    expect(txid, isNull);
    expect(provider.messages, isEmpty);
    expect(provider.postageSats, 2500);
    expect(provider.messageCostSats, 2600);
    expect(provider.isSending, isFalse);
    expect(provider.error, 'The postage increased to 2500 sats. Select Send again to accept the new cost.');
    final contacts = await GetIt.I.get<ClientSettings>().getValue(ChatContactsSetting());
    expect(contacts.value.single.paymailFeeSats, 2500);

    expect(await provider.sendMessage('Hello Alice'), 'tx-1');
    expect(rpc.transfers.single.value, 2500);
    expect(provider.messages.single.content, 'Hello Alice');
    expect(provider.error, isNull);
  });

  test('a postage decrease uses the lower current fee', () async {
    final contact = await provider.lookupBitName('alice');
    await provider.addContact(contact!);
    provider.selectContact(contact);
    expect(provider.messageCostSats, 1600);
    rpc.names[alice.hash] = BitNameData(encryptionPubkey: alice.details.encryptionPubkey, paymailFeeSats: 1000);

    expect(await provider.sendMessage('Hello Alice'), 'tx-1');
    expect(rpc.transfers.single.value, 1000);
    expect(provider.messages.single.valueSats, 1000);
    expect(provider.messageCostSats, 1100);
  });

  test('the BitName unknown stays separate from anonymous text', () async {
    final sender = rpc.addIdentity('unknown', 4);
    rpc.pending = {
      'signed:0': await rpc.output((await signed(sender: sender, text: 'Known sender')).encode(), bob),
      'old:0': await rpc.output('Old text', bob),
    };
    await provider.fetchPaymail();
    final unknown = provider.contacts.singleWhere((c) => c.id == 'unknown');
    provider.selectContact(unknown);
    expect(provider.currentConversation.single.content, 'Old text');
    expect(provider.unreadCount(sender.hash), 1);
    final known = provider.contacts.singleWhere((c) => c.id == sender.hash);
    provider.selectContact(known);
    expect(provider.currentConversation.single.content, 'Known sender');
  });

  for (final field in ['key', 'signature']) {
    test('an invalid $field does not hide the next message', () async {
      final memo = await signed();
      final data = jsonDecode(memo.encode().substring(BitnamesMessage.prefix.length)) as Map<String, dynamic>;
      data[field] = 'bad';
      rpc.pending = {
        'bad:0': await rpc.output('${BitnamesMessage.prefix}${jsonEncode(data)}', bob),
        'good:0': await rpc.output(memo.encode(), bob),
      };
      await provider.fetchPaymail();
      expect(provider.messages.single.content, 'Hello');
      expect(provider.error, contains('Rejected paymail bad:0'));
      expect(rpc.checks, hasLength(1));
    });
  }

  test('a key without an Ed25519 point does not hide valid mail', () async {
    final memo = await signed();
    final data = jsonDecode(memo.encode().substring(BitnamesMessage.prefix.length)) as Map<String, dynamic>;
    data['key'] = Bech32Encoder.encode(
      'bn-svk',
      hex.decode('0200000000000000000000000000000000000000000000000000000000000000'),
      encoding: Bech32Encodings.bech32m,
    );
    rpc.pending = {
      'bad:0': await rpc.output('${BitnamesMessage.prefix}${jsonEncode(data)}', bob),
      'good:0': await rpc.output(memo.encode(), bob),
    };
    await provider.fetchPaymail();
    expect(provider.messages.single.content, 'Hello');
    expect(provider.error, contains('Rejected paymail bad:0'));
    expect(rpc.checks, hasLength(1));
  });

  test('an unregistered sender does not hide the next message', () async {
    final sender = rpc.addIdentity('unregistered', 5);
    final bad = await signed(sender: sender);
    rpc.owners.remove(sender.hash);
    rpc.names.remove(sender.hash);
    rpc.pending = {
      'bad:0': await rpc.output(bad.encode(), bob),
      'good:0': await rpc.output((await signed()).encode(), bob),
    };
    await provider.fetchPaymail();
    expect(provider.messages.single.content, 'Hello');
    expect(provider.contacts.single.id, alice.hash);
    expect(provider.error, contains('The sender BitName has no owner'));
  });

  test('an owner RPC error stays visible', () async {
    final memo = await signed();
    rpc.ownerErrors[alice.hash] = ConnectException(Code.unavailable, 'The owner RPC is unavailable');
    rpc.pending = {'first:0': await rpc.output(memo.encode(), bob)};
    await provider.fetchPaymail();
    expect(provider.messages, isEmpty);
    expect(provider.error, contains('The owner RPC is unavailable'));
  });

  test('send and receive keep message previews out of plaintext settings', () async {
    final key = _StorageKey();
    final store = BitnamesSecureStore(store: MockStore(), keySource: key);
    provider.dispose();
    rpc.online = false;
    provider = ChatProvider(store: store);
    provider.selectIdentity(bob);
    rpc.online = true;
    rpc.pending = {'first:0': await rpc.output((await signed(text: 'Private incoming text')).encode(), bob)};
    await provider.fetchPaymail();
    final settings = GetIt.I.get<ClientSettings>().store;
    final receivedSettings = await settings.getString('chat_contacts');
    expect(receivedSettings, isNot(contains('Private incoming text')));
    expect(receivedSettings, isNot(contains('last_message')));
    expect(provider.contacts.single.lastMessage, 'Private incoming text');
    provider.selectContact(provider.contacts.single);
    expect(await provider.sendMessage('Private outgoing text'), 'tx-1');
    final sentSettings = await settings.getString('chat_contacts');
    expect(sentSettings, isNot(contains('Private outgoing text')));
    expect(sentSettings, isNot(contains('last_message')));
    expect(provider.contacts.single.lastMessage, 'Private outgoing text');
    final stored = await store.load();
    final messages = (stored['messages'] as List<dynamic>).cast<Map<String, dynamic>>();
    expect(messages.map((m) => m['content']), ['Private incoming text', 'Private outgoing text']);
    provider.dispose();
    provider = ChatProvider(store: store);
    rpc.online = false;
    provider.selectIdentity(bob);
    await waitForChat('Private outgoing text');
    expect(provider.messages, hasLength(2));
    expect(provider.contacts.single.lastMessage, 'Private outgoing text');
    key.dispose();
  });

  test('a legacy preview leaves settings and returns from encrypted messages', () async {
    final key = _StorageKey();
    final store = BitnamesSecureStore(store: MockStore(), keySource: key);
    final contact = ChatContact(
      id: alice.hash,
      name: alice.hash,
      plaintextName: 'Alice',
      encryptionPubkey: alice.details.encryptionPubkey!,
      address: rpc.owners[alice.hash]!,
      isManual: true,
      lastMessage: 'Private legacy text',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(0),
    );
    await GetIt.I.get<ClientSettings>().store.setString('chat_contacts', jsonEncode([contact.toJson()]));
    await store.save({
      'messages': [
        ChatMessage(
          id: 'legacy:0',
          content: 'Private legacy text',
          senderPubkey: bob.details.encryptionPubkey!,
          recipientPubkey: alice.details.encryptionPubkey!,
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          isOutgoing: true,
        ).toJson(),
      ],
    });
    provider.dispose();
    provider = ChatProvider(store: store);
    rpc.online = false;
    provider.selectIdentity(bob);
    await waitForChat('Private legacy text');
    final settings = await GetIt.I.get<ClientSettings>().store.getString('chat_contacts');
    expect(settings, isNot(contains('Private legacy text')));
    expect(settings, isNot(contains('last_message')));
    expect(provider.messages.single.content, 'Private legacy text');
    expect(provider.contacts.single.lastMessage, 'Private legacy text');
    expect(provider.contacts.single.plaintextName, 'Alice');
    expect(provider.contacts.single.isManual, isTrue);
    key.dispose();
  });
}
