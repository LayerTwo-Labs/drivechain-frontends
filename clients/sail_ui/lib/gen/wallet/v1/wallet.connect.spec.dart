//
//  Generated code. Do not modify.
//  source: wallet/v1/wallet.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart' as walletv1wallet;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;

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
}