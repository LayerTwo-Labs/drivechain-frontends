//
//  Generated code. Do not modify.
//  source: multisiglounge/v1/multisiglounge.proto
//

import "package:connectrpc/connect.dart" as connect;
import "multisiglounge.pb.dart" as multisigloungev1multisiglounge;

/// MultisigLoungeService builds watch-only multisig descriptors and validates
/// PSBTs for the BitWindow multisig lounge. Pure stateless logic — no wallet,
/// no signing, no broadcast.
abstract final class MultisigLoungeService {
  /// Fully-qualified name of the MultisigLoungeService service.
  static const name = 'multisiglounge.v1.MultisigLoungeService';

  /// BuildDescriptors builds the receive (/0/*) and change (/1/*) watch-only
  /// wsh(sortedmulti) descriptors for a multisig group, with checksums.
  static const buildDescriptors = connect.Spec(
    '/$name/BuildDescriptors',
    connect.StreamType.unary,
    multisigloungev1multisiglounge.BuildDescriptorsRequest.new,
    multisigloungev1multisiglounge.BuildDescriptorsResponse.new,
  );

  /// ValidatePsbt parses a base64 PSBT and reports signature progress. When a
  /// group is supplied, inputs whose script does not belong to the group's
  /// descriptor are rejected.
  static const validatePsbt = connect.Spec(
    '/$name/ValidatePsbt',
    connect.StreamType.unary,
    multisigloungev1multisiglounge.ValidatePsbtRequest.new,
    multisigloungev1multisiglounge.ValidatePsbtResponse.new,
  );

  /// PublishGroup encodes a multisig group as an OP_RETURN payload (the
  /// BitWindow wire format) and broadcasts it, funding a fresh own address.
  /// Returns the broadcast txid.
  static const publishGroup = connect.Spec(
    '/$name/PublishGroup',
    connect.StreamType.unary,
    multisigloungev1multisiglounge.PublishGroupRequest.new,
    multisigloungev1multisiglounge.PublishGroupResponse.new,
  );

  /// ImportGroupFromTxid fetches the OP_RETURN at the given txid, decodes the
  /// multisig group, and reports which of the group's keys belong to the wallet.
  static const importGroupFromTxid = connect.Spec(
    '/$name/ImportGroupFromTxid',
    connect.StreamType.unary,
    multisigloungev1multisiglounge.ImportGroupFromTxidRequest.new,
    multisigloungev1multisiglounge.ImportGroupFromTxidResponse.new,
  );

  /// SignTransaction adds the wallet's signature(s) to a multisig PSBT,
  /// deriving the wallet's keys server-side from its seed. The PSBT must belong
  /// to the group (foreign inputs are rejected).
  static const signTransaction = connect.Spec(
    '/$name/SignTransaction',
    connect.StreamType.unary,
    multisigloungev1multisiglounge.SignTransactionRequest.new,
    multisigloungev1multisiglounge.SignTransactionResponse.new,
  );

  /// CombineAndBroadcast merges partial PSBTs, finalizes, and broadcasts — but
  /// only if the combined PSBT reaches the threshold. A non-finalizable PSBT is
  /// never broadcast.
  static const combineAndBroadcast = connect.Spec(
    '/$name/CombineAndBroadcast',
    connect.StreamType.unary,
    multisigloungev1multisiglounge.CombineAndBroadcastRequest.new,
    multisigloungev1multisiglounge.CombineAndBroadcastResponse.new,
  );

  /// SyncGroup ensures the group's watch-only wallet exists (creating it from the
  /// Phase-1 descriptors if missing) and returns its balance and UTXOs.
  static const syncGroup = connect.Spec(
    '/$name/SyncGroup',
    connect.StreamType.unary,
    multisigloungev1multisiglounge.SyncGroupRequest.new,
    multisigloungev1multisiglounge.SyncGroupResponse.new,
  );

  /// RestoreHistory scans the watch-only wallet's transactions and reconstructs
  /// the group's spend/receive records with per-tx signature counts and status.
  static const restoreHistory = connect.Spec(
    '/$name/RestoreHistory',
    connect.StreamType.unary,
    multisigloungev1multisiglounge.RestoreHistoryRequest.new,
    multisigloungev1multisiglounge.RestoreHistoryResponse.new,
  );
}
