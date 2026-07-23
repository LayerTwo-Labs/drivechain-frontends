import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:synchronized/synchronized.dart';

enum BitnamesStorageState {
  locked,
  empty,
  ready,
  migrated,
  recovered,
  corrupt,
}

class BitnamesStorageStatus {
  const BitnamesStorageStatus(
    this.state, {
    this.generation,
    this.details,
  });

  final BitnamesStorageState state;
  final int? generation;
  final String? details;

  bool get writable => {
    BitnamesStorageState.empty,
    BitnamesStorageState.ready,
    BitnamesStorageState.migrated,
    BitnamesStorageState.recovered,
  }.contains(state);

  String get summary => switch (state) {
    BitnamesStorageState.locked => 'Private chat storage is locked',
    BitnamesStorageState.empty => 'Private chat storage is ready',
    BitnamesStorageState.ready => 'Chats and reply routes are encrypted',
    BitnamesStorageState.migrated => 'Existing chats were encrypted',
    BitnamesStorageState.recovered => 'Encrypted chat storage recovered safely',
    BitnamesStorageState.corrupt => 'Private chat storage needs recovery',
  };
}

class BitnamesStorageException implements Exception {
  const BitnamesStorageException(this.message);
  final String message;
  @override
  String toString() => message;
}

class BitnamesStorageIdentity {
  BitnamesStorageIdentity({
    required this.scope,
    required Uint8List secret,
  }) : secret = Uint8List.fromList(secret);

  final String scope;
  final Uint8List secret;
}

abstract class BitnamesStorageKeySource implements Listenable {
  Future<BitnamesStorageIdentity?> current();
}

class WalletBitnamesStorageKeySource implements BitnamesStorageKeySource {
  WalletBitnamesStorageKeySource(this.walletReader);

  final WalletReaderProvider walletReader;

  @visibleForTesting
  static BitnamesStorageIdentity derive({
    required String masterMnemonic,
    String walletBinding = '',
  }) {
    final mnemonic = _normalizeWords(masterMnemonic);
    final binding = _normalizeWords(walletBinding);
    if (mnemonic.isEmpty) {
      throw const BitnamesStorageException('The unlocked wallet has no encryption key material');
    }
    final root = crypto.sha256.convert(
      utf8.encode(
        'bitnames-storage-root-v2\u0000$mnemonic\u0000$binding',
      ),
    );
    return BitnamesStorageIdentity(
      scope: crypto.Hmac(
        crypto.sha256,
        root.bytes,
      ).convert(utf8.encode('scope')).toString(),
      secret: Uint8List.fromList(
        crypto.Hmac(
          crypto.sha256,
          root.bytes,
        ).convert(utf8.encode('encryption')).bytes,
      ),
    );
  }

  @override
  Future<BitnamesStorageIdentity?> current() async {
    final wallet = walletReader.activeWallet;
    if (!walletReader.isWalletUnlocked || wallet == null) {
      return null;
    }
    try {
      return derive(
        masterMnemonic: wallet.master.mnemonic,
        walletBinding: wallet.l1.mnemonic,
      );
    } on BitnamesStorageException {
      return null;
    }
  }

  @override
  void addListener(VoidCallback listener) => walletReader.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => walletReader.removeListener(listener);
}

class FixedBitnamesStorageKeySource extends ChangeNotifier implements BitnamesStorageKeySource {
  FixedBitnamesStorageKeySource({
    String scope = 'test-wallet',
    String secret = 'test-only-bitnames-storage-secret',
  }) : _identity = BitnamesStorageIdentity(
         scope: crypto.sha256.convert(utf8.encode(scope)).toString(),
         secret: Uint8List.fromList(crypto.sha256.convert(utf8.encode(secret)).bytes),
       );

  BitnamesStorageIdentity? _identity;

  @override
  Future<BitnamesStorageIdentity?> current() async => _identity;

  void lock() {
    _identity = null;
    notifyListeners();
  }

  void unlock({required String scope, required String secret}) {
    _identity = BitnamesStorageIdentity(
      scope: crypto.sha256.convert(utf8.encode(scope)).toString(),
      secret: Uint8List.fromList(crypto.sha256.convert(utf8.encode(secret)).bytes),
    );
    notifyListeners();
  }
}

