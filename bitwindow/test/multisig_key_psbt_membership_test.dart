import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/multisig/v1/multisig.pb.dart' as multisigpb;
import 'package:sail_ui/gen/multisiglounge/v1/multisiglounge.pb.dart' as mlpb;
import 'package:sail_ui/sail_ui.dart';

const _txId = 'tx-a';
const _memberXpub = 'xpub-a3';
const _foreignXpub = 'xpub-b1';

multisigpb.MultisigKey _key(String xpub) => multisigpb.MultisigKey(xpub: xpub, isWallet: true);

class _FakeMultisigApi implements MultisigAPI {
  multisigpb.MultisigTransaction? saved;

  @override
  Future<List<multisigpb.MultisigGroup>> listGroups() async {
    return [
      // 2-of-3, so the threshold differs from the transaction's slot count.
      multisigpb.MultisigGroup(
        id: 'group-a',
        m: 2,
        n: 3,
        keys: [_key('xpub-a1'), _key('xpub-a2'), _key(_memberXpub)],
      ),
      multisigpb.MultisigGroup(id: 'group-b', m: 1, n: 1, keys: [_key(_foreignXpub)]),
    ];
  }

  @override
  Future<multisigpb.MultisigTransaction> getTransaction(String transactionId) async {
    return multisigpb.MultisigTransaction(
      id: transactionId,
      groupId: 'group-a',
      status: multisigpb.TxStatus.TX_STATUS_NEEDS_SIGNATURES,
      keyPsbts: [
        multisigpb.KeyPSBTStatus(keyId: 'xpub-a1', psbt: 'psbt1', isSigned: true),
        multisigpb.KeyPSBTStatus(keyId: 'xpub-a2', psbt: 'psbt2', isSigned: true),
        multisigpb.KeyPSBTStatus(keyId: _memberXpub, isSigned: false),
      ],
    );
  }

  @override
  Future<multisigpb.MultisigTransaction> saveTransaction(multisigpb.MultisigTransaction transaction) async {
    saved = transaction;
    return transaction;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBitwindow implements BitwindowRPC {
  @override
  final MultisigAPI multisig;

  _FakeBitwindow(this.multisig);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLounge implements OrchestratorMultisigLoungeRPC {
  @override
  Future<mlpb.ValidatePsbtResponse> validatePsbt({
    required String psbtBase64,
    required int requiredSigs,
    mlpb.MultisigGroup? group,
  }) async {
    return mlpb.ValidatePsbtResponse(hasSignatures: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  OrchestratorMultisigLoungeRPC multisigLounge = _FakeLounge();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeMultisigApi multisigApi;

  setUp(() async {
    await GetIt.I.reset();
    multisigApi = _FakeMultisigApi();
    GetIt.I.registerSingleton<BitwindowRPC>(_FakeBitwindow(multisigApi));
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test("a key outside the transaction's group cannot be given a PSBT slot", () async {
    await expectLater(
      TransactionStorage.addOrUpdateKeyPSBT(_txId, _foreignXpub, 'psbt', true),
      throwsA(isA<Exception>()),
    );
    expect(multisigApi.saved, isNull);
  });

  test("readiness is measured against the owning group's threshold", () async {
    await TransactionStorage.addOrUpdateKeyPSBT(_txId, _memberXpub, 'psbt', false);

    final saved = multisigApi.saved;
    expect(saved, isNotNull);
    expect(saved!.keyPsbts.length, 3);
    // 2 signatures on a 2-of-3 group, even though the transaction has 3 slots.
    expect(saved.status, multisigpb.TxStatus.TX_STATUS_READY_TO_COMBINE);
  });
}
