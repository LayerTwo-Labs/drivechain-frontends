import 'dart:convert';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thirds/blake3.dart';

void main() {
  test('ten users complete registration, introductions, acceptance, chat, fallback, and restart', () async {
    final stopwatch = Stopwatch()..start();
    final ledger = _Chain();
    final mesh = _Mesh();
    final users = <_User>[];
    addTearDown(() async {
      for (final user in users) {
        user.provider.dispose();
      }
      await GetIt.I.reset();
    });

    for (var i = 0; i < 10; i++) {
      final store = _Store();
      final settings = ClientSettings(
        store: store,
        log: Logger(level: Level.off),
      );
      final rpc = _WalletRpc(ledger, i)..connected = true;
      final transport = BitMessageTransport(
        directDialer: mesh.direct,
        torDialer: mesh.tor,
        requestTimeout: const Duration(milliseconds: 100),
      );
      final provider = ChatProvider(
        rpc: rpc,
        settings: settings,
        transport: transport,
        torMutationGuard: () async => null,
        autoStart: false,
        now: () => DateTime.utc(2026, 7, 23, 12, i),
        id: () => 'user-$i-message-${ledger.nextId++}',
      );
      final user = _User(i, store, settings, rpc, provider);
      users.add(user);
      mesh.providers.add(provider);
      await _as(user, provider.initialize);

      final name = 'user${i + 1}';
      expect(await _as(user, () => provider.claimIdentity(name, introductionFeeSats: 500 + i)), isNotNull);
      final identity = provider.selectedIdentity!;
      final endpoint = i < 8 ? Uri.parse('http://user$i.test/') : Uri.parse('http://user$i.onion/');
      expect(
        await provider.publishProfile(
          direct: i < 8 ? [endpoint] : const [],
          tor: i < 8 ? const [] : [endpoint],
          paymailFeeSats: 500 + i,
        ),
        isNotNull,
      );
      await provider.refresh();
      expect(provider.profileReady(identity.hash), isTrue);
      expect(provider.myIdentities.single.plaintextName, name);
    }

    for (final user in users) {
      await user.provider.refresh();
    }

    // Every user introduces themselves to the next user in a ring.
    for (var i = 0; i < users.length; i++) {
      final sender = users[i], receiver = users[(i + 1) % users.length];
      final remote = sender.provider.allBitNames.singleWhere(
        (entry) => entry.hash == receiver.provider.selectedIdentity!.hash,
      );
      await sender.provider.addContactFromEntry(remote);
      sender.provider.selectContact(sender.provider.contacts.singleWhere((contact) => contact.id == remote.hash));
      final sent = await sender.provider.sendIntroduction('agenda ${sender.index}: hello user ${receiver.index + 1}');
      expect(sent.sent, isTrue);
      expect(ledger.transfers.last.value, 500 + receiver.index);
      expect(ledger.transfers.last.fee, ChatProvider.minerFeeSats);
      ledger.confirm(sent.reference!);
      await receiver.provider.fetchPaymail();
      expect(
        receiver.provider.contacts
            .singleWhere((contact) => contact.id == sender.provider.selectedIdentity!.hash)
            .relationshipState,
        ChatRelationshipState.incomingIntroduction,
      );
    }

    // Each receiver accepts and sends an ongoing message back.
    for (var i = 0; i < users.length; i++) {
      final receiver = users[(i + 1) % users.length];
      final sender = users[i];
      receiver.provider.selectContact(
        receiver.provider.contacts.singleWhere((contact) => contact.id == sender.provider.selectedIdentity!.hash),
      );
      expect((await receiver.provider.acceptIntroduction()).sent, isTrue);
      expect(receiver.provider.selectedContact!.relationshipState, ChatRelationshipState.accepted);

      final receiverHash = receiver.provider.selectedIdentity!.hash;
      final senderContact = sender.provider.contacts.singleWhere((contact) => contact.id == receiverHash);
      expect(senderContact.relationshipState, ChatRelationshipState.accepted);
      sender.provider.selectContact(senderContact);
      expect((await sender.provider.send('ongoing from user ${sender.index + 1}')).sent, isTrue);
      expect(receiver.provider.currentConversation.last.content, 'ongoing from user ${sender.index + 1}');
    }

    // A failed direct delivery reuses its encrypted ID for the 1-sat ledger fallback.
    final fallbackSender = users[0], fallbackReceiver = users[1];
    fallbackSender.provider.selectContact(
      fallbackSender.provider.contacts.singleWhere(
        (contact) => contact.id == fallbackReceiver.provider.selectedIdentity!.hash,
      ),
    );
    mesh.failRecipient = fallbackReceiver.provider.selectedIdentity!.hash;
    final failed = await fallbackSender.provider.send('fallback payload');
    expect(failed.needsChainConfirmation, isTrue);
    final fallback = await fallbackSender.provider.sendViaChain(failed.id!);
    expect(fallback.sent, isTrue);
    expect(ledger.transfers.last.value, ChatProvider.fallbackValueSats);
    expect(ledger.transfers.last.fee, ChatProvider.minerFeeSats);
    expect(ledger.transfers.last.idempotencyKey, failed.id);
    mesh.failRecipient = null;
    await fallbackReceiver.provider.fetchPaymail();
    expect(
      fallbackReceiver.provider.messages.where((message) => message.id == failed.id).length,
      0,
      reason: 'unconfirmed fallback must not be delivered',
    );
    ledger.confirm(fallback.reference!);
    await fallbackReceiver.provider.fetchPaymail();
    fallbackReceiver.provider.selectContact(
      fallbackReceiver.provider.contacts.singleWhere(
        (contact) => contact.id == fallbackSender.provider.selectedIdentity!.hash,
      ),
    );
    expect(
      fallbackReceiver.provider.currentConversation.where((message) => message.id == failed.id).length,
      1,
      reason:
          '${fallbackReceiver.provider.error}; selected=${fallbackReceiver.provider.selectedContact?.displayName}; '
          'messages=${fallbackReceiver.provider.messages.map((message) => '${message.id}:${message.content}:${message.transport.name}').join(',')}',
    );

    // Duplicate fallback polling remains deduplicated.
    await fallbackReceiver.provider.fetchPaymail();
    expect(
      fallbackReceiver.provider.currentConversation.where((message) => message.id == failed.id).length,
      1,
    );

    // Reject and block are enforced locally.
    final blocked = fallbackReceiver.provider.selectedContact!;
    fallbackReceiver.provider.selectContact(blocked);
    await fallbackReceiver.provider.blockContact();
    expect(fallbackReceiver.provider.selectedContact!.relationshipState, ChatRelationshipState.blocked);
    fallbackSender.provider.selectContact(
      fallbackSender.provider.contacts.singleWhere(
        (contact) => contact.id == fallbackReceiver.provider.selectedIdentity!.hash,
      ),
    );
    final blockedMessageCount = fallbackReceiver.provider.messages.length;
    expect((await fallbackSender.provider.send('blocked traffic')).needsChainConfirmation, isTrue);
    expect(fallbackReceiver.provider.messages.length, blockedMessageCount);

    // Another pair exercises acceptance fallback and confirmation-gated unlock.
    final chainSender = users[0], chainReceiver = users[3];
    await _introduce(ledger, chainSender, chainReceiver);
    chainReceiver.provider.selectContact(
      chainReceiver.provider.contacts.singleWhere(
        (contact) => contact.id == chainSender.provider.selectedIdentity!.hash,
      ),
    );
    mesh.failRecipient = chainSender.provider.selectedIdentity!.hash;
    final failedAcceptance = await chainReceiver.provider.acceptIntroduction();
    expect(failedAcceptance.needsChainConfirmation, isTrue);
    final chainAcceptance = await chainReceiver.provider.sendViaChain(failedAcceptance.id!);
    expect(chainAcceptance.sent, isTrue);
    expect(ledger.transfers.last.value, ChatProvider.fallbackValueSats);
    expect(ledger.transfers.last.fee, ChatProvider.minerFeeSats);
    expect(chainReceiver.provider.selectedContact!.relationshipState, ChatRelationshipState.acceptancePending);
    await chainSender.provider.fetchPaymail();
    expect(
      chainSender.provider.contacts
          .singleWhere((contact) => contact.id == chainReceiver.provider.selectedIdentity!.hash)
          .relationshipState,
      ChatRelationshipState.outgoingIntroduction,
    );
    mesh.failRecipient = null;
    ledger.confirm(chainAcceptance.reference!);
    await chainReceiver.provider.fetchPaymail();
    await chainSender.provider.fetchPaymail();
    expect(chainReceiver.provider.selectedContact!.relationshipState, ChatRelationshipState.accepted);
    expect(
      chainSender.provider.contacts
          .singleWhere((contact) => contact.id == chainReceiver.provider.selectedIdentity!.hash)
          .relationshipState,
      ChatRelationshipState.accepted,
    );

    // A new introduction can be rejected without unlocking chat.
    final rejectSender = users[4], rejectReceiver = users[6];
    await _introduce(ledger, rejectSender, rejectReceiver);
    rejectReceiver.provider.selectContact(
      rejectReceiver.provider.contacts.singleWhere(
        (contact) => contact.id == rejectSender.provider.selectedIdentity!.hash,
      ),
    );
    await rejectReceiver.provider.rejectIntroduction();
    expect(rejectReceiver.provider.selectedContact!.relationshipState, ChatRelationshipState.rejected);

    // Concurrent attempts cannot double-spend.
    final concurrentSender = users[5], concurrentReceiver = users[7];
    final remote = concurrentSender.provider.allBitNames.singleWhere(
      (entry) => entry.hash == concurrentReceiver.provider.selectedIdentity!.hash,
    );
    await concurrentSender.provider.addContactFromEntry(remote);
    concurrentSender.provider.selectContact(
      concurrentSender.provider.contacts.singleWhere((contact) => contact.id == remote.hash),
    );
    final beforeConcurrent = ledger.transfers.length;
    final concurrent = await Future.wait([
      concurrentSender.provider.sendIntroduction('first concurrent introduction'),
      concurrentSender.provider.sendIntroduction('second concurrent introduction'),
    ]);
    expect(concurrent.where((result) => result.sent).length, 1);
    expect(ledger.transfers.length, beforeConcurrent + 1);

    // Restart one user from the same settings and retain conversations.
    final restarting = users[2];
    final before = restarting.provider.messages.length;
    restarting.provider.dispose();
    final replacement = ChatProvider(
      rpc: restarting.rpc,
      settings: restarting.settings,
      transport: BitMessageTransport(directDialer: mesh.direct, torDialer: mesh.tor),
      torMutationGuard: () async => null,
      autoStart: false,
    );
    restarting.provider = replacement;
    mesh.providers[2] = replacement;
    await _as(restarting, replacement.initialize);
    expect(replacement.messages.length, before);
    expect(replacement.myIdentities.single.plaintextName, 'user3');

    // Oversized input, fee mutation, and lost ownership spend nothing.
    replacement.selectContact(
      replacement.contacts.singleWhere((contact) => contact.id == users[3].provider.selectedIdentity!.hash),
    );
    final spendCount = ledger.transfers.length;
    expect((await replacement.send('x' * (ChatProvider.maxMessageBytes + 1))).sent, isFalse);
    expect(ledger.transfers.length, spendCount);

    final feeTarget = users[4];
    final feeEntry = replacement.allBitNames.singleWhere(
      (entry) => entry.hash == feeTarget.provider.selectedIdentity!.hash,
    );
    await replacement.addContactFromEntry(feeEntry);
    replacement.selectContact(replacement.contacts.singleWhere((contact) => contact.id == feeEntry.hash));
    ledger.changeFee(feeEntry.hash, 9999);
    expect((await replacement.sendIntroduction('stale fee')).sent, isFalse);
    expect(ledger.transfers.length, spendCount);

    final ownershipUser = users[8], ownershipTarget = users[9];
    ownershipUser.provider.selectContact(
      ownershipUser.provider.contacts.singleWhere(
        (contact) => contact.id == ownershipTarget.provider.selectedIdentity!.hash,
      ),
    );
    ledger.records[ownershipUser.provider.selectedIdentity!.hash]!.owner = -1;
    expect((await ownershipUser.provider.send('must not sign')).sent, isFalse);
    expect(ledger.transfers.length, spendCount);

    for (final user in users) {
      for (final contact in user.provider.contacts) {
        expect(contact.displayName, isNotEmpty);
        expect(contact.id.length, 64);
      }
    }
    expect(mesh.directCalls, greaterThan(0));
    expect(mesh.torCalls, greaterThan(0));
    expect(mesh.torDirectLeaks, 0);
    stopwatch.stop();
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
  });
}

