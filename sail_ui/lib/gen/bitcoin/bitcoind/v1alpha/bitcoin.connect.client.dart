//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitcoin.pb.dart" as bitcoinbitcoindv1alphabitcoin;
import "bitcoin.connect.spec.dart" as specs;
import "../../../google/protobuf/empty.pb.dart" as googleprotobufempty;

extension type BitcoinServiceClient(connect.Transport _transport) {
  Future<bitcoinbitcoindv1alphabitcoin.GetBlockchainInfoResponse> getBlockchainInfo(
    bitcoinbitcoindv1alphabitcoin.GetBlockchainInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getBlockchainInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.GetPeerInfoResponse> getPeerInfo(
    bitcoinbitcoindv1alphabitcoin.GetPeerInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getPeerInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Fetches in-wallet transactions
  Future<bitcoinbitcoindv1alphabitcoin.GetTransactionResponse> getTransaction(
    bitcoinbitcoindv1alphabitcoin.GetTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ListSinceBlockResponse> listSinceBlock(
    bitcoinbitcoindv1alphabitcoin.ListSinceBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.listSinceBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Wallet stuff
  Future<bitcoinbitcoindv1alphabitcoin.GetNewAddressResponse> getNewAddress(
    bitcoinbitcoindv1alphabitcoin.GetNewAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.GetWalletInfoResponse> getWalletInfo(
    bitcoinbitcoindv1alphabitcoin.GetWalletInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getWalletInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.GetBalancesResponse> getBalances(
    bitcoinbitcoindv1alphabitcoin.GetBalancesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getBalances,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.SendResponse> send(
    bitcoinbitcoindv1alphabitcoin.SendRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.send,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.SendToAddressResponse> sendToAddress(
    bitcoinbitcoindv1alphabitcoin.SendToAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.sendToAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.BumpFeeResponse> bumpFee(
    bitcoinbitcoindv1alphabitcoin.BumpFeeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.bumpFee,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.EstimateSmartFeeResponse> estimateSmartFee(
    bitcoinbitcoindv1alphabitcoin.EstimateSmartFeeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.estimateSmartFee,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Import a descriptor. If importing a watch-only descriptor, the wallet itself needs
  /// to be watch-only as well. The descriptor also needs to be normalized, with a
  /// checksum. This can be obtained by running it through GetDescriptorInfo.
  Future<bitcoinbitcoindv1alphabitcoin.ImportDescriptorsResponse> importDescriptors(
    bitcoinbitcoindv1alphabitcoin.ImportDescriptorsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.importDescriptors,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ListWalletsResponse> listWallets(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.listWallets,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ListUnspentResponse> listUnspent(
    bitcoinbitcoindv1alphabitcoin.ListUnspentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.listUnspent,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ListTransactionsResponse> listTransactions(
    bitcoinbitcoindv1alphabitcoin.ListTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.listTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.GetDescriptorInfoResponse> getDescriptorInfo(
    bitcoinbitcoindv1alphabitcoin.GetDescriptorInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getDescriptorInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.GetAddressInfoResponse> getAddressInfo(
    bitcoinbitcoindv1alphabitcoin.GetAddressInfoRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getAddressInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Mempool stuff
  Future<bitcoinbitcoindv1alphabitcoin.GetRawMempoolResponse> getRawMempool(
    bitcoinbitcoindv1alphabitcoin.GetRawMempoolRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getRawMempool,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Raw TX stuff
  Future<bitcoinbitcoindv1alphabitcoin.GetRawTransactionResponse> getRawTransaction(
    bitcoinbitcoindv1alphabitcoin.GetRawTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getRawTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.DecodeRawTransactionResponse> decodeRawTransaction(
    bitcoinbitcoindv1alphabitcoin.DecodeRawTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.decodeRawTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.CreateRawTransactionResponse> createRawTransaction(
    bitcoinbitcoindv1alphabitcoin.CreateRawTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.createRawTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.GetBlockResponse> getBlock(
    bitcoinbitcoindv1alphabitcoin.GetBlockRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getBlock,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.GetBlockHashResponse> getBlockHash(
    bitcoinbitcoindv1alphabitcoin.GetBlockHashRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getBlockHash,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Wallet management
  Future<bitcoinbitcoindv1alphabitcoin.CreateWalletResponse> createWallet(
    bitcoinbitcoindv1alphabitcoin.CreateWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.createWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.BackupWalletResponse> backupWallet(
    bitcoinbitcoindv1alphabitcoin.BackupWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.backupWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.DumpWalletResponse> dumpWallet(
    bitcoinbitcoindv1alphabitcoin.DumpWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.dumpWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ImportWalletResponse> importWallet(
    bitcoinbitcoindv1alphabitcoin.ImportWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.importWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.UnloadWalletResponse> unloadWallet(
    bitcoinbitcoindv1alphabitcoin.UnloadWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.unloadWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Key/Address management
  Future<bitcoinbitcoindv1alphabitcoin.DumpPrivKeyResponse> dumpPrivKey(
    bitcoinbitcoindv1alphabitcoin.DumpPrivKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.dumpPrivKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ImportPrivKeyResponse> importPrivKey(
    bitcoinbitcoindv1alphabitcoin.ImportPrivKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.importPrivKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ImportAddressResponse> importAddress(
    bitcoinbitcoindv1alphabitcoin.ImportAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.importAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ImportPubKeyResponse> importPubKey(
    bitcoinbitcoindv1alphabitcoin.ImportPubKeyRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.importPubKey,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.KeyPoolRefillResponse> keyPoolRefill(
    bitcoinbitcoindv1alphabitcoin.KeyPoolRefillRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.keyPoolRefill,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Account operations
  Future<bitcoinbitcoindv1alphabitcoin.GetAccountResponse> getAccount(
    bitcoinbitcoindv1alphabitcoin.GetAccountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getAccount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.SetAccountResponse> setAccount(
    bitcoinbitcoindv1alphabitcoin.SetAccountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.setAccount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.GetAddressesByAccountResponse> getAddressesByAccount(
    bitcoinbitcoindv1alphabitcoin.GetAddressesByAccountRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getAddressesByAccount,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.ListAccountsResponse> listAccounts(
    bitcoinbitcoindv1alphabitcoin.ListAccountsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.listAccounts,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Multi-sig operations
  Future<bitcoinbitcoindv1alphabitcoin.AddMultisigAddressResponse> addMultisigAddress(
    bitcoinbitcoindv1alphabitcoin.AddMultisigAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.addMultisigAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.CreateMultisigResponse> createMultisig(
    bitcoinbitcoindv1alphabitcoin.CreateMultisigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.createMultisig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PSBT handling
  Future<bitcoinbitcoindv1alphabitcoin.CreatePsbtResponse> createPsbt(
    bitcoinbitcoindv1alphabitcoin.CreatePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.createPsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.DecodePsbtResponse> decodePsbt(
    bitcoinbitcoindv1alphabitcoin.DecodePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.decodePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.AnalyzePsbtResponse> analyzePsbt(
    bitcoinbitcoindv1alphabitcoin.AnalyzePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.analyzePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.CombinePsbtResponse> combinePsbt(
    bitcoinbitcoindv1alphabitcoin.CombinePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.combinePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.UtxoUpdatePsbtResponse> utxoUpdatePsbt(
    bitcoinbitcoindv1alphabitcoin.UtxoUpdatePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.utxoUpdatePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitcoinbitcoindv1alphabitcoin.JoinPsbtsResponse> joinPsbts(
    bitcoinbitcoindv1alphabitcoin.JoinPsbtsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.joinPsbts,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Transaction misc
  Future<bitcoinbitcoindv1alphabitcoin.TestMempoolAcceptResponse> testMempoolAccept(
    bitcoinbitcoindv1alphabitcoin.TestMempoolAcceptRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.testMempoolAccept,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Returns information about the active ZeroMQ notifications.
  Future<bitcoinbitcoindv1alphabitcoin.GetZmqNotificationsResponse> getZmqNotifications(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitcoinService.getZmqNotifications,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
