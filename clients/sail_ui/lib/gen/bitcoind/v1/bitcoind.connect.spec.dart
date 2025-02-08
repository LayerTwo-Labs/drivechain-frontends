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

  /// Lists blocks with pagination support
  static const listBlocks = connect.Spec(
    '/$name/ListBlocks',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ListBlocksRequest.new,
    bitcoindv1bitcoind.ListBlocksResponse.new,
  );

  /// Get a specific block by hash or height
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    bitcoindv1bitcoind.GetBlockRequest.new,
    bitcoindv1bitcoind.GetBlockResponse.new,
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

  static const getRawTransaction = connect.Spec(
    '/$name/GetRawTransaction',
    connect.StreamType.unary,
    bitcoindv1bitcoind.GetRawTransactionRequest.new,
    bitcoindv1bitcoind.GetRawTransactionResponse.new,
  );
}
