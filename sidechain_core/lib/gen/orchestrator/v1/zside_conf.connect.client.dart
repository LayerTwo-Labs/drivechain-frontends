//
//  Generated code. Do not modify.
//  source: orchestrator/v1/zside_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "zside_conf.pb.dart" as orchestratorv1zside_conf;
import "zside_conf.connect.spec.dart" as specs;

extension type ZSideConfServiceClient (connect.Transport _transport) {
  /// Get current ZSide sidechain configuration state.
  Future<orchestratorv1zside_conf.GetZSideConfigResponse> getZSideConfig(
    orchestratorv1zside_conf.GetZSideConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideConfService.getZSideConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Write ZSide configuration content.
  Future<orchestratorv1zside_conf.WriteZSideConfigResponse> writeZSideConfig(
    orchestratorv1zside_conf.WriteZSideConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideConfService.writeZSideConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sync network from Bitcoin Core config.
  Future<orchestratorv1zside_conf.ZSideSyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf(
    orchestratorv1zside_conf.ZSideSyncNetworkFromBitcoinConfRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideConfService.syncNetworkFromBitcoinConf,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
