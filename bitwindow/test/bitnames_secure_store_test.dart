import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/services/bitnames_secure_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  late FaultStore raw;
  late FixedBitnamesStorageKeySource keys;
  late int nonce;

  BitnamesSecureStore secure() => BitnamesSecureStore(
    store: raw,
    keySource: keys,
    now: () => DateTime.utc(2026, 7, 23),
    randomBytes: (length) => Uint8List.fromList(
      List<int>.generate(length, (index) => (nonce++ + index) & 0xff),
    ),
  );

  setUp(() {
    raw = FaultStore();
    keys = FixedBitnamesStorageKeySource(
      scope: 'wallet-a',
      secret: 'correct horse battery staple',
    );
    nonce = 1;
  });

  test('wallet backup derives the same key without depending on local wallet ID', () {
    final original = WalletBitnamesStorageKeySource.derive(
      masterMnemonic: 'Alpha Beta Gamma',
      walletBinding: 'Layer One Seed',
    );
    final restored = WalletBitnamesStorageKeySource.derive(
      masterMnemonic: '  alpha   beta gamma ',
      walletBinding: 'layer one seed',
    );
    final distinct = WalletBitnamesStorageKeySource.derive(
      masterMnemonic: 'alpha beta gamma',
      walletBinding: 'different passphrase-derived wallet',
    );

    expect(restored.scope, original.scope);
    expect(restored.secret, orderedEquals(original.secret));
    expect(distinct.scope, isNot(original.scope));
  });

  test('migrates every legacy private field and removes plaintext', () async {
    await raw.setString(
      BitnamesSecureStore.legacyStateKey,
      jsonEncode({
        'messages': [_message('m1', 'alice', 'bob', 'private hello')],
        'profiles': [
          {
            'bitname_hash': 'alice',
            'signing_public_key': 'signing',
            'encryption_public_key': 'encryption',
            'direct_endpoints': ['http://192.0.2.3:37999'],
            'tor_endpoints': ['http://examplehiddenservice.onion'],
          },
        ],
        'pending_wires': {
          'm1': {
            'recipient_bitname_hash': 'bob',
            'ciphertext': 'private-wire',
          },
        },
        'operations': [_operation('pay-1')],
      }),
    );
    await raw.setString(
      BitnamesSecureStore.legacyContactsKey,
      jsonEncode([_contact('alice', 'bob')]),
    );
    await raw.setString(
      BitnamesSecureStore.legacyOwnedKey,
      jsonEncode(['alice']),
    );

    final store = secure();
    final state = await store.load();

    expect(store.status.state, BitnamesStorageState.migrated);
    expect((state['messages'] as List).single['content'], 'private hello');
    expect((state['contacts'] as List).single['id'], 'bob');
    expect(state['owned'], ['alice']);
    expect(await raw.getString(BitnamesSecureStore.legacyStateKey), isNull);
    expect(await raw.getString(BitnamesSecureStore.legacyContactsKey), isNull);
    expect(await raw.getString(BitnamesSecureStore.legacyOwnedKey), isNull);
    expect(raw.encoded, isNot(contains('private hello')));
    expect(raw.encoded, isNot(contains('192.0.2.3')));
    expect(raw.encoded, isNot(contains('examplehiddenservice.onion')));
    expect(raw.encoded, isNot(contains('private-wire')));
  });

  test('missing and wrong keys fail closed without erasing ciphertext', () async {
    final store = secure();
    await store.load();
    await store.save({
      'messages': [_message('m1', 'alice', 'bob', 'secret')],
    });
    final before = Map<String, String>.from(raw.db);

    keys.lock();
    expect(await store.load(), isEmpty);
    expect(store.status.state, BitnamesStorageState.locked);
    await expectLater(
      store.save(<String, dynamic>{}),
      throwsA(isA<BitnamesStorageException>()),
    );
    expect(raw.db, before);

    keys.unlock(scope: 'wallet-a', secret: 'wrong key');
    await expectLater(
      secure().load(),
      throwsA(isA<BitnamesStorageException>()),
    );
    expect(raw.db, before);
  });

  test('slot failure rolls back and missing head rolls a valid write forward', () async {
    final store = secure();
    await store.load();
    await store.save({
      'owned': ['generation-one'],
    });

    raw.failSetSuffix = '_b';
    await expectLater(
      store.save({
        'owned': ['never-persisted'],
      }),
      throwsA(isA<BitnamesStorageException>()),
    );
    raw.failSetSuffix = null;
    expect((await secure().load())['owned'], ['generation-one']);

    raw.failSetSuffix = '_head';
    await expectLater(
      secure().save({
        'owned': ['generation-two'],
      }),
      throwsA(isA<BitnamesStorageException>()),
    );
    raw.failSetSuffix = null;
    final recovered = secure();
    expect((await recovered.load())['owned'], ['generation-two']);
    expect(recovered.status.state, BitnamesStorageState.recovered);
  });

  test('torn newest slot rolls back but corruption of all slots is rejected', () async {
    final store = secure();
    await store.load();
    await store.save({
      'owned': ['stable'],
    });
    raw.failSetSuffix = '_head';
    await expectLater(
      store.save({
        'owned': ['torn'],
      }),
      throwsA(isA<BitnamesStorageException>()),
    );
    raw.failSetSuffix = null;
    raw.db[_key(raw, '_b')] = '{"corrupt":true}';

    final recovered = secure();
    expect((await recovered.load())['owned'], ['stable']);
    expect(recovered.status.state, BitnamesStorageState.recovered);

    raw.db[_key(raw, '_a')] = '{"corrupt":true}';
    await expectLater(
      secure().load(),
      throwsA(isA<BitnamesStorageException>()),
    );
  });

  test('migration interruption resumes from authenticated state, never legacy', () async {
    await raw.setString(
      BitnamesSecureStore.legacyStateKey,
      jsonEncode({
        'messages': [_message('m1', 'alice', 'bob', 'original')],
      }),
    );
    raw.failDeleteKey = BitnamesSecureStore.legacyStateKey;
    await expectLater(
      secure().load(),
      throwsA(isA<BitnamesStorageException>()),
    );
    raw.failDeleteKey = null;

    await raw.setString(
      BitnamesSecureStore.legacyStateKey,
      jsonEncode({
        'messages': [_message('m1', 'alice', 'bob', 'downgrade')],
      }),
    );
    final restarted = secure();
    expect(
      ((await restarted.load())['messages'] as List).single['content'],
      'original',
    );
    expect(await raw.getString(BitnamesSecureStore.legacyStateKey), isNull);

    await raw.setString(
      BitnamesSecureStore.legacyStateKey,
      jsonEncode({
        'messages': [_message('m1', 'alice', 'bob', 'must-not-load')],
      }),
    );
    raw.db[_key(raw, '_a')] = '{"corrupt":true}';
    await expectLater(
      secure().load(),
      throwsA(isA<BitnamesStorageException>()),
    );
    expect(await raw.getString(BitnamesSecureStore.legacyStateKey), isNotNull);
  });

  test('duplicate replay is idempotent and conflicting replay aborts transaction', () async {
    final store = secure();
    await store.load();
    final operation = _operation('same-id');
    await store.save({
      'operations': [operation, operation],
    });
    expect(((await store.load())['operations'] as List), hasLength(1));
    final generation = store.status.generation;

    await expectLater(
      store.save({
        'operations': [
          operation,
          {...operation, 'phase': 'confirmed'},
        ],
      }),
      throwsA(isA<BitnamesStorageException>()),
    );
    expect(store.status.generation, generation);
    expect(
      ((await secure().load())['operations'] as List).single['phase'],
      'prepared',
    );
  });

  test('wallet and BitName identities remain independently scoped', () async {
    final walletA = secure();
    await walletA.load();
    await walletA.save({
      'messages': [
        _message('a1', 'alice', 'bob', 'alice-bob'),
        _message('c1', 'carol', 'bob', 'carol-bob'),
      ],
    });
    expect(
      walletA
          .pageMessages(
            await walletA.load(),
            localBitname: 'alice',
            remoteBitname: 'bob',
          )
          .single['content'],
      'alice-bob',
    );

    keys.unlock(scope: 'wallet-b', secret: 'another wallet secret');
    final walletB = secure();
    expect(await walletB.load(), isEmpty);
    await walletB.save({
      'messages': [_message('b1', 'bob', 'alice', 'wallet-b-only')],
    });

    keys.unlock(
      scope: 'wallet-a',
      secret: 'correct horse battery staple',
    );
    expect(
      ((await secure().load())['messages'] as List).map((entry) => entry['content']),
      containsAll(['alice-bob', 'carol-bob']),
    );
    expect(raw.keysEnding('_head'), hasLength(2));
  });

  test('wallet switch rejects a stale transaction before it reaches the new scope', () async {
    final store = secure();
    await store.load();
    await store.save({
      'owned': ['wallet-a'],
    });

    keys.unlock(scope: 'wallet-b', secret: 'another wallet secret');
    await expectLater(
      store.save({
        'owned': ['stale-wallet-a-memory'],
      }),
      throwsA(isA<BitnamesStorageException>()),
    );
    final walletB = secure();
    expect(await walletB.load(), isEmpty);

    keys.unlock(
      scope: 'wallet-a',
      secret: 'correct horse battery staple',
    );
    expect((await secure().load())['owned'], ['wallet-a']);
  });

  test('conversation index pages one identity without crossing another', () async {
    final store = secure();
    await store.load();
    final messages = [
      for (var index = 0; index < 75; index++)
        {
          ..._message('alice-$index', 'alice', 'bob', 'message-$index'),
          'timestamp': index,
        },
      {
        ..._message('carol-only', 'carol', 'bob', 'not-alice'),
        'timestamp': 1000,
      },
    ];
    await store.save({'messages': messages});
    final state = await store.load();

    final newest = store.pageMessages(
      state,
      localBitname: 'alice',
      remoteBitname: 'bob',
    );
    expect(newest, hasLength(50));
    expect(newest.first['content'], 'message-25');
    expect(newest.last['content'], 'message-74');
    final older = store.pageMessages(
      state,
      localBitname: 'alice',
      remoteBitname: 'bob',
      beforeTimestamp: newest.first['timestamp'] as int,
    );
    expect(older, hasLength(25));
    expect(older.first['content'], 'message-0');
    expect(older.last['content'], 'message-24');
    expect(
      [...newest, ...older].map((message) => message['content']),
      isNot(contains('not-alice')),
    );
  });

  test('encrypted backup authenticates, restores, and rejects rollback', () async {
    final source = secure();
    await source.load();
    await source.save({
      'messages': [_message('m1', 'alice', 'bob', 'backup-one')],
    });
    final oldBackup = await source.exportEncrypted();
    await source.save({
      'messages': [_message('m2', 'alice', 'bob', 'current')],
    });
    final currentBackup = jsonDecode(await source.exportEncrypted()) as Map<String, dynamic>;
    currentBackup['a'] = '{"corrupt":true}';
    await expectLater(
      source.restoreEncrypted(oldBackup),
      throwsA(isA<BitnamesStorageException>()),
    );

    final restoredRaw = FaultStore();
    final restored = BitnamesSecureStore(
      store: restoredRaw,
      keySource: keys,
      randomBytes: (length) => Uint8List(length)..fillRange(0, length, 7),
    );
    await restored.restoreEncrypted(oldBackup);
    expect(
      ((await restored.load())['messages'] as List).single['content'],
      'backup-one',
    );

    final recoveredBackup = BitnamesSecureStore(
      store: FaultStore(),
      keySource: keys,
    );
    await recoveredBackup.restoreEncrypted(jsonEncode(currentBackup));
    expect(
      ((await recoveredBackup.load())['messages'] as List).single['content'],
      'current',
    );
    await expectLater(
      recoveredBackup.restoreEncrypted(oldBackup),
      throwsA(isA<BitnamesStorageException>()),
    );

    keys.unlock(scope: 'other-wallet', secret: 'other');
    await expectLater(
      BitnamesSecureStore(store: FaultStore(), keySource: keys).restoreEncrypted(oldBackup),
      throwsA(isA<BitnamesStorageException>()),
    );
  });

  test('clear removes decryptable prior generations before a fresh save', () async {
    final store = secure();
    await store.load();
    await store.save({
      'messages': [_message('m1', 'alice', 'bob', 'erase-me')],
    });
    await store.save({
      'messages': [_message('m2', 'alice', 'bob', 'erase-me-too')],
    });
    await store.clear();
    expect(raw.encoded, isNot(contains('ciphertext')));
    await store.save(<String, dynamic>{});
    expect((await store.load())['messages'] as List? ?? [], isEmpty);
    expect(raw.encoded, isNot(contains('erase-me')));
  });

  test('migration and clear scrub the file recovery generation', () async {
    final directory = await Directory.systemTemp.createTemp(
      'bitnames-secure-store-',
    );
    try {
      final fileStore = FileStorage.fromDirectory(directory);
      await fileStore.setString(
        BitnamesSecureStore.legacyStateKey,
        jsonEncode({
          'messages': [_message('m1', 'alice', 'bob', 'legacy-secret')],
        }),
      );
      final store = BitnamesSecureStore(
        store: fileStore,
        keySource: keys,
      );
      await store.load();
      expect(
        await _settingsGenerations(directory),
        isNot(contains('legacy-secret')),
      );

      await store.save({
        'messages': [_message('m2', 'alice', 'bob', 'encrypted-secret')],
      });
      await store.clear();
      final generations = await _settingsGenerations(directory);
      expect(generations, isNot(contains('ciphertext')));
      expect(generations, isNot(contains('encrypted-secret')));
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

Map<String, dynamic> _message(
  String id,
  String sender,
  String recipient,
  String content,
) => {
  'id': id,
  'content': content,
  'sender_bitname': sender,
  'recipient_bitname': recipient,
  'timestamp': 1000,
  'is_outgoing': true,
};

Map<String, dynamic> _contact(String local, String remote) => {
  'id': remote,
  'local_bitname': local,
  'name': remote,
  'encryption_pubkey': 'key',
};

Map<String, dynamic> _operation(String id) => {
  'id': id,
  'type': 'registration',
  'phase': 'prepared',
  'bitname_hash': 'alice',
  'created_at': 1000,
  'updated_at': 1000,
};

String _key(FaultStore store, String suffix) => store.db.keys.singleWhere((key) => key.endsWith(suffix));

Future<String> _settingsGenerations(Directory directory) async {
  final primary = File('${directory.path}${Platform.pathSeparator}settings.json');
  final backup = File('${primary.path}.bak');
  return [
    if (await primary.exists()) await primary.readAsString(),
    if (await backup.exists()) await backup.readAsString(),
  ].join();
}

class FaultStore implements KeyValueStore {
  final Map<String, String> db = {};
  String? failSetSuffix;
  String? failDeleteKey;

  String get encoded => jsonEncode(db);
  Iterable<String> keysEnding(String suffix) => db.keys.where((key) => key.endsWith(suffix));

  @override
  Future<String?> getString(String key) async => db[key];

  @override
  Future<void> setString(String key, String value) async {
    if (failSetSuffix != null && key.endsWith(failSetSuffix!)) {
      throw StateError('injected set failure');
    }
    db[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (key == failDeleteKey) throw StateError('injected delete failure');
    db.remove(key);
  }
}