class BitnamesSecureStore {
  BitnamesSecureStore({
    required this.store,
    required this.keySource,
    DateTime Function()? now,
    Uint8List Function(int)? randomBytes,
  }) : _now = now ?? DateTime.now,
       _randomBytes = randomBytes ?? _secureRandomBytes;

  static const format = 'bitnames-private-store';
  static const schema = 2;
  static const legacyStateKey = 'bitintroduction_state_v1';
  static const legacyContactsKey = 'chat_contacts';
  static const legacyOwnedKey = 'owned_bitname_hashes';

  final KeyValueStore store;
  final BitnamesStorageKeySource keySource;
  final DateTime Function() _now;
  final Uint8List Function(int) _randomBytes;
  final Lock _lock = Lock();

  BitnamesStorageStatus status = const BitnamesStorageStatus(
    BitnamesStorageState.locked,
  );
  String? _activeScope;
  String? _activeSlot;
  int _generation = 0;
  bool _migratedThisSession = false;
  bool _recoveredThisSession = false;

  Future<Map<String, dynamic>> load() => _lock.synchronized(
    () => _translate(
      _load,
      'Private BitNames storage could not be read safely',
    ),
  );

  Future<void> save(Map<String, dynamic> state) => _lock.synchronized(
    () => _translate(
      () => _save(state),
      'The encrypted write did not complete; reload to recover an authenticated generation',
    ),
  );

  Future<String> exportEncrypted() => _lock.synchronized(
    () => _translate(() async {
      final identity = await _identity();
      await _loadSecure(identity, allowEmpty: false);
      final prefix = _prefix(identity.scope);
      final head = await store.getString('${prefix}head');
      final a = await store.getString('${prefix}a');
      final b = await store.getString('${prefix}b');
      if (head == null || (a == null && b == null)) {
        throw const BitnamesStorageException('No encrypted BitNames data is available to export');
      }
      return jsonEncode({
        'format': '$format-backup',
        'schema': schema,
        'scope': identity.scope,
        'exported_at': _now().toUtc().toIso8601String(),
        'head': head,
        if (a != null) 'a': a,
        if (b != null) 'b': b,
      });
    }, 'The encrypted BitNames backup could not be created'),
  );

  Future<void> restoreEncrypted(
    String encoded, {
    bool allowRollback = false,
  }) => _lock.synchronized(
    () => _translate(() async {
      final identity = await _identity();
      late Map<String, dynamic> backup;
      try {
        backup = Map<String, dynamic>.from(jsonDecode(encoded) as Map);
      } catch (_) {
        throw const BitnamesStorageException('The BitNames backup is malformed');
      }
      if (backup['format'] != '$format-backup' || backup['schema'] != schema || backup['scope'] != identity.scope) {
        throw const BitnamesStorageException(
          'The BitNames backup belongs to another wallet or storage version',
        );
      }
      final candidates = <_DecodedSlot>[];
      for (final slot in const ['a', 'b']) {
        final raw = backup[slot];
        if (raw is String) {
          try {
            candidates.add(_decryptSlot(raw, slot, identity));
          } on BitnamesStorageException {
            // A backup retains two generations. One valid authenticated slot
            // is sufficient; a corrupt companion is never loaded.
          }
        }
      }
      if (candidates.isEmpty) {
        throw const BitnamesStorageException('The BitNames backup contains no valid encrypted state');
      }
      candidates.sort((a, b) => b.generation.compareTo(a.generation));
      final restored = candidates.first;
      final current = await _loadSecure(identity, allowEmpty: true);
      if (!allowRollback && current != null && restored.generation < current.generation) {
        throw const BitnamesStorageException(
          'The BitNames backup is older than the current encrypted history',
        );
      }
      await _save(
        restored.state,
        minimumGeneration: restored.generation,
      );
    }, 'The encrypted BitNames backup could not be restored'),
  );

  Future<void> clear() => _lock.synchronized(
    () => _translate(() async {
      final identity = await _identity();
      final prefix = _prefix(identity.scope);
      for (final key in [
        '${prefix}head',
        '${prefix}a',
        '${prefix}b',
        legacyStateKey,
        legacyContactsKey,
        legacyOwnedKey,
      ]) {
        await store.delete(key);
      }
      await _scrubRecoveryCopy('${prefix}cleared');
      _activeSlot = null;
      _activeScope = identity.scope;
      _generation = 0;
      _migratedThisSession = false;
      _recoveredThisSession = false;
      status = const BitnamesStorageStatus(BitnamesStorageState.empty);
    }, 'Private BitNames data could not be cleared safely'),
  );

