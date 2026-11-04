// This is a generated file - do not edit.
//
// Generated from coinshift/v1/coinshift.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'coinshift.pb.dart' as $0;
import 'coinshift.pbjson.dart';

export 'coinshift.pb.dart';

abstract class CoinShiftServiceBase extends $pb.GeneratedService {
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
  $async.Future<$0.ForgetPeerResponse> forgetPeer($pb.ServerContext ctx, $0.ForgetPeerRequest request);
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
  $async.Future<$0.GetWalletAddressesResponse> getWalletAddresses(
      $pb.ServerContext ctx, $0.GetWalletAddressesRequest request);
  $async.Future<$0.OpenapiSchemaResponse> openapiSchema($pb.ServerContext ctx, $0.OpenapiSchemaRequest request);
  $async.Future<$0.CreateSwapResponse> createSwap($pb.ServerContext ctx, $0.CreateSwapRequest request);
  $async.Future<$0.ClaimSwapResponse> claimSwap($pb.ServerContext ctx, $0.ClaimSwapRequest request);
  $async.Future<$0.GetSwapStatusResponse> getSwapStatus($pb.ServerContext ctx, $0.GetSwapStatusRequest request);
  $async.Future<$0.ListSwapsResponse> listSwaps($pb.ServerContext ctx, $0.ListSwapsRequest request);
  $async.Future<$0.ListSwapsByRecipientResponse> listSwapsByRecipient(
      $pb.ServerContext ctx, $0.ListSwapsByRecipientRequest request);
  $async.Future<$0.UpdateSwapL1TxidResponse> updateSwapL1Txid(
      $pb.ServerContext ctx, $0.UpdateSwapL1TxidRequest request);
  $async.Future<$0.ReconstructSwapsResponse> reconstructSwaps(
      $pb.ServerContext ctx, $0.ReconstructSwapsRequest request);

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
      case 'ForgetPeer':
        return $0.ForgetPeerRequest();
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
      case 'GetWalletAddresses':
        return $0.GetWalletAddressesRequest();
      case 'OpenapiSchema':
        return $0.OpenapiSchemaRequest();
      case 'CreateSwap':
        return $0.CreateSwapRequest();
      case 'ClaimSwap':
        return $0.ClaimSwapRequest();
      case 'GetSwapStatus':
        return $0.GetSwapStatusRequest();
      case 'ListSwaps':
        return $0.ListSwapsRequest();
      case 'ListSwapsByRecipient':
        return $0.ListSwapsByRecipientRequest();
      case 'UpdateSwapL1Txid':
        return $0.UpdateSwapL1TxidRequest();
      case 'ReconstructSwaps':
        return $0.ReconstructSwapsRequest();
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
      case 'ForgetPeer':
        return forgetPeer(ctx, request as $0.ForgetPeerRequest);
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
      case 'GetWalletAddresses':
        return getWalletAddresses(ctx, request as $0.GetWalletAddressesRequest);
      case 'OpenapiSchema':
        return openapiSchema(ctx, request as $0.OpenapiSchemaRequest);
      case 'CreateSwap':
        return createSwap(ctx, request as $0.CreateSwapRequest);
      case 'ClaimSwap':
        return claimSwap(ctx, request as $0.ClaimSwapRequest);
      case 'GetSwapStatus':
        return getSwapStatus(ctx, request as $0.GetSwapStatusRequest);
      case 'ListSwaps':
        return listSwaps(ctx, request as $0.ListSwapsRequest);
      case 'ListSwapsByRecipient':
        return listSwapsByRecipient(ctx, request as $0.ListSwapsByRecipientRequest);
      case 'UpdateSwapL1Txid':
        return updateSwapL1Txid(ctx, request as $0.UpdateSwapL1TxidRequest);
      case 'ReconstructSwaps':
        return reconstructSwaps(ctx, request as $0.ReconstructSwapsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CoinShiftServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => CoinShiftServiceBase$messageJson;
}
