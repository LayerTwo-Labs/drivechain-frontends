//
//  Generated code. Do not modify.
//  source: orchestrator/v1/thunder_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "thunder_conf.pb.dart" as orchestratorv1thunder_conf;
import "thunder_conf.connect.spec.dart" as specs;

extension type ThunderConfServiceClient(connect.Transport _transport) {
  /// Get current Thunder sidechain configuration state.
  Future<orchestratorv1thunder_conf.GetThunderConfigResponse> getThunderConfig(
    orchestratorv1thunder_conf.GetThunderConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ThunderConfService.getThunderConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Write Thunder configuration content.
  Future<orchestratorv1thunder_conf.WriteThunderConfigResponse> writeThunderConfig(
    orchestratorv1thunder_conf.WriteThunderConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ThunderConfService.writeThunderConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sync network from Bitcoin Core config.
  Future<orchestratorv1thunder_conf.SyncNetworkFromBitcoinConfResponse> syncNetworkFromBitcoinConf(
    orchestratorv1thunder_conf.SyncNetworkFromBitcoinConfRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ThunderConfService.syncNetworkFromBitcoinConf,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
