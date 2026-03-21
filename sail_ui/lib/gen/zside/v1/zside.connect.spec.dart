//
//  Generated code. Do not modify.
//  source: zside/v1/zside.proto
//

import "package:connectrpc/connect.dart" as connect;
import "zside.pb.dart" as zsidev1zside;

abstract final class ZSideService {
  /// Fully-qualified name of the ZSideService service.
  static const name = 'zside.v1.ZSideService';

  /// Get wallet balance (total and available, with shielded/transparent breakdown).
  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    zsidev1zside.GetBalanceRequest.new,
    zsidev1zside.GetBalanceResponse.new,
  );

  /// Get detailed balance breakdown by pool type.
  static const getBalanceBreakdown = connect.Spec(
    '/$name/GetBalanceBreakdown',
    connect.StreamType.unary,
    zsidev1zside.GetBalanceBreakdownRequest.new,
    zsidev1zside.GetBalanceBreakdownResponse.new,
  );

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    zsidev1zside.GetBlockCountRequest.new,
    zsidev1zside.GetBlockCountResponse.new,
  );

  /// Stop the zside node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    zsidev1zside.StopRequest.new,
    zsidev1zside.StopResponse.new,
  );

  /// Get a new transparent address from the wallet.
  static const getNewTransparentAddress = connect.Spec(
    '/$name/GetNewTransparentAddress',
    connect.StreamType.unary,
    zsidev1zside.GetNewTransparentAddressRequest.new,
    zsidev1zside.GetNewTransparentAddressResponse.new,
  );

  /// Get a new shielded address from the wallet.
  static const getNewShieldedAddress = connect.Spec(
    '/$name/GetNewShieldedAddress',
    connect.StreamType.unary,
    zsidev1zside.GetNewShieldedAddressRequest.new,
    zsidev1zside.GetNewShieldedAddressResponse.new,
  );

  /// Get all shielded wallet addresses.
  static const getShieldedWalletAddresses = connect.Spec(
    '/$name/GetShieldedWalletAddresses',
    connect.StreamType.unary,
    zsidev1zside.GetShieldedWalletAddressesRequest.new,
    zsidev1zside.GetShieldedWalletAddressesResponse.new,
  );

  /// Get all transparent wallet addresses.
  static const getTransparentWalletAddresses = connect.Spec(
    '/$name/GetTransparentWalletAddresses',
    connect.StreamType.unary,
    zsidev1zside.GetTransparentWalletAddressesRequest.new,
    zsidev1zside.GetTransparentWalletAddressesResponse.new,
  );

  /// Withdraw to mainchain.
  static const withdraw = connect.Spec(
    '/$name/Withdraw',
    connect.StreamType.unary,
    zsidev1zside.WithdrawRequest.new,
    zsidev1zside.WithdrawResponse.new,
  );

  /// Transfer within sidechain (transparent).
  static const transparentTransfer = connect.Spec(
    '/$name/TransparentTransfer',
    connect.StreamType.unary,
    zsidev1zside.TransparentTransferRequest.new,
    zsidev1zside.TransparentTransferResponse.new,
  );

  /// Transfer within sidechain (shielded).
  static const shieldedTransfer = connect.Spec(
    '/$name/ShieldedTransfer',
    connect.StreamType.unary,
    zsidev1zside.ShieldedTransferRequest.new,
    zsidev1zside.ShieldedTransferResponse.new,
  );

  /// Shield transparent funds.
  static const shield = connect.Spec(
    '/$name/Shield',
    connect.StreamType.unary,
    zsidev1zside.ShieldRequest.new,
    zsidev1zside.ShieldResponse.new,
  );

  /// Unshield shielded funds.
  static const unshield = connect.Spec(
    '/$name/Unshield',
    connect.StreamType.unary,
    zsidev1zside.UnshieldRequest.new,
    zsidev1zside.UnshieldResponse.new,
  );

  /// Get total sidechain wealth in sats.
  static const getSidechainWealth = connect.Spec(
    '/$name/GetSidechainWealth',
    connect.StreamType.unary,
    zsidev1zside.GetSidechainWealthRequest.new,
    zsidev1zside.GetSidechainWealthResponse.new,
  );

  /// Create a deposit transaction.
  static const createDeposit = connect.Spec(
    '/$name/CreateDeposit',
    connect.StreamType.unary,
    zsidev1zside.CreateDepositRequest.new,
    zsidev1zside.CreateDepositResponse.new,
  );

  /// Get pending withdrawal bundle.
  static const getPendingWithdrawalBundle = connect.Spec(
    '/$name/GetPendingWithdrawalBundle',
    connect.StreamType.unary,
    zsidev1zside.GetPendingWithdrawalBundleRequest.new,
    zsidev1zside.GetPendingWithdrawalBundleResponse.new,
  );

  /// Connect to a peer.
  static const connectPeer = connect.Spec(
    '/$name/ConnectPeer',
    connect.StreamType.unary,
    zsidev1zside.ConnectPeerRequest.new,
    zsidev1zside.ConnectPeerResponse.new,
  );

  /// List connected peers.
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    zsidev1zside.ListPeersRequest.new,
    zsidev1zside.ListPeersResponse.new,
  );

  /// Mine a block.
  static const mine = connect.Spec(
    '/$name/Mine',
    connect.StreamType.unary,
    zsidev1zside.MineRequest.new,
    zsidev1zside.MineResponse.new,
  );

  /// Get block by hash.
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    zsidev1zside.GetBlockRequest.new,
    zsidev1zside.GetBlockResponse.new,
  );

  /// Get best mainchain block hash.
  static const getBestMainchainBlockHash = connect.Spec(
    '/$name/GetBestMainchainBlockHash',
    connect.StreamType.unary,
    zsidev1zside.GetBestMainchainBlockHashRequest.new,
    zsidev1zside.GetBestMainchainBlockHashResponse.new,
  );

  /// Get best sidechain block hash.
  static const getBestSidechainBlockHash = connect.Spec(
    '/$name/GetBestSidechainBlockHash',
    connect.StreamType.unary,
    zsidev1zside.GetBestSidechainBlockHashRequest.new,
    zsidev1zside.GetBestSidechainBlockHashResponse.new,
  );

  /// Get BMM inclusions for a block.
  static const getBmmInclusions = connect.Spec(
    '/$name/GetBmmInclusions',
    connect.StreamType.unary,
    zsidev1zside.GetBmmInclusionsRequest.new,
    zsidev1zside.GetBmmInclusionsResponse.new,
  );

  /// Get wallet UTXOs.
  static const getWalletUtxos = connect.Spec(
    '/$name/GetWalletUtxos',
    connect.StreamType.unary,
    zsidev1zside.GetWalletUtxosRequest.new,
    zsidev1zside.GetWalletUtxosResponse.new,
  );

  /// List all UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    zsidev1zside.ListUtxosRequest.new,
    zsidev1zside.ListUtxosResponse.new,
  );

  /// Remove transaction from mempool.
  static const removeFromMempool = connect.Spec(
    '/$name/RemoveFromMempool',
    connect.StreamType.unary,
    zsidev1zside.RemoveFromMempoolRequest.new,
    zsidev1zside.RemoveFromMempoolResponse.new,
  );

  /// Get latest failed withdrawal bundle height.
  static const getLatestFailedWithdrawalBundleHeight = connect.Spec(
    '/$name/GetLatestFailedWithdrawalBundleHeight',
    connect.StreamType.unary,
    zsidev1zside.GetLatestFailedWithdrawalBundleHeightRequest.new,
    zsidev1zside.GetLatestFailedWithdrawalBundleHeightResponse.new,
  );

  /// Generate a new mnemonic.
  static const generateMnemonic = connect.Spec(
    '/$name/GenerateMnemonic',
    connect.StreamType.unary,
    zsidev1zside.GenerateMnemonicRequest.new,
    zsidev1zside.GenerateMnemonicResponse.new,
  );

  /// Set seed from mnemonic.
  static const setSeedFromMnemonic = connect.Spec(
    '/$name/SetSeedFromMnemonic',
    connect.StreamType.unary,
    zsidev1zside.SetSeedFromMnemonicRequest.new,
    zsidev1zside.SetSeedFromMnemonicResponse.new,
  );

  /// Raw JSON-RPC passthrough for debug console.
  static const callRaw = connect.Spec(
    '/$name/CallRaw',
    connect.StreamType.unary,
    zsidev1zside.CallRawRequest.new,
    zsidev1zside.CallRawResponse.new,
  );
}
