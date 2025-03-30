//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitcoind.pb.dart" as bitcoindv1bitcoind;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

abstract final class BitcoindService {
  /// Fully-qualified name of the BitcoindService service.
  static const name = 'bitcoind.v1.BitcoindService';

  /// Lists the ten most recent transactions, both confirmed and unconfirmed.
  static const listRecentTransactions = connect.Spec(
    '/$name/ListRecentTransactions',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ListRecentTransactionsRequest.new,
    bitcoindv1bitcoind.ListRecentTransactionsResponse.new,
  );

  /// Lists blocks with pagination support
  static const listBlocks = connect.Spec(
    '/$name/ListBlocks',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ListBlocksRequest.new,
    bitcoindv1bitcoind.ListBlocksResponse.new,
  );

  /// Get a specific block by hash or height
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    bitcoindv1bitcoind.GetBlockRequest.new,
    bitcoindv1bitcoind.GetBlockResponse.new,
  );

  /// Get basic blockchain info like height, last block time, peers etc.
  static const getBlockchainInfo = connect.Spec(
    '/$name/GetBlockchainInfo',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitcoindv1bitcoind.GetBlockchainInfoResponse.new,
  );

  /// Lists very basic info about all peers
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitcoindv1bitcoind.ListPeersResponse.new,
  );

  /// Lists very basic info about all peers
  static const estimateSmartFee = connect.Spec(
    '/$name/EstimateSmartFee',
    connect.StreamType.unary,
    bitcoindv1bitcoind.EstimateSmartFeeRequest.new,
    bitcoindv1bitcoind.EstimateSmartFeeResponse.new,
  );

  static const getRawTransaction = connect.Spec(
    '/$name/GetRawTransaction',
    connect.StreamType.unary,
    bitcoindv1bitcoind.GetRawTransactionRequest.new,
    bitcoindv1bitcoind.GetRawTransactionResponse.new,
  );

  /// Wallet management
  static const createWallet = connect.Spec(
    '/$name/CreateWallet',
    connect.StreamType.unary,
    bitcoindv1bitcoind.CreateWalletRequest.new,
    bitcoindv1bitcoind.CreateWalletResponse.new,
  );

  static const backupWallet = connect.Spec(
    '/$name/BackupWallet',
    connect.StreamType.unary,
    bitcoindv1bitcoind.BackupWalletRequest.new,
    bitcoindv1bitcoind.BackupWalletResponse.new,
  );

  static const dumpWallet = connect.Spec(
    '/$name/DumpWallet',
    connect.StreamType.unary,
    bitcoindv1bitcoind.DumpWalletRequest.new,
    bitcoindv1bitcoind.DumpWalletResponse.new,
  );

  static const importWallet = connect.Spec(
    '/$name/ImportWallet',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ImportWalletRequest.new,
    bitcoindv1bitcoind.ImportWalletResponse.new,
  );

  static const unloadWallet = connect.Spec(
    '/$name/UnloadWallet',
    connect.StreamType.unary,
    bitcoindv1bitcoind.UnloadWalletRequest.new,
    bitcoindv1bitcoind.UnloadWalletResponse.new,
  );

  /// Key/Address management
  static const dumpPrivKey = connect.Spec(
    '/$name/DumpPrivKey',
    connect.StreamType.unary,
    bitcoindv1bitcoind.DumpPrivKeyRequest.new,
    bitcoindv1bitcoind.DumpPrivKeyResponse.new,
  );

  static const importPrivKey = connect.Spec(
    '/$name/ImportPrivKey',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ImportPrivKeyRequest.new,
    bitcoindv1bitcoind.ImportPrivKeyResponse.new,
  );

  static const importAddress = connect.Spec(
    '/$name/ImportAddress',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ImportAddressRequest.new,
    bitcoindv1bitcoind.ImportAddressResponse.new,
  );

  static const importPubKey = connect.Spec(
    '/$name/ImportPubKey',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ImportPubKeyRequest.new,
    bitcoindv1bitcoind.ImportPubKeyResponse.new,
  );

  static const keyPoolRefill = connect.Spec(
    '/$name/KeyPoolRefill',
    connect.StreamType.unary,
    bitcoindv1bitcoind.KeyPoolRefillRequest.new,
    bitcoindv1bitcoind.KeyPoolRefillResponse.new,
  );

  /// Account operations
  static const getAccount = connect.Spec(
    '/$name/GetAccount',
    connect.StreamType.unary,
    bitcoindv1bitcoind.GetAccountRequest.new,
    bitcoindv1bitcoind.GetAccountResponse.new,
  );

  static const setAccount = connect.Spec(
    '/$name/SetAccount',
    connect.StreamType.unary,
    bitcoindv1bitcoind.SetAccountRequest.new,
    bitcoindv1bitcoind.SetAccountResponse.new,
  );

  static const getAddressesByAccount = connect.Spec(
    '/$name/GetAddressesByAccount',
    connect.StreamType.unary,
    bitcoindv1bitcoind.GetAddressesByAccountRequest.new,
    bitcoindv1bitcoind.GetAddressesByAccountResponse.new,
  );

  static const listAccounts = connect.Spec(
    '/$name/ListAccounts',
    connect.StreamType.unary,
    bitcoindv1bitcoind.ListAccountsRequest.new,
    bitcoindv1bitcoind.ListAccountsResponse.new,
  );

  /// Multi-sig operations
  static const addMultisigAddress = connect.Spec(
    '/$name/AddMultisigAddress',
    connect.StreamType.unary,
    bitcoindv1bitcoind.AddMultisigAddressRequest.new,
    bitcoindv1bitcoind.AddMultisigAddressResponse.new,
  );

  static const createMultisig = connect.Spec(
    '/$name/CreateMultisig',
    connect.StreamType.unary,
    bitcoindv1bitcoind.CreateMultisigRequest.new,
    bitcoindv1bitcoind.CreateMultisigResponse.new,
  );
}
