//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/wallet.proto
//

import "package:connectrpc/connect.dart" as connect;
import "wallet.pb.dart" as cusfmainchainv1wallet;

abstract final class WalletService {
  /// Fully-qualified name of the WalletService service.
  static const name = 'cusf.mainchain.v1.WalletService';

  static const broadcastWithdrawalBundle = connect.Spec(
    '/$name/BroadcastWithdrawalBundle',
    connect.StreamType.unary,
    cusfmainchainv1wallet.BroadcastWithdrawalBundleRequest.new,
    cusfmainchainv1wallet.BroadcastWithdrawalBundleResponse.new,
  );

  static const createBmmCriticalDataTransaction = connect.Spec(
    '/$name/CreateBmmCriticalDataTransaction',
    connect.StreamType.unary,
    cusfmainchainv1wallet.CreateBmmCriticalDataTransactionRequest.new,
    cusfmainchainv1wallet.CreateBmmCriticalDataTransactionResponse.new,
  );

  static const createDepositTransaction = connect.Spec(
    '/$name/CreateDepositTransaction',
    connect.StreamType.unary,
    cusfmainchainv1wallet.CreateDepositTransactionRequest.new,
    cusfmainchainv1wallet.CreateDepositTransactionResponse.new,
  );

  static const createNewAddress = connect.Spec(
    '/$name/CreateNewAddress',
    connect.StreamType.unary,
    cusfmainchainv1wallet.CreateNewAddressRequest.new,
    cusfmainchainv1wallet.CreateNewAddressResponse.new,
  );

  /// Create a new sidechain proposal (M1 in BIP300) and persist to the local
  /// database for further processing.
  /// Sidechain proposals must be included in the coinbase transaction of a
  /// newly mined block, so this proposal is not active until the wallet has
  /// been able to generate a new block.
  /// Returns a stream of (non-)confirmation events for the sidechain proposal.
  static const createSidechainProposal = connect.Spec(
    '/$name/CreateSidechainProposal',
    connect.StreamType.server,
    cusfmainchainv1wallet.CreateSidechainProposalRequest.new,
    cusfmainchainv1wallet.CreateSidechainProposalResponse.new,
  );

  static const createWallet = connect.Spec(
    '/$name/CreateWallet',
    connect.StreamType.unary,
    cusfmainchainv1wallet.CreateWalletRequest.new,
    cusfmainchainv1wallet.CreateWalletResponse.new,
  );

  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    cusfmainchainv1wallet.GetBalanceRequest.new,
    cusfmainchainv1wallet.GetBalanceResponse.new,
  );

  static const listSidechainDepositTransactions = connect.Spec(
    '/$name/ListSidechainDepositTransactions',
    connect.StreamType.unary,
    cusfmainchainv1wallet.ListSidechainDepositTransactionsRequest.new,
    cusfmainchainv1wallet.ListSidechainDepositTransactionsResponse.new,
  );

  static const listTransactions = connect.Spec(
    '/$name/ListTransactions',
    connect.StreamType.unary,
    cusfmainchainv1wallet.ListTransactionsRequest.new,
    cusfmainchainv1wallet.ListTransactionsResponse.new,
  );

  static const sendTransaction = connect.Spec(
    '/$name/SendTransaction',
    connect.StreamType.unary,
    cusfmainchainv1wallet.SendTransactionRequest.new,
    cusfmainchainv1wallet.SendTransactionResponse.new,
  );

  static const unlockWallet = connect.Spec(
    '/$name/UnlockWallet',
    connect.StreamType.unary,
    cusfmainchainv1wallet.UnlockWalletRequest.new,
    cusfmainchainv1wallet.UnlockWalletResponse.new,
  );

  /// Regtest only
  static const generateBlocks = connect.Spec(
    '/$name/GenerateBlocks',
    connect.StreamType.server,
    cusfmainchainv1wallet.GenerateBlocksRequest.new,
    cusfmainchainv1wallet.GenerateBlocksResponse.new,
  );
}
