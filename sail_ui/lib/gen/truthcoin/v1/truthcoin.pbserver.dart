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

import 'truthcoin.pb.dart' as $12;
import 'truthcoin.pbjson.dart';

export 'truthcoin.pb.dart';

abstract class TruthcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$12.GetBalanceResponse> getBalance($pb.ServerContext ctx, $12.GetBalanceRequest request);
  $async.Future<$12.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $12.GetBlockCountRequest request);
  $async.Future<$12.StopResponse> stop($pb.ServerContext ctx, $12.StopRequest request);
  $async.Future<$12.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $12.GetNewAddressRequest request);
  $async.Future<$12.WithdrawResponse> withdraw($pb.ServerContext ctx, $12.WithdrawRequest request);
  $async.Future<$12.TransferResponse> transfer($pb.ServerContext ctx, $12.TransferRequest request);
  $async.Future<$12.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $12.GetSidechainWealthRequest request);
  $async.Future<$12.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $12.CreateDepositRequest request);
  $async.Future<$12.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $12.GetPendingWithdrawalBundleRequest request);
  $async.Future<$12.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $12.ConnectPeerRequest request);
  $async.Future<$12.ListPeersResponse> listPeers($pb.ServerContext ctx, $12.ListPeersRequest request);
  $async.Future<$12.MineResponse> mine($pb.ServerContext ctx, $12.MineRequest request);
  $async.Future<$12.GetBlockResponse> getBlock($pb.ServerContext ctx, $12.GetBlockRequest request);
  $async.Future<$12.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $12.GetBestMainchainBlockHashRequest request);
  $async.Future<$12.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $12.GetBestSidechainBlockHashRequest request);
  $async.Future<$12.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $12.GetBmmInclusionsRequest request);
  $async.Future<$12.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $12.GetWalletUtxosRequest request);
  $async.Future<$12.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $12.ListUtxosRequest request);
  $async.Future<$12.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $12.RemoveFromMempoolRequest request);
  $async.Future<$12.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $12.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$12.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $12.GenerateMnemonicRequest request);
  $async.Future<$12.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $12.SetSeedFromMnemonicRequest request);
  $async.Future<$12.CallRawResponse> callRaw($pb.ServerContext ctx, $12.CallRawRequest request);
  $async.Future<$12.RefreshWalletResponse> refreshWallet($pb.ServerContext ctx, $12.RefreshWalletRequest request);
  $async.Future<$12.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $12.GetTransactionRequest request);
  $async.Future<$12.GetTransactionInfoResponse> getTransactionInfo($pb.ServerContext ctx, $12.GetTransactionInfoRequest request);
  $async.Future<$12.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $12.GetWalletAddressesRequest request);
  $async.Future<$12.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $12.MyUtxosRequest request);
  $async.Future<$12.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos($pb.ServerContext ctx, $12.MyUnconfirmedUtxosRequest request);
  $async.Future<$12.CalculateInitialLiquidityResponse> calculateInitialLiquidity($pb.ServerContext ctx, $12.CalculateInitialLiquidityRequest request);
  $async.Future<$12.MarketCreateResponse> marketCreate($pb.ServerContext ctx, $12.MarketCreateRequest request);
  $async.Future<$12.MarketListResponse> marketList($pb.ServerContext ctx, $12.MarketListRequest request);
  $async.Future<$12.MarketGetResponse> marketGet($pb.ServerContext ctx, $12.MarketGetRequest request);
  $async.Future<$12.MarketBuyResponse> marketBuy($pb.ServerContext ctx, $12.MarketBuyRequest request);
  $async.Future<$12.MarketSellResponse> marketSell($pb.ServerContext ctx, $12.MarketSellRequest request);
  $async.Future<$12.MarketPositionsResponse> marketPositions($pb.ServerContext ctx, $12.MarketPositionsRequest request);
  $async.Future<$12.SlotStatusResponse> slotStatus($pb.ServerContext ctx, $12.SlotStatusRequest request);
  $async.Future<$12.SlotListResponse> slotList($pb.ServerContext ctx, $12.SlotListRequest request);
  $async.Future<$12.SlotGetResponse> slotGet($pb.ServerContext ctx, $12.SlotGetRequest request);
  $async.Future<$12.SlotClaimResponse> slotClaim($pb.ServerContext ctx, $12.SlotClaimRequest request);
  $async.Future<$12.SlotClaimCategoryResponse> slotClaimCategory($pb.ServerContext ctx, $12.SlotClaimCategoryRequest request);
  $async.Future<$12.VoteRegisterResponse> voteRegister($pb.ServerContext ctx, $12.VoteRegisterRequest request);
  $async.Future<$12.VoteVoterResponse> voteVoter($pb.ServerContext ctx, $12.VoteVoterRequest request);
  $async.Future<$12.VoteVotersResponse> voteVoters($pb.ServerContext ctx, $12.VoteVotersRequest request);
  $async.Future<$12.VoteSubmitResponse> voteSubmit($pb.ServerContext ctx, $12.VoteSubmitRequest request);
  $async.Future<$12.VoteListResponse> voteList($pb.ServerContext ctx, $12.VoteListRequest request);
  $async.Future<$12.VotePeriodResponse> votePeriod($pb.ServerContext ctx, $12.VotePeriodRequest request);
  $async.Future<$12.VotecoinTransferResponse> votecoinTransfer($pb.ServerContext ctx, $12.VotecoinTransferRequest request);
  $async.Future<$12.VotecoinBalanceResponse> votecoinBalance($pb.ServerContext ctx, $12.VotecoinBalanceRequest request);
  $async.Future<$12.TransferVotecoinResponse> transferVotecoin($pb.ServerContext ctx, $12.TransferVotecoinRequest request);
  $async.Future<$12.GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ServerContext ctx, $12.GetNewEncryptionKeyRequest request);
  $async.Future<$12.GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ServerContext ctx, $12.GetNewVerifyingKeyRequest request);
  $async.Future<$12.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $12.EncryptMsgRequest request);
  $async.Future<$12.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $12.DecryptMsgRequest request);
  $async.Future<$12.SignArbitraryMsgResponse> signArbitraryMsg($pb.ServerContext ctx, $12.SignArbitraryMsgRequest request);
  $async.Future<$12.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ServerContext ctx, $12.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$12.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $12.VerifySignatureRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $12.GetBalanceRequest();
      case 'GetBlockCount': return $12.GetBlockCountRequest();
      case 'Stop': return $12.StopRequest();
      case 'GetNewAddress': return $12.GetNewAddressRequest();
      case 'Withdraw': return $12.WithdrawRequest();
      case 'Transfer': return $12.TransferRequest();
      case 'GetSidechainWealth': return $12.GetSidechainWealthRequest();
      case 'CreateDeposit': return $12.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $12.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $12.ConnectPeerRequest();
      case 'ListPeers': return $12.ListPeersRequest();
      case 'Mine': return $12.MineRequest();
      case 'GetBlock': return $12.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $12.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $12.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $12.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $12.GetWalletUtxosRequest();
      case 'ListUtxos': return $12.ListUtxosRequest();
      case 'RemoveFromMempool': return $12.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $12.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $12.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $12.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $12.CallRawRequest();
      case 'RefreshWallet': return $12.RefreshWalletRequest();
      case 'GetTransaction': return $12.GetTransactionRequest();
      case 'GetTransactionInfo': return $12.GetTransactionInfoRequest();
      case 'GetWalletAddresses': return $12.GetWalletAddressesRequest();
      case 'MyUtxos': return $12.MyUtxosRequest();
      case 'MyUnconfirmedUtxos': return $12.MyUnconfirmedUtxosRequest();
      case 'CalculateInitialLiquidity': return $12.CalculateInitialLiquidityRequest();
      case 'MarketCreate': return $12.MarketCreateRequest();
      case 'MarketList': return $12.MarketListRequest();
      case 'MarketGet': return $12.MarketGetRequest();
      case 'MarketBuy': return $12.MarketBuyRequest();
      case 'MarketSell': return $12.MarketSellRequest();
      case 'MarketPositions': return $12.MarketPositionsRequest();
      case 'SlotStatus': return $12.SlotStatusRequest();
      case 'SlotList': return $12.SlotListRequest();
      case 'SlotGet': return $12.SlotGetRequest();
      case 'SlotClaim': return $12.SlotClaimRequest();
      case 'SlotClaimCategory': return $12.SlotClaimCategoryRequest();
      case 'VoteRegister': return $12.VoteRegisterRequest();
      case 'VoteVoter': return $12.VoteVoterRequest();
      case 'VoteVoters': return $12.VoteVotersRequest();
      case 'VoteSubmit': return $12.VoteSubmitRequest();
      case 'VoteList': return $12.VoteListRequest();
      case 'VotePeriod': return $12.VotePeriodRequest();
      case 'VotecoinTransfer': return $12.VotecoinTransferRequest();
      case 'VotecoinBalance': return $12.VotecoinBalanceRequest();
      case 'TransferVotecoin': return $12.TransferVotecoinRequest();
      case 'GetNewEncryptionKey': return $12.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey': return $12.GetNewVerifyingKeyRequest();
      case 'EncryptMsg': return $12.EncryptMsgRequest();
      case 'DecryptMsg': return $12.DecryptMsgRequest();
      case 'SignArbitraryMsg': return $12.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr': return $12.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature': return $12.VerifySignatureRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $12.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $12.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $12.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $12.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $12.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $12.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $12.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $12.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $12.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $12.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $12.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $12.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $12.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $12.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $12.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $12.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $12.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $12.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $12.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $12.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $12.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $12.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $12.CallRawRequest);
      case 'RefreshWallet': return this.refreshWallet(ctx, request as $12.RefreshWalletRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $12.GetTransactionRequest);
      case 'GetTransactionInfo': return this.getTransactionInfo(ctx, request as $12.GetTransactionInfoRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $12.GetWalletAddressesRequest);
      case 'MyUtxos': return this.myUtxos(ctx, request as $12.MyUtxosRequest);
      case 'MyUnconfirmedUtxos': return this.myUnconfirmedUtxos(ctx, request as $12.MyUnconfirmedUtxosRequest);
      case 'CalculateInitialLiquidity': return this.calculateInitialLiquidity(ctx, request as $12.CalculateInitialLiquidityRequest);
      case 'MarketCreate': return this.marketCreate(ctx, request as $12.MarketCreateRequest);
      case 'MarketList': return this.marketList(ctx, request as $12.MarketListRequest);
      case 'MarketGet': return this.marketGet(ctx, request as $12.MarketGetRequest);
      case 'MarketBuy': return this.marketBuy(ctx, request as $12.MarketBuyRequest);
      case 'MarketSell': return this.marketSell(ctx, request as $12.MarketSellRequest);
      case 'MarketPositions': return this.marketPositions(ctx, request as $12.MarketPositionsRequest);
      case 'SlotStatus': return this.slotStatus(ctx, request as $12.SlotStatusRequest);
      case 'SlotList': return this.slotList(ctx, request as $12.SlotListRequest);
      case 'SlotGet': return this.slotGet(ctx, request as $12.SlotGetRequest);
      case 'SlotClaim': return this.slotClaim(ctx, request as $12.SlotClaimRequest);
      case 'SlotClaimCategory': return this.slotClaimCategory(ctx, request as $12.SlotClaimCategoryRequest);
      case 'VoteRegister': return this.voteRegister(ctx, request as $12.VoteRegisterRequest);
      case 'VoteVoter': return this.voteVoter(ctx, request as $12.VoteVoterRequest);
      case 'VoteVoters': return this.voteVoters(ctx, request as $12.VoteVotersRequest);
      case 'VoteSubmit': return this.voteSubmit(ctx, request as $12.VoteSubmitRequest);
      case 'VoteList': return this.voteList(ctx, request as $12.VoteListRequest);
      case 'VotePeriod': return this.votePeriod(ctx, request as $12.VotePeriodRequest);
      case 'VotecoinTransfer': return this.votecoinTransfer(ctx, request as $12.VotecoinTransferRequest);
      case 'VotecoinBalance': return this.votecoinBalance(ctx, request as $12.VotecoinBalanceRequest);
      case 'TransferVotecoin': return this.transferVotecoin(ctx, request as $12.TransferVotecoinRequest);
      case 'GetNewEncryptionKey': return this.getNewEncryptionKey(ctx, request as $12.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey': return this.getNewVerifyingKey(ctx, request as $12.GetNewVerifyingKeyRequest);
      case 'EncryptMsg': return this.encryptMsg(ctx, request as $12.EncryptMsgRequest);
      case 'DecryptMsg': return this.decryptMsg(ctx, request as $12.DecryptMsgRequest);
      case 'SignArbitraryMsg': return this.signArbitraryMsg(ctx, request as $12.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr': return this.signArbitraryMsgAsAddr(ctx, request as $12.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature': return this.verifySignature(ctx, request as $12.VerifySignatureRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TruthcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => TruthcoinServiceBase$messageJson;
}