  List<Map<String, dynamic>> pageMessages(
    Map<String, dynamic> state, {
    required String localBitname,
    required String remoteBitname,
    int limit = 50,
    int? beforeTimestamp,
  }) {
    if (limit < 1 || limit > 500) {
      throw const BitnamesStorageException('Message page size must be between 1 and 500');
    }
    final normalized = _normalizeState(state);
    final records = {
      for (final message in _maps(normalized['messages'])) _messageKey(message): message,
    };
    final indexes = Map<String, dynamic>.from(normalized['_indexes'] as Map);
    final conversations = Map<String, dynamic>.from(indexes['conversations'] as Map);
    final keys = (conversations[_canonicalJson([localBitname, remoteBitname])] as List? ?? []).whereType<String>();
    final messages =
        keys.map((key) => records[key]).whereType<Map<String, dynamic>>().where((message) {
          final timestamp = message['timestamp'];
          return timestamp is int && (beforeTimestamp == null || timestamp < beforeTimestamp);
        }).toList()..sort(
          (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int),
        );
    return messages.take(limit).toList().reversed.toList();
  }

  Future<Map<String, dynamic>> _load() async {
    final identity = await keySource.current();
    if (identity == null) {
      status = const BitnamesStorageStatus(
        BitnamesStorageState.locked,
        details: 'Unlock the active BitWindow wallet to decrypt chat data',
      );
      _forgetActive();
      return {};
    }
    try {
      final secure = await _loadSecure(identity, allowEmpty: true);
      if (secure != null) {
        await _deleteLegacy();
        return secure.state;
      }
      final legacy = await _readLegacy();
      if (legacy == null) {
        status = const BitnamesStorageStatus(BitnamesStorageState.empty);
        return {};
      }
      await _save(legacy);
      await _deleteLegacy();
      _migratedThisSession = true;
      status = BitnamesStorageStatus(
        BitnamesStorageState.migrated,
        generation: _generation,
        details: 'Plaintext BitNames settings were moved into authenticated encryption',
      );
      return legacy;
    } on BitnamesStorageException catch (error) {
      status = BitnamesStorageStatus(
        BitnamesStorageState.corrupt,
        generation: _generation == 0 ? null : _generation,
        details: error.message,
      );
      _forgetActive();
      rethrow;
    }
  }

  Future<T> _translate<T>(
    Future<T> Function() action,
    String safeFailure,
  ) async {
    try {
      return await action();
    } on BitnamesStorageException {
      rethrow;
    } catch (_) {
      status = BitnamesStorageStatus(
        BitnamesStorageState.corrupt,
        generation: _generation == 0 ? null : _generation,
        details: safeFailure,
      );
      throw BitnamesStorageException(safeFailure);
    }
  }

  Future<void> _save(
    Map<String, dynamic> state, {
    int? minimumGeneration,
  }) async {
    final identity = await _identity();
    if (_activeScope != null && _activeScope != identity.scope) {
      throw const BitnamesStorageException(
        'The active wallet changed before the encrypted transaction committed',
      );
    }
    final current = await _loadSecure(identity, allowEmpty: true);
    final normalized = _normalizeState(state);
    final generation = max(
      (current?.generation ?? 0) + 1,
      minimumGeneration ?? 1,
    );
    final slot = (current?.slot ?? _activeSlot) == 'a' ? 'b' : 'a';
    final raw = _encryptSlot(normalized, slot, generation, identity);
    final prefix = _prefix(identity.scope);
    await store.setString('$prefix$slot', raw);
    final verified = _decryptSlot(
      (await store.getString('$prefix$slot')) ??
          (throw const BitnamesStorageException('Encrypted write was not persisted')),
      slot,
      identity,
    );
    if (verified.generation != generation) {
      throw const BitnamesStorageException('Encrypted write verification failed');
    }
    await store.setString(
      '${prefix}head',
      jsonEncode({
        'format': format,
        'schema': schema,
        'scope': identity.scope,
        'slot': slot,
        'generation': generation,
      }),
    );
    _activeSlot = slot;
    _activeScope = identity.scope;
    _generation = generation;
    status = BitnamesStorageStatus(
      _recoveredThisSession
          ? BitnamesStorageState.recovered
          : _migratedThisSession
          ? BitnamesStorageState.migrated
          : BitnamesStorageState.ready,
      generation: generation,
      details: _recoveredThisSession
          ? 'A complete authenticated generation was selected; incomplete or corrupt data was not loaded'
          : _migratedThisSession
          ? 'Plaintext BitNames settings were moved into authenticated encryption'
          : null,
    );
  }

