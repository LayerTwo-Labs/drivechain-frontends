//
//  Generated code. Do not modify.
//  source: truthcoin/v1/truthcoin.proto
//

import "package:connectrpc/connect.dart" as connect;
import "truthcoin.pb.dart" as truthcoinv1truthcoin;

abstract final class TruthcoinService {
  /// Fully-qualified name of the TruthcoinService service.
  static const name = 'truthcoin.v1.TruthcoinService';

  /// Get wallet balance (total and available).
  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetBalanceRequest.new,
    truthcoinv1truthcoin.GetBalanceResponse.new,
  );

  /// Get current block count.
  static const getBlockCount = connect.Spec(
    '/$name/GetBlockCount',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetBlockCountRequest.new,
    truthcoinv1truthcoin.GetBlockCountResponse.new,
  );

  /// Stop the truthcoin node.
  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    truthcoinv1truthcoin.StopRequest.new,
    truthcoinv1truthcoin.StopResponse.new,
  );

  /// Get a new address from the wallet.
  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetNewAddressRequest.new,
    truthcoinv1truthcoin.GetNewAddressResponse.new,
  );

  /// Withdraw to mainchain.
  static const withdraw = connect.Spec(
    '/$name/Withdraw',
    connect.StreamType.unary,
    truthcoinv1truthcoin.WithdrawRequest.new,
    truthcoinv1truthcoin.WithdrawResponse.new,
  );

  /// Transfer within sidechain.
  static const transfer = connect.Spec(
    '/$name/Transfer',
    connect.StreamType.unary,
    truthcoinv1truthcoin.TransferRequest.new,
    truthcoinv1truthcoin.TransferResponse.new,
  );

  /// Get total sidechain wealth in sats.
  static const getSidechainWealth = connect.Spec(
    '/$name/GetSidechainWealth',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetSidechainWealthRequest.new,
    truthcoinv1truthcoin.GetSidechainWealthResponse.new,
  );

  /// Create a deposit transaction.
  static const createDeposit = connect.Spec(
    '/$name/CreateDeposit',
    connect.StreamType.unary,
    truthcoinv1truthcoin.CreateDepositRequest.new,
    truthcoinv1truthcoin.CreateDepositResponse.new,
  );

  /// Get pending withdrawal bundle.
  static const getPendingWithdrawalBundle = connect.Spec(
    '/$name/GetPendingWithdrawalBundle',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetPendingWithdrawalBundleRequest.new,
    truthcoinv1truthcoin.GetPendingWithdrawalBundleResponse.new,
  );

  /// Connect to a peer.
  static const connectPeer = connect.Spec(
    '/$name/ConnectPeer',
    connect.StreamType.unary,
    truthcoinv1truthcoin.ConnectPeerRequest.new,
    truthcoinv1truthcoin.ConnectPeerResponse.new,
  );

  /// List connected peers.
  static const listPeers = connect.Spec(
    '/$name/ListPeers',
    connect.StreamType.unary,
    truthcoinv1truthcoin.ListPeersRequest.new,
    truthcoinv1truthcoin.ListPeersResponse.new,
  );

  /// Mine a block.
  static const mine = connect.Spec(
    '/$name/Mine',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MineRequest.new,
    truthcoinv1truthcoin.MineResponse.new,
  );

  /// Get block by hash.
  static const getBlock = connect.Spec(
    '/$name/GetBlock',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetBlockRequest.new,
    truthcoinv1truthcoin.GetBlockResponse.new,
  );

  /// Get best mainchain block hash.
  static const getBestMainchainBlockHash = connect.Spec(
    '/$name/GetBestMainchainBlockHash',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetBestMainchainBlockHashRequest.new,
    truthcoinv1truthcoin.GetBestMainchainBlockHashResponse.new,
  );

  /// Get best sidechain block hash.
  static const getBestSidechainBlockHash = connect.Spec(
    '/$name/GetBestSidechainBlockHash',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetBestSidechainBlockHashRequest.new,
    truthcoinv1truthcoin.GetBestSidechainBlockHashResponse.new,
  );

  /// Get BMM inclusions for a block.
  static const getBmmInclusions = connect.Spec(
    '/$name/GetBmmInclusions',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetBmmInclusionsRequest.new,
    truthcoinv1truthcoin.GetBmmInclusionsResponse.new,
  );

  /// Get wallet UTXOs.
  static const getWalletUtxos = connect.Spec(
    '/$name/GetWalletUtxos',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetWalletUtxosRequest.new,
    truthcoinv1truthcoin.GetWalletUtxosResponse.new,
  );

  /// List all UTXOs.
  static const listUtxos = connect.Spec(
    '/$name/ListUtxos',
    connect.StreamType.unary,
    truthcoinv1truthcoin.ListUtxosRequest.new,
    truthcoinv1truthcoin.ListUtxosResponse.new,
  );

  /// Remove transaction from mempool.
  static const removeFromMempool = connect.Spec(
    '/$name/RemoveFromMempool',
    connect.StreamType.unary,
    truthcoinv1truthcoin.RemoveFromMempoolRequest.new,
    truthcoinv1truthcoin.RemoveFromMempoolResponse.new,
  );

  /// Get latest failed withdrawal bundle height.
  static const getLatestFailedWithdrawalBundleHeight = connect.Spec(
    '/$name/GetLatestFailedWithdrawalBundleHeight',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetLatestFailedWithdrawalBundleHeightRequest.new,
    truthcoinv1truthcoin.GetLatestFailedWithdrawalBundleHeightResponse.new,
  );

  /// Generate a new mnemonic.
  static const generateMnemonic = connect.Spec(
    '/$name/GenerateMnemonic',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GenerateMnemonicRequest.new,
    truthcoinv1truthcoin.GenerateMnemonicResponse.new,
  );

  /// Set seed from mnemonic.
  static const setSeedFromMnemonic = connect.Spec(
    '/$name/SetSeedFromMnemonic',
    connect.StreamType.unary,
    truthcoinv1truthcoin.SetSeedFromMnemonicRequest.new,
    truthcoinv1truthcoin.SetSeedFromMnemonicResponse.new,
  );

  /// Raw JSON-RPC passthrough for debug console.
  static const callRaw = connect.Spec(
    '/$name/CallRaw',
    connect.StreamType.unary,
    truthcoinv1truthcoin.CallRawRequest.new,
    truthcoinv1truthcoin.CallRawResponse.new,
  );

  /// Refresh wallet state.
  static const refreshWallet = connect.Spec(
    '/$name/RefreshWallet',
    connect.StreamType.unary,
    truthcoinv1truthcoin.RefreshWalletRequest.new,
    truthcoinv1truthcoin.RefreshWalletResponse.new,
  );

  /// Get transaction by txid.
  static const getTransaction = connect.Spec(
    '/$name/GetTransaction',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetTransactionRequest.new,
    truthcoinv1truthcoin.GetTransactionResponse.new,
  );

  /// Get transaction info.
  static const getTransactionInfo = connect.Spec(
    '/$name/GetTransactionInfo',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetTransactionInfoRequest.new,
    truthcoinv1truthcoin.GetTransactionInfoResponse.new,
  );

  /// Get wallet addresses.
  static const getWalletAddresses = connect.Spec(
    '/$name/GetWalletAddresses',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetWalletAddressesRequest.new,
    truthcoinv1truthcoin.GetWalletAddressesResponse.new,
  );

  /// Get owned UTXOs (confirmed).
  static const myUtxos = connect.Spec(
    '/$name/MyUtxos',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MyUtxosRequest.new,
    truthcoinv1truthcoin.MyUtxosResponse.new,
  );

  /// Get owned UTXOs (unconfirmed).
  static const myUnconfirmedUtxos = connect.Spec(
    '/$name/MyUnconfirmedUtxos',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MyUnconfirmedUtxosRequest.new,
    truthcoinv1truthcoin.MyUnconfirmedUtxosResponse.new,
  );

  /// Calculate initial liquidity required for market creation.
  static const calculateInitialLiquidity = connect.Spec(
    '/$name/CalculateInitialLiquidity',
    connect.StreamType.unary,
    truthcoinv1truthcoin.CalculateInitialLiquidityRequest.new,
    truthcoinv1truthcoin.CalculateInitialLiquidityResponse.new,
  );

  /// Create a new prediction market.
  static const marketCreate = connect.Spec(
    '/$name/MarketCreate',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MarketCreateRequest.new,
    truthcoinv1truthcoin.MarketCreateResponse.new,
  );

  /// List all markets.
  static const marketList = connect.Spec(
    '/$name/MarketList',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MarketListRequest.new,
    truthcoinv1truthcoin.MarketListResponse.new,
  );

  /// Get a specific market.
  static const marketGet = connect.Spec(
    '/$name/MarketGet',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MarketGetRequest.new,
    truthcoinv1truthcoin.MarketGetResponse.new,
  );

  /// Buy shares in a market.
  static const marketBuy = connect.Spec(
    '/$name/MarketBuy',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MarketBuyRequest.new,
    truthcoinv1truthcoin.MarketBuyResponse.new,
  );

  /// Sell shares in a market.
  static const marketSell = connect.Spec(
    '/$name/MarketSell',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MarketSellRequest.new,
    truthcoinv1truthcoin.MarketSellResponse.new,
  );

  /// Get positions in a market.
  static const marketPositions = connect.Spec(
    '/$name/MarketPositions',
    connect.StreamType.unary,
    truthcoinv1truthcoin.MarketPositionsRequest.new,
    truthcoinv1truthcoin.MarketPositionsResponse.new,
  );

  /// Get slot system status and configuration.
  static const slotStatus = connect.Spec(
    '/$name/SlotStatus',
    connect.StreamType.unary,
    truthcoinv1truthcoin.SlotStatusRequest.new,
    truthcoinv1truthcoin.SlotStatusResponse.new,
  );

  /// List slots with optional filtering.
  static const slotList = connect.Spec(
    '/$name/SlotList',
    connect.StreamType.unary,
    truthcoinv1truthcoin.SlotListRequest.new,
    truthcoinv1truthcoin.SlotListResponse.new,
  );

  /// Get a specific slot by ID.
  static const slotGet = connect.Spec(
    '/$name/SlotGet',
    connect.StreamType.unary,
    truthcoinv1truthcoin.SlotGetRequest.new,
    truthcoinv1truthcoin.SlotGetResponse.new,
  );

  /// Claim a decision slot.
  static const slotClaim = connect.Spec(
    '/$name/SlotClaim',
    connect.StreamType.unary,
    truthcoinv1truthcoin.SlotClaimRequest.new,
    truthcoinv1truthcoin.SlotClaimResponse.new,
  );

  /// Claim multiple slots as a category.
  static const slotClaimCategory = connect.Spec(
    '/$name/SlotClaimCategory',
    connect.StreamType.unary,
    truthcoinv1truthcoin.SlotClaimCategoryRequest.new,
    truthcoinv1truthcoin.SlotClaimCategoryResponse.new,
  );

  /// Register as a voter.
  static const voteRegister = connect.Spec(
    '/$name/VoteRegister',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VoteRegisterRequest.new,
    truthcoinv1truthcoin.VoteRegisterResponse.new,
  );

  /// Get voter info.
  static const voteVoter = connect.Spec(
    '/$name/VoteVoter',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VoteVoterRequest.new,
    truthcoinv1truthcoin.VoteVoterResponse.new,
  );

  /// List all voters.
  static const voteVoters = connect.Spec(
    '/$name/VoteVoters',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VoteVotersRequest.new,
    truthcoinv1truthcoin.VoteVotersResponse.new,
  );

  /// Submit votes (batch).
  static const voteSubmit = connect.Spec(
    '/$name/VoteSubmit',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VoteSubmitRequest.new,
    truthcoinv1truthcoin.VoteSubmitResponse.new,
  );

  /// List votes with optional filters.
  static const voteList = connect.Spec(
    '/$name/VoteList',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VoteListRequest.new,
    truthcoinv1truthcoin.VoteListResponse.new,
  );

  /// Get voting period information.
  static const votePeriod = connect.Spec(
    '/$name/VotePeriod',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VotePeriodRequest.new,
    truthcoinv1truthcoin.VotePeriodResponse.new,
  );

  /// Transfer votecoins.
  static const votecoinTransfer = connect.Spec(
    '/$name/VotecoinTransfer',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VotecoinTransferRequest.new,
    truthcoinv1truthcoin.VotecoinTransferResponse.new,
  );

  /// Get votecoin balance for an address.
  static const votecoinBalance = connect.Spec(
    '/$name/VotecoinBalance',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VotecoinBalanceRequest.new,
    truthcoinv1truthcoin.VotecoinBalanceResponse.new,
  );

  /// Transfer votecoin (alternative method).
  static const transferVotecoin = connect.Spec(
    '/$name/TransferVotecoin',
    connect.StreamType.unary,
    truthcoinv1truthcoin.TransferVotecoinRequest.new,
    truthcoinv1truthcoin.TransferVotecoinResponse.new,
  );

  /// Get a new encryption key.
  static const getNewEncryptionKey = connect.Spec(
    '/$name/GetNewEncryptionKey',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetNewEncryptionKeyRequest.new,
    truthcoinv1truthcoin.GetNewEncryptionKeyResponse.new,
  );

  /// Get a new verifying key.
  static const getNewVerifyingKey = connect.Spec(
    '/$name/GetNewVerifyingKey',
    connect.StreamType.unary,
    truthcoinv1truthcoin.GetNewVerifyingKeyRequest.new,
    truthcoinv1truthcoin.GetNewVerifyingKeyResponse.new,
  );

  /// Encrypt a message.
  static const encryptMsg = connect.Spec(
    '/$name/EncryptMsg',
    connect.StreamType.unary,
    truthcoinv1truthcoin.EncryptMsgRequest.new,
    truthcoinv1truthcoin.EncryptMsgResponse.new,
  );

  /// Decrypt a message.
  static const decryptMsg = connect.Spec(
    '/$name/DecryptMsg',
    connect.StreamType.unary,
    truthcoinv1truthcoin.DecryptMsgRequest.new,
    truthcoinv1truthcoin.DecryptMsgResponse.new,
  );

  /// Sign an arbitrary message with verifying key.
  static const signArbitraryMsg = connect.Spec(
    '/$name/SignArbitraryMsg',
    connect.StreamType.unary,
    truthcoinv1truthcoin.SignArbitraryMsgRequest.new,
    truthcoinv1truthcoin.SignArbitraryMsgResponse.new,
  );

  /// Sign an arbitrary message as address.
  static const signArbitraryMsgAsAddr = connect.Spec(
    '/$name/SignArbitraryMsgAsAddr',
    connect.StreamType.unary,
    truthcoinv1truthcoin.SignArbitraryMsgAsAddrRequest.new,
    truthcoinv1truthcoin.SignArbitraryMsgAsAddrResponse.new,
  );

  /// Verify a signature.
  static const verifySignature = connect.Spec(
    '/$name/VerifySignature',
    connect.StreamType.unary,
    truthcoinv1truthcoin.VerifySignatureRequest.new,
    truthcoinv1truthcoin.VerifySignatureResponse.new,
  );
}
