//
//  Generated code. Do not modify.
//  source: truthcoin/v1/truthcoin.proto
//

import "package:connectrpc/connect.dart" as connect;
import "truthcoin.pb.dart" as truthcoinv1truthcoin;
import "truthcoin.connect.spec.dart" as specs;

extension type TruthcoinServiceClient(connect.Transport _transport) {
  /// Get wallet balance (total and available).
  Future<truthcoinv1truthcoin.GetBalanceResponse> getBalance(
    truthcoinv1truthcoin.GetBalanceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getBalance,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get current block count.
  Future<truthcoinv1truthcoin.GetBlockCountResponse> getBlockCount(
    truthcoinv1truthcoin.GetBlockCountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getBlockCount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stop the truthcoin node.
  Future<truthcoinv1truthcoin.StopResponse> stop(
    truthcoinv1truthcoin.StopRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new address from the wallet.
  Future<truthcoinv1truthcoin.GetNewAddressResponse> getNewAddress(
    truthcoinv1truthcoin.GetNewAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Withdraw to mainchain.
  Future<truthcoinv1truthcoin.WithdrawResponse> withdraw(
    truthcoinv1truthcoin.WithdrawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.withdraw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transfer within sidechain.
  Future<truthcoinv1truthcoin.TransferResponse> transfer(
    truthcoinv1truthcoin.TransferRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.transfer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get total sidechain wealth in sats.
  Future<truthcoinv1truthcoin.GetSidechainWealthResponse> getSidechainWealth(
    truthcoinv1truthcoin.GetSidechainWealthRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getSidechainWealth,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a deposit transaction.
  Future<truthcoinv1truthcoin.CreateDepositResponse> createDeposit(
    truthcoinv1truthcoin.CreateDepositRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.createDeposit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get pending withdrawal bundle.
  Future<truthcoinv1truthcoin.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
    truthcoinv1truthcoin.GetPendingWithdrawalBundleRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getPendingWithdrawalBundle,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Connect to a peer.
  Future<truthcoinv1truthcoin.ConnectPeerResponse> connectPeer(
    truthcoinv1truthcoin.ConnectPeerRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.connectPeer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List connected peers.
  Future<truthcoinv1truthcoin.ListPeersResponse> listPeers(
    truthcoinv1truthcoin.ListPeersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.listPeers,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Mine a block.
  Future<truthcoinv1truthcoin.MineResponse> mine(
    truthcoinv1truthcoin.MineRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.mine,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get block by hash.
  Future<truthcoinv1truthcoin.GetBlockResponse> getBlock(
    truthcoinv1truthcoin.GetBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get best mainchain block hash.
  Future<truthcoinv1truthcoin.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
    truthcoinv1truthcoin.GetBestMainchainBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getBestMainchainBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get best sidechain block hash.
  Future<truthcoinv1truthcoin.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
    truthcoinv1truthcoin.GetBestSidechainBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getBestSidechainBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get BMM inclusions for a block.
  Future<truthcoinv1truthcoin.GetBmmInclusionsResponse> getBmmInclusions(
    truthcoinv1truthcoin.GetBmmInclusionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getBmmInclusions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get wallet UTXOs.
  Future<truthcoinv1truthcoin.GetWalletUtxosResponse> getWalletUtxos(
    truthcoinv1truthcoin.GetWalletUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getWalletUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all UTXOs.
  Future<truthcoinv1truthcoin.ListUtxosResponse> listUtxos(
    truthcoinv1truthcoin.ListUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.listUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Remove transaction from mempool.
  Future<truthcoinv1truthcoin.RemoveFromMempoolResponse> removeFromMempool(
    truthcoinv1truthcoin.RemoveFromMempoolRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.removeFromMempool,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get latest failed withdrawal bundle height.
  Future<truthcoinv1truthcoin.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
    truthcoinv1truthcoin.GetLatestFailedWithdrawalBundleHeightRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getLatestFailedWithdrawalBundleHeight,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Generate a new mnemonic.
  Future<truthcoinv1truthcoin.GenerateMnemonicResponse> generateMnemonic(
    truthcoinv1truthcoin.GenerateMnemonicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.generateMnemonic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set seed from mnemonic.
  Future<truthcoinv1truthcoin.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
    truthcoinv1truthcoin.SetSeedFromMnemonicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.setSeedFromMnemonic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Raw JSON-RPC passthrough for debug console.
  Future<truthcoinv1truthcoin.CallRawResponse> callRaw(
    truthcoinv1truthcoin.CallRawRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.callRaw,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Refresh wallet state.
  Future<truthcoinv1truthcoin.RefreshWalletResponse> refreshWallet(
    truthcoinv1truthcoin.RefreshWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.refreshWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get transaction by txid.
  Future<truthcoinv1truthcoin.GetTransactionResponse> getTransaction(
    truthcoinv1truthcoin.GetTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get transaction info.
  Future<truthcoinv1truthcoin.GetTransactionInfoResponse> getTransactionInfo(
    truthcoinv1truthcoin.GetTransactionInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getTransactionInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get wallet addresses.
  Future<truthcoinv1truthcoin.GetWalletAddressesResponse> getWalletAddresses(
    truthcoinv1truthcoin.GetWalletAddressesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getWalletAddresses,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get owned UTXOs (confirmed).
  Future<truthcoinv1truthcoin.MyUtxosResponse> myUtxos(
    truthcoinv1truthcoin.MyUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.myUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get owned UTXOs (unconfirmed).
  Future<truthcoinv1truthcoin.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos(
    truthcoinv1truthcoin.MyUnconfirmedUtxosRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.myUnconfirmedUtxos,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Calculate initial liquidity required for market creation.
  Future<truthcoinv1truthcoin.CalculateInitialLiquidityResponse> calculateInitialLiquidity(
    truthcoinv1truthcoin.CalculateInitialLiquidityRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.calculateInitialLiquidity,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a new prediction market.
  Future<truthcoinv1truthcoin.MarketCreateResponse> marketCreate(
    truthcoinv1truthcoin.MarketCreateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.marketCreate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all markets.
  Future<truthcoinv1truthcoin.MarketListResponse> marketList(
    truthcoinv1truthcoin.MarketListRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.marketList,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a specific market.
  Future<truthcoinv1truthcoin.MarketGetResponse> marketGet(
    truthcoinv1truthcoin.MarketGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.marketGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Buy shares in a market.
  Future<truthcoinv1truthcoin.MarketBuyResponse> marketBuy(
    truthcoinv1truthcoin.MarketBuyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.marketBuy,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sell shares in a market.
  Future<truthcoinv1truthcoin.MarketSellResponse> marketSell(
    truthcoinv1truthcoin.MarketSellRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.marketSell,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get positions in a market.
  Future<truthcoinv1truthcoin.MarketPositionsResponse> marketPositions(
    truthcoinv1truthcoin.MarketPositionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.marketPositions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get slot system status and configuration.
  Future<truthcoinv1truthcoin.SlotStatusResponse> slotStatus(
    truthcoinv1truthcoin.SlotStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.slotStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List slots with optional filtering.
  Future<truthcoinv1truthcoin.SlotListResponse> slotList(
    truthcoinv1truthcoin.SlotListRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.slotList,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a specific slot by ID.
  Future<truthcoinv1truthcoin.SlotGetResponse> slotGet(
    truthcoinv1truthcoin.SlotGetRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.slotGet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Claim a decision slot.
  Future<truthcoinv1truthcoin.SlotClaimResponse> slotClaim(
    truthcoinv1truthcoin.SlotClaimRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.slotClaim,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Claim multiple slots as a category.
  Future<truthcoinv1truthcoin.SlotClaimCategoryResponse> slotClaimCategory(
    truthcoinv1truthcoin.SlotClaimCategoryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.slotClaimCategory,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Register as a voter.
  Future<truthcoinv1truthcoin.VoteRegisterResponse> voteRegister(
    truthcoinv1truthcoin.VoteRegisterRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.voteRegister,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get voter info.
  Future<truthcoinv1truthcoin.VoteVoterResponse> voteVoter(
    truthcoinv1truthcoin.VoteVoterRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.voteVoter,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all voters.
  Future<truthcoinv1truthcoin.VoteVotersResponse> voteVoters(
    truthcoinv1truthcoin.VoteVotersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.voteVoters,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Submit votes (batch).
  Future<truthcoinv1truthcoin.VoteSubmitResponse> voteSubmit(
    truthcoinv1truthcoin.VoteSubmitRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.voteSubmit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List votes with optional filters.
  Future<truthcoinv1truthcoin.VoteListResponse> voteList(
    truthcoinv1truthcoin.VoteListRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.voteList,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get voting period information.
  Future<truthcoinv1truthcoin.VotePeriodResponse> votePeriod(
    truthcoinv1truthcoin.VotePeriodRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.votePeriod,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transfer votecoins.
  Future<truthcoinv1truthcoin.VotecoinTransferResponse> votecoinTransfer(
    truthcoinv1truthcoin.VotecoinTransferRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.votecoinTransfer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get votecoin balance for an address.
  Future<truthcoinv1truthcoin.VotecoinBalanceResponse> votecoinBalance(
    truthcoinv1truthcoin.VotecoinBalanceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.votecoinBalance,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transfer votecoin (alternative method).
  Future<truthcoinv1truthcoin.TransferVotecoinResponse> transferVotecoin(
    truthcoinv1truthcoin.TransferVotecoinRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.transferVotecoin,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new encryption key.
  Future<truthcoinv1truthcoin.GetNewEncryptionKeyResponse> getNewEncryptionKey(
    truthcoinv1truthcoin.GetNewEncryptionKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getNewEncryptionKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a new verifying key.
  Future<truthcoinv1truthcoin.GetNewVerifyingKeyResponse> getNewVerifyingKey(
    truthcoinv1truthcoin.GetNewVerifyingKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.getNewVerifyingKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Encrypt a message.
  Future<truthcoinv1truthcoin.EncryptMsgResponse> encryptMsg(
    truthcoinv1truthcoin.EncryptMsgRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.encryptMsg,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Decrypt a message.
  Future<truthcoinv1truthcoin.DecryptMsgResponse> decryptMsg(
    truthcoinv1truthcoin.DecryptMsgRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.decryptMsg,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sign an arbitrary message with verifying key.
  Future<truthcoinv1truthcoin.SignArbitraryMsgResponse> signArbitraryMsg(
    truthcoinv1truthcoin.SignArbitraryMsgRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.signArbitraryMsg,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sign an arbitrary message as address.
  Future<truthcoinv1truthcoin.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
    truthcoinv1truthcoin.SignArbitraryMsgAsAddrRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.signArbitraryMsgAsAddr,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Verify a signature.
  Future<truthcoinv1truthcoin.VerifySignatureResponse> verifySignature(
    truthcoinv1truthcoin.VerifySignatureRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.TruthcoinService.verifySignature,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
