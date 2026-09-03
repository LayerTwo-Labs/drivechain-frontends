//
//  Generated code. Do not modify.
//  source: orchestrator/v1/bitcoin_conf.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitcoin_conf.pb.dart" as orchestratorv1bitcoin_conf;
import "bitcoin_conf.connect.spec.dart" as specs;

extension type BitcoinConfServiceClient (connect.Transport _transport) {
  /// Get current Bitcoin Core configuration state.
  Future<orchestratorv1bitcoin_conf.GetBitcoinConfigResponse> getBitcoinConfig(
    orchestratorv1bitcoin_conf.GetBitcoinConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinConfService.getBitcoinConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Report what the user must resolve before a network and/or wallet-backend
  /// change can be applied. Side-effect free.
  Future<orchestratorv1bitcoin_conf.NetworkChangePlan> prepareNetworkChange(
    orchestratorv1bitcoin_conf.PrepareNetworkChangeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinConfService.prepareNetworkChange,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// The networks the user can pick, from the published catalog plus regtest.
  Future<orchestratorv1bitcoin_conf.ListNetworksResponse> listNetworks(
    orchestratorv1bitcoin_conf.ListNetworksRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinConfService.listNetworks,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// The networks that appeared in the catalog since the last call, so the app
  /// can name them in a notice. Reporting a network also marks it told: a
  /// second call returns it no more. A first run reports nothing.
  Future<orchestratorv1bitcoin_conf.TakeNewNetworksResponse> takeNewNetworks(
    orchestratorv1bitcoin_conf.TakeNewNetworksRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinConfService.takeNewNetworks,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// What a move to another eCash network costs. Both fork mainnet, so the
  /// blocks below the lower fork height are shared and the move is a reset
  /// rather than a resync. Side-effect free.
  Future<orchestratorv1bitcoin_conf.PlanECashSwitchResponse> planECashSwitch(
    orchestratorv1bitcoin_conf.PlanECashSwitchRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinConfService.planECashSwitch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set the Bitcoin Core network. Takes a catalog id ("alphanet") or a slot
  /// name (signet, mainnet, ecash, regtest).
  Future<orchestratorv1bitcoin_conf.SetBitcoinConfigNetworkResponse> setBitcoinConfigNetwork(
    orchestratorv1bitcoin_conf.SetBitcoinConfigNetworkRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinConfService.setBitcoinConfigNetwork,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set the Bitcoin Core datadir for a specific network.
  Future<orchestratorv1bitcoin_conf.SetBitcoinConfigDataDirResponse> setBitcoinConfigDataDir(
    orchestratorv1bitcoin_conf.SetBitcoinConfigDataDirRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinConfService.setBitcoinConfigDataDir,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Write raw Bitcoin Core configuration content.
  Future<orchestratorv1bitcoin_conf.WriteBitcoinConfigResponse> writeBitcoinConfig(
    orchestratorv1bitcoin_conf.WriteBitcoinConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinConfService.writeBitcoinConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
