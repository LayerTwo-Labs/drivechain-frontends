//
//  Generated code. Do not modify.
//  source: orchestrator/v1/sidechain_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "sidechain_conf.pb.dart" as orchestratorv1sidechain_conf;

abstract final class SidechainConfService {
  /// Fully-qualified name of the SidechainConfService service.
  static const name = 'orchestrator.v1.SidechainConfService';

  /// Get current sidechain configuration state.
  static const getSidechainConfig = connect.Spec(
    '/$name/GetSidechainConfig',
    connect.StreamType.unary,
    orchestratorv1sidechain_conf.GetSidechainConfigRequest.new,
    orchestratorv1sidechain_conf.GetSidechainConfigResponse.new,
  );

  /// Write sidechain configuration content.
  static const writeSidechainConfig = connect.Spec(
    '/$name/WriteSidechainConfig',
    connect.StreamType.unary,
    orchestratorv1sidechain_conf.WriteSidechainConfigRequest.new,
    orchestratorv1sidechain_conf.WriteSidechainConfigResponse.new,
  );

  /// Sync network from Bitcoin Core config.
  static const syncSidechainNetworkFromBitcoinConf = connect.Spec(
    '/$name/SyncSidechainNetworkFromBitcoinConf',
    connect.StreamType.unary,
    orchestratorv1sidechain_conf.SyncSidechainNetworkFromBitcoinConfRequest.new,
    orchestratorv1sidechain_conf.SyncSidechainNetworkFromBitcoinConfResponse.new,
  );
}
