//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
//

import "package:connectrpc/connect.dart" as connect;
import "explorer.pb.dart" as explorerv1explorer;
import "explorer.connect.spec.dart" as specs;

extension type ExplorerServiceClient (connect.Transport _transport) {
  Future<explorerv1explorer.GetChainTipsResponse> getChainTips(
    explorerv1explorer.GetChainTipsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ExplorerService.getChainTips,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
