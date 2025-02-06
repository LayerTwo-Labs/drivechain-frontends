//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart' as bitcoindv1bitcoind;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;

abstract final class BitcoindService {
  /// Fully-qualified name of the BitcoindService service.
  static const name = 'bitcoind.v1.BitcoindService';

  /// Lists the ten most recent transactions, both confirmed and unconfirmed.
  static const listRecentTransactions = connect.Spec(
    '/$name/ListRecentTransactions',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ListRecentTransactionsRequest.new,
    bitcoindv1bitcoind.ListRecentTransactionsResponse.new,
  );

  /// Lists the ten most recent blocks, lightly populated with data.
  static const listRecentBlocks = connect.Spec(
    '/$name/ListRecentBlocks',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ListRecentBlocksRequest.new,
    bitcoindv1bitcoind.ListRecentBlocksResponse.new,
  );

  /// Get basic blockchain info like height, last block time, peers etc.
  static const getBlockchainInfo = connect.Spec(
    '/$name/GetBlockchainInfo',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitcoindv1bitcoind.GetBlockchainInfoResponse.new,
  );

  /// Lists very basic info about all peers
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitcoindv1bitcoind.ListPeersResponse.new,
  );

  /// Lists very basic info about all peers
  static const estimateSmartFee = connect.Spec(
    '/$name/EstimateSmartFee',
    connect.StreamType.unary,
    bitcoindv1bitcoind.EstimateSmartFeeRequest.new,
    bitcoindv1bitcoind.EstimateSmartFeeResponse.new,
  );
}