Future<void> _introduce(_Chain ledger, _User sender, _User receiver) async {
  final remote = sender.provider.allBitNames.singleWhere(
    (entry) => entry.hash == receiver.provider.selectedIdentity!.hash,
  );
  await sender.provider.addContactFromEntry(remote);
  sender.provider.selectContact(sender.provider.contacts.singleWhere((contact) => contact.id == remote.hash));
  final sent = await sender.provider.sendIntroduction('new introduction from user ${sender.index + 1}');
  expect(sent.sent, isTrue);
  ledger.confirm(sent.reference!);
  await receiver.provider.fetchPaymail();
}

Future<T> _as<T>(_User user, Future<T> Function() action) async {
  if (GetIt.I.isRegistered<ClientSettings>()) {
    GetIt.I.unregister<ClientSettings>();
  }
  GetIt.I.registerSingleton<ClientSettings>(user.settings);
  return action();
}

class _User {
  _User(this.index, this.store, this.settings, this.rpc, this.provider);
  final int index;
  final _Store store;
  final ClientSettings settings;
  final _WalletRpc rpc;
  ChatProvider provider;
}

class _Store implements KeyValueStore {
  final values = <String, String>{};
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<String?> getString(String key) async => values[key];
  @override
  Future<void> setString(String key, String value) async => values[key] = value;
}

