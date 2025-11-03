//
//  Generated code. Do not modify.
//  source: wallet/v1/wallet.proto
//

import "package:connectrpc/connect.dart" as connect;
import "wallet.pb.dart" as walletv1wallet;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

abstract final class WalletService {
  /// Fully-qualified name of the WalletService service.
  static const name = 'wallet.v1.WalletService';

  static const sendTransaction = connect.Spec(
    '/$name/SendTransaction',
    connect.StreamType.unary,
    walletv1wallet.SendTransactionRequest.new,
    walletv1wallet.SendTransactionResponse.new,
  );

  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    walletv1wallet.GetBalanceResponse.new,
  );

  /// Problem: deriving nilly willy here is potentially problematic. There's no way of listing
  /// out unused addresses, so we risk crossing the sync gap.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    walletv1wallet.GetNewAddressResponse.new,
  );

  static const listTransactions = connect.Spec(
    '/$name/ListTransactions',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    walletv1wallet.ListTransactionsResponse.new,
  );

  static const listUnspent = connect.Spec(
    '/$name/ListUnspent',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    walletv1wallet.ListUnspentResponse.new,
  );

  static const listReceiveAddresses = connect.Spec(
    '/$name/ListReceiveAddresses',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    walletv1wallet.ListReceiveAddressesResponse.new,
  );

  static const listSidechainDeposits = connect.Spec(
    '/$name/ListSidechainDeposits',
    connect.StreamType.unary,
    walletv1wallet.ListSidechainDepositsRequest.new,
    walletv1wallet.ListSidechainDepositsResponse.new,
  );

  static const createSidechainDeposit = connect.Spec(
    '/$name/CreateSidechainDeposit',
    connect.StreamType.unary,
    walletv1wallet.CreateSidechainDepositRequest.new,
    walletv1wallet.CreateSidechainDepositResponse.new,
  );

  static const signMessage = connect.Spec(
    '/$name/SignMessage',
    connect.StreamType.unary,
    walletv1wallet.SignMessageRequest.new,
    walletv1wallet.SignMessageResponse.new,
  );

  static const verifyMessage = connect.Spec(
    '/$name/VerifyMessage',
    connect.StreamType.unary,
    walletv1wallet.VerifyMessageRequest.new,
    walletv1wallet.VerifyMessageResponse.new,
  );

  static const getStats = connect.Spec(
    '/$name/GetStats',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    walletv1wallet.GetStatsResponse.new,
  );

  /// Wallet unlock/lock for cheque operations
  static const unlockWallet = connect.Spec(
    '/$name/UnlockWallet',
    connect.StreamType.unary,
    walletv1wallet.UnlockWalletRequest.new,
    googleprotobufempty.Empty.new,
  );

  static const lockWallet = connect.Spec(
    '/$name/LockWallet',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    googleprotobufempty.Empty.new,
  );

  static const isWalletUnlocked = connect.Spec(
    '/$name/IsWalletUnlocked',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    googleprotobufempty.Empty.new,
  );

  /// Cheque operations
  static const createCheque = connect.Spec(
    '/$name/CreateCheque',
    connect.StreamType.unary,
    walletv1wallet.CreateChequeRequest.new,
    walletv1wallet.CreateChequeResponse.new,
  );

  static const getCheque = connect.Spec(
    '/$name/GetCheque',
    connect.StreamType.unary,
    walletv1wallet.GetChequeRequest.new,
    walletv1wallet.GetChequeResponse.new,
  );

  static const getChequePrivateKey = connect.Spec(
    '/$name/GetChequePrivateKey',
    connect.StreamType.unary,
    walletv1wallet.GetChequePrivateKeyRequest.new,
    walletv1wallet.GetChequePrivateKeyResponse.new,
  );

  static const listCheques = connect.Spec(
    '/$name/ListCheques',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    walletv1wallet.ListChequesResponse.new,
  );

  static const checkChequeFunding = connect.Spec(
    '/$name/CheckChequeFunding',
    connect.StreamType.unary,
    walletv1wallet.CheckChequeFundingRequest.new,
    walletv1wallet.CheckChequeFundingResponse.new,
  );

  static const sweepCheque = connect.Spec(
    '/$name/SweepCheque',
    connect.StreamType.unary,
    walletv1wallet.SweepChequeRequest.new,
    walletv1wallet.SweepChequeResponse.new,
  );

  static const deleteCheque = connect.Spec(
    '/$name/DeleteCheque',
    connect.StreamType.unary,
    walletv1wallet.DeleteChequeRequest.new,
    googleprotobufempty.Empty.new,
  );
}
