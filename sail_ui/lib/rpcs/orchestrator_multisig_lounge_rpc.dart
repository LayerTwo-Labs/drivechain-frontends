import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:sail_ui/gen/multisiglounge/v1/multisiglounge.connect.client.dart';
import 'package:sail_ui/gen/multisiglounge/v1/multisiglounge.pb.dart' as mlpb;

/// Wallet-multisig-lounge RPCs backed by orchestrator MultisigLoungeService:
/// watch-only descriptor building, PSBT validation, and OP_RETURN group
/// publish/import.
class OrchestratorMultisigLoungeRPC {
  late MultisigLoungeServiceClient _client;

  OrchestratorMultisigLoungeRPC.fromTransport(connect.Transport unary) {
    _client = MultisigLoungeServiceClient(unary);
  }

  Future<mlpb.BuildDescriptorsResponse> buildDescriptors(mlpb.MultisigGroup group) {
    return _client.buildDescriptors(mlpb.BuildDescriptorsRequest(group: group));
  }

  Future<mlpb.ValidatePsbtResponse> validatePsbt({
    required String psbtBase64,
    required int requiredSigs,
    mlpb.MultisigGroup? group,
  }) {
    return _client.validatePsbt(
      mlpb.ValidatePsbtRequest(
        psbtBase64: psbtBase64,
        requiredSigs: requiredSigs,
        group: group,
      ),
    );
  }

  Future<mlpb.PublishGroupResponse> publishGroup({
    required mlpb.GroupData group,
    required String walletId,
  }) {
    return _client.publishGroup(mlpb.PublishGroupRequest(group: group, walletId: walletId));
  }

  Future<mlpb.ImportGroupFromTxidResponse> importGroupFromTxid({
    required String txid,
    required String walletId,
  }) {
    return _client.importGroupFromTxid(mlpb.ImportGroupFromTxidRequest(txid: txid, walletId: walletId));
  }

  Future<mlpb.SignTransactionResponse> signTransaction({
    required String psbtBase64,
    required mlpb.GroupData group,
    required String walletId,
  }) {
    return _client.signTransaction(
      mlpb.SignTransactionRequest(psbtBase64: psbtBase64, group: group, walletId: walletId),
    );
  }

  Future<mlpb.CombineAndBroadcastResponse> combineAndBroadcast({
    required List<String> psbts,
    required mlpb.GroupData group,
  }) {
    return _client.combineAndBroadcast(
      mlpb.CombineAndBroadcastRequest(psbts: psbts, group: group),
    );
  }
}
