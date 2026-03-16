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

  /// Set the Bitcoin Core network (signet, mainnet, forknet, testnet, regtest).
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
