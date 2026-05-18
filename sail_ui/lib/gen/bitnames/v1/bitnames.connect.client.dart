//
//  Generated code. Do not modify.
//  source: bitnames/v1/bitnames.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitnames.pb.dart" as bitnamesv1bitnames;
import "bitnames.connect.spec.dart" as specs;

extension type BitnamesServiceClient(connect.Transport _transport) {
  /// Get wallet balance (total and available).
  Future<bitnamesv1bitnames.GetBalanceResponse> getBalance(
    bitnamesv1bitnames.GetBalanceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getBalance,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get current block count.
  Future<bitnamesv1bitnames.GetBlockCountResponse> getBlockCount(
    bitnamesv1bitnames.GetBlockCountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getBlockCount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stop the bitnames node.
  Future<bitnamesv1bitnames.StopResponse> stop(
    bitnamesv1bitnames.StopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new address from the wallet.
  Future<bitnamesv1bitnames.GetNewAddressResponse> getNewAddress(
    bitnamesv1bitnames.GetNewAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Withdraw to mainchain.
  Future<bitnamesv1bitnames.WithdrawResponse> withdraw(
    bitnamesv1bitnames.WithdrawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.withdraw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transfer within sidechain.
  Future<bitnamesv1bitnames.TransferResponse> transfer(
    bitnamesv1bitnames.TransferRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.transfer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get total sidechain wealth in sats.
  Future<bitnamesv1bitnames.GetSidechainWealthResponse> getSidechainWealth(
    bitnamesv1bitnames.GetSidechainWealthRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getSidechainWealth,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a deposit transaction.
  Future<bitnamesv1bitnames.CreateDepositResponse> createDeposit(
    bitnamesv1bitnames.CreateDepositRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.createDeposit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get pending withdrawal bundle.
  Future<bitnamesv1bitnames.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
    bitnamesv1bitnames.GetPendingWithdrawalBundleRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getPendingWithdrawalBundle,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Connect to a peer.
  Future<bitnamesv1bitnames.ConnectPeerResponse> connectPeer(
    bitnamesv1bitnames.ConnectPeerRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.connectPeer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List connected peers.
  Future<bitnamesv1bitnames.ListPeersResponse> listPeers(
    bitnamesv1bitnames.ListPeersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.listPeers,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Mine a block.
  Future<bitnamesv1bitnames.MineResponse> mine(
    bitnamesv1bitnames.MineRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.mine,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get block by hash.
  Future<bitnamesv1bitnames.GetBlockResponse> getBlock(
    bitnamesv1bitnames.GetBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get best mainchain block hash.
  Future<bitnamesv1bitnames.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
    bitnamesv1bitnames.GetBestMainchainBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getBestMainchainBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get best sidechain block hash.
  Future<bitnamesv1bitnames.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
    bitnamesv1bitnames.GetBestSidechainBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getBestSidechainBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get BMM inclusions for a block.
  Future<bitnamesv1bitnames.GetBmmInclusionsResponse> getBmmInclusions(
    bitnamesv1bitnames.GetBmmInclusionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getBmmInclusions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get wallet UTXOs.
  Future<bitnamesv1bitnames.GetWalletUtxosResponse> getWalletUtxos(
    bitnamesv1bitnames.GetWalletUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getWalletUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all UTXOs.
  Future<bitnamesv1bitnames.ListUtxosResponse> listUtxos(
    bitnamesv1bitnames.ListUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.listUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get latest failed withdrawal bundle height.
  Future<bitnamesv1bitnames.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
    bitnamesv1bitnames.GetLatestFailedWithdrawalBundleHeightRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getLatestFailedWithdrawalBundleHeight,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Generate a new mnemonic.
  Future<bitnamesv1bitnames.GenerateMnemonicResponse> generateMnemonic(
    bitnamesv1bitnames.GenerateMnemonicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.generateMnemonic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set seed from mnemonic.
  Future<bitnamesv1bitnames.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
    bitnamesv1bitnames.SetSeedFromMnemonicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.setSeedFromMnemonic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Raw JSON-RPC passthrough for debug console.
  Future<bitnamesv1bitnames.CallRawResponse> callRaw(
    bitnamesv1bitnames.CallRawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.callRaw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get BitName data by name.
  Future<bitnamesv1bitnames.GetBitNameDataResponse> getBitNameData(
    bitnamesv1bitnames.GetBitNameDataRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getBitNameData,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all BitNames.
  Future<bitnamesv1bitnames.ListBitNamesResponse> listBitNames(
    bitnamesv1bitnames.ListBitNamesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.listBitNames,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Register a BitName.
  Future<bitnamesv1bitnames.RegisterBitNameResponse> registerBitName(
    bitnamesv1bitnames.RegisterBitNameRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.registerBitName,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Reserve a BitName.
  Future<bitnamesv1bitnames.ReserveBitNameResponse> reserveBitName(
    bitnamesv1bitnames.ReserveBitNameRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.reserveBitName,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new encryption key.
  Future<bitnamesv1bitnames.GetNewEncryptionKeyResponse> getNewEncryptionKey(
    bitnamesv1bitnames.GetNewEncryptionKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getNewEncryptionKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new verifying key.
  Future<bitnamesv1bitnames.GetNewVerifyingKeyResponse> getNewVerifyingKey(
    bitnamesv1bitnames.GetNewVerifyingKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getNewVerifyingKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Decrypt a message.
  Future<bitnamesv1bitnames.DecryptMsgResponse> decryptMsg(
    bitnamesv1bitnames.DecryptMsgRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.decryptMsg,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Encrypt a message.
  Future<bitnamesv1bitnames.EncryptMsgResponse> encryptMsg(
    bitnamesv1bitnames.EncryptMsgRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.encryptMsg,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get paymail information.
  Future<bitnamesv1bitnames.GetPaymailResponse> getPaymail(
    bitnamesv1bitnames.GetPaymailRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getPaymail,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Resolve a commitment from a BitName.
  Future<bitnamesv1bitnames.ResolveCommitResponse> resolveCommit(
    bitnamesv1bitnames.ResolveCommitRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.resolveCommit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sign an arbitrary message with the specified verifying key.
  Future<bitnamesv1bitnames.SignArbitraryMsgResponse> signArbitraryMsg(
    bitnamesv1bitnames.SignArbitraryMsgRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.signArbitraryMsg,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sign an arbitrary message as a specific address.
  Future<bitnamesv1bitnames.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
    bitnamesv1bitnames.SignArbitraryMsgAsAddrRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.signArbitraryMsgAsAddr,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get wallet addresses.
  Future<bitnamesv1bitnames.GetWalletAddressesResponse> getWalletAddresses(
    bitnamesv1bitnames.GetWalletAddressesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.getWalletAddresses,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List owned UTXOs.
  Future<bitnamesv1bitnames.MyUtxosResponse> myUtxos(
    bitnamesv1bitnames.MyUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.myUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get OpenAPI schema.
  Future<bitnamesv1bitnames.OpenapiSchemaResponse> openapiSchema(
    bitnamesv1bitnames.OpenapiSchemaRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitnamesService.openapiSchema,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