class _Transfer {
  _Transfer(this.txid, this.idempotencyKey, this.sender, this.recipient, this.value, this.fee, this.memo);
  final String txid, idempotencyKey, sender, recipient, memo;
  final int value, fee;
  bool confirmed = false;
}

class _Record {
  _Record(this.name, this.hash, this.owner, this.address, this.data);
  final String name, hash, address;
  int owner;
  BitNameData data;
}

class _Chain {
  final records = <String, _Record>{};
  final transfers = <_Transfer>[];
  final idempotent = <String, _Transfer>{};
  int nextId = 1;

  String register(int owner, String name, BitNameData data) {
    final hash = blake3Hex(utf8.encode(name.toLowerCase()));
    records[hash] = _Record(name, hash, owner, 'address-$owner', data);
    return 'register-${nextId++}';
  }

  void confirm(String txid) => transfers.singleWhere((transfer) => transfer.txid == txid).confirmed = true;

  void changeFee(String hash, int fee) {
    final record = records[hash]!;
    record.data = _copyData(record.data, paymailFeeSats: fee);
  }
}

class _WalletRpc extends BitnamesRPC {
  _WalletRpc(this.ledger, this.owner) : super(binaryType: BinaryType.BINARY_TYPE_BITNAMES);
  final _Chain ledger;
  final int owner;
  int keyIndex = 0;

