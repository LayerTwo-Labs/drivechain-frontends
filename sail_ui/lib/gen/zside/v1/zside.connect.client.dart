//
//  Generated code. Do not modify.
//  source: zside/v1/zside.proto
//

import "package:connectrpc/connect.dart" as connect;
import "zside.pb.dart" as zsidev1zside;
import "zside.connect.spec.dart" as specs;

extension type ZSideServiceClient(connect.Transport _transport) {
  /// Get wallet balance (total and available, both transparent and shielded).
  Future<zsidev1zside.GetBalanceResponse> getBalance(
    zsidev1zside.GetBalanceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getBalance,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get current block count.
  Future<zsidev1zside.GetBlockCountResponse> getBlockCount(
    zsidev1zside.GetBlockCountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getBlockCount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stop the zside node.
  Future<zsidev1zside.StopResponse> stop(
    zsidev1zside.StopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Withdraw to mainchain.
  Future<zsidev1zside.WithdrawResponse> withdraw(
    zsidev1zside.WithdrawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.withdraw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transfer within sidechain (transparent).
  Future<zsidev1zside.TransferResponse> transfer(
    zsidev1zside.TransferRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.transfer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get total sidechain wealth in sats.
  Future<zsidev1zside.GetSidechainWealthResponse> getSidechainWealth(
    zsidev1zside.GetSidechainWealthRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getSidechainWealth,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a deposit transaction.
  Future<zsidev1zside.CreateDepositResponse> createDeposit(
    zsidev1zside.CreateDepositRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.createDeposit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get pending withdrawal bundle.
  Future<zsidev1zside.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
    zsidev1zside.GetPendingWithdrawalBundleRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getPendingWithdrawalBundle,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Connect to a peer.
  Future<zsidev1zside.ConnectPeerResponse> connectPeer(
    zsidev1zside.ConnectPeerRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.connectPeer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List connected peers.
  Future<zsidev1zside.ListPeersResponse> listPeers(
    zsidev1zside.ListPeersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.listPeers,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Mine a block.
  Future<zsidev1zside.MineResponse> mine(
    zsidev1zside.MineRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.mine,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get block by hash.
  Future<zsidev1zside.GetBlockResponse> getBlock(
    zsidev1zside.GetBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get best mainchain block hash.
  Future<zsidev1zside.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
    zsidev1zside.GetBestMainchainBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getBestMainchainBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get best sidechain block hash.
  Future<zsidev1zside.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
    zsidev1zside.GetBestSidechainBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getBestSidechainBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get BMM inclusions for a block.
  Future<zsidev1zside.GetBmmInclusionsResponse> getBmmInclusions(
    zsidev1zside.GetBmmInclusionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getBmmInclusions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get wallet UTXOs.
  Future<zsidev1zside.GetWalletUtxosResponse> getWalletUtxos(
    zsidev1zside.GetWalletUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getWalletUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all UTXOs.
  Future<zsidev1zside.ListUtxosResponse> listUtxos(
    zsidev1zside.ListUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.listUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Remove transaction from mempool.
  Future<zsidev1zside.RemoveFromMempoolResponse> removeFromMempool(
    zsidev1zside.RemoveFromMempoolRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.removeFromMempool,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get latest failed withdrawal bundle height.
  Future<zsidev1zside.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
    zsidev1zside.GetLatestFailedWithdrawalBundleHeightRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getLatestFailedWithdrawalBundleHeight,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Generate a new mnemonic.
  Future<zsidev1zside.GenerateMnemonicResponse> generateMnemonic(
    zsidev1zside.GenerateMnemonicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.generateMnemonic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set seed from mnemonic.
  Future<zsidev1zside.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
    zsidev1zside.SetSeedFromMnemonicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.setSeedFromMnemonic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Raw JSON-RPC passthrough for debug console.
  Future<zsidev1zside.CallRawResponse> callRaw(
    zsidev1zside.CallRawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.callRaw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new shielded address.
  Future<zsidev1zside.GetNewShieldedAddressResponse> getNewShieldedAddress(
    zsidev1zside.GetNewShieldedAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getNewShieldedAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new transparent address.
  Future<zsidev1zside.GetNewTransparentAddressResponse> getNewTransparentAddress(
    zsidev1zside.GetNewTransparentAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getNewTransparentAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get shielded wallet addresses.
  Future<zsidev1zside.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses(
    zsidev1zside.GetShieldedWalletAddressesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getShieldedWalletAddresses,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get transparent wallet addresses.
  Future<zsidev1zside.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses(
    zsidev1zside.GetTransparentWalletAddressesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.getTransparentWalletAddresses,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Shield transparent funds to shielded pool.
  Future<zsidev1zside.ShieldResponse> shield(
    zsidev1zside.ShieldRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.shield,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Unshield (deshield) shielded funds to transparent pool.
  Future<zsidev1zside.UnshieldResponse> unshield(
    zsidev1zside.UnshieldRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.unshield,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Send a shielded transfer.
  Future<zsidev1zside.ShieldedTransferResponse> shieldedTransfer(
    zsidev1zside.ShieldedTransferRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.shieldedTransfer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Send a transparent transfer.
  Future<zsidev1zside.TransparentTransferResponse> transparentTransfer(
    zsidev1zside.TransparentTransferRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.ZSideService.transparentTransfer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
