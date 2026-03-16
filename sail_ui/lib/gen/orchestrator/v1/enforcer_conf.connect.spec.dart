//
//  Generated code. Do not modify.
//  source: orchestrator/v1/enforcer_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "enforcer_conf.pb.dart" as orchestratorv1enforcer_conf;

abstract final class EnforcerConfService {
  /// Fully-qualified name of the EnforcerConfService service.
  static const name = 'orchestrator.v1.EnforcerConfService';

  /// Get current Enforcer configuration state.
  static const getEnforcerConfig = connect.Spec(
    '/$name/GetEnforcerConfig',
    connect.StreamType.unary,
    orchestratorv1enforcer_conf.GetEnforcerConfigRequest.new,
    orchestratorv1enforcer_conf.GetEnforcerConfigResponse.new,
  );

  /// Write Enforcer configuration content.
  static const writeEnforcerConfig = connect.Spec(
    '/$name/WriteEnforcerConfig',
    connect.StreamType.unary,
    orchestratorv1enforcer_conf.WriteEnforcerConfigRequest.new,
    orchestratorv1enforcer_conf.WriteEnforcerConfigResponse.new,
  );

  /// Sync node-rpc settings from Bitcoin Core config.
  static const syncNodeRpcFromBitcoinConf = connect.Spec(
    '/$name/SyncNodeRpcFromBitcoinConf',
    connect.StreamType.unary,
    orchestratorv1enforcer_conf.SyncNodeRpcFromBitcoinConfRequest.new,
    orchestratorv1enforcer_conf.SyncNodeRpcFromBitcoinConfResponse.new,
  );
}
