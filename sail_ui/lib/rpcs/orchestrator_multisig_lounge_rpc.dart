import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:sail_ui/gen/multisiglounge/v1/multisiglounge.connect.client.dart';
import 'package:sail_ui/gen/multisiglounge/v1/multisiglounge.pb.dart' as mlpb;

/// Wallet-multisig-lounge RPCs backed by orchestrator MultisigLoungeService:
/// watch-only descriptor building and PSBT validation. Pure stateless logic.
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
}