  @override
  Future<BalanceResponse> getBalance() async => BalanceResponse(totalSats: 1000000, availableSats: 1000000);
  @override
  Future<String> reserveBitName(String name) async => 'reserve-${ledger.nextId++}';
  @override
  Future<String> registerBitName(String plainName, BitNameData? data) async =>
      ledger.register(owner, plainName, data ?? BitNameData());
  @override
  Future<String> getNewEncryptionKey() async => 'encryption-$owner-${keyIndex++}';
  @override
  Future<String> getNewVerifyingKey() async => 'signing-$owner-${keyIndex++}';
  @override
  Future<List<BitnameEntry>> listBitNames() async => ledger.records.values
      .map(
        (record) => BitnameEntry(
          hash: record.hash,
          plaintextName: record.name,
          details: BitnameDetails(
            seqId: record.data.seqId ?? '0',
            commitment: record.data.commitment,
            encryptionPubkey: record.data.encryptionPubkey,
            signingPubkey: record.data.signingPubkey,
            paymailFeeSats: record.data.paymailFeeSats,
          ),
        ),
      )
      .toList();
  @override
  Future<List<SidechainUTXO>> listUTXOs() async => ledger.records.values
      .where((record) => record.owner == owner)
      .map(
        (record) => BitnamesUTXO(
          outpoint: 'owned:${record.hash}',
          address: record.address,
          valueSats: 0,
          type: OutpointType.bitname,
          content: jsonEncode({'BitName': record.hash}),
        ),
      )
      .toList();
  @override
  Future<BitNameResolution?> resolveBitName(String bitname) async {
    final record = ledger.records[bitname];
    return record == null
        ? null
        : BitNameResolution(
            bitname: bitname,
            outpoint: {'txid': 'owner-${record.owner}'},
            address: record.address,
            data: record.data,
          );
  }

