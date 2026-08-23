//
//  Generated code. Do not modify.
//  source: multisiglounge/v1/multisiglounge.proto
//

import "package:connectrpc/connect.dart" as connect;
import "multisiglounge.pb.dart" as multisigloungev1multisiglounge;
import "multisiglounge.connect.spec.dart" as specs;

/// MultisigLoungeService builds watch-only multisig descriptors and validates
/// PSBTs for the BitWindow multisig lounge. Pure stateless logic — no wallet,
/// no signing, no broadcast.
extension type MultisigLoungeServiceClient (connect.Transport _transport) {
  /// BuildDescriptors builds the receive (/0/*) and change (/1/*) watch-only
  /// wsh(sortedmulti) descriptors for a multisig group, with checksums.
  Future<multisigloungev1multisiglounge.BuildDescriptorsResponse> buildDescriptors(
    multisigloungev1multisiglounge.BuildDescriptorsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.buildDescriptors,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ValidatePsbt parses a base64 PSBT and reports signature progress. When a
  /// group is supplied, inputs whose script does not belong to the group's
  /// descriptor are rejected.
  Future<multisigloungev1multisiglounge.ValidatePsbtResponse> validatePsbt(
    multisigloungev1multisiglounge.ValidatePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.validatePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PublishGroup encodes a multisig group as an OP_RETURN payload (the
  /// BitWindow wire format) and broadcasts it, funding a fresh own address.
  /// Returns the broadcast txid.
  Future<multisigloungev1multisiglounge.PublishGroupResponse> publishGroup(
    multisigloungev1multisiglounge.PublishGroupRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.publishGroup,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ImportGroupFromTxid fetches the OP_RETURN at the given txid, decodes the
  /// multisig group, and reports which of the group's keys belong to the wallet.
  Future<multisigloungev1multisiglounge.ImportGroupFromTxidResponse> importGroupFromTxid(
    multisigloungev1multisiglounge.ImportGroupFromTxidRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.importGroupFromTxid,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SignTransaction adds the wallet's signature(s) to a multisig PSBT,
  /// deriving the wallet's keys server-side from its seed. The PSBT must belong
  /// to the group (foreign inputs are rejected).
  Future<multisigloungev1multisiglounge.SignTransactionResponse> signTransaction(
    multisigloungev1multisiglounge.SignTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.signTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// CombineAndBroadcast merges partial PSBTs, finalizes, and broadcasts — but
  /// only if the combined PSBT reaches the threshold. A non-finalizable PSBT is
  /// never broadcast.
  Future<multisigloungev1multisiglounge.CombineAndBroadcastResponse> combineAndBroadcast(
    multisigloungev1multisiglounge.CombineAndBroadcastRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.combineAndBroadcast,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SyncGroup ensures the group's watch-only wallet exists (creating it from the
  /// Phase-1 descriptors if missing) and returns its balance and UTXOs.
  Future<multisigloungev1multisiglounge.SyncGroupResponse> syncGroup(
    multisigloungev1multisiglounge.SyncGroupRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.syncGroup,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// RestoreHistory scans the watch-only wallet's transactions and reconstructs
  /// the group's spend/receive records with per-tx signature counts and status.
  Future<multisigloungev1multisiglounge.RestoreHistoryResponse> restoreHistory(
    multisigloungev1multisiglounge.RestoreHistoryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.restoreHistory,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// CreateSpendPsbt builds an unsigned funded PSBT spending from the group's
  /// watch-only wallet to the given destinations (ensuring the wallet exists).
  Future<multisigloungev1multisiglounge.CreateSpendPsbtResponse> createSpendPsbt(
    multisigloungev1multisiglounge.CreateSpendPsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MultisigLoungeService.createSpendPsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
