//
//  Generated code. Do not modify.
//  source: truthcoin/v1/truthcoin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'truthcoin.pb.dart' as $17;
import 'truthcoin.pbjson.dart';

export 'truthcoin.pb.dart';

abstract class TruthcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$17.GetBalanceResponse> getBalance($pb.ServerContext ctx, $17.GetBalanceRequest request);
  $async.Future<$17.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $17.GetBlockCountRequest request);
  $async.Future<$17.StopResponse> stop($pb.ServerContext ctx, $17.StopRequest request);
  $async.Future<$17.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $17.GetNewAddressRequest request);
  $async.Future<$17.WithdrawResponse> withdraw($pb.ServerContext ctx, $17.WithdrawRequest request);
  $async.Future<$17.TransferResponse> transfer($pb.ServerContext ctx, $17.TransferRequest request);
  $async.Future<$17.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $17.GetSidechainWealthRequest request);
  $async.Future<$17.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $17.CreateDepositRequest request);
  $async.Future<$17.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $17.GetPendingWithdrawalBundleRequest request);
  $async.Future<$17.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $17.ConnectPeerRequest request);
  $async.Future<$17.ListPeersResponse> listPeers($pb.ServerContext ctx, $17.ListPeersRequest request);
  $async.Future<$17.MineResponse> mine($pb.ServerContext ctx, $17.MineRequest request);
  $async.Future<$17.GetBlockResponse> getBlock($pb.ServerContext ctx, $17.GetBlockRequest request);
  $async.Future<$17.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $17.GetBestMainchainBlockHashRequest request);
  $async.Future<$17.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $17.GetBestSidechainBlockHashRequest request);
  $async.Future<$17.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $17.GetBmmInclusionsRequest request);
  $async.Future<$17.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $17.GetWalletUtxosRequest request);
  $async.Future<$17.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $17.ListUtxosRequest request);
  $async.Future<$17.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $17.RemoveFromMempoolRequest request);
  $async.Future<$17.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $17.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$17.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $17.GenerateMnemonicRequest request);
  $async.Future<$17.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $17.SetSeedFromMnemonicRequest request);
  $async.Future<$17.CallRawResponse> callRaw($pb.ServerContext ctx, $17.CallRawRequest request);
  $async.Future<$17.RefreshWalletResponse> refreshWallet($pb.ServerContext ctx, $17.RefreshWalletRequest request);
  $async.Future<$17.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $17.GetTransactionRequest request);
  $async.Future<$17.GetTransactionInfoResponse> getTransactionInfo($pb.ServerContext ctx, $17.GetTransactionInfoRequest request);
  $async.Future<$17.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $17.GetWalletAddressesRequest request);
  $async.Future<$17.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $17.MyUtxosRequest request);
  $async.Future<$17.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos($pb.ServerContext ctx, $17.MyUnconfirmedUtxosRequest request);
  $async.Future<$17.CalculateInitialLiquidityResponse> calculateInitialLiquidity($pb.ServerContext ctx, $17.CalculateInitialLiquidityRequest request);
  $async.Future<$17.MarketCreateResponse> marketCreate($pb.ServerContext ctx, $17.MarketCreateRequest request);
  $async.Future<$17.MarketListResponse> marketList($pb.ServerContext ctx, $17.MarketListRequest request);
  $async.Future<$17.MarketGetResponse> marketGet($pb.ServerContext ctx, $17.MarketGetRequest request);
  $async.Future<$17.MarketBuyResponse> marketBuy($pb.ServerContext ctx, $17.MarketBuyRequest request);
  $async.Future<$17.MarketSellResponse> marketSell($pb.ServerContext ctx, $17.MarketSellRequest request);
  $async.Future<$17.MarketPositionsResponse> marketPositions($pb.ServerContext ctx, $17.MarketPositionsRequest request);
  $async.Future<$17.SlotStatusResponse> slotStatus($pb.ServerContext ctx, $17.SlotStatusRequest request);
  $async.Future<$17.SlotListResponse> slotList($pb.ServerContext ctx, $17.SlotListRequest request);
  $async.Future<$17.SlotGetResponse> slotGet($pb.ServerContext ctx, $17.SlotGetRequest request);
  $async.Future<$17.SlotClaimResponse> slotClaim($pb.ServerContext ctx, $17.SlotClaimRequest request);
  $async.Future<$17.SlotClaimCategoryResponse> slotClaimCategory($pb.ServerContext ctx, $17.SlotClaimCategoryRequest request);
  $async.Future<$17.VoteRegisterResponse> voteRegister($pb.ServerContext ctx, $17.VoteRegisterRequest request);
  $async.Future<$17.VoteVoterResponse> voteVoter($pb.ServerContext ctx, $17.VoteVoterRequest request);
  $async.Future<$17.VoteVotersResponse> voteVoters($pb.ServerContext ctx, $17.VoteVotersRequest request);
  $async.Future<$17.VoteSubmitResponse> voteSubmit($pb.ServerContext ctx, $17.VoteSubmitRequest request);
  $async.Future<$17.VoteListResponse> voteList($pb.ServerContext ctx, $17.VoteListRequest request);
  $async.Future<$17.VotePeriodResponse> votePeriod($pb.ServerContext ctx, $17.VotePeriodRequest request);
  $async.Future<$17.VotecoinTransferResponse> votecoinTransfer($pb.ServerContext ctx, $17.VotecoinTransferRequest request);
  $async.Future<$17.VotecoinBalanceResponse> votecoinBalance($pb.ServerContext ctx, $17.VotecoinBalanceRequest request);
  $async.Future<$17.TransferVotecoinResponse> transferVotecoin($pb.ServerContext ctx, $17.TransferVotecoinRequest request);
  $async.Future<$17.GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ServerContext ctx, $17.GetNewEncryptionKeyRequest request);
  $async.Future<$17.GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ServerContext ctx, $17.GetNewVerifyingKeyRequest request);
  $async.Future<$17.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $17.EncryptMsgRequest request);
  $async.Future<$17.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $17.DecryptMsgRequest request);
  $async.Future<$17.SignArbitraryMsgResponse> signArbitraryMsg($pb.ServerContext ctx, $17.SignArbitraryMsgRequest request);
  $async.Future<$17.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ServerContext ctx, $17.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$17.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $17.VerifySignatureRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $17.GetBalanceRequest();
      case 'GetBlockCount': return $17.GetBlockCountRequest();
      case 'Stop': return $17.StopRequest();
      case 'GetNewAddress': return $17.GetNewAddressRequest();
      case 'Withdraw': return $17.WithdrawRequest();
      case 'Transfer': return $17.TransferRequest();
      case 'GetSidechainWealth': return $17.GetSidechainWealthRequest();
      case 'CreateDeposit': return $17.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $17.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $17.ConnectPeerRequest();
      case 'ListPeers': return $17.ListPeersRequest();
      case 'Mine': return $17.MineRequest();
      case 'GetBlock': return $17.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $17.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $17.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $17.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $17.GetWalletUtxosRequest();
      case 'ListUtxos': return $17.ListUtxosRequest();
      case 'RemoveFromMempool': return $17.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $17.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $17.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $17.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $17.CallRawRequest();
      case 'RefreshWallet': return $17.RefreshWalletRequest();
      case 'GetTransaction': return $17.GetTransactionRequest();
      case 'GetTransactionInfo': return $17.GetTransactionInfoRequest();
      case 'GetWalletAddresses': return $17.GetWalletAddressesRequest();
      case 'MyUtxos': return $17.MyUtxosRequest();
      case 'MyUnconfirmedUtxos': return $17.MyUnconfirmedUtxosRequest();
      case 'CalculateInitialLiquidity': return $17.CalculateInitialLiquidityRequest();
      case 'MarketCreate': return $17.MarketCreateRequest();
      case 'MarketList': return $17.MarketListRequest();
      case 'MarketGet': return $17.MarketGetRequest();
      case 'MarketBuy': return $17.MarketBuyRequest();
      case 'MarketSell': return $17.MarketSellRequest();
      case 'MarketPositions': return $17.MarketPositionsRequest();
      case 'SlotStatus': return $17.SlotStatusRequest();
      case 'SlotList': return $17.SlotListRequest();
      case 'SlotGet': return $17.SlotGetRequest();
      case 'SlotClaim': return $17.SlotClaimRequest();
      case 'SlotClaimCategory': return $17.SlotClaimCategoryRequest();
      case 'VoteRegister': return $17.VoteRegisterRequest();
      case 'VoteVoter': return $17.VoteVoterRequest();
      case 'VoteVoters': return $17.VoteVotersRequest();
      case 'VoteSubmit': return $17.VoteSubmitRequest();
      case 'VoteList': return $17.VoteListRequest();
      case 'VotePeriod': return $17.VotePeriodRequest();
      case 'VotecoinTransfer': return $17.VotecoinTransferRequest();
      case 'VotecoinBalance': return $17.VotecoinBalanceRequest();
      case 'TransferVotecoin': return $17.TransferVotecoinRequest();
      case 'GetNewEncryptionKey': return $17.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey': return $17.GetNewVerifyingKeyRequest();
      case 'EncryptMsg': return $17.EncryptMsgRequest();
      case 'DecryptMsg': return $17.DecryptMsgRequest();
      case 'SignArbitraryMsg': return $17.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr': return $17.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature': return $17.VerifySignatureRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $17.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $17.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $17.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $17.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $17.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $17.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $17.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $17.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $17.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $17.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $17.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $17.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $17.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $17.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $17.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $17.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $17.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $17.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $17.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $17.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $17.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $17.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $17.CallRawRequest);
      case 'RefreshWallet': return this.refreshWallet(ctx, request as $17.RefreshWalletRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $17.GetTransactionRequest);
      case 'GetTransactionInfo': return this.getTransactionInfo(ctx, request as $17.GetTransactionInfoRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $17.GetWalletAddressesRequest);
      case 'MyUtxos': return this.myUtxos(ctx, request as $17.MyUtxosRequest);
      case 'MyUnconfirmedUtxos': return this.myUnconfirmedUtxos(ctx, request as $17.MyUnconfirmedUtxosRequest);
      case 'CalculateInitialLiquidity': return this.calculateInitialLiquidity(ctx, request as $17.CalculateInitialLiquidityRequest);
      case 'MarketCreate': return this.marketCreate(ctx, request as $17.MarketCreateRequest);
      case 'MarketList': return this.marketList(ctx, request as $17.MarketListRequest);
      case 'MarketGet': return this.marketGet(ctx, request as $17.MarketGetRequest);
      case 'MarketBuy': return this.marketBuy(ctx, request as $17.MarketBuyRequest);
      case 'MarketSell': return this.marketSell(ctx, request as $17.MarketSellRequest);
      case 'MarketPositions': return this.marketPositions(ctx, request as $17.MarketPositionsRequest);
      case 'SlotStatus': return this.slotStatus(ctx, request as $17.SlotStatusRequest);
      case 'SlotList': return this.slotList(ctx, request as $17.SlotListRequest);
      case 'SlotGet': return this.slotGet(ctx, request as $17.SlotGetRequest);
      case 'SlotClaim': return this.slotClaim(ctx, request as $17.SlotClaimRequest);
      case 'SlotClaimCategory': return this.slotClaimCategory(ctx, request as $17.SlotClaimCategoryRequest);
      case 'VoteRegister': return this.voteRegister(ctx, request as $17.VoteRegisterRequest);
      case 'VoteVoter': return this.voteVoter(ctx, request as $17.VoteVoterRequest);
      case 'VoteVoters': return this.voteVoters(ctx, request as $17.VoteVotersRequest);
      case 'VoteSubmit': return this.voteSubmit(ctx, request as $17.VoteSubmitRequest);
      case 'VoteList': return this.voteList(ctx, request as $17.VoteListRequest);
      case 'VotePeriod': return this.votePeriod(ctx, request as $17.VotePeriodRequest);
      case 'VotecoinTransfer': return this.votecoinTransfer(ctx, request as $17.VotecoinTransferRequest);
      case 'VotecoinBalance': return this.votecoinBalance(ctx, request as $17.VotecoinBalanceRequest);
      case 'TransferVotecoin': return this.transferVotecoin(ctx, request as $17.TransferVotecoinRequest);
      case 'GetNewEncryptionKey': return this.getNewEncryptionKey(ctx, request as $17.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey': return this.getNewVerifyingKey(ctx, request as $17.GetNewVerifyingKeyRequest);
      case 'EncryptMsg': return this.encryptMsg(ctx, request as $17.EncryptMsgRequest);
      case 'DecryptMsg': return this.decryptMsg(ctx, request as $17.DecryptMsgRequest);
      case 'SignArbitraryMsg': return this.signArbitraryMsg(ctx, request as $17.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr': return this.signArbitraryMsgAsAddr(ctx, request as $17.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature': return this.verifySignature(ctx, request as $17.VerifySignatureRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TruthcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => TruthcoinServiceBase$messageJson;
}

