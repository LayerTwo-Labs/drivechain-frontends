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
}
