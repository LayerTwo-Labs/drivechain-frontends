//
//  Generated code. Do not modify.
//  source: stratum/v1/stratum.proto
//

import "package:connectrpc/connect.dart" as connect;
import "stratum.pb.dart" as stratumv1stratum;
import "stratum.connect.spec.dart" as specs;

/// StratumService runs a Stratum v1 server for ASIC miners on the local
/// network. The server sends their work to this node or to a pool, and keeps
/// running with no client attached. eCash networks only.
extension type StratumServiceClient (connect.Transport _transport) {
  Future<stratumv1stratum.StartStratumResponse> startStratum(
    stratumv1stratum.StartStratumRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.StratumService.startStratum,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<stratumv1stratum.StopStratumResponse> stopStratum(
    stratumv1stratum.StopStratumRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.StratumService.stopStratum,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<stratumv1stratum.GetStratumStatusResponse> getStratumStatus(
    stratumv1stratum.GetStratumStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.StratumService.getStratumStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SetTarget selects where the miners' work goes. A running server switches
  /// at once and sends clean jobs.
  Future<stratumv1stratum.SetTargetResponse> setTarget(
    stratumv1stratum.SetTargetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.StratumService.setTarget,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ListTargets returns the catalog pools of the running network.
  Future<stratumv1stratum.ListTargetsResponse> listTargets(
    stratumv1stratum.ListTargetsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.StratumService.listTargets,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SetWorkMode changes the power mode of a connected miner over its device API.
  Future<stratumv1stratum.SetWorkModeResponse> setWorkMode(
    stratumv1stratum.SetWorkModeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.StratumService.setWorkMode,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
