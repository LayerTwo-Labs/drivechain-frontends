//
//  Generated code. Do not modify.
//  source: wallet/v1/wallet.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart' as walletv1wallet;
import 'package:sail_ui/gen/wallet/v1/wallet.connect.spec.dart' as specs;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;

extension type WalletServiceClient (connect.Transport _transport) {
  Future<walletv1wallet.SendTransactionResponse> sendTransaction(
    walletv1wallet.SendTransactionRequest input, {
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

  Future<walletv1wallet.GetBalanceResponse> getBalance(
    googleprotobufempty.Empty input, {
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

  /// Problem: deriving nilly willy here is potentially problematic. There's no way of listing
  /// out unused addresses, so we risk crossing the sync gap.
  Future<walletv1wallet.GetNewAddressResponse> getNewAddress(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.getNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletv1wallet.ListTransactionsResponse> listTransactions(
    googleprotobufempty.Empty input, {
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

  Future<walletv1wallet.ListSidechainDepositsResponse> listSidechainDeposits(
    walletv1wallet.ListSidechainDepositsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.listSidechainDeposits,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletv1wallet.CreateSidechainDepositResponse> createSidechainDeposit(
    walletv1wallet.CreateSidechainDepositRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletService.createSidechainDeposit,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
