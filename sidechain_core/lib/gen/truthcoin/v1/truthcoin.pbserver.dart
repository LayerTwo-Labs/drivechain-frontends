// This is a generated file - do not edit.
//
// Generated from truthcoin/v1/truthcoin.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'truthcoin.pb.dart' as $0;
import 'truthcoin.pbjson.dart';

export 'truthcoin.pb.dart';

abstract class TruthcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetBalanceResponse> getBalance($pb.ServerContext ctx, $0.GetBalanceRequest request);
  $async.Future<$0.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $0.GetBlockCountRequest request);
  $async.Future<$0.StopResponse> stop($pb.ServerContext ctx, $0.StopRequest request);
  $async.Future<$0.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $0.GetNewAddressRequest request);
  $async.Future<$0.WithdrawResponse> withdraw($pb.ServerContext ctx, $0.WithdrawRequest request);
  $async.Future<$0.TransferResponse> transfer($pb.ServerContext ctx, $0.TransferRequest request);
  $async.Future<$0.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $0.GetSidechainWealthRequest request);
  $async.Future<$0.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $0.CreateDepositRequest request);
  $async.Future<$0.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $0.GetPendingWithdrawalBundleRequest request);
  $async.Future<$0.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $0.ConnectPeerRequest request);
  $async.Future<$0.ListPeersResponse> listPeers($pb.ServerContext ctx, $0.ListPeersRequest request);
  $async.Future<$0.MineResponse> mine($pb.ServerContext ctx, $0.MineRequest request);
  $async.Future<$0.GetBlockResponse> getBlock($pb.ServerContext ctx, $0.GetBlockRequest request);
  $async.Future<$0.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $0.GetBestMainchainBlockHashRequest request);
  $async.Future<$0.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $0.GetBestSidechainBlockHashRequest request);
  $async.Future<$0.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $0.GetBmmInclusionsRequest request);
  $async.Future<$0.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $0.GetWalletUtxosRequest request);
  $async.Future<$0.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $0.ListUtxosRequest request);
  $async.Future<$0.RemoveFromMempoolResponse> removeFromMempool(
      $pb.ServerContext ctx, $0.RemoveFromMempoolRequest request);
  $async.Future<$0.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $0.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$0.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $0.GenerateMnemonicRequest request);
  $async.Future<$0.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $0.SetSeedFromMnemonicRequest request);
  $async.Future<$0.CallRawResponse> callRaw($pb.ServerContext ctx, $0.CallRawRequest request);
  $async.Future<$0.RefreshWalletResponse> refreshWallet($pb.ServerContext ctx, $0.RefreshWalletRequest request);
  $async.Future<$0.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $0.GetTransactionRequest request);
  $async.Future<$0.GetTransactionInfoResponse> getTransactionInfo(
      $pb.ServerContext ctx, $0.GetTransactionInfoRequest request);
  $async.Future<$0.GetWalletAddressesResponse> getWalletAddresses(
      $pb.ServerContext ctx, $0.GetWalletAddressesRequest request);
  $async.Future<$0.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $0.MyUtxosRequest request);
  $async.Future<$0.MyUnconfirmedUtxosResponse> myUnconfirmedUtxos(
      $pb.ServerContext ctx, $0.MyUnconfirmedUtxosRequest request);
  $async.Future<$0.CalculateInitialLiquidityResponse> calculateInitialLiquidity(
      $pb.ServerContext ctx, $0.CalculateInitialLiquidityRequest request);
  $async.Future<$0.MarketCreateResponse> marketCreate($pb.ServerContext ctx, $0.MarketCreateRequest request);
  $async.Future<$0.MarketListResponse> marketList($pb.ServerContext ctx, $0.MarketListRequest request);
  $async.Future<$0.MarketGetResponse> marketGet($pb.ServerContext ctx, $0.MarketGetRequest request);
  $async.Future<$0.MarketBuyResponse> marketBuy($pb.ServerContext ctx, $0.MarketBuyRequest request);
  $async.Future<$0.MarketSellResponse> marketSell($pb.ServerContext ctx, $0.MarketSellRequest request);
  $async.Future<$0.MarketPositionsResponse> marketPositions($pb.ServerContext ctx, $0.MarketPositionsRequest request);
  $async.Future<$0.MarketAmplifyBetaResponse> marketAmplifyBeta(
      $pb.ServerContext ctx, $0.MarketAmplifyBetaRequest request);
  $async.Future<$0.SlotStatusResponse> slotStatus($pb.ServerContext ctx, $0.SlotStatusRequest request);
  $async.Future<$0.SlotListResponse> slotList($pb.ServerContext ctx, $0.SlotListRequest request);
  $async.Future<$0.SlotGetResponse> slotGet($pb.ServerContext ctx, $0.SlotGetRequest request);
  $async.Future<$0.SlotClaimResponse> slotClaim($pb.ServerContext ctx, $0.SlotClaimRequest request);
  $async.Future<$0.SlotClaimCategoryResponse> slotClaimCategory(
      $pb.ServerContext ctx, $0.SlotClaimCategoryRequest request);
  $async.Future<$0.GetVoterAddressResponse> getVoterAddress($pb.ServerContext ctx, $0.GetVoterAddressRequest request);
  $async.Future<$0.VoteVoterResponse> voteVoter($pb.ServerContext ctx, $0.VoteVoterRequest request);
  $async.Future<$0.VoteVotersResponse> voteVoters($pb.ServerContext ctx, $0.VoteVotersRequest request);
  $async.Future<$0.VoteSubmitResponse> voteSubmit($pb.ServerContext ctx, $0.VoteSubmitRequest request);
  $async.Future<$0.VoteListResponse> voteList($pb.ServerContext ctx, $0.VoteListRequest request);
  $async.Future<$0.VotePeriodResponse> votePeriod($pb.ServerContext ctx, $0.VotePeriodRequest request);
  $async.Future<$0.VotecoinTransferResponse> votecoinTransfer(
      $pb.ServerContext ctx, $0.VotecoinTransferRequest request);
  $async.Future<$0.VotecoinBalanceResponse> votecoinBalance($pb.ServerContext ctx, $0.VotecoinBalanceRequest request);
  $async.Future<$0.TransferVotecoinResponse> transferVotecoin(
      $pb.ServerContext ctx, $0.TransferVotecoinRequest request);
  $async.Future<$0.GetNewEncryptionKeyResponse> getNewEncryptionKey(
      $pb.ServerContext ctx, $0.GetNewEncryptionKeyRequest request);
  $async.Future<$0.GetNewVerifyingKeyResponse> getNewVerifyingKey(
      $pb.ServerContext ctx, $0.GetNewVerifyingKeyRequest request);
  $async.Future<$0.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $0.EncryptMsgRequest request);
  $async.Future<$0.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $0.DecryptMsgRequest request);
  $async.Future<$0.SignArbitraryMsgResponse> signArbitraryMsg(
      $pb.ServerContext ctx, $0.SignArbitraryMsgRequest request);
  $async.Future<$0.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
      $pb.ServerContext ctx, $0.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$0.VerifySignatureResponse> verifySignature($pb.ServerContext ctx, $0.VerifySignatureRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $0.GetBalanceRequest();
      case 'GetBlockCount':
        return $0.GetBlockCountRequest();
      case 'Stop':
        return $0.StopRequest();
      case 'GetNewAddress':
        return $0.GetNewAddressRequest();
      case 'Withdraw':
        return $0.WithdrawRequest();
      case 'Transfer':
        return $0.TransferRequest();
      case 'GetSidechainWealth':
        return $0.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $0.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $0.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $0.ConnectPeerRequest();
      case 'ListPeers':
        return $0.ListPeersRequest();
      case 'Mine':
        return $0.MineRequest();
      case 'GetBlock':
        return $0.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $0.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $0.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $0.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $0.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $0.ListUtxosRequest();
      case 'RemoveFromMempool':
        return $0.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $0.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $0.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $0.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $0.CallRawRequest();
      case 'RefreshWallet':
        return $0.RefreshWalletRequest();
      case 'GetTransaction':
        return $0.GetTransactionRequest();
      case 'GetTransactionInfo':
        return $0.GetTransactionInfoRequest();
      case 'GetWalletAddresses':
        return $0.GetWalletAddressesRequest();
      case 'MyUtxos':
        return $0.MyUtxosRequest();
      case 'MyUnconfirmedUtxos':
        return $0.MyUnconfirmedUtxosRequest();
      case 'CalculateInitialLiquidity':
        return $0.CalculateInitialLiquidityRequest();
      case 'MarketCreate':
        return $0.MarketCreateRequest();
      case 'MarketList':
        return $0.MarketListRequest();
      case 'MarketGet':
        return $0.MarketGetRequest();
      case 'MarketBuy':
        return $0.MarketBuyRequest();
      case 'MarketSell':
        return $0.MarketSellRequest();
      case 'MarketPositions':
        return $0.MarketPositionsRequest();
      case 'MarketAmplifyBeta':
        return $0.MarketAmplifyBetaRequest();
      case 'SlotStatus':
        return $0.SlotStatusRequest();
      case 'SlotList':
        return $0.SlotListRequest();
      case 'SlotGet':
        return $0.SlotGetRequest();
      case 'SlotClaim':
        return $0.SlotClaimRequest();
      case 'SlotClaimCategory':
        return $0.SlotClaimCategoryRequest();
      case 'GetVoterAddress':
        return $0.GetVoterAddressRequest();
      case 'VoteVoter':
        return $0.VoteVoterRequest();
      case 'VoteVoters':
        return $0.VoteVotersRequest();
      case 'VoteSubmit':
        return $0.VoteSubmitRequest();
      case 'VoteList':
        return $0.VoteListRequest();
      case 'VotePeriod':
        return $0.VotePeriodRequest();
      case 'VotecoinTransfer':
        return $0.VotecoinTransferRequest();
      case 'VotecoinBalance':
        return $0.VotecoinBalanceRequest();
      case 'TransferVotecoin':
        return $0.TransferVotecoinRequest();
      case 'GetNewEncryptionKey':
        return $0.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey':
        return $0.GetNewVerifyingKeyRequest();
      case 'EncryptMsg':
        return $0.EncryptMsgRequest();
      case 'DecryptMsg':
        return $0.DecryptMsgRequest();
      case 'SignArbitraryMsg':
        return $0.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr':
        return $0.SignArbitraryMsgAsAddrRequest();
      case 'VerifySignature':
        return $0.VerifySignatureRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return getBalance(ctx, request as $0.GetBalanceRequest);
      case 'GetBlockCount':
        return getBlockCount(ctx, request as $0.GetBlockCountRequest);
      case 'Stop':
        return stop(ctx, request as $0.StopRequest);
      case 'GetNewAddress':
        return getNewAddress(ctx, request as $0.GetNewAddressRequest);
      case 'Withdraw':
        return withdraw(ctx, request as $0.WithdrawRequest);
      case 'Transfer':
        return transfer(ctx, request as $0.TransferRequest);
      case 'GetSidechainWealth':
        return getSidechainWealth(ctx, request as $0.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return createDeposit(ctx, request as $0.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return getPendingWithdrawalBundle(ctx, request as $0.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return connectPeer(ctx, request as $0.ConnectPeerRequest);
      case 'ListPeers':
        return listPeers(ctx, request as $0.ListPeersRequest);
      case 'Mine':
        return mine(ctx, request as $0.MineRequest);
      case 'GetBlock':
        return getBlock(ctx, request as $0.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return getBestMainchainBlockHash(ctx, request as $0.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return getBestSidechainBlockHash(ctx, request as $0.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return getBmmInclusions(ctx, request as $0.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return getWalletUtxos(ctx, request as $0.GetWalletUtxosRequest);
      case 'ListUtxos':
        return listUtxos(ctx, request as $0.ListUtxosRequest);
      case 'RemoveFromMempool':
        return removeFromMempool(ctx, request as $0.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return getLatestFailedWithdrawalBundleHeight(ctx, request as $0.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return generateMnemonic(ctx, request as $0.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return setSeedFromMnemonic(ctx, request as $0.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return callRaw(ctx, request as $0.CallRawRequest);
      case 'RefreshWallet':
        return refreshWallet(ctx, request as $0.RefreshWalletRequest);
      case 'GetTransaction':
        return getTransaction(ctx, request as $0.GetTransactionRequest);
      case 'GetTransactionInfo':
        return getTransactionInfo(ctx, request as $0.GetTransactionInfoRequest);
      case 'GetWalletAddresses':
        return getWalletAddresses(ctx, request as $0.GetWalletAddressesRequest);
      case 'MyUtxos':
        return myUtxos(ctx, request as $0.MyUtxosRequest);
      case 'MyUnconfirmedUtxos':
        return myUnconfirmedUtxos(ctx, request as $0.MyUnconfirmedUtxosRequest);
      case 'CalculateInitialLiquidity':
        return calculateInitialLiquidity(ctx, request as $0.CalculateInitialLiquidityRequest);
      case 'MarketCreate':
        return marketCreate(ctx, request as $0.MarketCreateRequest);
      case 'MarketList':
        return marketList(ctx, request as $0.MarketListRequest);
      case 'MarketGet':
        return marketGet(ctx, request as $0.MarketGetRequest);
      case 'MarketBuy':
        return marketBuy(ctx, request as $0.MarketBuyRequest);
      case 'MarketSell':
        return marketSell(ctx, request as $0.MarketSellRequest);
      case 'MarketPositions':
        return marketPositions(ctx, request as $0.MarketPositionsRequest);
      case 'MarketAmplifyBeta':
        return marketAmplifyBeta(ctx, request as $0.MarketAmplifyBetaRequest);
      case 'SlotStatus':
        return slotStatus(ctx, request as $0.SlotStatusRequest);
      case 'SlotList':
        return slotList(ctx, request as $0.SlotListRequest);
      case 'SlotGet':
        return slotGet(ctx, request as $0.SlotGetRequest);
      case 'SlotClaim':
        return slotClaim(ctx, request as $0.SlotClaimRequest);
      case 'SlotClaimCategory':
        return slotClaimCategory(ctx, request as $0.SlotClaimCategoryRequest);
      case 'GetVoterAddress':
        return getVoterAddress(ctx, request as $0.GetVoterAddressRequest);
      case 'VoteVoter':
        return voteVoter(ctx, request as $0.VoteVoterRequest);
      case 'VoteVoters':
        return voteVoters(ctx, request as $0.VoteVotersRequest);
      case 'VoteSubmit':
        return voteSubmit(ctx, request as $0.VoteSubmitRequest);
      case 'VoteList':
        return voteList(ctx, request as $0.VoteListRequest);
      case 'VotePeriod':
        return votePeriod(ctx, request as $0.VotePeriodRequest);
      case 'VotecoinTransfer':
        return votecoinTransfer(ctx, request as $0.VotecoinTransferRequest);
      case 'VotecoinBalance':
        return votecoinBalance(ctx, request as $0.VotecoinBalanceRequest);
      case 'TransferVotecoin':
        return transferVotecoin(ctx, request as $0.TransferVotecoinRequest);
      case 'GetNewEncryptionKey':
        return getNewEncryptionKey(ctx, request as $0.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey':
        return getNewVerifyingKey(ctx, request as $0.GetNewVerifyingKeyRequest);
      case 'EncryptMsg':
        return encryptMsg(ctx, request as $0.EncryptMsgRequest);
      case 'DecryptMsg':
        return decryptMsg(ctx, request as $0.DecryptMsgRequest);
      case 'SignArbitraryMsg':
        return signArbitraryMsg(ctx, request as $0.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr':
        return signArbitraryMsgAsAddr(ctx, request as $0.SignArbitraryMsgAsAddrRequest);
      case 'VerifySignature':
        return verifySignature(ctx, request as $0.VerifySignatureRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => TruthcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => TruthcoinServiceBase$messageJson;
}
