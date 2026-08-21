//
//  Generated code. Do not modify.
//  source: walletpsbt/v1/walletpsbt.proto
//

import "package:connectrpc/connect.dart" as connect;
import "walletpsbt.pb.dart" as walletpsbtv1walletpsbt;
import "walletpsbt.connect.spec.dart" as specs;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

/// Persists in-progress multisig spends for the Send tab, so partial
/// signatures survive restarts. The PSBT blob itself carries the
/// signatures; signing state is derived from it, never stored.
extension type WalletPsbtServiceClient (connect.Transport _transport) {
  Future<walletpsbtv1walletpsbt.ListDraftsResponse> listDrafts(
    walletpsbtv1walletpsbt.ListDraftsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletPsbtService.listDrafts,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletpsbtv1walletpsbt.SaveDraftResponse> saveDraft(
    walletpsbtv1walletpsbt.SaveDraftRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletPsbtService.saveDraft,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<googleprotobufempty.Empty> deleteDraft(
    walletpsbtv1walletpsbt.DeleteDraftRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletPsbtService.deleteDraft,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
