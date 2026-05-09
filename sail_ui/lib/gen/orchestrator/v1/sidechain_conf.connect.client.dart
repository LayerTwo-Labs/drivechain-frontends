//
//  Generated code. Do not modify.
//  source: orchestrator/v1/sidechain_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "sidechain_conf.pb.dart" as orchestratorv1sidechain_conf;
import "sidechain_conf.connect.spec.dart" as specs;

extension type SidechainConfServiceClient (connect.Transport _transport) {
  /// Get current sidechain configuration state.
  Future<orchestratorv1sidechain_conf.GetSidechainConfigResponse> getSidechainConfig(
    orchestratorv1sidechain_conf.GetSidechainConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SidechainConfService.getSidechainConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Write sidechain configuration content.
  Future<orchestratorv1sidechain_conf.WriteSidechainConfigResponse> writeSidechainConfig(
    orchestratorv1sidechain_conf.WriteSidechainConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SidechainConfService.writeSidechainConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sync network from Bitcoin Core config.
  Future<orchestratorv1sidechain_conf.SyncSidechainNetworkFromBitcoinConfResponse> syncSidechainNetworkFromBitcoinConf(
    orchestratorv1sidechain_conf.SyncSidechainNetworkFromBitcoinConfRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.SidechainConfService.syncSidechainNetworkFromBitcoinConf,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
