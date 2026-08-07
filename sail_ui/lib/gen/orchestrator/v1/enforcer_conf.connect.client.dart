//
//  Generated code. Do not modify.
//  source: orchestrator/v1/enforcer_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "enforcer_conf.pb.dart" as orchestratorv1enforcer_conf;
import "enforcer_conf.connect.spec.dart" as specs;

extension type EnforcerConfServiceClient(connect.Transport _transport) {
  /// Get current Enforcer configuration state.
  Future<orchestratorv1enforcer_conf.GetEnforcerConfigResponse> getEnforcerConfig(
    orchestratorv1enforcer_conf.GetEnforcerConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.EnforcerConfService.getEnforcerConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Write Enforcer configuration content.
  Future<orchestratorv1enforcer_conf.WriteEnforcerConfigResponse> writeEnforcerConfig(
    orchestratorv1enforcer_conf.WriteEnforcerConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.EnforcerConfService.writeEnforcerConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sync node-rpc settings from Bitcoin Core config.
  Future<orchestratorv1enforcer_conf.SyncNodeRpcFromBitcoinConfResponse> syncNodeRpcFromBitcoinConf(
    orchestratorv1enforcer_conf.SyncNodeRpcFromBitcoinConfRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.EnforcerConfService.syncNodeRpcFromBitcoinConf,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