  @override
  Future<String> updateBitName({
    required String bitname,
    required BitNameDataUpdates updates,
    required int feeSats,
  }) async {
    final record = ledger.records[bitname]!;
    if (record.owner != owner) throw StateError('not owned');
    record.data = _apply(record.data, updates);
    return 'update-${ledger.nextId++}';
  }

  @override
  Future<String> signArbitraryMsg({required String msg, required String verifyingKey}) async =>
      '$verifyingKey:${base64UrlEncode(utf8.encode(msg))}';
  @override
  Future<bool> verifySignature({
    required String signature,
    required String verifyingKey,
    String domain = 'arbitrary',
    required String msg,
  }) async => signature == '$verifyingKey:${base64UrlEncode(utf8.encode(msg))}';
  @override
  Future<String> encryptMsg({required String msg, required String encryptionPubkey}) async =>
      base64UrlEncode(utf8.encode(jsonEncode({'key': encryptionPubkey, 'message': msg})));
  @override
  Future<String> decryptMsg({required String ciphertext, required String encryptionPubkey}) async {
    final decoded = jsonDecode(utf8.decode(base64Url.decode(ciphertext))) as Map<String, dynamic>;
    if (decoded['key'] != encryptionPubkey) throw StateError('wrong recipient key');
    return decoded['message'] as String;
  }

  @override
  Future<BitNameData> bitNameDataAtPosition(String bitname, String blockHash, int txIndex) async =>
      ledger.records[bitname]!.data;
  @override
  Future<List<PaymailEntry>> getPaymailEntries() async => [
    for (var i = 0; i < ledger.transfers.length; i++)
      if (ledger.transfers[i].confirmed)
        _mail(
          ledger.transfers[i],
          ledger.records.values.singleWhere((record) => record.address == ledger.transfers[i].recipient),
          i,
        ),
  ];
  @override
  Future<String> transferIdempotent({
    required String idempotencyKey,
    required String dest,
    required int value,
    required int fee,
    String? memo,
  }) async {
    final existing = ledger.idempotent[idempotencyKey];
    if (existing != null) return existing.txid;
    final transfer = _Transfer(
      'transfer-${ledger.nextId++}',
      idempotencyKey,
      'wallet-$owner',
      dest,
      value,
      fee,
      memo ?? '',
    );
    ledger.transfers.add(transfer);
    ledger.idempotent[idempotencyKey] = transfer;
    return transfer.txid;
  }

