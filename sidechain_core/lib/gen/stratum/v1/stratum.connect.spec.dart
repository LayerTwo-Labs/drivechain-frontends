//
//  Generated code. Do not modify.
//  source: stratum/v1/stratum.proto
//

import "package:connectrpc/connect.dart" as connect;
import "stratum.pb.dart" as stratumv1stratum;

/// StratumService runs a Stratum v1 server for ASIC miners on the local
/// network. The server sends their work to this node or to a pool, and keeps
/// running with no client attached. eCash networks only.
abstract final class StratumService {
  /// Fully-qualified name of the StratumService service.
  static const name = 'stratum.v1.StratumService';

  static const startStratum = connect.Spec(
    '/$name/StartStratum',
    connect.StreamType.unary,
    stratumv1stratum.StartStratumRequest.new,
    stratumv1stratum.StartStratumResponse.new,
  );

  static const stopStratum = connect.Spec(
    '/$name/StopStratum',
    connect.StreamType.unary,
    stratumv1stratum.StopStratumRequest.new,
    stratumv1stratum.StopStratumResponse.new,
  );

  static const getStratumStatus = connect.Spec(
    '/$name/GetStratumStatus',
    connect.StreamType.unary,
    stratumv1stratum.GetStratumStatusRequest.new,
    stratumv1stratum.GetStratumStatusResponse.new,
  );

  /// SetTarget selects where the miners' work goes. A running server switches
  /// at once and sends clean jobs.
  static const setTarget = connect.Spec(
    '/$name/SetTarget',
    connect.StreamType.unary,
    stratumv1stratum.SetTargetRequest.new,
    stratumv1stratum.SetTargetResponse.new,
  );

  /// ListTargets returns the catalog pools of the running network.
  static const listTargets = connect.Spec(
    '/$name/ListTargets',
    connect.StreamType.unary,
    stratumv1stratum.ListTargetsRequest.new,
    stratumv1stratum.ListTargetsResponse.new,
  );

  /// SetWorkMode changes the power mode of a connected miner over its device API.
  static const setWorkMode = connect.Spec(
    '/$name/SetWorkMode',
    connect.StreamType.unary,
    stratumv1stratum.SetWorkModeRequest.new,
    stratumv1stratum.SetWorkModeResponse.new,
  );

  /// SetMiningSettings changes the fields it carries and leaves the rest. The
  /// hasher on this computer starts the server first when the server is stopped.
  static const setMiningSettings = connect.Spec(
    '/$name/SetMiningSettings',
    connect.StreamType.unary,
    stratumv1stratum.SetMiningSettingsRequest.new,
    stratumv1stratum.SetMiningSettingsResponse.new,
  );

  /// GetHashrateHistory returns the hashrate of all miners together over a range.
  static const getHashrateHistory = connect.Spec(
    '/$name/GetHashrateHistory',
    connect.StreamType.unary,
    stratumv1stratum.GetHashrateHistoryRequest.new,
    stratumv1stratum.GetHashrateHistoryResponse.new,
  );

  /// ListPoolBlocks returns the blocks the upstream pool found, newest first.
  static const listPoolBlocks = connect.Spec(
    '/$name/ListPoolBlocks',
    connect.StreamType.unary,
    stratumv1stratum.ListPoolBlocksRequest.new,
    stratumv1stratum.ListPoolBlocksResponse.new,
  );
}
