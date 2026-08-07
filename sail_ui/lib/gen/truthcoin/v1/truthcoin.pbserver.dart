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

import 'truthcoin.pb.dart' as $13;
import 'truthcoin.pbjson.dart';

export 'truthcoin.pb.dart';

abstract class TruthcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$13.GetBalanceResponse> getBalance($pb.ServerContext ctx, $13.GetBalanceRequest request);
  $async.Future<$13.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $13.GetBlockCountRequest request);
  $async.Future<$13.StopResponse> stop($pb.ServerContext ctx, $13.StopRequest request);
  $async.Future<$13.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $13.GetNewAddressRequest request);
  $async.Future<$13.WithdrawResponse> withdraw($pb.ServerContext ctx, $13.WithdrawRequest request);
  $async.Future<$13.TransferResponse> transfer($pb.ServerContext ctx, $13.TransferRequest request);
  $async.Future<$13.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $13.GetSidechainWealthRequest request);
  $async.Future<$13.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $13.CreateDepositRequest request);
  $async.Future<$13.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $13.GetPendingWithdrawalBundleRequest request);
  $async.Future<$13.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $13.ConnectPeerRequest request);
  $async.Future<$13.ListPeersResponse> listPeers($pb.ServerContext ctx, $13.ListPeersRequest request);
  $async.Future<$13.MineResponse> mine($pb.ServerContext ctx, $13.MineRequest request);
  $async.Future<$13.GetBlockResponse> getBlock($pb.ServerContext ctx, $13.GetBlockRequest request);
  $async.Future<$13.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $13.GetBestMainchainBlockHashRequest request);
  $async.Future<$13.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $13.GetBestSidechainBlockHashRequest request);
  $async.Future<$13.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $13.GetBmmInclusionsRequest request);
  $async.Future<$13.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $13.GetWalletUtxosRequest request);
  $async.Future<$13.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $13.ListUtxosRequest request);
  $async.Future<$13.RemoveFromMempoolResponse> removeFromMempool(
      $pb.ServerContext ctx, $13.RemoveFromMempoolRequest request);
  $async.Future<$13.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $13.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$13.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $13.GenerateMnemonicRequest request);
  $async.Future<$13.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $13.SetSeedFromMnemonicRequest request);
  $async.Future<$13.CallRawResponse> callRaw($pb.ServerContext ctx, $13.CallRawRequest request);
  $async.Future<$13.RefreshWalletResponse> refreshWallet($pb.ServerContext ctx, $13.RefreshWalletRequest request);
  $async.Future<$13.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $13.GetTransactionRequest request);
  $async.Future<$13.GetTransactionInfoResponse> getTransactionInfo(
      $pb.ServerContext ctx, $13.GetTransactionInfoRequest request);
  $async.Future<$13.GetWalletAddressesResponse> getWalletAddresses(
      $pb.ServerContext ctx, $13.GetWalletAddressesRequest request);
  $async.Future<$13.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $13.MyUtxosRequest request);
  $async.Future<$13.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos(
      $pb.ServerContext ctx, $13.MyUnconfirmedUtxosRequest request);
  $async.Future<$13.CalculateInitialLiquidityResponse> calculateInitialLiquidity(
      $pb.ServerContext ctx, $13.CalculateInitialLiquidityRequest request);
  $async.Future<$13.MarketCreateResponse> marketCreate($pb.ServerContext ctx, $13.MarketCreateRequest request);
  $async.Future<$13.MarketListResponse> marketList($pb.ServerContext ctx, $13.MarketListRequest request);
  $async.Future<$13.MarketGetResponse> marketGet($pb.ServerContext ctx, $13.MarketGetRequest request);
  $async.Future<$13.MarketBuyResponse> marketBuy($pb.ServerContext ctx, $13.MarketBuyRequest request);
  $async.Future<$13.MarketSellResponse> marketSell($pb.ServerContext ctx, $13.MarketSellRequest request);
  $async.Future<$13.MarketPositionsResponse> marketPositions($pb.ServerContext ctx, $13.MarketPositionsRequest request);
  $async.Future<$13.SlotStatusResponse> slotStatus($pb.ServerContext ctx, $13.SlotStatusRequest request);
  $async.Future<$13.SlotListResponse> slotList($pb.ServerContext ctx, $13.SlotListRequest request);
  $async.Future<$13.SlotGetResponse> slotGet($pb.ServerContext ctx, $13.SlotGetRequest request);
  $async.Future<$13.SlotClaimResponse> slotClaim($pb.ServerContext ctx, $13.SlotClaimRequest request);
  $async.Future<$13.SlotClaimCategoryResponse> slotClaimCategory(
      $pb.ServerContext ctx, $13.SlotClaimCategoryRequest request);
  $async.Future<$13.VoteRegisterResponse> voteRegister($pb.ServerContext ctx, $13.VoteRegisterRequest request);
  $async.Future<$13.VoteVoterResponse> voteVoter($pb.ServerContext ctx, $13.VoteVoterRequest request);
  $async.Future<$13.VoteVotersResponse> voteVoters($pb.ServerContext ctx, $13.VoteVotersRequest request);
  $async.Future<$13.VoteSubmitResponse> voteSubmit($pb.ServerContext ctx, $13.VoteSubmitRequest request);
  $async.Future<$13.VoteListResponse> voteList($pb.ServerContext ctx, $13.VoteListRequest request);
  $async.Future<$13.VotePeriodResponse> votePeriod($pb.ServerContext ctx, $13.VotePeriodRequest request);
  $async.Future<$13.VotecoinTransferResponse> votecoinTransfer(
      $pb.ServerContext ctx, $13.VotecoinTransferRequest request);
  $async.Future<$13.VotecoinBalanceResponse> votecoinBalance($pb.ServerContext ctx, $13.VotecoinBalanceRequest request);
  $async.Future<$13.TransferVotecoinResponse> transferVotecoin(
      $pb.ServerContext ctx, $13.TransferVotecoinRequest request);
  $async.Future<$13.GetNewEncryptionKeyResponse> getNewEncryptionKey(
      $pb.ServerContext ctx, $13.GetNewEncryptionKeyRequest request);
  $async.Future<$13.GetNewVerifyingKeyResponse> getNewVerifyingKey(
      $pb.ServerContext ctx, $13.GetNewVerifyingKeyRequest request);
  $async.Future<$13.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $13.EncryptMsgRequest request);
  $async.Future<$13.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $13.DecryptMsgRequest request);
  $async.Future<$13.SignArbitraryMsgResponse> signArbitraryMsg(
      $pb.ServerContext ctx, $13.SignArbitraryMsgRequest request);
  $async.Future<$13.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
      $pb.ServerContext ctx, $13.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$13.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $13.VerifySignatureRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $13.GetBalanceRequest();
      case 'GetBlockCount':
        return $13.GetBlockCountRequest();
      case 'Stop':
        return $13.StopRequest();
      case 'GetNewAddress':
        return $13.GetNewAddressRequest();
      case 'Withdraw':
        return $13.WithdrawRequest();
      case 'Transfer':
        return $13.TransferRequest();
      case 'GetSidechainWealth':
        return $13.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $13.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $13.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $13.ConnectPeerRequest();
      case 'ListPeers':
        return $13.ListPeersRequest();
      case 'Mine':
        return $13.MineRequest();
      case 'GetBlock':
        return $13.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $13.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $13.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $13.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $13.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $13.ListUtxosRequest();
      case 'RemoveFromMempool':
        return $13.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $13.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $13.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $13.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $13.CallRawRequest();
      case 'RefreshWallet':
        return $13.RefreshWalletRequest();
      case 'GetTransaction':
        return $13.GetTransactionRequest();
      case 'GetTransactionInfo':
        return $13.GetTransactionInfoRequest();
      case 'GetWalletAddresses':
        return $13.GetWalletAddressesRequest();
      case 'MyUtxos':
        return $13.MyUtxosRequest();
      case 'MyUnconfirmedUtxos':
        return $13.MyUnconfirmedUtxosRequest();
      case 'CalculateInitialLiquidity':
        return $13.CalculateInitialLiquidityRequest();
      case 'MarketCreate':
        return $13.MarketCreateRequest();
      case 'MarketList':
        return $13.MarketListRequest();
      case 'MarketGet':
        return $13.MarketGetRequest();
      case 'MarketBuy':
        return $13.MarketBuyRequest();
      case 'MarketSell':
        return $13.MarketSellRequest();
      case 'MarketPositions':
        return $13.MarketPositionsRequest();
      case 'SlotStatus':
        return $13.SlotStatusRequest();
      case 'SlotList':
        return $13.SlotListRequest();
      case 'SlotGet':
        return $13.SlotGetRequest();
      case 'SlotClaim':
        return $13.SlotClaimRequest();
      case 'SlotClaimCategory':
        return $13.SlotClaimCategoryRequest();
      case 'VoteRegister':
        return $13.VoteRegisterRequest();
      case 'VoteVoter':
        return $13.VoteVoterRequest();
      case 'VoteVoters':
        return $13.VoteVotersRequest();
      case 'VoteSubmit':
        return $13.VoteSubmitRequest();
      case 'VoteList':
        return $13.VoteListRequest();
      case 'VotePeriod':
        return $13.VotePeriodRequest();
      case 'VotecoinTransfer':
        return $13.VotecoinTransferRequest();
      case 'VotecoinBalance':
        return $13.VotecoinBalanceRequest();
      case 'TransferVotecoin':
        return $13.TransferVotecoinRequest();
      case 'GetNewEncryptionKey':
        return $13.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey':
        return $13.GetNewVerifyingKeyRequest();
      case 'EncryptMsg':
        return $13.EncryptMsgRequest();
      case 'DecryptMsg':
        return $13.DecryptMsgRequest();
      case 'SignArbitraryMsg':
        return $13.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr':
        return $13.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature':
        return $13.VerifySignatureRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return this.getBalance(ctx, request as $13.GetBalanceRequest);
      case 'GetBlockCount':
        return this.getBlockCount(ctx, request as $13.GetBlockCountRequest);
      case 'Stop':
        return this.stop(ctx, request as $13.StopRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $13.GetNewAddressRequest);
      case 'Withdraw':
        return this.withdraw(ctx, request as $13.WithdrawRequest);
      case 'Transfer':
        return this.transfer(ctx, request as $13.TransferRequest);
      case 'GetSidechainWealth':
        return this.getSidechainWealth(ctx, request as $13.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $13.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return this.getPendingWithdrawalBundle(ctx, request as $13.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return this.connectPeer(ctx, request as $13.ConnectPeerRequest);
      case 'ListPeers':
        return this.listPeers(ctx, request as $13.ListPeersRequest);
      case 'Mine':
        return this.mine(ctx, request as $13.MineRequest);
      case 'GetBlock':
        return this.getBlock(ctx, request as $13.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return this.getBestMainchainBlockHash(ctx, request as $13.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return this.getBestSidechainBlockHash(ctx, request as $13.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return this.getBmmInclusions(ctx, request as $13.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return this.getWalletUtxos(ctx, request as $13.GetWalletUtxosRequest);
      case 'ListUtxos':
        return this.listUtxos(ctx, request as $13.ListUtxosRequest);
      case 'RemoveFromMempool':
        return this.removeFromMempool(ctx, request as $13.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return this
            .getLatestFailedWithdrawalBundleHeight(ctx, request as $13.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return this.generateMnemonic(ctx, request as $13.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return this.setSeedFromMnemonic(ctx, request as $13.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return this.callRaw(ctx, request as $13.CallRawRequest);
      case 'RefreshWallet':
        return this.refreshWallet(ctx, request as $13.RefreshWalletRequest);
      case 'GetTransaction':
        return this.getTransaction(ctx, request as $13.GetTransactionRequest);
      case 'GetTransactionInfo':
        return this.getTransactionInfo(ctx, request as $13.GetTransactionInfoRequest);
      case 'GetWalletAddresses':
        return this.getWalletAddresses(ctx, request as $13.GetWalletAddressesRequest);
      case 'MyUtxos':
        return this.myUtxos(ctx, request as $13.MyUtxosRequest);
      case 'MyUnconfirmedUtxos':
        return this.myUnconfirmedUtxos(ctx, request as $13.MyUnconfirmedUtxosRequest);
      case 'CalculateInitialLiquidity':
        return this.calculateInitialLiquidity(ctx, request as $13.CalculateInitialLiquidityRequest);
      case 'MarketCreate':
        return this.marketCreate(ctx, request as $13.MarketCreateRequest);
      case 'MarketList':
        return this.marketList(ctx, request as $13.MarketListRequest);
      case 'MarketGet':
        return this.marketGet(ctx, request as $13.MarketGetRequest);
      case 'MarketBuy':
        return this.marketBuy(ctx, request as $13.MarketBuyRequest);
      case 'MarketSell':
        return this.marketSell(ctx, request as $13.MarketSellRequest);
      case 'MarketPositions':
        return this.marketPositions(ctx, request as $13.MarketPositionsRequest);
      case 'SlotStatus':
        return this.slotStatus(ctx, request as $13.SlotStatusRequest);
      case 'SlotList':
        return this.slotList(ctx, request as $13.SlotListRequest);
      case 'SlotGet':
        return this.slotGet(ctx, request as $13.SlotGetRequest);
      case 'SlotClaim':
        return this.slotClaim(ctx, request as $13.SlotClaimRequest);
      case 'SlotClaimCategory':
        return this.slotClaimCategory(ctx, request as $13.SlotClaimCategoryRequest);
      case 'VoteRegister':
        return this.voteRegister(ctx, request as $13.VoteRegisterRequest);
      case 'VoteVoter':
        return this.voteVoter(ctx, request as $13.VoteVoterRequest);
      case 'VoteVoters':
        return this.voteVoters(ctx, request as $13.VoteVotersRequest);
      case 'VoteSubmit':
        return this.voteSubmit(ctx, request as $13.VoteSubmitRequest);
      case 'VoteList':
        return this.voteList(ctx, request as $13.VoteListRequest);
      case 'VotePeriod':
        return this.votePeriod(ctx, request as $13.VotePeriodRequest);
      case 'VotecoinTransfer':
        return this.votecoinTransfer(ctx, request as $13.VotecoinTransferRequest);
      case 'VotecoinBalance':
        return this.votecoinBalance(ctx, request as $13.VotecoinBalanceRequest);
      case 'TransferVotecoin':
        return this.transferVotecoin(ctx, request as $13.TransferVotecoinRequest);
      case 'GetNewEncryptionKey':
        return this.getNewEncryptionKey(ctx, request as $13.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey':
        return this.getNewVerifyingKey(ctx, request as $13.GetNewVerifyingKeyRequest);
      case 'EncryptMsg':
        return this.encryptMsg(ctx, request as $13.EncryptMsgRequest);
      case 'DecryptMsg':
        return this.decryptMsg(ctx, request as $13.DecryptMsgRequest);
      case 'SignArbitraryMsg':
        return this.signArbitraryMsg(ctx, request as $13.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr':
        return this.signArbitraryMsgAsAddr(ctx, request as $13.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature':
        return this.verifySignature(ctx, request as $13.VerifySignatureRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TruthcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => TruthcoinServiceBase$messageJson;
}
