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

import 'truthcoin.pb.dart' as $14;
import 'truthcoin.pbjson.dart';

export 'truthcoin.pb.dart';

abstract class TruthcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$14.GetBalanceResponse> getBalance($pb.ServerContext ctx, $14.GetBalanceRequest request);
  $async.Future<$14.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $14.GetBlockCountRequest request);
  $async.Future<$14.StopResponse> stop($pb.ServerContext ctx, $14.StopRequest request);
  $async.Future<$14.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $14.GetNewAddressRequest request);
  $async.Future<$14.WithdrawResponse> withdraw($pb.ServerContext ctx, $14.WithdrawRequest request);
  $async.Future<$14.TransferResponse> transfer($pb.ServerContext ctx, $14.TransferRequest request);
  $async.Future<$14.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $14.GetSidechainWealthRequest request);
  $async.Future<$14.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $14.CreateDepositRequest request);
  $async.Future<$14.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $14.GetPendingWithdrawalBundleRequest request);
  $async.Future<$14.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $14.ConnectPeerRequest request);
  $async.Future<$14.ListPeersResponse> listPeers($pb.ServerContext ctx, $14.ListPeersRequest request);
  $async.Future<$14.MineResponse> mine($pb.ServerContext ctx, $14.MineRequest request);
  $async.Future<$14.GetBlockResponse> getBlock($pb.ServerContext ctx, $14.GetBlockRequest request);
  $async.Future<$14.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $14.GetBestMainchainBlockHashRequest request);
  $async.Future<$14.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $14.GetBestSidechainBlockHashRequest request);
  $async.Future<$14.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $14.GetBmmInclusionsRequest request);
  $async.Future<$14.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $14.GetWalletUtxosRequest request);
  $async.Future<$14.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $14.ListUtxosRequest request);
  $async.Future<$14.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $14.RemoveFromMempoolRequest request);
  $async.Future<$14.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $14.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$14.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $14.GenerateMnemonicRequest request);
  $async.Future<$14.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $14.SetSeedFromMnemonicRequest request);
  $async.Future<$14.CallRawResponse> callRaw($pb.ServerContext ctx, $14.CallRawRequest request);
  $async.Future<$14.RefreshWalletResponse> refreshWallet($pb.ServerContext ctx, $14.RefreshWalletRequest request);
  $async.Future<$14.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $14.GetTransactionRequest request);
  $async.Future<$14.GetTransactionInfoResponse> getTransactionInfo($pb.ServerContext ctx, $14.GetTransactionInfoRequest request);
  $async.Future<$14.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $14.GetWalletAddressesRequest request);
  $async.Future<$14.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $14.MyUtxosRequest request);
  $async.Future<$14.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos($pb.ServerContext ctx, $14.MyUnconfirmedUtxosRequest request);
  $async.Future<$14.CalculateInitialLiquidityResponse> calculateInitialLiquidity($pb.ServerContext ctx, $14.CalculateInitialLiquidityRequest request);
  $async.Future<$14.MarketCreateResponse> marketCreate($pb.ServerContext ctx, $14.MarketCreateRequest request);
  $async.Future<$14.MarketListResponse> marketList($pb.ServerContext ctx, $14.MarketListRequest request);
  $async.Future<$14.MarketGetResponse> marketGet($pb.ServerContext ctx, $14.MarketGetRequest request);
  $async.Future<$14.MarketBuyResponse> marketBuy($pb.ServerContext ctx, $14.MarketBuyRequest request);
  $async.Future<$14.MarketSellResponse> marketSell($pb.ServerContext ctx, $14.MarketSellRequest request);
  $async.Future<$14.MarketPositionsResponse> marketPositions($pb.ServerContext ctx, $14.MarketPositionsRequest request);
  $async.Future<$14.SlotStatusResponse> slotStatus($pb.ServerContext ctx, $14.SlotStatusRequest request);
  $async.Future<$14.SlotListResponse> slotList($pb.ServerContext ctx, $14.SlotListRequest request);
  $async.Future<$14.SlotGetResponse> slotGet($pb.ServerContext ctx, $14.SlotGetRequest request);
  $async.Future<$14.SlotClaimResponse> slotClaim($pb.ServerContext ctx, $14.SlotClaimRequest request);
  $async.Future<$14.SlotClaimCategoryResponse> slotClaimCategory($pb.ServerContext ctx, $14.SlotClaimCategoryRequest request);
  $async.Future<$14.VoteRegisterResponse> voteRegister($pb.ServerContext ctx, $14.VoteRegisterRequest request);
  $async.Future<$14.VoteVoterResponse> voteVoter($pb.ServerContext ctx, $14.VoteVoterRequest request);
  $async.Future<$14.VoteVotersResponse> voteVoters($pb.ServerContext ctx, $14.VoteVotersRequest request);
  $async.Future<$14.VoteSubmitResponse> voteSubmit($pb.ServerContext ctx, $14.VoteSubmitRequest request);
  $async.Future<$14.VoteListResponse> voteList($pb.ServerContext ctx, $14.VoteListRequest request);
  $async.Future<$14.VotePeriodResponse> votePeriod($pb.ServerContext ctx, $14.VotePeriodRequest request);
  $async.Future<$14.VotecoinTransferResponse> votecoinTransfer($pb.ServerContext ctx, $14.VotecoinTransferRequest request);
  $async.Future<$14.VotecoinBalanceResponse> votecoinBalance($pb.ServerContext ctx, $14.VotecoinBalanceRequest request);
  $async.Future<$14.TransferVotecoinResponse> transferVotecoin($pb.ServerContext ctx, $14.TransferVotecoinRequest request);
  $async.Future<$14.GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ServerContext ctx, $14.GetNewEncryptionKeyRequest request);
  $async.Future<$14.GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ServerContext ctx, $14.GetNewVerifyingKeyRequest request);
  $async.Future<$14.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $14.EncryptMsgRequest request);
  $async.Future<$14.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $14.DecryptMsgRequest request);
  $async.Future<$14.SignArbitraryMsgResponse> signArbitraryMsg($pb.ServerContext ctx, $14.SignArbitraryMsgRequest request);
  $async.Future<$14.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ServerContext ctx, $14.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$14.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $14.VerifySignatureRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $14.GetBalanceRequest();
      case 'GetBlockCount': return $14.GetBlockCountRequest();
      case 'Stop': return $14.StopRequest();
      case 'GetNewAddress': return $14.GetNewAddressRequest();
      case 'Withdraw': return $14.WithdrawRequest();
      case 'Transfer': return $14.TransferRequest();
      case 'GetSidechainWealth': return $14.GetSidechainWealthRequest();
      case 'CreateDeposit': return $14.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $14.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $14.ConnectPeerRequest();
      case 'ListPeers': return $14.ListPeersRequest();
      case 'Mine': return $14.MineRequest();
      case 'GetBlock': return $14.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $14.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $14.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $14.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $14.GetWalletUtxosRequest();
      case 'ListUtxos': return $14.ListUtxosRequest();
      case 'RemoveFromMempool': return $14.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $14.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $14.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $14.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $14.CallRawRequest();
      case 'RefreshWallet': return $14.RefreshWalletRequest();
      case 'GetTransaction': return $14.GetTransactionRequest();
      case 'GetTransactionInfo': return $14.GetTransactionInfoRequest();
      case 'GetWalletAddresses': return $14.GetWalletAddressesRequest();
      case 'MyUtxos': return $14.MyUtxosRequest();
      case 'MyUnconfirmedUtxos': return $14.MyUnconfirmedUtxosRequest();
      case 'CalculateInitialLiquidity': return $14.CalculateInitialLiquidityRequest();
      case 'MarketCreate': return $14.MarketCreateRequest();
      case 'MarketList': return $14.MarketListRequest();
      case 'MarketGet': return $14.MarketGetRequest();
      case 'MarketBuy': return $14.MarketBuyRequest();
      case 'MarketSell': return $14.MarketSellRequest();
      case 'MarketPositions': return $14.MarketPositionsRequest();
      case 'SlotStatus': return $14.SlotStatusRequest();
      case 'SlotList': return $14.SlotListRequest();
      case 'SlotGet': return $14.SlotGetRequest();
      case 'SlotClaim': return $14.SlotClaimRequest();
      case 'SlotClaimCategory': return $14.SlotClaimCategoryRequest();
      case 'VoteRegister': return $14.VoteRegisterRequest();
      case 'VoteVoter': return $14.VoteVoterRequest();
      case 'VoteVoters': return $14.VoteVotersRequest();
      case 'VoteSubmit': return $14.VoteSubmitRequest();
      case 'VoteList': return $14.VoteListRequest();
      case 'VotePeriod': return $14.VotePeriodRequest();
      case 'VotecoinTransfer': return $14.VotecoinTransferRequest();
      case 'VotecoinBalance': return $14.VotecoinBalanceRequest();
      case 'TransferVotecoin': return $14.TransferVotecoinRequest();
      case 'GetNewEncryptionKey': return $14.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey': return $14.GetNewVerifyingKeyRequest();
      case 'EncryptMsg': return $14.EncryptMsgRequest();
      case 'DecryptMsg': return $14.DecryptMsgRequest();
      case 'SignArbitraryMsg': return $14.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr': return $14.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature': return $14.VerifySignatureRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $14.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $14.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $14.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $14.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $14.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $14.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $14.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $14.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $14.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $14.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $14.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $14.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $14.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $14.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $14.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $14.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $14.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $14.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $14.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $14.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $14.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $14.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $14.CallRawRequest);
      case 'RefreshWallet': return this.refreshWallet(ctx, request as $14.RefreshWalletRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $14.GetTransactionRequest);
      case 'GetTransactionInfo': return this.getTransactionInfo(ctx, request as $14.GetTransactionInfoRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $14.GetWalletAddressesRequest);
      case 'MyUtxos': return this.myUtxos(ctx, request as $14.MyUtxosRequest);
      case 'MyUnconfirmedUtxos': return this.myUnconfirmedUtxos(ctx, request as $14.MyUnconfirmedUtxosRequest);
      case 'CalculateInitialLiquidity': return this.calculateInitialLiquidity(ctx, request as $14.CalculateInitialLiquidityRequest);
      case 'MarketCreate': return this.marketCreate(ctx, request as $14.MarketCreateRequest);
      case 'MarketList': return this.marketList(ctx, request as $14.MarketListRequest);
      case 'MarketGet': return this.marketGet(ctx, request as $14.MarketGetRequest);
      case 'MarketBuy': return this.marketBuy(ctx, request as $14.MarketBuyRequest);
      case 'MarketSell': return this.marketSell(ctx, request as $14.MarketSellRequest);
      case 'MarketPositions': return this.marketPositions(ctx, request as $14.MarketPositionsRequest);
      case 'SlotStatus': return this.slotStatus(ctx, request as $14.SlotStatusRequest);
      case 'SlotList': return this.slotList(ctx, request as $14.SlotListRequest);
      case 'SlotGet': return this.slotGet(ctx, request as $14.SlotGetRequest);
      case 'SlotClaim': return this.slotClaim(ctx, request as $14.SlotClaimRequest);
      case 'SlotClaimCategory': return this.slotClaimCategory(ctx, request as $14.SlotClaimCategoryRequest);
      case 'VoteRegister': return this.voteRegister(ctx, request as $14.VoteRegisterRequest);
      case 'VoteVoter': return this.voteVoter(ctx, request as $14.VoteVoterRequest);
      case 'VoteVoters': return this.voteVoters(ctx, request as $14.VoteVotersRequest);
      case 'VoteSubmit': return this.voteSubmit(ctx, request as $14.VoteSubmitRequest);
      case 'VoteList': return this.voteList(ctx, request as $14.VoteListRequest);
      case 'VotePeriod': return this.votePeriod(ctx, request as $14.VotePeriodRequest);
      case 'VotecoinTransfer': return this.votecoinTransfer(ctx, request as $14.VotecoinTransferRequest);
      case 'VotecoinBalance': return this.votecoinBalance(ctx, request as $14.VotecoinBalanceRequest);
      case 'TransferVotecoin': return this.transferVotecoin(ctx, request as $14.TransferVotecoinRequest);
      case 'GetNewEncryptionKey': return this.getNewEncryptionKey(ctx, request as $14.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey': return this.getNewVerifyingKey(ctx, request as $14.GetNewVerifyingKeyRequest);
      case 'EncryptMsg': return this.encryptMsg(ctx, request as $14.EncryptMsgRequest);
      case 'DecryptMsg': return this.decryptMsg(ctx, request as $14.DecryptMsgRequest);
      case 'SignArbitraryMsg': return this.signArbitraryMsg(ctx, request as $14.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr': return this.signArbitraryMsgAsAddr(ctx, request as $14.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature': return this.verifySignature(ctx, request as $14.VerifySignatureRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TruthcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => TruthcoinServiceBase$messageJson;
}

