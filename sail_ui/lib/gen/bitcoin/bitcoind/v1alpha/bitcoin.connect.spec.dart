//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitcoin.pb.dart" as bitcoinbitcoindv1alphabitcoin;
import "../../../google/protobuf/empty.pb.dart" as googleprotobufempty;

abstract final class BitcoinService {
  /// Fully-qualified name of the BitcoinService service.
  static const name = 'bitcoin.bitcoind.v1alpha.BitcoinService';

  static const getBlockchainInfo = connect.Spec(
    '/$name/GetBlockchainInfo',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetBlockchainInfoRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetBlockchainInfoResponse.new,
  );

  static const getPeerInfo = connect.Spec(
    '/$name/GetPeerInfo',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetPeerInfoRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetPeerInfoResponse.new,
  );

  /// Fetches in-wallet transactions
  static const getTransaction = connect.Spec(
    '/$name/GetTransaction',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetTransactionRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetTransactionResponse.new,
  );

  static const listSinceBlock = connect.Spec(
    '/$name/ListSinceBlock',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ListSinceBlockRequest.new,
    bitcoinbitcoindv1alphabitcoin.ListSinceBlockResponse.new,
  );

  /// Wallet stuff
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetNewAddressRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetNewAddressResponse.new,
  );

  static const getWalletInfo = connect.Spec(
    '/$name/GetWalletInfo',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetWalletInfoRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetWalletInfoResponse.new,
  );

  static const getBalances = connect.Spec(
    '/$name/GetBalances',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetBalancesRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetBalancesResponse.new,
  );

  static const send = connect.Spec(
    '/$name/Send',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.SendRequest.new,
    bitcoinbitcoindv1alphabitcoin.SendResponse.new,
  );

  static const sendToAddress = connect.Spec(
    '/$name/SendToAddress',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.SendToAddressRequest.new,
    bitcoinbitcoindv1alphabitcoin.SendToAddressResponse.new,
  );

  static const bumpFee = connect.Spec(
    '/$name/BumpFee',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.BumpFeeRequest.new,
    bitcoinbitcoindv1alphabitcoin.BumpFeeResponse.new,
  );

  static const estimateSmartFee = connect.Spec(
    '/$name/EstimateSmartFee',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.EstimateSmartFeeRequest.new,
    bitcoinbitcoindv1alphabitcoin.EstimateSmartFeeResponse.new,
  );

  /// Import a descriptor. If importing a watch-only descriptor, the wallet itself needs
  /// to be watch-only as well. The descriptor also needs to be normalized, with a
  /// checksum. This can be obtained by running it through GetDescriptorInfo.
  static const importDescriptors = connect.Spec(
    '/$name/ImportDescriptors',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ImportDescriptorsRequest.new,
    bitcoinbitcoindv1alphabitcoin.ImportDescriptorsResponse.new,
  );

  static const listWallets = connect.Spec(
    '/$name/ListWallets',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitcoinbitcoindv1alphabitcoin.ListWalletsResponse.new,
  );

  static const listUnspent = connect.Spec(
    '/$name/ListUnspent',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ListUnspentRequest.new,
    bitcoinbitcoindv1alphabitcoin.ListUnspentResponse.new,
  );

  static const listTransactions = connect.Spec(
    '/$name/ListTransactions',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ListTransactionsRequest.new,
    bitcoinbitcoindv1alphabitcoin.ListTransactionsResponse.new,
  );

  static const getDescriptorInfo = connect.Spec(
    '/$name/GetDescriptorInfo',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetDescriptorInfoRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetDescriptorInfoResponse.new,
  );

  static const getAddressInfo = connect.Spec(
    '/$name/GetAddressInfo',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetAddressInfoRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetAddressInfoResponse.new,
  );

  /// Mempool stuff
  static const getRawMempool = connect.Spec(
    '/$name/GetRawMempool',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetRawMempoolRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetRawMempoolResponse.new,
  );

  /// Raw TX stuff
  static const getRawTransaction = connect.Spec(
    '/$name/GetRawTransaction',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetRawTransactionRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetRawTransactionResponse.new,
  );

  static const decodeRawTransaction = connect.Spec(
    '/$name/DecodeRawTransaction',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.DecodeRawTransactionRequest.new,
    bitcoinbitcoindv1alphabitcoin.DecodeRawTransactionResponse.new,
  );

  static const createRawTransaction = connect.Spec(
    '/$name/CreateRawTransaction',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.CreateRawTransactionRequest.new,
    bitcoinbitcoindv1alphabitcoin.CreateRawTransactionResponse.new,
  );

  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetBlockRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetBlockResponse.new,
  );

  static const getBlockHash = connect.Spec(
    '/$name/GetBlockHash',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetBlockHashRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetBlockHashResponse.new,
  );

  /// Wallet management
  static const createWallet = connect.Spec(
    '/$name/CreateWallet',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.CreateWalletRequest.new,
    bitcoinbitcoindv1alphabitcoin.CreateWalletResponse.new,
  );

  static const backupWallet = connect.Spec(
    '/$name/BackupWallet',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.BackupWalletRequest.new,
    bitcoinbitcoindv1alphabitcoin.BackupWalletResponse.new,
  );

  static const dumpWallet = connect.Spec(
    '/$name/DumpWallet',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.DumpWalletRequest.new,
    bitcoinbitcoindv1alphabitcoin.DumpWalletResponse.new,
  );

  static const importWallet = connect.Spec(
    '/$name/ImportWallet',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ImportWalletRequest.new,
    bitcoinbitcoindv1alphabitcoin.ImportWalletResponse.new,
  );

  static const unloadWallet = connect.Spec(
    '/$name/UnloadWallet',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.UnloadWalletRequest.new,
    bitcoinbitcoindv1alphabitcoin.UnloadWalletResponse.new,
  );

  /// Key/Address management
  static const dumpPrivKey = connect.Spec(
    '/$name/DumpPrivKey',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.DumpPrivKeyRequest.new,
    bitcoinbitcoindv1alphabitcoin.DumpPrivKeyResponse.new,
  );

  static const importPrivKey = connect.Spec(
    '/$name/ImportPrivKey',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ImportPrivKeyRequest.new,
    bitcoinbitcoindv1alphabitcoin.ImportPrivKeyResponse.new,
  );

  static const importAddress = connect.Spec(
    '/$name/ImportAddress',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ImportAddressRequest.new,
    bitcoinbitcoindv1alphabitcoin.ImportAddressResponse.new,
  );

  static const importPubKey = connect.Spec(
    '/$name/ImportPubKey',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ImportPubKeyRequest.new,
    bitcoinbitcoindv1alphabitcoin.ImportPubKeyResponse.new,
  );

  static const keyPoolRefill = connect.Spec(
    '/$name/KeyPoolRefill',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.KeyPoolRefillRequest.new,
    bitcoinbitcoindv1alphabitcoin.KeyPoolRefillResponse.new,
  );

  /// Account operations
  static const getAccount = connect.Spec(
    '/$name/GetAccount',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetAccountRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetAccountResponse.new,
  );

  static const setAccount = connect.Spec(
    '/$name/SetAccount',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.SetAccountRequest.new,
    bitcoinbitcoindv1alphabitcoin.SetAccountResponse.new,
  );

  static const getAddressesByAccount = connect.Spec(
    '/$name/GetAddressesByAccount',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.GetAddressesByAccountRequest.new,
    bitcoinbitcoindv1alphabitcoin.GetAddressesByAccountResponse.new,
  );

  static const listAccounts = connect.Spec(
    '/$name/ListAccounts',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.ListAccountsRequest.new,
    bitcoinbitcoindv1alphabitcoin.ListAccountsResponse.new,
  );

  /// Multi-sig operations
  static const addMultisigAddress = connect.Spec(
    '/$name/AddMultisigAddress',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.AddMultisigAddressRequest.new,
    bitcoinbitcoindv1alphabitcoin.AddMultisigAddressResponse.new,
  );

  static const createMultisig = connect.Spec(
    '/$name/CreateMultisig',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.CreateMultisigRequest.new,
    bitcoinbitcoindv1alphabitcoin.CreateMultisigResponse.new,
  );

  /// PSBT handling
  static const createPsbt = connect.Spec(
    '/$name/CreatePsbt',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.CreatePsbtRequest.new,
    bitcoinbitcoindv1alphabitcoin.CreatePsbtResponse.new,
  );

  static const decodePsbt = connect.Spec(
    '/$name/DecodePsbt',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.DecodePsbtRequest.new,
    bitcoinbitcoindv1alphabitcoin.DecodePsbtResponse.new,
  );

  static const analyzePsbt = connect.Spec(
    '/$name/AnalyzePsbt',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.AnalyzePsbtRequest.new,
    bitcoinbitcoindv1alphabitcoin.AnalyzePsbtResponse.new,
  );

  static const combinePsbt = connect.Spec(
    '/$name/CombinePsbt',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.CombinePsbtRequest.new,
    bitcoinbitcoindv1alphabitcoin.CombinePsbtResponse.new,
  );

  static const utxoUpdatePsbt = connect.Spec(
    '/$name/UtxoUpdatePsbt',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.UtxoUpdatePsbtRequest.new,
    bitcoinbitcoindv1alphabitcoin.UtxoUpdatePsbtResponse.new,
  );

  static const joinPsbts = connect.Spec(
    '/$name/JoinPsbts',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.JoinPsbtsRequest.new,
    bitcoinbitcoindv1alphabitcoin.JoinPsbtsResponse.new,
  );

  /// Transaction misc
  static const testMempoolAccept = connect.Spec(
    '/$name/TestMempoolAccept',
    connect.StreamType.unary,
    bitcoinbitcoindv1alphabitcoin.TestMempoolAcceptRequest.new,
    bitcoinbitcoindv1alphabitcoin.TestMempoolAcceptResponse.new,
  );

  /// Returns information about the active ZeroMQ notifications.
  static const getZmqNotifications = connect.Spec(
    '/$name/GetZmqNotifications',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitcoinbitcoindv1alphabitcoin.GetZmqNotificationsResponse.new,
  );
}
