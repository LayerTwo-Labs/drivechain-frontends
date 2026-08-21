//
//  Generated code. Do not modify.
//  source: walletpsbt/v1/walletpsbt.proto
//

import "package:connectrpc/connect.dart" as connect;
import "walletpsbt.pb.dart" as walletpsbtv1walletpsbt;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

/// Persists in-progress multisig spends for the Send tab, so partial
/// signatures survive restarts. The PSBT blob itself carries the
/// signatures; signing state is derived from it, never stored.
abstract final class WalletPsbtService {
  /// Fully-qualified name of the WalletPsbtService service.
  static const name = 'walletpsbt.v1.WalletPsbtService';

  static const listDrafts = connect.Spec(
    '/$name/ListDrafts',
    connect.StreamType.unary,
    walletpsbtv1walletpsbt.ListDraftsRequest.new,
    walletpsbtv1walletpsbt.ListDraftsResponse.new,
  );

  static const saveDraft = connect.Spec(
    '/$name/SaveDraft',
    connect.StreamType.unary,
    walletpsbtv1walletpsbt.SaveDraftRequest.new,
    walletpsbtv1walletpsbt.SaveDraftResponse.new,
  );

  static const deleteDraft = connect.Spec(
    '/$name/DeleteDraft',
    connect.StreamType.unary,
    walletpsbtv1walletpsbt.DeleteDraftRequest.new,
    googleprotobufempty.Empty.new,
  );
}
