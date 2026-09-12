import 'dart:io';

import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/services/bitnames_secure_store.dart';
import 'package:bitwindow/services/chat_file_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the wallet. The real source derives the same way from the
/// unlocked wallet's mnemonic.
class _Keys extends ChangeNotifier implements BitnamesStorageKeySource {
  _Keys(this.identity);

  BitnamesStorageIdentity? identity;

  @override
  Future<BitnamesStorageIdentity?> current() async => identity;
}

ChatMessage message(String id, String body) => ChatMessage(
  id: id,
  content: body,
  senderPubkey: 'bn-enc1sender',
  recipientPubkey: 'bn-enc1me',
  timestamp: DateTime.fromMillisecondsSinceEpoch(1757680000000),
  isOutgoing: false,
);

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('chat_store_test');
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  BitnamesSecureStore storeFor(String mnemonic) => BitnamesSecureStore(
    store: ChatFileStorage.fromDirectory(directory),
    keySource: _Keys(WalletBitnamesStorageKeySource.derive(masterMnemonic: mnemonic)),
  );

  // A restart must give the chat back. The chain cannot, because a sent
  // message is encrypted to the reader.
  test('the chat survives a restart', () async {
    final store = storeFor('test wallet');
    await store.save({
      'messages': [message('a:0', 'hei ecash').toJson()],
    });

    final reopened = storeFor('test wallet');
    final state = await reopened.load();
    final stored = state['messages'] as List<dynamic>;
    expect(stored, hasLength(1));
    expect(ChatMessage.fromJson(stored.first as Map<String, dynamic>).content, 'hei ecash');
  });

  // A chat holds private text, so the disk must not.
  test('the disk never holds the message text', () async {
    await storeFor('test wallet').save({
      'messages': [message('a:0', 'hemmelig melding').toJson()],
    });

    final onDisk = await File('${directory.path}${Platform.pathSeparator}chat.json').readAsString();
    expect(onDisk, isNot(contains('hemmelig melding')));
    expect(onDisk, isNot(contains('bn-enc1sender')));
  });

  // The key comes from the wallet, so another wallet reads nothing.
  test('another wallet cannot read the chat', () async {
    await storeFor('test wallet').save({
      'messages': [message('a:0', 'hei ecash').toJson()],
    });

    final other = storeFor('a different wallet');
    final state = await other.load();
    expect(state['messages'], anyOf(isNull, isEmpty));
  });

  // A locked wallet holds no key, so the chat stays shut.
  test('a locked wallet reads nothing', () async {
    final locked = BitnamesSecureStore(
      store: ChatFileStorage.fromDirectory(directory),
      keySource: _Keys(null),
    );
    final state = await locked.load();
    expect(state['messages'], anyOf(isNull, isEmpty));
  });
}