  Future<_DecodedSlot?> _loadSecure(
    BitnamesStorageIdentity identity, {
    required bool allowEmpty,
  }) async {
    if (_activeScope != null && _activeScope != identity.scope) {
      _migratedThisSession = false;
      _recoveredThisSession = false;
    }
    final prefix = _prefix(identity.scope);
    final rawHead = await store.getString('${prefix}head');
    final rawA = await store.getString('${prefix}a');
    final rawB = await store.getString('${prefix}b');
    if (rawHead == null && rawA == null && rawB == null) {
      if (!allowEmpty) {
        throw const BitnamesStorageException('No encrypted BitNames state exists');
      }
      _activeSlot = null;
      _activeScope = identity.scope;
      _generation = 0;
      return null;
    }

    final valid = <_DecodedSlot>[];
    final failures = <String>[];
    for (final candidate in [('a', rawA), ('b', rawB)]) {
      if (candidate.$2 == null) continue;
      try {
        valid.add(_decryptSlot(candidate.$2!, candidate.$1, identity));
      } on BitnamesStorageException catch (error) {
        failures.add('${candidate.$1}: ${error.message}');
      }
    }
    if (valid.isEmpty) {
      throw BitnamesStorageException(
        'Encrypted BitNames state could not be authenticated'
        '${failures.isEmpty ? '' : ' (${failures.join('; ')})'}',
      );
    }
    valid.sort((a, b) => b.generation.compareTo(a.generation));
    final selected = valid.first;
    var recovered = failures.isNotEmpty;
    try {
      final head = Map<String, dynamic>.from(jsonDecode(rawHead!) as Map);
      recovered =
          recovered ||
          head['format'] != format ||
          head['schema'] != schema ||
          head['scope'] != identity.scope ||
          head['slot'] != selected.slot ||
          head['generation'] != selected.generation;
    } catch (_) {
      recovered = true;
    }
    if (recovered) {
      _recoveredThisSession = true;
      await store.setString(
        '${prefix}head',
        jsonEncode({
          'format': format,
          'schema': schema,
          'scope': identity.scope,
          'slot': selected.slot,
          'generation': selected.generation,
        }),
      );
    }
    _activeSlot = selected.slot;
    _activeScope = identity.scope;
    _generation = selected.generation;
    status = BitnamesStorageStatus(
      _recoveredThisSession ? BitnamesStorageState.recovered : BitnamesStorageState.ready,
      generation: selected.generation,
      details: _recoveredThisSession
          ? 'A complete authenticated generation was selected; incomplete or corrupt data was not loaded'
          : null,
    );
    return selected;
  }

