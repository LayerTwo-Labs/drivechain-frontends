//
//  Generated code. Do not modify.
//  source: explorer/v1/explorer.proto
//

import "package:connectrpc/connect.dart" as connect;
import "explorer.pb.dart" as explorerv1explorer;

abstract final class ExplorerService {
  /// Fully-qualified name of the ExplorerService service.
  static const name = 'explorer.v1.ExplorerService';

  static const getChainTips = connect.Spec(
    '/$name/GetChainTips',
    connect.StreamType.unary,
    explorerv1explorer.GetChainTipsRequest.new,
    explorerv1explorer.GetChainTipsResponse.new,
  );
}
