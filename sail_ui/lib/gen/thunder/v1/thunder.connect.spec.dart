//
//  Generated code. Do not modify.
//  source: thunder/v1/thunder.proto
//

import "package:connectrpc/connect.dart" as connect;
import "thunder.pb.dart" as thunderv1thunder;

abstract final class ThunderService {
  /// Fully-qualified name of the ThunderService service.
  static const name = 'thunder.v1.ThunderService';

  /// Get wallet balance (total and available).
  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    thunderv1thunder.GetBalanceRequest.new,
    thunderv1thunder.GetBalanceResponse.new,
  );

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    thunderv1thunder.GetBlockCountRequest.new,
    thunderv1thunder.GetBlockCountResponse.new,
  );

  /// Stop the thunder node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    thunderv1thunder.StopRequest.new,
    thunderv1thunder.StopResponse.new,
  );

  /// Get a new address from the wallet.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    thunderv1thunder.GetNewAddressRequest.new,
    thunderv1thunder.GetNewAddressResponse.new,
  );

  /// Withdraw to mainchain.
  static const withdraw = connect.Spec(
    '/$name/Withdraw',
    connect.StreamType.unary,
    thunderv1thunder.WithdrawRequest.new,
    thunderv1thunder.WithdrawResponse.new,
  );

  /// Transfer within sidechain.
  static const transfer = connect.Spec(
    '/$name/Transfer',
    connect.StreamType.unary,
    thunderv1thunder.TransferRequest.new,
    thunderv1thunder.TransferResponse.new,
  );

  /// Get total sidechain wealth in sats.
  static const getSidechainWealth = connect.Spec(
    '/$name/GetSidechainWealth',
    connect.StreamType.unary,
    thunderv1thunder.GetSidechainWealthRequest.new,
    thunderv1thunder.GetSidechainWealthResponse.new,
  );

  /// Create a deposit transaction.
  static const createDeposit = connect.Spec(
    '/$name/CreateDeposit',
    connect.StreamType.unary,
    thunderv1thunder.CreateDepositRequest.new,
    thunderv1thunder.CreateDepositResponse.new,
  );

  /// Get pending withdrawal bundle.
  static const getPendingWithdrawalBundle = connect.Spec(
    '/$name/GetPendingWithdrawalBundle',
    connect.StreamType.unary,
    thunderv1thunder.GetPendingWithdrawalBundleRequest.new,
    thunderv1thunder.GetPendingWithdrawalBundleResponse.new,
  );

  /// Connect to a peer.
  static const connectPeer = connect.Spec(
    '/$name/ConnectPeer',
    connect.StreamType.unary,
    thunderv1thunder.ConnectPeerRequest.new,
    thunderv1thunder.ConnectPeerResponse.new,
  );

  /// List connected peers.
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    thunderv1thunder.ListPeersRequest.new,
    thunderv1thunder.ListPeersResponse.new,
  );

  /// Mine a block.
  static const mine = connect.Spec(
    '/$name/Mine',
    connect.StreamType.unary,
    thunderv1thunder.MineRequest.new,
    thunderv1thunder.MineResponse.new,
  );

  /// Get block by hash.
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    thunderv1thunder.GetBlockRequest.new,
    thunderv1thunder.GetBlockResponse.new,
  );

  /// Get best mainchain block hash.
  static const getBestMainchainBlockHash = connect.Spec(
    '/$name/GetBestMainchainBlockHash',
    connect.StreamType.unary,
    thunderv1thunder.GetBestMainchainBlockHashRequest.new,
    thunderv1thunder.GetBestMainchainBlockHashResponse.new,
  );

  /// Get best sidechain block hash.
  static const getBestSidechainBlockHash = connect.Spec(
    '/$name/GetBestSidechainBlockHash',
    connect.StreamType.unary,
    thunderv1thunder.GetBestSidechainBlockHashRequest.new,
    thunderv1thunder.GetBestSidechainBlockHashResponse.new,
  );

  /// Get BMM inclusions for a block.
  static const getBmmInclusions = connect.Spec(
    '/$name/GetBmmInclusions',
    connect.StreamType.unary,
    thunderv1thunder.GetBmmInclusionsRequest.new,
    thunderv1thunder.GetBmmInclusionsResponse.new,
  );

  /// Get wallet UTXOs.
  static const getWalletUtxos = connect.Spec(
    '/$name/GetWalletUtxos',
    connect.StreamType.unary,
    thunderv1thunder.GetWalletUtxosRequest.new,
    thunderv1thunder.GetWalletUtxosResponse.new,
  );

  /// List all UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    thunderv1thunder.ListUtxosRequest.new,
    thunderv1thunder.ListUtxosResponse.new,
  );

  /// Remove transaction from mempool.
  static const removeFromMempool = connect.Spec(
    '/$name/RemoveFromMempool',
    connect.StreamType.unary,
    thunderv1thunder.RemoveFromMempoolRequest.new,
    thunderv1thunder.RemoveFromMempoolResponse.new,
  );

  /// Get latest failed withdrawal bundle height.
  static const getLatestFailedWithdrawalBundleHeight = connect.Spec(
    '/$name/GetLatestFailedWithdrawalBundleHeight',
    connect.StreamType.unary,
    thunderv1thunder.GetLatestFailedWithdrawalBundleHeightRequest.new,
    thunderv1thunder.GetLatestFailedWithdrawalBundleHeightResponse.new,
  );

  /// Generate a new mnemonic.
  static const generateMnemonic = connect.Spec(
    '/$name/GenerateMnemonic',
    connect.StreamType.unary,
    thunderv1thunder.GenerateMnemonicRequest.new,
    thunderv1thunder.GenerateMnemonicResponse.new,
  );

  /// Set seed from mnemonic.
  static const setSeedFromMnemonic = connect.Spec(
    '/$name/SetSeedFromMnemonic',
    connect.StreamType.unary,
    thunderv1thunder.SetSeedFromMnemonicRequest.new,
    thunderv1thunder.SetSeedFromMnemonicResponse.new,
  );

  /// Raw JSON-RPC passthrough for debug console.
  static const callRaw = connect.Spec(
    '/$name/CallRaw',
    connect.StreamType.unary,
    thunderv1thunder.CallRawRequest.new,
    thunderv1thunder.CallRawResponse.new,
  );
}
