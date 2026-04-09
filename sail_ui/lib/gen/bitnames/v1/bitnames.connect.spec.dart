//
//  Generated code. Do not modify.
//  source: bitnames/v1/bitnames.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitnames.pb.dart" as bitnamesv1bitnames;

abstract final class BitnamesService {
  /// Fully-qualified name of the BitnamesService service.
  static const name = 'bitnames.v1.BitnamesService';

  /// Get wallet balance (total and available).
  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetBalanceRequest.new,
    bitnamesv1bitnames.GetBalanceResponse.new,
  );

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetBlockCountRequest.new,
    bitnamesv1bitnames.GetBlockCountResponse.new,
  );

  /// Stop the bitnames node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    bitnamesv1bitnames.StopRequest.new,
    bitnamesv1bitnames.StopResponse.new,
  );

  /// Get a new address from the wallet.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetNewAddressRequest.new,
    bitnamesv1bitnames.GetNewAddressResponse.new,
  );

  /// Withdraw to mainchain.
  static const withdraw = connect.Spec(
    '/$name/Withdraw',
    connect.StreamType.unary,
    bitnamesv1bitnames.WithdrawRequest.new,
    bitnamesv1bitnames.WithdrawResponse.new,
  );

  /// Transfer within sidechain.
  static const transfer = connect.Spec(
    '/$name/Transfer',
    connect.StreamType.unary,
    bitnamesv1bitnames.TransferRequest.new,
    bitnamesv1bitnames.TransferResponse.new,
  );

  /// Get total sidechain wealth in sats.
  static const getSidechainWealth = connect.Spec(
    '/$name/GetSidechainWealth',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetSidechainWealthRequest.new,
    bitnamesv1bitnames.GetSidechainWealthResponse.new,
  );

  /// Create a deposit transaction.
  static const createDeposit = connect.Spec(
    '/$name/CreateDeposit',
    connect.StreamType.unary,
    bitnamesv1bitnames.CreateDepositRequest.new,
    bitnamesv1bitnames.CreateDepositResponse.new,
  );

  /// Get pending withdrawal bundle.
  static const getPendingWithdrawalBundle = connect.Spec(
    '/$name/GetPendingWithdrawalBundle',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetPendingWithdrawalBundleRequest.new,
    bitnamesv1bitnames.GetPendingWithdrawalBundleResponse.new,
  );

  /// Connect to a peer.
  static const connectPeer = connect.Spec(
    '/$name/ConnectPeer',
    connect.StreamType.unary,
    bitnamesv1bitnames.ConnectPeerRequest.new,
    bitnamesv1bitnames.ConnectPeerResponse.new,
  );

  /// List connected peers.
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    bitnamesv1bitnames.ListPeersRequest.new,
    bitnamesv1bitnames.ListPeersResponse.new,
  );

  /// Mine a block.
  static const mine = connect.Spec(
    '/$name/Mine',
    connect.StreamType.unary,
    bitnamesv1bitnames.MineRequest.new,
    bitnamesv1bitnames.MineResponse.new,
  );

  /// Get block by hash.
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetBlockRequest.new,
    bitnamesv1bitnames.GetBlockResponse.new,
  );

  /// Get best mainchain block hash.
  static const getBestMainchainBlockHash = connect.Spec(
    '/$name/GetBestMainchainBlockHash',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetBestMainchainBlockHashRequest.new,
    bitnamesv1bitnames.GetBestMainchainBlockHashResponse.new,
  );

  /// Get best sidechain block hash.
  static const getBestSidechainBlockHash = connect.Spec(
    '/$name/GetBestSidechainBlockHash',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetBestSidechainBlockHashRequest.new,
    bitnamesv1bitnames.GetBestSidechainBlockHashResponse.new,
  );

  /// Get BMM inclusions for a block.
  static const getBmmInclusions = connect.Spec(
    '/$name/GetBmmInclusions',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetBmmInclusionsRequest.new,
    bitnamesv1bitnames.GetBmmInclusionsResponse.new,
  );

  /// Get wallet UTXOs.
  static const getWalletUtxos = connect.Spec(
    '/$name/GetWalletUtxos',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetWalletUtxosRequest.new,
    bitnamesv1bitnames.GetWalletUtxosResponse.new,
  );

  /// List all UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    bitnamesv1bitnames.ListUtxosRequest.new,
    bitnamesv1bitnames.ListUtxosResponse.new,
  );

  /// Get latest failed withdrawal bundle height.
  static const getLatestFailedWithdrawalBundleHeight = connect.Spec(
    '/$name/GetLatestFailedWithdrawalBundleHeight',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetLatestFailedWithdrawalBundleHeightRequest.new,
    bitnamesv1bitnames.GetLatestFailedWithdrawalBundleHeightResponse.new,
  );

  /// Generate a new mnemonic.
  static const generateMnemonic = connect.Spec(
    '/$name/GenerateMnemonic',
    connect.StreamType.unary,
    bitnamesv1bitnames.GenerateMnemonicRequest.new,
    bitnamesv1bitnames.GenerateMnemonicResponse.new,
  );

  /// Set seed from mnemonic.
  static const setSeedFromMnemonic = connect.Spec(
    '/$name/SetSeedFromMnemonic',
    connect.StreamType.unary,
    bitnamesv1bitnames.SetSeedFromMnemonicRequest.new,
    bitnamesv1bitnames.SetSeedFromMnemonicResponse.new,
  );

  /// Raw JSON-RPC passthrough for debug console.
  static const callRaw = connect.Spec(
    '/$name/CallRaw',
    connect.StreamType.unary,
    bitnamesv1bitnames.CallRawRequest.new,
    bitnamesv1bitnames.CallRawResponse.new,
  );

  /// Get BitName data by name.
  static const getBitNameData = connect.Spec(
    '/$name/GetBitNameData',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetBitNameDataRequest.new,
    bitnamesv1bitnames.GetBitNameDataResponse.new,
  );

  /// List all BitNames.
  static const listBitNames = connect.Spec(
    '/$name/ListBitNames',
    connect.StreamType.unary,
    bitnamesv1bitnames.ListBitNamesRequest.new,
    bitnamesv1bitnames.ListBitNamesResponse.new,
  );

  /// Register a BitName.
  static const registerBitName = connect.Spec(
    '/$name/RegisterBitName',
    connect.StreamType.unary,
    bitnamesv1bitnames.RegisterBitNameRequest.new,
    bitnamesv1bitnames.RegisterBitNameResponse.new,
  );

  /// Reserve a BitName.
  static const reserveBitName = connect.Spec(
    '/$name/ReserveBitName',
    connect.StreamType.unary,
    bitnamesv1bitnames.ReserveBitNameRequest.new,
    bitnamesv1bitnames.ReserveBitNameResponse.new,
  );

  /// Get a new encryption key.
  static const getNewEncryptionKey = connect.Spec(
    '/$name/GetNewEncryptionKey',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetNewEncryptionKeyRequest.new,
    bitnamesv1bitnames.GetNewEncryptionKeyResponse.new,
  );

  /// Get a new verifying key.
  static const getNewVerifyingKey = connect.Spec(
    '/$name/GetNewVerifyingKey',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetNewVerifyingKeyRequest.new,
    bitnamesv1bitnames.GetNewVerifyingKeyResponse.new,
  );

  /// Decrypt a message.
  static const decryptMsg = connect.Spec(
    '/$name/DecryptMsg',
    connect.StreamType.unary,
    bitnamesv1bitnames.DecryptMsgRequest.new,
    bitnamesv1bitnames.DecryptMsgResponse.new,
  );

  /// Encrypt a message.
  static const encryptMsg = connect.Spec(
    '/$name/EncryptMsg',
    connect.StreamType.unary,
    bitnamesv1bitnames.EncryptMsgRequest.new,
    bitnamesv1bitnames.EncryptMsgResponse.new,
  );

  /// Get paymail information.
  static const getPaymail = connect.Spec(
    '/$name/GetPaymail',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetPaymailRequest.new,
    bitnamesv1bitnames.GetPaymailResponse.new,
  );

  /// Resolve a commitment from a BitName.
  static const resolveCommit = connect.Spec(
    '/$name/ResolveCommit',
    connect.StreamType.unary,
    bitnamesv1bitnames.ResolveCommitRequest.new,
    bitnamesv1bitnames.ResolveCommitResponse.new,
  );

  /// Sign an arbitrary message with the specified verifying key.
  static const signArbitraryMsg = connect.Spec(
    '/$name/SignArbitraryMsg',
    connect.StreamType.unary,
    bitnamesv1bitnames.SignArbitraryMsgRequest.new,
    bitnamesv1bitnames.SignArbitraryMsgResponse.new,
  );

  /// Sign an arbitrary message as a specific address.
  static const signArbitraryMsgAsAddr = connect.Spec(
    '/$name/SignArbitraryMsgAsAddr',
    connect.StreamType.unary,
    bitnamesv1bitnames.SignArbitraryMsgAsAddrRequest.new,
    bitnamesv1bitnames.SignArbitraryMsgAsAddrResponse.new,
  );

  /// Get wallet addresses.
  static const getWalletAddresses = connect.Spec(
    '/$name/GetWalletAddresses',
    connect.StreamType.unary,
    bitnamesv1bitnames.GetWalletAddressesRequest.new,
    bitnamesv1bitnames.GetWalletAddressesResponse.new,
  );

  /// List owned UTXOs.
  static const myUtxos = connect.Spec(
    '/$name/MyUtxos',
    connect.StreamType.unary,
    bitnamesv1bitnames.MyUtxosRequest.new,
    bitnamesv1bitnames.MyUtxosResponse.new,
  );

  /// Get OpenAPI schema.
  static const openapiSchema = connect.Spec(
    '/$name/OpenapiSchema',
    connect.StreamType.unary,
    bitnamesv1bitnames.OpenapiSchemaRequest.new,
    bitnamesv1bitnames.OpenapiSchemaResponse.new,
  );
}
