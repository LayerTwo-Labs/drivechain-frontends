//
//  Generated code. Do not modify.
//  source: cusf/sidechain/v1/sidechain.proto
//

import "package:connectrpc/connect.dart" as connect;
import "sidechain.pb.dart" as cusfsidechainv1sidechain;
import "sidechain.connect.spec.dart" as specs;

extension type SidechainServiceClient (connect.Transport _transport) {
  Future<cusfsidechainv1sidechain.GetMempoolTxsResponse> getMempoolTxs(
    cusfsidechainv1sidechain.GetMempoolTxsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SidechainService.getMempoolTxs,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfsidechainv1sidechain.GetUtxosResponse> getUtxos(
    cusfsidechainv1sidechain.GetUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SidechainService.getUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfsidechainv1sidechain.SubmitTransactionResponse> submitTransaction(
    cusfsidechainv1sidechain.SubmitTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SidechainService.submitTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<cusfsidechainv1sidechain.SubscribeEventsResponse> subscribeEvents(
    cusfsidechainv1sidechain.SubscribeEventsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.SidechainService.subscribeEvents,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
