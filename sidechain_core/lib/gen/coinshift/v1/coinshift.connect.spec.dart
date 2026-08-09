//
//  Generated code. Do not modify.
//  source: coinshift/v1/coinshift.proto
//

import "package:connectrpc/connect.dart" as connect;
import "coinshift.pb.dart" as coinshiftv1coinshift;

abstract final class CoinShiftService {
  /// Fully-qualified name of the CoinShiftService service.
  static const name = 'coinshift.v1.CoinShiftService';

  /// Get wallet balance (total and available).
  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetBalanceRequest.new,
    coinshiftv1coinshift.GetBalanceResponse.new,
  );

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetBlockCountRequest.new,
    coinshiftv1coinshift.GetBlockCountResponse.new,
  );

  /// Stop the coinshift node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    coinshiftv1coinshift.StopRequest.new,
    coinshiftv1coinshift.StopResponse.new,
  );

  /// Get a new address from the wallet.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetNewAddressRequest.new,
    coinshiftv1coinshift.GetNewAddressResponse.new,
  );

  /// Withdraw to mainchain.
  static const withdraw = connect.Spec(
    '/$name/Withdraw',
    connect.StreamType.unary,
    coinshiftv1coinshift.WithdrawRequest.new,
    coinshiftv1coinshift.WithdrawResponse.new,
  );

  /// Transfer within sidechain.
  static const transfer = connect.Spec(
    '/$name/Transfer',
    connect.StreamType.unary,
    coinshiftv1coinshift.TransferRequest.new,
    coinshiftv1coinshift.TransferResponse.new,
  );

  /// Get total sidechain wealth in sats.
  static const getSidechainWealth = connect.Spec(
    '/$name/GetSidechainWealth',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetSidechainWealthRequest.new,
    coinshiftv1coinshift.GetSidechainWealthResponse.new,
  );

  /// Create a deposit transaction.
  static const createDeposit = connect.Spec(
    '/$name/CreateDeposit',
    connect.StreamType.unary,
    coinshiftv1coinshift.CreateDepositRequest.new,
    coinshiftv1coinshift.CreateDepositResponse.new,
  );

  /// Get pending withdrawal bundle.
  static const getPendingWithdrawalBundle = connect.Spec(
    '/$name/GetPendingWithdrawalBundle',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetPendingWithdrawalBundleRequest.new,
    coinshiftv1coinshift.GetPendingWithdrawalBundleResponse.new,
  );

  /// Connect to a peer.
  static const connectPeer = connect.Spec(
    '/$name/ConnectPeer',
    connect.StreamType.unary,
    coinshiftv1coinshift.ConnectPeerRequest.new,
    coinshiftv1coinshift.ConnectPeerResponse.new,
  );

  /// Forget a peer.
  static const forgetPeer = connect.Spec(
    '/$name/ForgetPeer',
    connect.StreamType.unary,
    coinshiftv1coinshift.ForgetPeerRequest.new,
    coinshiftv1coinshift.ForgetPeerResponse.new,
  );

  /// List connected peers.
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    coinshiftv1coinshift.ListPeersRequest.new,
    coinshiftv1coinshift.ListPeersResponse.new,
  );

  /// Mine a block.
  static const mine = connect.Spec(
    '/$name/Mine',
    connect.StreamType.unary,
    coinshiftv1coinshift.MineRequest.new,
    coinshiftv1coinshift.MineResponse.new,
  );

  /// Get block by hash.
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetBlockRequest.new,
    coinshiftv1coinshift.GetBlockResponse.new,
  );

  /// Get best mainchain block hash.
  static const getBestMainchainBlockHash = connect.Spec(
    '/$name/GetBestMainchainBlockHash',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetBestMainchainBlockHashRequest.new,
    coinshiftv1coinshift.GetBestMainchainBlockHashResponse.new,
  );

  /// Get best sidechain block hash.
  static const getBestSidechainBlockHash = connect.Spec(
    '/$name/GetBestSidechainBlockHash',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetBestSidechainBlockHashRequest.new,
    coinshiftv1coinshift.GetBestSidechainBlockHashResponse.new,
  );

  /// Get BMM inclusions for a block.
  static const getBmmInclusions = connect.Spec(
    '/$name/GetBmmInclusions',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetBmmInclusionsRequest.new,
    coinshiftv1coinshift.GetBmmInclusionsResponse.new,
  );

  /// Get wallet UTXOs.
  static const getWalletUtxos = connect.Spec(
    '/$name/GetWalletUtxos',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetWalletUtxosRequest.new,
    coinshiftv1coinshift.GetWalletUtxosResponse.new,
  );

  /// List all UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    coinshiftv1coinshift.ListUtxosRequest.new,
    coinshiftv1coinshift.ListUtxosResponse.new,
  );

  /// Remove transaction from mempool.
  static const removeFromMempool = connect.Spec(
    '/$name/RemoveFromMempool',
    connect.StreamType.unary,
    coinshiftv1coinshift.RemoveFromMempoolRequest.new,
    coinshiftv1coinshift.RemoveFromMempoolResponse.new,
  );

  /// Get latest failed withdrawal bundle height.
  static const getLatestFailedWithdrawalBundleHeight = connect.Spec(
    '/$name/GetLatestFailedWithdrawalBundleHeight',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetLatestFailedWithdrawalBundleHeightRequest.new,
    coinshiftv1coinshift.GetLatestFailedWithdrawalBundleHeightResponse.new,
  );

  /// Generate a new mnemonic.
  static const generateMnemonic = connect.Spec(
    '/$name/GenerateMnemonic',
    connect.StreamType.unary,
    coinshiftv1coinshift.GenerateMnemonicRequest.new,
    coinshiftv1coinshift.GenerateMnemonicResponse.new,
  );

  /// Set seed from mnemonic.
  static const setSeedFromMnemonic = connect.Spec(
    '/$name/SetSeedFromMnemonic',
    connect.StreamType.unary,
    coinshiftv1coinshift.SetSeedFromMnemonicRequest.new,
    coinshiftv1coinshift.SetSeedFromMnemonicResponse.new,
  );

  /// Raw JSON-RPC passthrough for debug console.
  static const callRaw = connect.Spec(
    '/$name/CallRaw',
    connect.StreamType.unary,
    coinshiftv1coinshift.CallRawRequest.new,
    coinshiftv1coinshift.CallRawResponse.new,
  );

  /// Get wallet addresses.
  static const getWalletAddresses = connect.Spec(
    '/$name/GetWalletAddresses',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetWalletAddressesRequest.new,
    coinshiftv1coinshift.GetWalletAddressesResponse.new,
  );

  /// Get OpenAPI schema.
  static const openapiSchema = connect.Spec(
    '/$name/OpenapiSchema',
    connect.StreamType.unary,
    coinshiftv1coinshift.OpenapiSchemaRequest.new,
    coinshiftv1coinshift.OpenapiSchemaResponse.new,
  );

  /// Create a swap (L2 to L1).
  static const createSwap = connect.Spec(
    '/$name/CreateSwap',
    connect.StreamType.unary,
    coinshiftv1coinshift.CreateSwapRequest.new,
    coinshiftv1coinshift.CreateSwapResponse.new,
  );

  /// Claim a swap.
  static const claimSwap = connect.Spec(
    '/$name/ClaimSwap',
    connect.StreamType.unary,
    coinshiftv1coinshift.ClaimSwapRequest.new,
    coinshiftv1coinshift.ClaimSwapResponse.new,
  );

  /// Get swap status.
  static const getSwapStatus = connect.Spec(
    '/$name/GetSwapStatus',
    connect.StreamType.unary,
    coinshiftv1coinshift.GetSwapStatusRequest.new,
    coinshiftv1coinshift.GetSwapStatusResponse.new,
  );

  /// List all swaps.
  static const listSwaps = connect.Spec(
    '/$name/ListSwaps',
    connect.StreamType.unary,
    coinshiftv1coinshift.ListSwapsRequest.new,
    coinshiftv1coinshift.ListSwapsResponse.new,
  );

  /// List swaps for a specific recipient.
  static const listSwapsByRecipient = connect.Spec(
    '/$name/ListSwapsByRecipient',
    connect.StreamType.unary,
    coinshiftv1coinshift.ListSwapsByRecipientRequest.new,
    coinshiftv1coinshift.ListSwapsByRecipientResponse.new,
  );

  /// Update swap L1 transaction ID.
  static const updateSwapL1Txid = connect.Spec(
    '/$name/UpdateSwapL1Txid',
    connect.StreamType.unary,
    coinshiftv1coinshift.UpdateSwapL1TxidRequest.new,
    coinshiftv1coinshift.UpdateSwapL1TxidResponse.new,
  );

  /// Reconstruct all swaps from blockchain.
  static const reconstructSwaps = connect.Spec(
    '/$name/ReconstructSwaps',
    connect.StreamType.unary,
    coinshiftv1coinshift.ReconstructSwapsRequest.new,
    coinshiftv1coinshift.ReconstructSwapsResponse.new,
  );
}
