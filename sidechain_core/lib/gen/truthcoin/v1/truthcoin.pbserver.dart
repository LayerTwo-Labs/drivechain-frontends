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

import 'truthcoin.pb.dart' as $15;
import 'truthcoin.pbjson.dart';

export 'truthcoin.pb.dart';

abstract class TruthcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$15.GetBalanceResponse> getBalance($pb.ServerContext ctx, $15.GetBalanceRequest request);
  $async.Future<$15.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $15.GetBlockCountRequest request);
  $async.Future<$15.StopResponse> stop($pb.ServerContext ctx, $15.StopRequest request);
  $async.Future<$15.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $15.GetNewAddressRequest request);
  $async.Future<$15.WithdrawResponse> withdraw($pb.ServerContext ctx, $15.WithdrawRequest request);
  $async.Future<$15.TransferResponse> transfer($pb.ServerContext ctx, $15.TransferRequest request);
  $async.Future<$15.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $15.GetSidechainWealthRequest request);
  $async.Future<$15.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $15.CreateDepositRequest request);
  $async.Future<$15.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $15.GetPendingWithdrawalBundleRequest request);
  $async.Future<$15.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $15.ConnectPeerRequest request);
  $async.Future<$15.ListPeersResponse> listPeers($pb.ServerContext ctx, $15.ListPeersRequest request);
  $async.Future<$15.MineResponse> mine($pb.ServerContext ctx, $15.MineRequest request);
  $async.Future<$15.GetBlockResponse> getBlock($pb.ServerContext ctx, $15.GetBlockRequest request);
  $async.Future<$15.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $15.GetBestMainchainBlockHashRequest request);
  $async.Future<$15.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $15.GetBestSidechainBlockHashRequest request);
  $async.Future<$15.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $15.GetBmmInclusionsRequest request);
  $async.Future<$15.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $15.GetWalletUtxosRequest request);
  $async.Future<$15.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $15.ListUtxosRequest request);
  $async.Future<$15.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $15.RemoveFromMempoolRequest request);
  $async.Future<$15.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $15.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$15.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $15.GenerateMnemonicRequest request);
  $async.Future<$15.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $15.SetSeedFromMnemonicRequest request);
  $async.Future<$15.CallRawResponse> callRaw($pb.ServerContext ctx, $15.CallRawRequest request);
  $async.Future<$15.RefreshWalletResponse> refreshWallet($pb.ServerContext ctx, $15.RefreshWalletRequest request);
  $async.Future<$15.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $15.GetTransactionRequest request);
  $async.Future<$15.GetTransactionInfoResponse> getTransactionInfo($pb.ServerContext ctx, $15.GetTransactionInfoRequest request);
  $async.Future<$15.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $15.GetWalletAddressesRequest request);
  $async.Future<$15.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $15.MyUtxosRequest request);
  $async.Future<$15.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos($pb.ServerContext ctx, $15.MyUnconfirmedUtxosRequest request);
  $async.Future<$15.CalculateInitialLiquidityResponse> calculateInitialLiquidity($pb.ServerContext ctx, $15.CalculateInitialLiquidityRequest request);
  $async.Future<$15.MarketCreateResponse> marketCreate($pb.ServerContext ctx, $15.MarketCreateRequest request);
  $async.Future<$15.MarketListResponse> marketList($pb.ServerContext ctx, $15.MarketListRequest request);
  $async.Future<$15.MarketGetResponse> marketGet($pb.ServerContext ctx, $15.MarketGetRequest request);
  $async.Future<$15.MarketBuyResponse> marketBuy($pb.ServerContext ctx, $15.MarketBuyRequest request);
  $async.Future<$15.MarketSellResponse> marketSell($pb.ServerContext ctx, $15.MarketSellRequest request);
  $async.Future<$15.MarketPositionsResponse> marketPositions($pb.ServerContext ctx, $15.MarketPositionsRequest request);
  $async.Future<$15.SlotStatusResponse> slotStatus($pb.ServerContext ctx, $15.SlotStatusRequest request);
  $async.Future<$15.SlotListResponse> slotList($pb.ServerContext ctx, $15.SlotListRequest request);
  $async.Future<$15.SlotGetResponse> slotGet($pb.ServerContext ctx, $15.SlotGetRequest request);
  $async.Future<$15.SlotClaimResponse> slotClaim($pb.ServerContext ctx, $15.SlotClaimRequest request);
  $async.Future<$15.SlotClaimCategoryResponse> slotClaimCategory($pb.ServerContext ctx, $15.SlotClaimCategoryRequest request);
  $async.Future<$15.VoteRegisterResponse> voteRegister($pb.ServerContext ctx, $15.VoteRegisterRequest request);
  $async.Future<$15.VoteVoterResponse> voteVoter($pb.ServerContext ctx, $15.VoteVoterRequest request);
  $async.Future<$15.VoteVotersResponse> voteVoters($pb.ServerContext ctx, $15.VoteVotersRequest request);
  $async.Future<$15.VoteSubmitResponse> voteSubmit($pb.ServerContext ctx, $15.VoteSubmitRequest request);
  $async.Future<$15.VoteListResponse> voteList($pb.ServerContext ctx, $15.VoteListRequest request);
  $async.Future<$15.VotePeriodResponse> votePeriod($pb.ServerContext ctx, $15.VotePeriodRequest request);
  $async.Future<$15.VotecoinTransferResponse> votecoinTransfer($pb.ServerContext ctx, $15.VotecoinTransferRequest request);
  $async.Future<$15.VotecoinBalanceResponse> votecoinBalance($pb.ServerContext ctx, $15.VotecoinBalanceRequest request);
  $async.Future<$15.TransferVotecoinResponse> transferVotecoin($pb.ServerContext ctx, $15.TransferVotecoinRequest request);
  $async.Future<$15.GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ServerContext ctx, $15.GetNewEncryptionKeyRequest request);
  $async.Future<$15.GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ServerContext ctx, $15.GetNewVerifyingKeyRequest request);
  $async.Future<$15.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $15.EncryptMsgRequest request);
  $async.Future<$15.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $15.DecryptMsgRequest request);
  $async.Future<$15.SignArbitraryMsgResponse> signArbitraryMsg($pb.ServerContext ctx, $15.SignArbitraryMsgRequest request);
  $async.Future<$15.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ServerContext ctx, $15.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$15.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $15.VerifySignatureRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $15.GetBalanceRequest();
      case 'GetBlockCount': return $15.GetBlockCountRequest();
      case 'Stop': return $15.StopRequest();
      case 'GetNewAddress': return $15.GetNewAddressRequest();
      case 'Withdraw': return $15.WithdrawRequest();
      case 'Transfer': return $15.TransferRequest();
      case 'GetSidechainWealth': return $15.GetSidechainWealthRequest();
      case 'CreateDeposit': return $15.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $15.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $15.ConnectPeerRequest();
      case 'ListPeers': return $15.ListPeersRequest();
      case 'Mine': return $15.MineRequest();
      case 'GetBlock': return $15.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $15.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $15.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $15.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $15.GetWalletUtxosRequest();
      case 'ListUtxos': return $15.ListUtxosRequest();
      case 'RemoveFromMempool': return $15.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $15.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $15.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $15.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $15.CallRawRequest();
      case 'RefreshWallet': return $15.RefreshWalletRequest();
      case 'GetTransaction': return $15.GetTransactionRequest();
      case 'GetTransactionInfo': return $15.GetTransactionInfoRequest();
      case 'GetWalletAddresses': return $15.GetWalletAddressesRequest();
      case 'MyUtxos': return $15.MyUtxosRequest();
      case 'MyUnconfirmedUtxos': return $15.MyUnconfirmedUtxosRequest();
      case 'CalculateInitialLiquidity': return $15.CalculateInitialLiquidityRequest();
      case 'MarketCreate': return $15.MarketCreateRequest();
      case 'MarketList': return $15.MarketListRequest();
      case 'MarketGet': return $15.MarketGetRequest();
      case 'MarketBuy': return $15.MarketBuyRequest();
      case 'MarketSell': return $15.MarketSellRequest();
      case 'MarketPositions': return $15.MarketPositionsRequest();
      case 'SlotStatus': return $15.SlotStatusRequest();
      case 'SlotList': return $15.SlotListRequest();
      case 'SlotGet': return $15.SlotGetRequest();
      case 'SlotClaim': return $15.SlotClaimRequest();
      case 'SlotClaimCategory': return $15.SlotClaimCategoryRequest();
      case 'VoteRegister': return $15.VoteRegisterRequest();
      case 'VoteVoter': return $15.VoteVoterRequest();
      case 'VoteVoters': return $15.VoteVotersRequest();
      case 'VoteSubmit': return $15.VoteSubmitRequest();
      case 'VoteList': return $15.VoteListRequest();
      case 'VotePeriod': return $15.VotePeriodRequest();
      case 'VotecoinTransfer': return $15.VotecoinTransferRequest();
      case 'VotecoinBalance': return $15.VotecoinBalanceRequest();
      case 'TransferVotecoin': return $15.TransferVotecoinRequest();
      case 'GetNewEncryptionKey': return $15.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey': return $15.GetNewVerifyingKeyRequest();
      case 'EncryptMsg': return $15.EncryptMsgRequest();
      case 'DecryptMsg': return $15.DecryptMsgRequest();
      case 'SignArbitraryMsg': return $15.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr': return $15.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature': return $15.VerifySignatureRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $15.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $15.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $15.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $15.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $15.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $15.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $15.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $15.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $15.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $15.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $15.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $15.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $15.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $15.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $15.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $15.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $15.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $15.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $15.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $15.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $15.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $15.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $15.CallRawRequest);
      case 'RefreshWallet': return this.refreshWallet(ctx, request as $15.RefreshWalletRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $15.GetTransactionRequest);
      case 'GetTransactionInfo': return this.getTransactionInfo(ctx, request as $15.GetTransactionInfoRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $15.GetWalletAddressesRequest);
      case 'MyUtxos': return this.myUtxos(ctx, request as $15.MyUtxosRequest);
      case 'MyUnconfirmedUtxos': return this.myUnconfirmedUtxos(ctx, request as $15.MyUnconfirmedUtxosRequest);
      case 'CalculateInitialLiquidity': return this.calculateInitialLiquidity(ctx, request as $15.CalculateInitialLiquidityRequest);
      case 'MarketCreate': return this.marketCreate(ctx, request as $15.MarketCreateRequest);
      case 'MarketList': return this.marketList(ctx, request as $15.MarketListRequest);
      case 'MarketGet': return this.marketGet(ctx, request as $15.MarketGetRequest);
      case 'MarketBuy': return this.marketBuy(ctx, request as $15.MarketBuyRequest);
      case 'MarketSell': return this.marketSell(ctx, request as $15.MarketSellRequest);
      case 'MarketPositions': return this.marketPositions(ctx, request as $15.MarketPositionsRequest);
      case 'SlotStatus': return this.slotStatus(ctx, request as $15.SlotStatusRequest);
      case 'SlotList': return this.slotList(ctx, request as $15.SlotListRequest);
      case 'SlotGet': return this.slotGet(ctx, request as $15.SlotGetRequest);
      case 'SlotClaim': return this.slotClaim(ctx, request as $15.SlotClaimRequest);
      case 'SlotClaimCategory': return this.slotClaimCategory(ctx, request as $15.SlotClaimCategoryRequest);
      case 'VoteRegister': return this.voteRegister(ctx, request as $15.VoteRegisterRequest);
      case 'VoteVoter': return this.voteVoter(ctx, request as $15.VoteVoterRequest);
      case 'VoteVoters': return this.voteVoters(ctx, request as $15.VoteVotersRequest);
      case 'VoteSubmit': return this.voteSubmit(ctx, request as $15.VoteSubmitRequest);
      case 'VoteList': return this.voteList(ctx, request as $15.VoteListRequest);
      case 'VotePeriod': return this.votePeriod(ctx, request as $15.VotePeriodRequest);
      case 'VotecoinTransfer': return this.votecoinTransfer(ctx, request as $15.VotecoinTransferRequest);
      case 'VotecoinBalance': return this.votecoinBalance(ctx, request as $15.VotecoinBalanceRequest);
      case 'TransferVotecoin': return this.transferVotecoin(ctx, request as $15.TransferVotecoinRequest);
      case 'GetNewEncryptionKey': return this.getNewEncryptionKey(ctx, request as $15.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey': return this.getNewVerifyingKey(ctx, request as $15.GetNewVerifyingKeyRequest);
      case 'EncryptMsg': return this.encryptMsg(ctx, request as $15.EncryptMsgRequest);
      case 'DecryptMsg': return this.decryptMsg(ctx, request as $15.DecryptMsgRequest);
      case 'SignArbitraryMsg': return this.signArbitraryMsg(ctx, request as $15.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr': return this.signArbitraryMsgAsAddr(ctx, request as $15.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature': return this.verifySignature(ctx, request as $15.VerifySignatureRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TruthcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => TruthcoinServiceBase$messageJson;
}

