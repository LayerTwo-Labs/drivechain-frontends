//
//  Generated code. Do not modify.
//  source: photon/v1/photon.proto
//

import "package:connectrpc/connect.dart" as connect;
import "photon.pb.dart" as photonv1photon;

abstract final class PhotonService {
  /// Fully-qualified name of the PhotonService service.
  static const name = 'photon.v1.PhotonService';

  /// Get wallet balance (total and available).
  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    photonv1photon.GetBalanceRequest.new,
    photonv1photon.GetBalanceResponse.new,
  );

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    photonv1photon.GetBlockCountRequest.new,
    photonv1photon.GetBlockCountResponse.new,
  );

  /// Stop the photon node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    photonv1photon.StopRequest.new,
    photonv1photon.StopResponse.new,
  );

  /// Get a new address from the wallet.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    photonv1photon.GetNewAddressRequest.new,
    photonv1photon.GetNewAddressResponse.new,
  );

  /// Withdraw to mainchain.
  static const withdraw = connect.Spec(
    '/$name/Withdraw',
    connect.StreamType.unary,
    photonv1photon.WithdrawRequest.new,
    photonv1photon.WithdrawResponse.new,
  );

  /// Transfer within sidechain.
  static const transfer = connect.Spec(
    '/$name/Transfer',
    connect.StreamType.unary,
    photonv1photon.TransferRequest.new,
    photonv1photon.TransferResponse.new,
  );

  /// Get total sidechain wealth in sats.
  static const getSidechainWealth = connect.Spec(
    '/$name/GetSidechainWealth',
    connect.StreamType.unary,
    photonv1photon.GetSidechainWealthRequest.new,
    photonv1photon.GetSidechainWealthResponse.new,
  );

  /// Create a deposit transaction.
  static const createDeposit = connect.Spec(
    '/$name/CreateDeposit',
    connect.StreamType.unary,
    photonv1photon.CreateDepositRequest.new,
    photonv1photon.CreateDepositResponse.new,
  );

  /// Get pending withdrawal bundle.
  static const getPendingWithdrawalBundle = connect.Spec(
    '/$name/GetPendingWithdrawalBundle',
    connect.StreamType.unary,
    photonv1photon.GetPendingWithdrawalBundleRequest.new,
    photonv1photon.GetPendingWithdrawalBundleResponse.new,
  );

  /// Connect to a peer.
  static const connectPeer = connect.Spec(
    '/$name/ConnectPeer',
    connect.StreamType.unary,
    photonv1photon.ConnectPeerRequest.new,
    photonv1photon.ConnectPeerResponse.new,
  );

  /// Forget a peer.
  static const forgetPeer = connect.Spec(
    '/$name/ForgetPeer',
    connect.StreamType.unary,
    photonv1photon.ForgetPeerRequest.new,
    photonv1photon.ForgetPeerResponse.new,
  );

  /// List connected peers.
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    photonv1photon.ListPeersRequest.new,
    photonv1photon.ListPeersResponse.new,
  );

  /// Mine a block.
  static const mine = connect.Spec(
    '/$name/Mine',
    connect.StreamType.unary,
    photonv1photon.MineRequest.new,
    photonv1photon.MineResponse.new,
  );

  /// Get block by hash.
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    photonv1photon.GetBlockRequest.new,
    photonv1photon.GetBlockResponse.new,
  );

  /// Get best mainchain block hash.
  static const getBestMainchainBlockHash = connect.Spec(
    '/$name/GetBestMainchainBlockHash',
    connect.StreamType.unary,
    photonv1photon.GetBestMainchainBlockHashRequest.new,
    photonv1photon.GetBestMainchainBlockHashResponse.new,
  );

  /// Get best sidechain block hash.
  static const getBestSidechainBlockHash = connect.Spec(
    '/$name/GetBestSidechainBlockHash',
    connect.StreamType.unary,
    photonv1photon.GetBestSidechainBlockHashRequest.new,
    photonv1photon.GetBestSidechainBlockHashResponse.new,
  );

  /// Get BMM inclusions for a block.
  static const getBmmInclusions = connect.Spec(
    '/$name/GetBmmInclusions',
    connect.StreamType.unary,
    photonv1photon.GetBmmInclusionsRequest.new,
    photonv1photon.GetBmmInclusionsResponse.new,
  );

  /// Get wallet UTXOs.
  static const getWalletUtxos = connect.Spec(
    '/$name/GetWalletUtxos',
    connect.StreamType.unary,
    photonv1photon.GetWalletUtxosRequest.new,
    photonv1photon.GetWalletUtxosResponse.new,
  );

  /// List all UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    photonv1photon.ListUtxosRequest.new,
    photonv1photon.ListUtxosResponse.new,
  );

  /// Remove transaction from mempool.
  static const removeFromMempool = connect.Spec(
    '/$name/RemoveFromMempool',
    connect.StreamType.unary,
    photonv1photon.RemoveFromMempoolRequest.new,
    photonv1photon.RemoveFromMempoolResponse.new,
  );

  /// Get latest failed withdrawal bundle height.
  static const getLatestFailedWithdrawalBundleHeight = connect.Spec(
    '/$name/GetLatestFailedWithdrawalBundleHeight',
    connect.StreamType.unary,
    photonv1photon.GetLatestFailedWithdrawalBundleHeightRequest.new,
    photonv1photon.GetLatestFailedWithdrawalBundleHeightResponse.new,
  );

  /// Generate a new mnemonic.
  static const generateMnemonic = connect.Spec(
    '/$name/GenerateMnemonic',
    connect.StreamType.unary,
    photonv1photon.GenerateMnemonicRequest.new,
    photonv1photon.GenerateMnemonicResponse.new,
  );

  /// Set seed from mnemonic.
  static const setSeedFromMnemonic = connect.Spec(
    '/$name/SetSeedFromMnemonic',
    connect.StreamType.unary,
    photonv1photon.SetSeedFromMnemonicRequest.new,
    photonv1photon.SetSeedFromMnemonicResponse.new,
  );

  /// Raw JSON-RPC passthrough for debug console.
  static const callRaw = connect.Spec(
    '/$name/CallRaw',
    connect.StreamType.unary,
    photonv1photon.CallRawRequest.new,
    photonv1photon.CallRawResponse.new,
  );

  /// Get wallet addresses.
  static const getWalletAddresses = connect.Spec(
    '/$name/GetWalletAddresses',
    connect.StreamType.unary,
    photonv1photon.GetWalletAddressesRequest.new,
    photonv1photon.GetWalletAddressesResponse.new,
  );
}
