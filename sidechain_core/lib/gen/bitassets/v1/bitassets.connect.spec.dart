//
//  Generated code. Do not modify.
//  source: bitassets/v1/bitassets.proto
//

import "package:connectrpc/connect.dart" as connect;
import "bitassets.pb.dart" as bitassetsv1bitassets;

abstract final class BitAssetsService {
  /// Fully-qualified name of the BitAssetsService service.
  static const name = 'bitassets.v1.BitAssetsService';

  /// Get wallet balance (total and available).
  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetBalanceRequest.new,
    bitassetsv1bitassets.GetBalanceResponse.new,
  );

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetBlockCountRequest.new,
    bitassetsv1bitassets.GetBlockCountResponse.new,
  );

  /// Stop the bitassets node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    bitassetsv1bitassets.StopRequest.new,
    bitassetsv1bitassets.StopResponse.new,
  );

  /// Get a new address from the wallet.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetNewAddressRequest.new,
    bitassetsv1bitassets.GetNewAddressResponse.new,
  );

  /// Withdraw to mainchain.
  static const withdraw = connect.Spec(
    '/$name/Withdraw',
    connect.StreamType.unary,
    bitassetsv1bitassets.WithdrawRequest.new,
    bitassetsv1bitassets.WithdrawResponse.new,
  );

  /// Transfer within sidechain.
  static const transfer = connect.Spec(
    '/$name/Transfer',
    connect.StreamType.unary,
    bitassetsv1bitassets.TransferRequest.new,
    bitassetsv1bitassets.TransferResponse.new,
  );

  /// Get total sidechain wealth in sats.
  static const getSidechainWealth = connect.Spec(
    '/$name/GetSidechainWealth',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetSidechainWealthRequest.new,
    bitassetsv1bitassets.GetSidechainWealthResponse.new,
  );

  /// Create a deposit transaction.
  static const createDeposit = connect.Spec(
    '/$name/CreateDeposit',
    connect.StreamType.unary,
    bitassetsv1bitassets.CreateDepositRequest.new,
    bitassetsv1bitassets.CreateDepositResponse.new,
  );

  /// Get pending withdrawal bundle.
  static const getPendingWithdrawalBundle = connect.Spec(
    '/$name/GetPendingWithdrawalBundle',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetPendingWithdrawalBundleRequest.new,
    bitassetsv1bitassets.GetPendingWithdrawalBundleResponse.new,
  );

  /// Connect to a peer.
  static const connectPeer = connect.Spec(
    '/$name/ConnectPeer',
    connect.StreamType.unary,
    bitassetsv1bitassets.ConnectPeerRequest.new,
    bitassetsv1bitassets.ConnectPeerResponse.new,
  );

  /// Forget a peer.
  static const forgetPeer = connect.Spec(
    '/$name/ForgetPeer',
    connect.StreamType.unary,
    bitassetsv1bitassets.ForgetPeerRequest.new,
    bitassetsv1bitassets.ForgetPeerResponse.new,
  );

  /// List connected peers.
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    bitassetsv1bitassets.ListPeersRequest.new,
    bitassetsv1bitassets.ListPeersResponse.new,
  );

  /// Mine a block.
  static const mine = connect.Spec(
    '/$name/Mine',
    connect.StreamType.unary,
    bitassetsv1bitassets.MineRequest.new,
    bitassetsv1bitassets.MineResponse.new,
  );

  /// Get block by hash.
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetBlockRequest.new,
    bitassetsv1bitassets.GetBlockResponse.new,
  );

  /// Get best mainchain block hash.
  static const getBestMainchainBlockHash = connect.Spec(
    '/$name/GetBestMainchainBlockHash',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetBestMainchainBlockHashRequest.new,
    bitassetsv1bitassets.GetBestMainchainBlockHashResponse.new,
  );

  /// Get best sidechain block hash.
  static const getBestSidechainBlockHash = connect.Spec(
    '/$name/GetBestSidechainBlockHash',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetBestSidechainBlockHashRequest.new,
    bitassetsv1bitassets.GetBestSidechainBlockHashResponse.new,
  );

  /// Get BMM inclusions for a block.
  static const getBmmInclusions = connect.Spec(
    '/$name/GetBmmInclusions',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetBmmInclusionsRequest.new,
    bitassetsv1bitassets.GetBmmInclusionsResponse.new,
  );

  /// Get wallet UTXOs.
  static const getWalletUtxos = connect.Spec(
    '/$name/GetWalletUtxos',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetWalletUtxosRequest.new,
    bitassetsv1bitassets.GetWalletUtxosResponse.new,
  );

  /// List all UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    bitassetsv1bitassets.ListUtxosRequest.new,
    bitassetsv1bitassets.ListUtxosResponse.new,
  );

  /// Remove transaction from mempool.
  static const removeFromMempool = connect.Spec(
    '/$name/RemoveFromMempool',
    connect.StreamType.unary,
    bitassetsv1bitassets.RemoveFromMempoolRequest.new,
    bitassetsv1bitassets.RemoveFromMempoolResponse.new,
  );

  /// Get latest failed withdrawal bundle height.
  static const getLatestFailedWithdrawalBundleHeight = connect.Spec(
    '/$name/GetLatestFailedWithdrawalBundleHeight',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetLatestFailedWithdrawalBundleHeightRequest.new,
    bitassetsv1bitassets.GetLatestFailedWithdrawalBundleHeightResponse.new,
  );

  /// Generate a new mnemonic.
  static const generateMnemonic = connect.Spec(
    '/$name/GenerateMnemonic',
    connect.StreamType.unary,
    bitassetsv1bitassets.GenerateMnemonicRequest.new,
    bitassetsv1bitassets.GenerateMnemonicResponse.new,
  );

  /// Set seed from mnemonic.
  static const setSeedFromMnemonic = connect.Spec(
    '/$name/SetSeedFromMnemonic',
    connect.StreamType.unary,
    bitassetsv1bitassets.SetSeedFromMnemonicRequest.new,
    bitassetsv1bitassets.SetSeedFromMnemonicResponse.new,
  );

  /// Raw JSON-RPC passthrough for debug console.
  static const callRaw = connect.Spec(
    '/$name/CallRaw',
    connect.StreamType.unary,
    bitassetsv1bitassets.CallRawRequest.new,
    bitassetsv1bitassets.CallRawResponse.new,
  );

  /// Get BitAsset data by asset ID.
  static const getBitAssetData = connect.Spec(
    '/$name/GetBitAssetData',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetBitAssetDataRequest.new,
    bitassetsv1bitassets.GetBitAssetDataResponse.new,
  );

  /// List all BitAssets.
  static const listBitAssets = connect.Spec(
    '/$name/ListBitAssets',
    connect.StreamType.unary,
    bitassetsv1bitassets.ListBitAssetsRequest.new,
    bitassetsv1bitassets.ListBitAssetsResponse.new,
  );

  /// Register a BitAsset.
  static const registerBitAsset = connect.Spec(
    '/$name/RegisterBitAsset',
    connect.StreamType.unary,
    bitassetsv1bitassets.RegisterBitAssetRequest.new,
    bitassetsv1bitassets.RegisterBitAssetResponse.new,
  );

  /// Reserve a BitAsset.
  static const reserveBitAsset = connect.Spec(
    '/$name/ReserveBitAsset',
    connect.StreamType.unary,
    bitassetsv1bitassets.ReserveBitAssetRequest.new,
    bitassetsv1bitassets.ReserveBitAssetResponse.new,
  );

  /// Transfer a BitAsset token.
  static const transferBitAsset = connect.Spec(
    '/$name/TransferBitAsset',
    connect.StreamType.unary,
    bitassetsv1bitassets.TransferBitAssetRequest.new,
    bitassetsv1bitassets.TransferBitAssetResponse.new,
  );

  /// Get a new encryption key.
  static const getNewEncryptionKey = connect.Spec(
    '/$name/GetNewEncryptionKey',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetNewEncryptionKeyRequest.new,
    bitassetsv1bitassets.GetNewEncryptionKeyResponse.new,
  );

  /// Get a new verifying key.
  static const getNewVerifyingKey = connect.Spec(
    '/$name/GetNewVerifyingKey',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetNewVerifyingKeyRequest.new,
    bitassetsv1bitassets.GetNewVerifyingKeyResponse.new,
  );

  /// Decrypt a message.
  static const decryptMsg = connect.Spec(
    '/$name/DecryptMsg',
    connect.StreamType.unary,
    bitassetsv1bitassets.DecryptMsgRequest.new,
    bitassetsv1bitassets.DecryptMsgResponse.new,
  );

  /// Encrypt a message.
  static const encryptMsg = connect.Spec(
    '/$name/EncryptMsg',
    connect.StreamType.unary,
    bitassetsv1bitassets.EncryptMsgRequest.new,
    bitassetsv1bitassets.EncryptMsgResponse.new,
  );

  /// Sign an arbitrary message with the specified verifying key.
  static const signArbitraryMsg = connect.Spec(
    '/$name/SignArbitraryMsg',
    connect.StreamType.unary,
    bitassetsv1bitassets.SignArbitraryMsgRequest.new,
    bitassetsv1bitassets.SignArbitraryMsgResponse.new,
  );

  /// Sign an arbitrary message as a specific address.
  static const signArbitraryMsgAsAddr = connect.Spec(
    '/$name/SignArbitraryMsgAsAddr',
    connect.StreamType.unary,
    bitassetsv1bitassets.SignArbitraryMsgAsAddrRequest.new,
    bitassetsv1bitassets.SignArbitraryMsgAsAddrResponse.new,
  );

  /// Verify a signature.
  static const verifySignature = connect.Spec(
    '/$name/VerifySignature',
    connect.StreamType.unary,
    bitassetsv1bitassets.VerifySignatureRequest.new,
    bitassetsv1bitassets.VerifySignatureResponse.new,
  );

  /// Get wallet addresses.
  static const getWalletAddresses = connect.Spec(
    '/$name/GetWalletAddresses',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetWalletAddressesRequest.new,
    bitassetsv1bitassets.GetWalletAddressesResponse.new,
  );

  /// List unconfirmed owned UTXOs.
  static const myUnconfirmedUtxos = connect.Spec(
    '/$name/MyUnconfirmedUtxos',
    connect.StreamType.unary,
    bitassetsv1bitassets.MyUnconfirmedUtxosRequest.new,
    bitassetsv1bitassets.MyUnconfirmedUtxosResponse.new,
  );

  /// Get OpenAPI schema.
  static const openapiSchema = connect.Spec(
    '/$name/OpenapiSchema',
    connect.StreamType.unary,
    bitassetsv1bitassets.OpenapiSchemaRequest.new,
    bitassetsv1bitassets.OpenapiSchemaResponse.new,
  );

  /// Burn an AMM position.
  static const ammBurn = connect.Spec(
    '/$name/AmmBurn',
    connect.StreamType.unary,
    bitassetsv1bitassets.AmmBurnRequest.new,
    bitassetsv1bitassets.AmmBurnResponse.new,
  );

  /// Mint an AMM position.
  static const ammMint = connect.Spec(
    '/$name/AmmMint',
    connect.StreamType.unary,
    bitassetsv1bitassets.AmmMintRequest.new,
    bitassetsv1bitassets.AmmMintResponse.new,
  );

  /// AMM swap.
  static const ammSwap = connect.Spec(
    '/$name/AmmSwap',
    connect.StreamType.unary,
    bitassetsv1bitassets.AmmSwapRequest.new,
    bitassetsv1bitassets.AmmSwapResponse.new,
  );

  /// Get the state of the specified AMM pool.
  static const getAmmPoolState = connect.Spec(
    '/$name/GetAmmPoolState',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetAmmPoolStateRequest.new,
    bitassetsv1bitassets.GetAmmPoolStateResponse.new,
  );

  /// Get the current price for the specified pair.
  static const getAmmPrice = connect.Spec(
    '/$name/GetAmmPrice',
    connect.StreamType.unary,
    bitassetsv1bitassets.GetAmmPriceRequest.new,
    bitassetsv1bitassets.GetAmmPriceResponse.new,
  );

  /// Bid on a dutch auction.
  static const dutchAuctionBid = connect.Spec(
    '/$name/DutchAuctionBid',
    connect.StreamType.unary,
    bitassetsv1bitassets.DutchAuctionBidRequest.new,
    bitassetsv1bitassets.DutchAuctionBidResponse.new,
  );

  /// Collect from a dutch auction.
  static const dutchAuctionCollect = connect.Spec(
    '/$name/DutchAuctionCollect',
    connect.StreamType.unary,
    bitassetsv1bitassets.DutchAuctionCollectRequest.new,
    bitassetsv1bitassets.DutchAuctionCollectResponse.new,
  );

  /// Create a dutch auction.
  static const dutchAuctionCreate = connect.Spec(
    '/$name/DutchAuctionCreate',
    connect.StreamType.unary,
    bitassetsv1bitassets.DutchAuctionCreateRequest.new,
    bitassetsv1bitassets.DutchAuctionCreateResponse.new,
  );

  /// List all dutch auctions.
  static const dutchAuctions = connect.Spec(
    '/$name/DutchAuctions',
    connect.StreamType.unary,
    bitassetsv1bitassets.DutchAuctionsRequest.new,
    bitassetsv1bitassets.DutchAuctionsResponse.new,
  );
}
