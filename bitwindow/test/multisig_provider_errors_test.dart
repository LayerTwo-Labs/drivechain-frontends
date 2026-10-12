import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:connectrpc/connect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/multisig/v1/multisig.pb.dart' as multisigpb;
import 'package:sidechain_core/gen/multisiglounge/v1/multisiglounge.pb.dart' as mlpb;

import 'mocks/api_mock.dart';

const _txId = 'tx-1';
const _ownKey = 'xpub-own';

class _FakeMultisigAPI extends MockMultisigAPI {
  Object? getError;
  Object? saveGroupError;
  int saveTransactionCalls = 0;

  @override
  Future<List<multisigpb.MultisigGroup>> listGroups() async {
    return [
      multisigpb.MultisigGroup(
        id: 'g1',
        name: 'group',
        n: 2,
        m: 2,
        keys: [
          multisigpb.MultisigKey(owner: 'me', xpub: _ownKey, isWallet: true),
          multisigpb.MultisigKey(owner: 'them', xpub: 'xpub-other'),
        ],
        transactionIds: [_txId],
      ),
    ];
  }

  @override
  Future<multisigpb.MultisigGroup> saveGroup(multisigpb.MultisigGroup group) async {
    if (saveGroupError != null) {
      throw saveGroupError!;
    }
    return group;
  }

  @override
  Future<multisigpb.MultisigTransaction> getTransaction(String transactionId) async {
    if (getError != null) {
      throw getError!;
    }
    return multisigpb.MultisigTransaction(
      id: _txId,
      groupId: 'g1',
      initialPsbt: 'initial',
      requiredSignatures: 2,
      keyPsbts: [
        multisigpb.KeyPSBTStatus(keyId: _ownKey),
        multisigpb.KeyPSBTStatus(keyId: 'xpub-other'),
      ],
    );
  }

  @override
  Future<multisigpb.MultisigTransaction> getTransactionByTxid(String txid) async {
    if (getError != null) {
      throw getError!;
    }
    return multisigpb.MultisigTransaction();
  }

  @override
  Future<multisigpb.MultisigTransaction> saveTransaction(multisigpb.MultisigTransaction transaction) async {
    saveTransactionCalls++;
    return transaction;
  }
}

class _FakeLounge implements OrchestratorMultisigLoungeRPC {
  Object? error;
  mlpb.ValidatePsbtResponse response = mlpb.ValidatePsbtResponse(hasSignatures: true, signatureCount: 1);

  @override
  Future<mlpb.ValidatePsbtResponse> validatePsbt({
    required String psbtBase64,
    required int requiredSigs,
    mlpb.MultisigGroup? group,
  }) async {
    if (error != null) {
      throw error!;
    }
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.multisigLounge);

  @override
  final OrchestratorMultisigLoungeRPC multisigLounge;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBitwindow implements BitwindowRPC {
  _FakeBitwindow(this.multisig);

  @override
  final MultisigAPI multisig;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeMultisigAPI api;
  late _FakeLounge lounge;

  setUp(() async {
    await GetIt.I.reset();
    api = _FakeMultisigAPI();
    lounge = _FakeLounge();
    GetIt.I.registerSingleton<BitwindowRPC>(_FakeBitwindow(api));
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(lounge));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('updateKeyPSBT throws and saves nothing when validatePsbt fails', () async {
    lounge.error = ConnectException(Code.unavailable, 'orchestrator down');

    await expectLater(TransactionStorage.updateKeyPSBT(_txId, _ownKey, 'signed'), throwsA(isA<ConnectException>()));
    expect(api.saveTransactionCalls, 0);
  });

  test('hasAnySignatures throws when validatePsbt returns an error text', () async {
    lounge.response = mlpb.ValidatePsbtResponse(error: 'bad psbt');

    await expectLater(PSBTValidator.hasAnySignatures('psbt', 2), throwsA(isA<Exception>()));
  });

  test('getTransaction returns null only for not found', () async {
    api.getError = ConnectException(Code.notFound, 'transaction not found');
    expect(await TransactionStorage.getTransaction(_txId), isNull);
    expect(await TransactionStorage.getTransactionByTxid('txid'), isNull);

    api.getError = MultisigException('could not get transaction: db locked');
    await expectLater(TransactionStorage.getTransaction(_txId), throwsA(isA<MultisigException>()));
    await expectLater(TransactionStorage.getTransactionByTxid('txid'), throwsA(isA<MultisigException>()));
  });

  test('updateKeyPSBT throws when the owned key PSBT is not stored in the group', () async {
    api.saveGroupError = MultisigException('could not save group');

    await expectLater(
      TransactionStorage.updateKeyPSBT(_txId, _ownKey, 'signed', isOwnedKey: true),
      throwsA(isA<MultisigException>()),
    );
  });
}