  @override
  Future<String> transfer({
    required String dest,
    required int value,
    required int fee,
    String? memo,
  }) => transferIdempotent(
    idempotencyKey: 'transfer-${ledger.nextId++}',
    dest: dest,
    value: value,
    fee: fee,
    memo: memo,
  );
  @override
  Future<bool> isTransactionConfirmed(String txid) async =>
      ledger.transfers.where((transfer) => transfer.txid == txid).firstOrNull?.confirmed ?? true;
  @override
  Future<BitnamesTransactionStatus> transactionStatus(String txid) async {
    final transfer = ledger.transfers.where((item) => item.txid == txid).firstOrNull;
    if (transfer == null) return BitnamesTransactionStatus.absent;
    return transfer.confirmed ? BitnamesTransactionStatus.confirmed : BitnamesTransactionStatus.pending;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PaymailEntry _mail(_Transfer transfer, _Record recipient, int index) => PaymailEntry(
  outpoint: {'txid': transfer.txid},
  output: PaymailOutput(address: transfer.recipient, content: const {}, memoHex: transfer.memo),
  valueSats: transfer.value,
  blockHash: 'block-$index',
  blockHeight: index + 1,
  txIndex: index,
  recipients: [
    PaymailRecipient(
      bitname: recipient.hash,
      data: recipient.data,
      requiredFeeSats: recipient.data.paymailFeeSats,
    ),
  ],
);

BitNameData _apply(BitNameData old, BitNameDataUpdates updates) => BitNameData(
  seqId: old.seqId,
  commitment: _updated(old.commitment, updates.commitment),
  encryptionPubkey: _updated(old.encryptionPubkey, updates.encryptionPubkey),
  signingPubkey: _updated(old.signingPubkey, updates.signingPubkey),
  paymailFeeSats: _updated(old.paymailFeeSats, updates.paymailFeeSats),
  socketAddrV4: _updated(old.socketAddrV4, updates.socketAddrV4),
  socketAddrV6: _updated(old.socketAddrV6, updates.socketAddrV6),
);

T? _updated<T extends Object>(T? old, BitNameUpdate<T> update) => switch (update.action) {
  BitNameUpdateAction.retain => old,
  BitNameUpdateAction.delete => null,
  BitNameUpdateAction.set => update.value,
};

BitNameData _copyData(BitNameData old, {int? paymailFeeSats}) => BitNameData(
  seqId: old.seqId,
  commitment: old.commitment,
  encryptionPubkey: old.encryptionPubkey,
  signingPubkey: old.signingPubkey,
  paymailFeeSats: paymailFeeSats ?? old.paymailFeeSats,
  socketAddrV4: old.socketAddrV4,
  socketAddrV6: old.socketAddrV6,
);

class _Mesh {
  final providers = <ChatProvider>[];
  late final direct = _MeshDialer(this, false);
  late final tor = _MeshDialer(this, true);
  String? failRecipient;
  int directCalls = 0;
  int torCalls = 0;
  int torDirectLeaks = 0;

  ChatProvider _provider(String hash) => providers.singleWhere(
    (provider) => provider.myIdentities.any((identity) => identity.hash == hash),
  );
}

class _MeshDialer implements BitMessageHttpDialer {
  _MeshDialer(this.mesh, this.isTor);
  final _Mesh mesh;
  final bool isTor;
  @override
  Future<BitMessageHttpResponse> get(Uri uri, {required Duration timeout}) async {
    isTor ? mesh.torCalls++ : mesh.directCalls++;
    final hash = uri.pathSegments[1];
    final profile = mesh._provider(hash).profiles[hash];
    return BitMessageHttpResponse(statusCode: profile == null ? 404 : 200, body: jsonEncode(profile?.toJson()));
  }

  @override
  Future<BitMessageHttpResponse> postJson(Uri uri, {required String body, required Duration timeout}) async {
    final wire = BitMessageWire.fromJson(Map<String, dynamic>.from(jsonDecode(body) as Map));
    if (mesh.failRecipient == wire.recipientBitNameHash) throw StateError('simulated network outage');
    if (isTor && uri.host.endsWith('.test')) mesh.torDirectLeaks++;
    final accepted = await mesh
        ._provider(wire.recipientBitNameHash)
        .receiveWire(
          wire,
          isTor ? ChatTransport.tor : ChatTransport.direct,
        );
    return BitMessageHttpResponse(statusCode: accepted ? 202 : 409, body: '');
  }

  @override
  void close() {}
}
