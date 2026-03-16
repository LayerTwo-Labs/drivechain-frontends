//
//  Generated code. Do not modify.
//  source: orchestrator/v1/bitcoin_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitcoin_conf.pb.dart" as orchestratorv1bitcoin_conf;

abstract final class BitcoinConfService {
  /// Fully-qualified name of the BitcoinConfService service.
  static const name = 'orchestrator.v1.BitcoinConfService';

  /// Get current Bitcoin Core configuration state.
  static const getBitcoinConfig = connect.Spec(
    '/$name/GetBitcoinConfig',
    connect.StreamType.unary,
    orchestratorv1bitcoin_conf.GetBitcoinConfigRequest.new,
    orchestratorv1bitcoin_conf.GetBitcoinConfigResponse.new,
  );

  /// Set the Bitcoin Core network (signet, mainnet, forknet, testnet, regtest).
  static const setBitcoinConfigNetwork = connect.Spec(
    '/$name/SetBitcoinConfigNetwork',
    connect.StreamType.unary,
    orchestratorv1bitcoin_conf.SetBitcoinConfigNetworkRequest.new,
    orchestratorv1bitcoin_conf.SetBitcoinConfigNetworkResponse.new,
  );

  /// Set the Bitcoin Core datadir for a specific network.
  static const setBitcoinConfigDataDir = connect.Spec(
    '/$name/SetBitcoinConfigDataDir',
    connect.StreamType.unary,
    orchestratorv1bitcoin_conf.SetBitcoinConfigDataDirRequest.new,
    orchestratorv1bitcoin_conf.SetBitcoinConfigDataDirResponse.new,
  );

  /// Write raw Bitcoin Core configuration content.
  static const writeBitcoinConfig = connect.Spec(
    '/$name/WriteBitcoinConfig',
    connect.StreamType.unary,
    orchestratorv1bitcoin_conf.WriteBitcoinConfigRequest.new,
    orchestratorv1bitcoin_conf.WriteBitcoinConfigResponse.new,
  );
}
