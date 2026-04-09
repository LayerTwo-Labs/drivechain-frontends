//
//  Generated code. Do not modify.
//  source: coinshift/v1/coinshift.proto
//

import "package:connectrpc/connect.dart" as connect;
import "coinshift.pb.dart" as coinshiftv1coinshift;
import "coinshift.connect.spec.dart" as specs;

extension type CoinShiftServiceClient (connect.Transport _transport) {
  /// Get wallet balance (total and available).
  Future<coinshiftv1coinshift.GetBalanceResponse> getBalance(
    coinshiftv1coinshift.GetBalanceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getBalance,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get current block count.
  Future<coinshiftv1coinshift.GetBlockCountResponse> getBlockCount(
    coinshiftv1coinshift.GetBlockCountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getBlockCount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stop the coinshift node.
  Future<coinshiftv1coinshift.StopResponse> stop(
    coinshiftv1coinshift.StopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new address from the wallet.
  Future<coinshiftv1coinshift.GetNewAddressResponse> getNewAddress(
    coinshiftv1coinshift.GetNewAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Withdraw to mainchain.
  Future<coinshiftv1coinshift.WithdrawResponse> withdraw(
    coinshiftv1coinshift.WithdrawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.withdraw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transfer within sidechain.
  Future<coinshiftv1coinshift.TransferResponse> transfer(
    coinshiftv1coinshift.TransferRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.transfer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get total sidechain wealth in sats.
  Future<coinshiftv1coinshift.GetSidechainWealthResponse> getSidechainWealth(
    coinshiftv1coinshift.GetSidechainWealthRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getSidechainWealth,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a deposit transaction.
  Future<coinshiftv1coinshift.CreateDepositResponse> createDeposit(
    coinshiftv1coinshift.CreateDepositRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.createDeposit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get pending withdrawal bundle.
  Future<coinshiftv1coinshift.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
    coinshiftv1coinshift.GetPendingWithdrawalBundleRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getPendingWithdrawalBundle,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Connect to a peer.
  Future<coinshiftv1coinshift.ConnectPeerResponse> connectPeer(
    coinshiftv1coinshift.ConnectPeerRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.connectPeer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Forget a peer.
  Future<coinshiftv1coinshift.ForgetPeerResponse> forgetPeer(
    coinshiftv1coinshift.ForgetPeerRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.forgetPeer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List connected peers.
  Future<coinshiftv1coinshift.ListPeersResponse> listPeers(
    coinshiftv1coinshift.ListPeersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.listPeers,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Mine a block.
  Future<coinshiftv1coinshift.MineResponse> mine(
    coinshiftv1coinshift.MineRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.mine,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get block by hash.
  Future<coinshiftv1coinshift.GetBlockResponse> getBlock(
    coinshiftv1coinshift.GetBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get best mainchain block hash.
  Future<coinshiftv1coinshift.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
    coinshiftv1coinshift.GetBestMainchainBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getBestMainchainBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get best sidechain block hash.
  Future<coinshiftv1coinshift.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
    coinshiftv1coinshift.GetBestSidechainBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getBestSidechainBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get BMM inclusions for a block.
  Future<coinshiftv1coinshift.GetBmmInclusionsResponse> getBmmInclusions(
    coinshiftv1coinshift.GetBmmInclusionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getBmmInclusions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get wallet UTXOs.
  Future<coinshiftv1coinshift.GetWalletUtxosResponse> getWalletUtxos(
    coinshiftv1coinshift.GetWalletUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getWalletUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all UTXOs.
  Future<coinshiftv1coinshift.ListUtxosResponse> listUtxos(
    coinshiftv1coinshift.ListUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.listUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Remove transaction from mempool.
  Future<coinshiftv1coinshift.RemoveFromMempoolResponse> removeFromMempool(
    coinshiftv1coinshift.RemoveFromMempoolRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.removeFromMempool,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get latest failed withdrawal bundle height.
  Future<coinshiftv1coinshift.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
    coinshiftv1coinshift.GetLatestFailedWithdrawalBundleHeightRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getLatestFailedWithdrawalBundleHeight,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Generate a new mnemonic.
  Future<coinshiftv1coinshift.GenerateMnemonicResponse> generateMnemonic(
    coinshiftv1coinshift.GenerateMnemonicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.generateMnemonic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set seed from mnemonic.
  Future<coinshiftv1coinshift.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
    coinshiftv1coinshift.SetSeedFromMnemonicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.setSeedFromMnemonic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Raw JSON-RPC passthrough for debug console.
  Future<coinshiftv1coinshift.CallRawResponse> callRaw(
    coinshiftv1coinshift.CallRawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.callRaw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get wallet addresses.
  Future<coinshiftv1coinshift.GetWalletAddressesResponse> getWalletAddresses(
    coinshiftv1coinshift.GetWalletAddressesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getWalletAddresses,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get OpenAPI schema.
  Future<coinshiftv1coinshift.OpenapiSchemaResponse> openapiSchema(
    coinshiftv1coinshift.OpenapiSchemaRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.openapiSchema,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a swap (L2 to L1).
  Future<coinshiftv1coinshift.CreateSwapResponse> createSwap(
    coinshiftv1coinshift.CreateSwapRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.createSwap,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Claim a swap.
  Future<coinshiftv1coinshift.ClaimSwapResponse> claimSwap(
    coinshiftv1coinshift.ClaimSwapRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.claimSwap,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get swap status.
  Future<coinshiftv1coinshift.GetSwapStatusResponse> getSwapStatus(
    coinshiftv1coinshift.GetSwapStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.getSwapStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all swaps.
  Future<coinshiftv1coinshift.ListSwapsResponse> listSwaps(
    coinshiftv1coinshift.ListSwapsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.listSwaps,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List swaps for a specific recipient.
  Future<coinshiftv1coinshift.ListSwapsByRecipientResponse> listSwapsByRecipient(
    coinshiftv1coinshift.ListSwapsByRecipientRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.listSwapsByRecipient,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Update swap L1 transaction ID.
  Future<coinshiftv1coinshift.UpdateSwapL1TxidResponse> updateSwapL1Txid(
    coinshiftv1coinshift.UpdateSwapL1TxidRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.updateSwapL1Txid,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Reconstruct all swaps from blockchain.
  Future<coinshiftv1coinshift.ReconstructSwapsResponse> reconstructSwaps(
    coinshiftv1coinshift.ReconstructSwapsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.CoinShiftService.reconstructSwaps,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
