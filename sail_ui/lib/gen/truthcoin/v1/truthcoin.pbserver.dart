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

import 'truthcoin.pb.dart' as $11;
import 'truthcoin.pbjson.dart';

export 'truthcoin.pb.dart';

abstract class TruthcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$11.GetBalanceResponse> getBalance($pb.ServerContext ctx, $11.GetBalanceRequest request);
  $async.Future<$11.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $11.GetBlockCountRequest request);
  $async.Future<$11.StopResponse> stop($pb.ServerContext ctx, $11.StopRequest request);
  $async.Future<$11.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $11.GetNewAddressRequest request);
  $async.Future<$11.WithdrawResponse> withdraw($pb.ServerContext ctx, $11.WithdrawRequest request);
  $async.Future<$11.TransferResponse> transfer($pb.ServerContext ctx, $11.TransferRequest request);
  $async.Future<$11.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $11.GetSidechainWealthRequest request);
  $async.Future<$11.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $11.CreateDepositRequest request);
  $async.Future<$11.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $11.GetPendingWithdrawalBundleRequest request);
  $async.Future<$11.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $11.ConnectPeerRequest request);
  $async.Future<$11.ListPeersResponse> listPeers($pb.ServerContext ctx, $11.ListPeersRequest request);
  $async.Future<$11.MineResponse> mine($pb.ServerContext ctx, $11.MineRequest request);
  $async.Future<$11.GetBlockResponse> getBlock($pb.ServerContext ctx, $11.GetBlockRequest request);
  $async.Future<$11.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $11.GetBestMainchainBlockHashRequest request);
  $async.Future<$11.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $11.GetBestSidechainBlockHashRequest request);
  $async.Future<$11.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $11.GetBmmInclusionsRequest request);
  $async.Future<$11.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $11.GetWalletUtxosRequest request);
  $async.Future<$11.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $11.ListUtxosRequest request);
  $async.Future<$11.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $11.RemoveFromMempoolRequest request);
  $async.Future<$11.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $11.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$11.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $11.GenerateMnemonicRequest request);
  $async.Future<$11.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $11.SetSeedFromMnemonicRequest request);
  $async.Future<$11.CallRawResponse> callRaw($pb.ServerContext ctx, $11.CallRawRequest request);
  $async.Future<$11.RefreshWalletResponse> refreshWallet($pb.ServerContext ctx, $11.RefreshWalletRequest request);
  $async.Future<$11.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $11.GetTransactionRequest request);
  $async.Future<$11.GetTransactionInfoResponse> getTransactionInfo($pb.ServerContext ctx, $11.GetTransactionInfoRequest request);
  $async.Future<$11.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $11.GetWalletAddressesRequest request);
  $async.Future<$11.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $11.MyUtxosRequest request);
  $async.Future<$11.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos($pb.ServerContext ctx, $11.MyUnconfirmedUtxosRequest request);
  $async.Future<$11.CalculateInitialLiquidityResponse> calculateInitialLiquidity($pb.ServerContext ctx, $11.CalculateInitialLiquidityRequest request);
  $async.Future<$11.MarketCreateResponse> marketCreate($pb.ServerContext ctx, $11.MarketCreateRequest request);
  $async.Future<$11.MarketListResponse> marketList($pb.ServerContext ctx, $11.MarketListRequest request);
  $async.Future<$11.MarketGetResponse> marketGet($pb.ServerContext ctx, $11.MarketGetRequest request);
  $async.Future<$11.MarketBuyResponse> marketBuy($pb.ServerContext ctx, $11.MarketBuyRequest request);
  $async.Future<$11.MarketSellResponse> marketSell($pb.ServerContext ctx, $11.MarketSellRequest request);
  $async.Future<$11.MarketPositionsResponse> marketPositions($pb.ServerContext ctx, $11.MarketPositionsRequest request);
  $async.Future<$11.SlotStatusResponse> slotStatus($pb.ServerContext ctx, $11.SlotStatusRequest request);
  $async.Future<$11.SlotListResponse> slotList($pb.ServerContext ctx, $11.SlotListRequest request);
  $async.Future<$11.SlotGetResponse> slotGet($pb.ServerContext ctx, $11.SlotGetRequest request);
  $async.Future<$11.SlotClaimResponse> slotClaim($pb.ServerContext ctx, $11.SlotClaimRequest request);
  $async.Future<$11.SlotClaimCategoryResponse> slotClaimCategory($pb.ServerContext ctx, $11.SlotClaimCategoryRequest request);
  $async.Future<$11.VoteRegisterResponse> voteRegister($pb.ServerContext ctx, $11.VoteRegisterRequest request);
  $async.Future<$11.VoteVoterResponse> voteVoter($pb.ServerContext ctx, $11.VoteVoterRequest request);
  $async.Future<$11.VoteVotersResponse> voteVoters($pb.ServerContext ctx, $11.VoteVotersRequest request);
  $async.Future<$11.VoteSubmitResponse> voteSubmit($pb.ServerContext ctx, $11.VoteSubmitRequest request);
  $async.Future<$11.VoteListResponse> voteList($pb.ServerContext ctx, $11.VoteListRequest request);
  $async.Future<$11.VotePeriodResponse> votePeriod($pb.ServerContext ctx, $11.VotePeriodRequest request);
  $async.Future<$11.VotecoinTransferResponse> votecoinTransfer($pb.ServerContext ctx, $11.VotecoinTransferRequest request);
  $async.Future<$11.VotecoinBalanceResponse> votecoinBalance($pb.ServerContext ctx, $11.VotecoinBalanceRequest request);
  $async.Future<$11.TransferVotecoinResponse> transferVotecoin($pb.ServerContext ctx, $11.TransferVotecoinRequest request);
  $async.Future<$11.GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ServerContext ctx, $11.GetNewEncryptionKeyRequest request);
  $async.Future<$11.GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ServerContext ctx, $11.GetNewVerifyingKeyRequest request);
  $async.Future<$11.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $11.EncryptMsgRequest request);
  $async.Future<$11.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $11.DecryptMsgRequest request);
  $async.Future<$11.SignArbitraryMsgResponse> signArbitraryMsg($pb.ServerContext ctx, $11.SignArbitraryMsgRequest request);
  $async.Future<$11.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ServerContext ctx, $11.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$11.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $11.VerifySignatureRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $11.GetBalanceRequest();
      case 'GetBlockCount': return $11.GetBlockCountRequest();
      case 'Stop': return $11.StopRequest();
      case 'GetNewAddress': return $11.GetNewAddressRequest();
      case 'Withdraw': return $11.WithdrawRequest();
      case 'Transfer': return $11.TransferRequest();
      case 'GetSidechainWealth': return $11.GetSidechainWealthRequest();
      case 'CreateDeposit': return $11.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $11.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $11.ConnectPeerRequest();
      case 'ListPeers': return $11.ListPeersRequest();
      case 'Mine': return $11.MineRequest();
      case 'GetBlock': return $11.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $11.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $11.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $11.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $11.GetWalletUtxosRequest();
      case 'ListUtxos': return $11.ListUtxosRequest();
      case 'RemoveFromMempool': return $11.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $11.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $11.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $11.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $11.CallRawRequest();
      case 'RefreshWallet': return $11.RefreshWalletRequest();
      case 'GetTransaction': return $11.GetTransactionRequest();
      case 'GetTransactionInfo': return $11.GetTransactionInfoRequest();
      case 'GetWalletAddresses': return $11.GetWalletAddressesRequest();
      case 'MyUtxos': return $11.MyUtxosRequest();
      case 'MyUnconfirmedUtxos': return $11.MyUnconfirmedUtxosRequest();
      case 'CalculateInitialLiquidity': return $11.CalculateInitialLiquidityRequest();
      case 'MarketCreate': return $11.MarketCreateRequest();
      case 'MarketList': return $11.MarketListRequest();
      case 'MarketGet': return $11.MarketGetRequest();
      case 'MarketBuy': return $11.MarketBuyRequest();
      case 'MarketSell': return $11.MarketSellRequest();
      case 'MarketPositions': return $11.MarketPositionsRequest();
      case 'SlotStatus': return $11.SlotStatusRequest();
      case 'SlotList': return $11.SlotListRequest();
      case 'SlotGet': return $11.SlotGetRequest();
      case 'SlotClaim': return $11.SlotClaimRequest();
      case 'SlotClaimCategory': return $11.SlotClaimCategoryRequest();
      case 'VoteRegister': return $11.VoteRegisterRequest();
      case 'VoteVoter': return $11.VoteVoterRequest();
      case 'VoteVoters': return $11.VoteVotersRequest();
      case 'VoteSubmit': return $11.VoteSubmitRequest();
      case 'VoteList': return $11.VoteListRequest();
      case 'VotePeriod': return $11.VotePeriodRequest();
      case 'VotecoinTransfer': return $11.VotecoinTransferRequest();
      case 'VotecoinBalance': return $11.VotecoinBalanceRequest();
      case 'TransferVotecoin': return $11.TransferVotecoinRequest();
      case 'GetNewEncryptionKey': return $11.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey': return $11.GetNewVerifyingKeyRequest();
      case 'EncryptMsg': return $11.EncryptMsgRequest();
      case 'DecryptMsg': return $11.DecryptMsgRequest();
      case 'SignArbitraryMsg': return $11.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr': return $11.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature': return $11.VerifySignatureRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $11.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $11.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $11.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $11.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $11.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $11.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $11.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $11.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $11.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $11.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $11.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $11.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $11.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $11.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $11.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $11.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $11.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $11.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $11.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $11.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $11.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $11.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $11.CallRawRequest);
      case 'RefreshWallet': return this.refreshWallet(ctx, request as $11.RefreshWalletRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $11.GetTransactionRequest);
      case 'GetTransactionInfo': return this.getTransactionInfo(ctx, request as $11.GetTransactionInfoRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $11.GetWalletAddressesRequest);
      case 'MyUtxos': return this.myUtxos(ctx, request as $11.MyUtxosRequest);
      case 'MyUnconfirmedUtxos': return this.myUnconfirmedUtxos(ctx, request as $11.MyUnconfirmedUtxosRequest);
      case 'CalculateInitialLiquidity': return this.calculateInitialLiquidity(ctx, request as $11.CalculateInitialLiquidityRequest);
      case 'MarketCreate': return this.marketCreate(ctx, request as $11.MarketCreateRequest);
      case 'MarketList': return this.marketList(ctx, request as $11.MarketListRequest);
      case 'MarketGet': return this.marketGet(ctx, request as $11.MarketGetRequest);
      case 'MarketBuy': return this.marketBuy(ctx, request as $11.MarketBuyRequest);
      case 'MarketSell': return this.marketSell(ctx, request as $11.MarketSellRequest);
      case 'MarketPositions': return this.marketPositions(ctx, request as $11.MarketPositionsRequest);
      case 'SlotStatus': return this.slotStatus(ctx, request as $11.SlotStatusRequest);
      case 'SlotList': return this.slotList(ctx, request as $11.SlotListRequest);
      case 'SlotGet': return this.slotGet(ctx, request as $11.SlotGetRequest);
      case 'SlotClaim': return this.slotClaim(ctx, request as $11.SlotClaimRequest);
      case 'SlotClaimCategory': return this.slotClaimCategory(ctx, request as $11.SlotClaimCategoryRequest);
      case 'VoteRegister': return this.voteRegister(ctx, request as $11.VoteRegisterRequest);
      case 'VoteVoter': return this.voteVoter(ctx, request as $11.VoteVoterRequest);
      case 'VoteVoters': return this.voteVoters(ctx, request as $11.VoteVotersRequest);
      case 'VoteSubmit': return this.voteSubmit(ctx, request as $11.VoteSubmitRequest);
      case 'VoteList': return this.voteList(ctx, request as $11.VoteListRequest);
      case 'VotePeriod': return this.votePeriod(ctx, request as $11.VotePeriodRequest);
      case 'VotecoinTransfer': return this.votecoinTransfer(ctx, request as $11.VotecoinTransferRequest);
      case 'VotecoinBalance': return this.votecoinBalance(ctx, request as $11.VotecoinBalanceRequest);
      case 'TransferVotecoin': return this.transferVotecoin(ctx, request as $11.TransferVotecoinRequest);
      case 'GetNewEncryptionKey': return this.getNewEncryptionKey(ctx, request as $11.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey': return this.getNewVerifyingKey(ctx, request as $11.GetNewVerifyingKeyRequest);
      case 'EncryptMsg': return this.encryptMsg(ctx, request as $11.EncryptMsgRequest);
      case 'DecryptMsg': return this.decryptMsg(ctx, request as $11.DecryptMsgRequest);
      case 'SignArbitraryMsg': return this.signArbitraryMsg(ctx, request as $11.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr': return this.signArbitraryMsgAsAddr(ctx, request as $11.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature': return this.verifySignature(ctx, request as $11.VerifySignatureRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TruthcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => TruthcoinServiceBase$messageJson;
}

