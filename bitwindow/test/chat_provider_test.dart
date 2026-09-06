import 'package:bitwindow/models/chat_models.dart';
import 'package:bitwindow/providers/chat_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';

import 'mocks/store_mock.dart';

const _recipientHash = 'aaaabbbbccccdddd';

/// A chain UTXO holding a BitName, as list_utxos returns it.
BitnamesUTXO bitnameUTXO(String hash, String address) => BitnamesUTXO.fromJson({
  'outpoint': {
    'Regular': {'txid': 'deadbeef', 'vout': 0},
  },
  'output': {
    'address': address,
    'content': {'BitName': hash},
  },
});

class _FakeBitnames extends MockBitnamesRPC {
  List<SidechainUTXO> chainUTXOs = [];
  final List<String> transferDests = [];
  int newAddressCalls = 0;

  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async => chainUTXOs;

  @override
  Future<String> getNewAddress() async {
    newAddressCalls++;
    return super.getNewAddress();
  }

  @override
  Future<String> transfer({
    required String dest,
    required int value,
    required int fee,
    String? memo,
  }) async {
    transferDests.add(dest);
    return 'txid_transfer';
  }
}

class _FakeBalance extends ChangeNotifier implements BalanceProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeBitnames bitnames;
  late ChatProvider provider;

  BitnameEntry entry(String hash) => BitnameEntry(
    hash: hash,
    details: BitnameDetails(seqId: '0', encryptionPubkey: 'pubkey_$hash'),
  );

  ChatContact contact({String? address}) => ChatContact(
    id: _recipientHash,
    name: _recipientHash,
    encryptionPubkey: 'pubkey_$_recipientHash',
    address: address,
  );

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    bitnames = _FakeBitnames();
    GetIt.I.registerSingleton<BitnamesRPC>(bitnames);
    GetIt.I.registerSingleton<BalanceProvider>(_FakeBalance());
    provider = ChatProvider();
    provider.selectIdentity(entry('my_own_identity'));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('sends to the address that holds the recipient BitName', () async {
    bitnames.chainUTXOs = [bitnameUTXO(_recipientHash, 'recipient_address')];
    provider.selectContact(contact());

    final txid = await provider.sendMessage('hello');

    expect(txid, 'txid_transfer');
    expect(bitnames.transferDests, ['recipient_address']);
    expect(bitnames.newAddressCalls, 0, reason: 'our own wallet never supplies the destination');
  });

  // The BitName UTXO moves every time its owner updates it, so a cached
  // address goes stale.
  test('re-resolves the destination instead of reusing the stored address', () async {
    bitnames.chainUTXOs = [bitnameUTXO(_recipientHash, 'moved_to_address')];
    provider.selectContact(contact(address: 'stale_address'));

    await provider.sendMessage('hello');

    expect(bitnames.transferDests, ['moved_to_address']);
  });

  // Paying an address we cannot resolve means paying ourselves.
  test('refuses to send when the recipient address cannot be resolved', () async {
    bitnames.chainUTXOs = [];
    provider.selectContact(contact(address: 'stale_address'));

    final txid = await provider.sendMessage('hello');

    expect(txid, isNull);
    expect(bitnames.transferDests, isEmpty);
    expect(provider.error, contains('cannot send'));
    expect(provider.messages, isEmpty);
  });

  test('stores the owner address of a contact added from a BitName', () async {
    bitnames.chainUTXOs = [bitnameUTXO(_recipientHash, 'recipient_address')];

    await provider.addContactFromEntry(entry(_recipientHash));

    expect(provider.contacts.single.address, 'recipient_address');
    expect(bitnames.newAddressCalls, 0);
  });

  test('leaves the address unset when the BitName is not on chain', () async {
    bitnames.chainUTXOs = [bitnameUTXO('some_other_bitname', 'someone_elses_address')];

    await provider.addContactFromEntry(entry(_recipientHash));

    expect(provider.contacts.single.address, isNull);
  });
}
