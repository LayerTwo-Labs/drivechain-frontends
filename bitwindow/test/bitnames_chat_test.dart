import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/models/bitintroduction_protocol.dart';
import 'package:bitwindow/services/bitmessage_server.dart';
import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:bitwindow/services/bitnames_secure_store.dart';
import 'package:bitwindow/services/chat_file_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _Keys extends ChangeNotifier implements BitnamesStorageKeySource {
  BitnamesStorageIdentity? identity = WalletBitnamesStorageKeySource.derive(masterMnemonic: 'test wallet');
  @override
  Future<BitnamesStorageIdentity?> current() async => identity;
}

void main() {
  test('direct delivery verifies the served commitment before accepting a wire', () async {
    final hash = 'a' * 64;
    late BitMessageProfile profile;
    final received = <BitMessageWire>[];
    final server = BitMessageServer(profileProvider: (_) => profile, onIncomingWire: received.add);
    final endpoint = await server.start();
    final transport = BitMessageTransport(directDialer: DirectBitMessageHttpDialer());
    addTearDown(server.stop);
    addTearDown(transport.close);
    profile = BitMessageProfile(
      bitNameHash: hash,
      signingPublicKey: 'signing-key',
      encryptionPublicKey: 'encryption-key',
      directEndpoints: [endpoint.resolve('bitname/$hash/')],
    );
    final verified = VerifiedBitMessageProfile.verified(
      profile: profile,
      onChainCommitment: bitMessageProfileCommitment(profile),
      verificationReference: 'test-block',
    );
    final wire = BitMessageWire(recipientBitNameHash: hash, ciphertext: 'encrypted-message');
    expect((await transport.send(wire, verified)).transport, BitMessageTransportType.direct);
    expect(received.single.ciphertext, wire.ciphertext);
    profile = BitMessageProfile(
      bitNameHash: hash,
      signingPublicKey: 'changed-key',
      encryptionPublicKey: 'encryption-key',
      directEndpoints: profile.directEndpoints,
    );
    await expectLater(transport.send(wire, verified), throwsA(isA<BitMessageTransportException>()));
    expect(received, hasLength(1));
  });

  test('chat storage encrypts, restores, and isolates wallet scopes', () async {
    final dir = await Directory.systemTemp.createTemp('bitnames-chat-test-');
    addTearDown(() => dir.delete(recursive: true));
    final keys = _Keys();
    final store = ChatFileStorage.fromDirectory(dir);
    final secure = BitnamesSecureStore(store: store, keySource: keys);
    expect(await secure.load(), isEmpty);
    await secure.save({
      'selected_identity': 'private text',
    });
    expect(await store.file.readAsString(), isNot(contains('private text')));
    final backup = await secure.exportEncrypted();
    await secure.clear();
    await secure.restoreEncrypted(backup);
    expect((await secure.load())['selected_identity'], 'private text');
    keys.identity = WalletBitnamesStorageKeySource.derive(masterMnemonic: 'different wallet');
    expect(await secure.load(), isEmpty);
    await expectLater(secure.restoreEncrypted(backup), throwsA(isA<BitnamesStorageException>()));
    keys.identity = null;
    await expectLater(secure.save({'messages': []}), throwsA(isA<BitnamesStorageException>()));
  });

  test('chat file recovers a corrupt primary without losing the recovery copy', () async {
    final dir = await Directory.systemTemp.createTemp('bitnames-recovery-test-');
    addTearDown(() => dir.delete(recursive: true));
    final store = ChatFileStorage.fromDirectory(dir);
    await store.setString('state', 'first');
    await store.setString('state', 'second');
    await store.file.writeAsString('{corrupt');
    final reopened = ChatFileStorage.fromDirectory(dir);
    expect(await reopened.getString('state'), 'first');
    await reopened.setString('other', 'value');
    expect(jsonDecode(await reopened.file.readAsString()), {'state': 'first', 'other': 'value'});
  });
}
