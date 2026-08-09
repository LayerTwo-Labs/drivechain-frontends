//
//  Generated code. Do not modify.
//  source: cusf/sidechain/v1/sidechain.proto
//

import "package:connectrpc/connect.dart" as connect;
import "sidechain.pb.dart" as cusfsidechainv1sidechain;

abstract final class SidechainService {
  /// Fully-qualified name of the SidechainService service.
  static const name = 'cusf.sidechain.v1.SidechainService';

  static const getMempoolTxs = connect.Spec(
    '/$name/GetMempoolTxs',
    connect.StreamType.unary,
    cusfsidechainv1sidechain.GetMempoolTxsRequest.new,
    cusfsidechainv1sidechain.GetMempoolTxsResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const getUtxos = connect.Spec(
    '/$name/GetUtxos',
    connect.StreamType.unary,
    cusfsidechainv1sidechain.GetUtxosRequest.new,
    cusfsidechainv1sidechain.GetUtxosResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );

  static const submitTransaction = connect.Spec(
    '/$name/SubmitTransaction',
    connect.StreamType.unary,
    cusfsidechainv1sidechain.SubmitTransactionRequest.new,
    cusfsidechainv1sidechain.SubmitTransactionResponse.new,
    idempotency: connect.Idempotency.idempotent,
  );

  static const subscribeEvents = connect.Spec(
    '/$name/SubscribeEvents',
    connect.StreamType.server,
    cusfsidechainv1sidechain.SubscribeEventsRequest.new,
    cusfsidechainv1sidechain.SubscribeEventsResponse.new,
    idempotency: connect.Idempotency.noSideEffects,
  );
}
