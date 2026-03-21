//
//  Generated code. Do not modify.
//  source: orchestrator/v1/zside_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "zside_conf.pb.dart" as orchestratorv1zside_conf;

abstract final class ZSideConfService {
  /// Fully-qualified name of the ZSideConfService service.
  static const name = 'orchestrator.v1.ZSideConfService';

  /// Get current ZSide sidechain configuration state.
  static const getZSideConfig = connect.Spec(
    '/$name/GetZSideConfig',
    connect.StreamType.unary,
    orchestratorv1zside_conf.GetZSideConfigRequest.new,
    orchestratorv1zside_conf.GetZSideConfigResponse.new,
  );

  /// Write ZSide configuration content.
  static const writeZSideConfig = connect.Spec(
    '/$name/WriteZSideConfig',
    connect.StreamType.unary,
    orchestratorv1zside_conf.WriteZSideConfigRequest.new,
    orchestratorv1zside_conf.WriteZSideConfigResponse.new,
  );

  /// Sync network from Bitcoin Core config.
  static const syncNetworkFromBitcoinConf = connect.Spec(
    '/$name/SyncNetworkFromBitcoinConf',
    connect.StreamType.unary,
    orchestratorv1zside_conf.ZSideSyncNetworkFromBitcoinConfRequest.new,
    orchestratorv1zside_conf.ZSideSyncNetworkFromBitcoinConfResponse.new,
  );
}
