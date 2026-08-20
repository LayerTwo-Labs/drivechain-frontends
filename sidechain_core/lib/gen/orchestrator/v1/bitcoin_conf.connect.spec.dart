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

  /// Report what the user must resolve before a network and/or wallet-backend
  /// change can be applied. Side-effect free.
  static const prepareNetworkChange = connect.Spec(
    '/$name/PrepareNetworkChange',
    connect.StreamType.unary,
    orchestratorv1bitcoin_conf.PrepareNetworkChangeRequest.new,
    orchestratorv1bitcoin_conf.NetworkChangePlan.new,
  );

  /// The networks the user can pick, from the published catalog plus regtest.
  static const listNetworks = connect.Spec(
    '/$name/ListNetworks',
    connect.StreamType.unary,
    orchestratorv1bitcoin_conf.ListNetworksRequest.new,
    orchestratorv1bitcoin_conf.ListNetworksResponse.new,
  );

  /// The networks that appeared in the catalog since the last call, so the app
  /// can name them in a notice. Reporting a network also marks it told: a
  /// second call returns it no more. A first run reports nothing.
  static const takeNewNetworks = connect.Spec(
    '/$name/TakeNewNetworks',
    connect.StreamType.unary,
    orchestratorv1bitcoin_conf.TakeNewNetworksRequest.new,
    orchestratorv1bitcoin_conf.TakeNewNetworksResponse.new,
  );

  /// What a move to another eCash network costs. Both fork mainnet, so the
  /// blocks below the lower fork height are shared and the move is a reset
  /// rather than a resync. Side-effect free.
  static const planECashSwitch = connect.Spec(
    '/$name/PlanECashSwitch',
    connect.StreamType.unary,
    orchestratorv1bitcoin_conf.PlanECashSwitchRequest.new,
    orchestratorv1bitcoin_conf.PlanECashSwitchResponse.new,
  );

  /// Set the Bitcoin Core network. Takes a catalog id ("alphanet") or a slot
  /// name (signet, mainnet, forknet, ecash, regtest).
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
