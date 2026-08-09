//
//  Generated code. Do not modify.
//  source: orchestrator/v1/thunder_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "thunder_conf.pb.dart" as orchestratorv1thunder_conf;

abstract final class ThunderConfService {
  /// Fully-qualified name of the ThunderConfService service.
  static const name = 'orchestrator.v1.ThunderConfService';

  /// Get current Thunder sidechain configuration state.
  static const getThunderConfig = connect.Spec(
    '/$name/GetThunderConfig',
    connect.StreamType.unary,
    orchestratorv1thunder_conf.GetThunderConfigRequest.new,
    orchestratorv1thunder_conf.GetThunderConfigResponse.new,
  );

  /// Write Thunder configuration content.
  static const writeThunderConfig = connect.Spec(
    '/$name/WriteThunderConfig',
    connect.StreamType.unary,
    orchestratorv1thunder_conf.WriteThunderConfigRequest.new,
    orchestratorv1thunder_conf.WriteThunderConfigResponse.new,
  );

  /// Sync network from Bitcoin Core config.
  static const syncNetworkFromBitcoinConf = connect.Spec(
    '/$name/SyncNetworkFromBitcoinConf',
    connect.StreamType.unary,
    orchestratorv1thunder_conf.SyncNetworkFromBitcoinConfRequest.new,
    orchestratorv1thunder_conf.SyncNetworkFromBitcoinConfResponse.new,
  );
}