  String _encryptSlot(
    Map<String, dynamic> state,
    String slot,
    int generation,
    BitnamesStorageIdentity identity,
  ) {
    final nonce = _randomBytes(12);
    final header = _header(slot, generation, identity.scope);
    final plaintext = utf8.encode(
      jsonEncode({
        ...header,
        'saved_at': _now().toUtc().toIso8601String(),
        'state': state,
      }),
    );
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(_deriveKey(identity)),
          128,
          nonce,
          Uint8List.fromList(utf8.encode(jsonEncode(header))),
        ),
      );
    final encrypted = cipher.process(Uint8List.fromList(plaintext));
    return jsonEncode({
      ...header,
      'nonce': base64Encode(nonce),
      'ciphertext': base64Encode(encrypted),
    });
  }

  _DecodedSlot _decryptSlot(
    String raw,
    String expectedSlot,
    BitnamesStorageIdentity identity,
  ) {
    try {
      final envelope = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final generation = envelope['generation'];
      final slot = envelope['slot'];
      if (envelope['format'] != format ||
          envelope['schema'] != schema ||
          envelope['scope'] != identity.scope ||
          slot != expectedSlot ||
          generation is! int ||
          generation < 1 ||
          envelope['nonce'] is! String ||
          envelope['ciphertext'] is! String) {
        throw const BitnamesStorageException('Encrypted slot metadata is invalid');
      }
      final nonce = base64Decode(envelope['nonce'] as String);
      if (nonce.length != 12) {
        throw const BitnamesStorageException('Encrypted slot nonce is invalid');
      }
      final header = _header(slot as String, generation, identity.scope);
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false,
          AEADParameters(
            KeyParameter(_deriveKey(identity)),
            128,
            nonce,
            Uint8List.fromList(utf8.encode(jsonEncode(header))),
          ),
        );
      final plaintext = cipher.process(
        Uint8List.fromList(base64Decode(envelope['ciphertext'] as String)),
      );
      final decoded = Map<String, dynamic>.from(
        jsonDecode(utf8.decode(plaintext)) as Map,
      );
      if (decoded['format'] != format ||
          decoded['schema'] != schema ||
          decoded['scope'] != identity.scope ||
          decoded['slot'] != slot ||
          decoded['generation'] != generation ||
          decoded['state'] is! Map) {
        throw const BitnamesStorageException('Encrypted slot contents are inconsistent');
      }
      return _DecodedSlot(
        slot,
        generation,
        _normalizeState(Map<String, dynamic>.from(decoded['state'] as Map)),
      );
    } on BitnamesStorageException {
      rethrow;
    } catch (_) {
      throw const BitnamesStorageException(
        'Encrypted slot is corrupt or the wallet key does not match',
      );
    }
  }

  Map<String, dynamic> _header(String slot, int generation, String scope) => {
    'format': format,
    'schema': schema,
    'scope': scope,
    'slot': slot,
    'generation': generation,
  };

  Uint8List _deriveKey(BitnamesStorageIdentity identity) {
    final salt = utf8.encode('BitWindow BitNames private storage v2');
    final extracted = crypto.Hmac(crypto.sha256, salt).convert(identity.secret).bytes;
    final info = utf8.encode('wallet:${identity.scope}\u0000aes-256-gcm\u0001');
    return Uint8List.fromList(
      crypto.Hmac(crypto.sha256, extracted).convert(info).bytes,
    );
  }

  Future<BitnamesStorageIdentity> _identity() async {
    final identity = await keySource.current();
    if (identity == null) {
      status = const BitnamesStorageStatus(
        BitnamesStorageState.locked,
        details: 'Unlock the active BitWindow wallet to decrypt chat data',
      );
      _forgetActive();
      throw const BitnamesStorageException(
        'Unlock the active BitWindow wallet before using BitNames chat',
      );
    }
    return identity;
  }

  Future<Map<String, dynamic>?> _readLegacy() async {
    final rawState = await store.getString(legacyStateKey);
    final rawContacts = await store.getString(legacyContactsKey);
    final rawOwned = await store.getString(legacyOwnedKey);
    if (rawState == null && rawContacts == null && rawOwned == null) return null;
    try {
      final state = rawState == null ? <String, dynamic>{} : Map<String, dynamic>.from(jsonDecode(rawState) as Map);
      if ((state['contacts'] as List?)?.isNotEmpty != true && rawContacts != null) {
        state['contacts'] = List<dynamic>.from(jsonDecode(rawContacts) as List);
      }
      if ((state['owned'] as List?)?.isNotEmpty != true && rawOwned != null) {
        state['owned'] = List<dynamic>.from(jsonDecode(rawOwned) as List);
      }
      return _normalizeState(state);
    } catch (_) {
      throw const BitnamesStorageException(
        'Existing plaintext BitNames data is malformed; it was left untouched',
      );
    }
  }

  Future<void> _deleteLegacy() async {
    await store.delete(legacyStateKey);
    await store.delete(legacyContactsKey);
    await store.delete(legacyOwnedKey);
    await _scrubRecoveryCopy('bitintroduction_legacy_scrub_v2');
  }

  Future<void> _scrubRecoveryCopy(String marker) async {
    // FileStorage keeps one complete prior generation for crash recovery.
    // Rotate a non-secret tombstone through it so deleted plaintext/ciphertext
    // is not left in that logical recovery copy.
    await store.setString(marker, 'cleared');
    await store.delete(marker);
  }

  Map<String, dynamic> _normalizeState(Map<String, dynamic> input) {
    late Map<String, dynamic> state;
    try {
      state = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(input)) as Map,
      );
    } catch (_) {
      throw const BitnamesStorageException('BitNames state is not valid JSON data');
    }
    _deduplicate(state, 'contacts', (entry) => '${entry['local_bitname'] ?? ''}:${entry['id'] ?? ''}');
    _deduplicate(state, 'messages', (entry) {
      return _messageKey(entry);
    });
    _deduplicate(state, 'operations', (entry) => '${entry['id'] ?? ''}');
    _rebuildIndexes(state);
    return state;
  }

  void _rebuildIndexes(Map<String, dynamic> state) {
    final contacts = _maps(state['contacts']);
    final operations = _maps(state['operations']);
    final conversations = <String, List<String>>{};
    for (final message in _maps(state['messages'])) {
      final outgoing = message['is_outgoing'] == true;
      final local = outgoing ? message['sender_bitname'] : message['recipient_bitname'];
      final remote = outgoing ? message['recipient_bitname'] : message['sender_bitname'];
      if (local is! String || remote is! String) continue;
      conversations.putIfAbsent(_canonicalJson([local, remote]), () => []).add(_messageKey(message));
    }
    state['_indexes'] = {
      'contacts': {
        for (var index = 0; index < contacts.length; index++)
          '${contacts[index]['local_bitname'] ?? ''}:${contacts[index]['id'] ?? ''}': index,
      },
      'operations': {
        for (var index = 0; index < operations.length; index++) '${operations[index]['id'] ?? ''}': index,
      },
      'conversations': conversations,
    };
  }

  void _deduplicate(
    Map<String, dynamic> state,
    String field,
    String Function(Map<String, dynamic>) keyOf,
  ) {
    final raw = state[field];
    if (raw == null) return;
    if (raw is! List) {
      throw BitnamesStorageException('BitNames $field index is malformed');
    }
    final seen = <String, String>{};
    final clean = <Map<String, dynamic>>[];
    for (final value in raw) {
      if (value is! Map) {
        throw BitnamesStorageException('BitNames $field record is malformed');
      }
      final record = Map<String, dynamic>.from(value);
      final key = keyOf(record);
      if (key.isEmpty || key.endsWith(':')) {
        throw BitnamesStorageException('BitNames $field record has no stable identity');
      }
      final canonical = _canonicalJson(record);
      final prior = seen[key];
      if (prior != null && prior != canonical) {
        throw BitnamesStorageException(
          'BitNames $field contains conflicting record $key',
        );
      }
      if (prior == null) {
        seen[key] = canonical;
        clean.add(record);
      }
    }
    state[field] = clean;
  }

  String _prefix(String scope) => 'bitintroduction_secure_v2_${scope}_';

  void _forgetActive() {
    _activeScope = null;
    _activeSlot = null;
    _generation = 0;
    _migratedThisSession = false;
    _recoveredThisSession = false;
  }

  static Uint8List _secureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}

class _DecodedSlot {
  const _DecodedSlot(this.slot, this.generation, this.state);
  final String slot;
  final int generation;
  final Map<String, dynamic> state;
}

List<Map<String, dynamic>> _maps(Object? value) =>
    (value as List? ?? []).map((entry) => Map<String, dynamic>.from(entry as Map)).toList();

String _messageKey(Map<String, dynamic> message) {
  final local = message['is_outgoing'] == true ? message['sender_bitname'] : message['recipient_bitname'];
  return '$local:${message['id'] ?? ''}';
}

String _normalizeWords(String value) => value.trim().toLowerCase().split(RegExp(r'\s+')).join(' ');

String _canonicalJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return '{${keys.map((key) => '${jsonEncode(key)}:${_canonicalJson(value[key])}').join(',')}}';
  }
  if (value is List) {
    return '[${value.map(_canonicalJson).join(',')}]';
  }
  return jsonEncode(value);
}
