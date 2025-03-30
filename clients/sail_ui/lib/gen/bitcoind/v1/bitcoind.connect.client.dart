//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitcoind.pb.dart" as bitcoindv1bitcoind;
import "bitcoind.connect.spec.dart" as specs;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

extension type BitcoindServiceClient (connect.Transport _transport) {
  /// Lists the ten most recent transactions, both confirmed and unconfirmed.
  Future<bitcoindv1bitcoind.ListRecentTransactionsResponse> listRecentTransactions(
    bitcoindv1bitcoind.ListRecentTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.listRecentTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists blocks with pagination support
  Future<bitcoindv1bitcoind.ListBlocksResponse> listBlocks(
    bitcoindv1bitcoind.ListBlocksRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.listBlocks,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get a specific block by hash or height
  Future<bitcoindv1bitcoind.GetBlockResponse> getBlock(
    bitcoindv1bitcoind.GetBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.getBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get basic blockchain info like height, last block time, peers etc.
  Future<bitcoindv1bitcoind.GetBlockchainInfoResponse> getBlockchainInfo(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.getBlockchainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists very basic info about all peers
  Future<bitcoindv1bitcoind.ListPeersResponse> listPeers(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.listPeers,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Lists very basic info about all peers
  Future<bitcoindv1bitcoind.EstimateSmartFeeResponse> estimateSmartFee(
    bitcoindv1bitcoind.EstimateSmartFeeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.estimateSmartFee,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.GetRawTransactionResponse> getRawTransaction(
    bitcoindv1bitcoind.GetRawTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.getRawTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Wallet management
  Future<bitcoindv1bitcoind.CreateWalletResponse> createWallet(
    bitcoindv1bitcoind.CreateWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.createWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.BackupWalletResponse> backupWallet(
    bitcoindv1bitcoind.BackupWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.backupWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.DumpWalletResponse> dumpWallet(
    bitcoindv1bitcoind.DumpWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.dumpWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.ImportWalletResponse> importWallet(
    bitcoindv1bitcoind.ImportWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.importWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.UnloadWalletResponse> unloadWallet(
    bitcoindv1bitcoind.UnloadWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.unloadWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Key/Address management
  Future<bitcoindv1bitcoind.DumpPrivKeyResponse> dumpPrivKey(
    bitcoindv1bitcoind.DumpPrivKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.dumpPrivKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.ImportPrivKeyResponse> importPrivKey(
    bitcoindv1bitcoind.ImportPrivKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.importPrivKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.ImportAddressResponse> importAddress(
    bitcoindv1bitcoind.ImportAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.importAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.ImportPubKeyResponse> importPubKey(
    bitcoindv1bitcoind.ImportPubKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.importPubKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.KeyPoolRefillResponse> keyPoolRefill(
    bitcoindv1bitcoind.KeyPoolRefillRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.keyPoolRefill,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Account operations
  Future<bitcoindv1bitcoind.GetAccountResponse> getAccount(
    bitcoindv1bitcoind.GetAccountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.getAccount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.SetAccountResponse> setAccount(
    bitcoindv1bitcoind.SetAccountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.setAccount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.GetAddressesByAccountResponse> getAddressesByAccount(
    bitcoindv1bitcoind.GetAddressesByAccountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.getAddressesByAccount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.ListAccountsResponse> listAccounts(
    bitcoindv1bitcoind.ListAccountsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.listAccounts,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Multi-sig operations
  Future<bitcoindv1bitcoind.AddMultisigAddressResponse> addMultisigAddress(
    bitcoindv1bitcoind.AddMultisigAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.addMultisigAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoindv1bitcoind.CreateMultisigResponse> createMultisig(
    bitcoindv1bitcoind.CreateMultisigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoindService.createMultisig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
