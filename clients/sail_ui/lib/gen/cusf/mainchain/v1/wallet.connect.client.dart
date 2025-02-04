//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/wallet.proto
//

import "package:connectrpc/connect.dart" as connect;
import "wallet.pb.dart" as cusfmainchainv1wallet;
import "wallet.connect.spec.dart" as specs;

extension type WalletServiceClient (connect.Transport _transport) {
  Future<cusfmainchainv1wallet.BroadcastWithdrawalBundleResponse> broadcastWithdrawalBundle(
    cusfmainchainv1wallet.BroadcastWithdrawalBundleRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.broadcastWithdrawalBundle,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.CreateBmmCriticalDataTransactionResponse> createBmmCriticalDataTransaction(
    cusfmainchainv1wallet.CreateBmmCriticalDataTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.createBmmCriticalDataTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.CreateDepositTransactionResponse> createDepositTransaction(
    cusfmainchainv1wallet.CreateDepositTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.createDepositTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.CreateNewAddressResponse> createNewAddress(
    cusfmainchainv1wallet.CreateNewAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.createNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a new sidechain proposal (M1 in BIP300) and persist to the local
  /// database for further processing.
  /// Sidechain proposals must be included in the coinbase transaction of a
  /// newly mined block, so this proposal is not active until the wallet has
  /// been able to generate a new block.
  /// Returns a stream of (non-)confirmation events for the sidechain proposal.
  Stream<cusfmainchainv1wallet.CreateSidechainProposalResponse> createSidechainProposal(
    cusfmainchainv1wallet.CreateSidechainProposalRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.WalletService.createSidechainProposal,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.CreateWalletResponse> createWallet(
    cusfmainchainv1wallet.CreateWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.createWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.GetBalanceResponse> getBalance(
    cusfmainchainv1wallet.GetBalanceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.getBalance,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.ListSidechainDepositTransactionsResponse> listSidechainDepositTransactions(
    cusfmainchainv1wallet.ListSidechainDepositTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.listSidechainDepositTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.ListTransactionsResponse> listTransactions(
    cusfmainchainv1wallet.ListTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.listTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.SendTransactionResponse> sendTransaction(
    cusfmainchainv1wallet.SendTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.sendTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<cusfmainchainv1wallet.UnlockWalletResponse> unlockWallet(
    cusfmainchainv1wallet.UnlockWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.unlockWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Regtest only
  Stream<cusfmainchainv1wallet.GenerateBlocksResponse> generateBlocks(
    cusfmainchainv1wallet.GenerateBlocksRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.WalletService.generateBlocks,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
