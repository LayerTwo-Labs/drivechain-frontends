//
//  Generated code. Do not modify.
//  source: coinshift/v1/coinshift.proto
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

import 'coinshift.pb.dart' as $4;
import 'coinshift.pbjson.dart';

export 'coinshift.pb.dart';

abstract class CoinShiftServiceBase extends $pb.GeneratedService {
  $async.Future<$4.GetBalanceResponse> getBalance($pb.ServerContext ctx, $4.GetBalanceRequest request);
  $async.Future<$4.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $4.GetBlockCountRequest request);
  $async.Future<$4.StopResponse> stop($pb.ServerContext ctx, $4.StopRequest request);
  $async.Future<$4.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $4.GetNewAddressRequest request);
  $async.Future<$4.WithdrawResponse> withdraw($pb.ServerContext ctx, $4.WithdrawRequest request);
  $async.Future<$4.TransferResponse> transfer($pb.ServerContext ctx, $4.TransferRequest request);
  $async.Future<$4.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $4.GetSidechainWealthRequest request);
  $async.Future<$4.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $4.CreateDepositRequest request);
  $async.Future<$4.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $4.GetPendingWithdrawalBundleRequest request);
  $async.Future<$4.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $4.ConnectPeerRequest request);
  $async.Future<$4.ForgetPeerResponse> forgetPeer($pb.ServerContext ctx, $4.ForgetPeerRequest request);
  $async.Future<$4.ListPeersResponse> listPeers($pb.ServerContext ctx, $4.ListPeersRequest request);
  $async.Future<$4.MineResponse> mine($pb.ServerContext ctx, $4.MineRequest request);
  $async.Future<$4.GetBlockResponse> getBlock($pb.ServerContext ctx, $4.GetBlockRequest request);
  $async.Future<$4.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $4.GetBestMainchainBlockHashRequest request);
  $async.Future<$4.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $4.GetBestSidechainBlockHashRequest request);
  $async.Future<$4.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $4.GetBmmInclusionsRequest request);
  $async.Future<$4.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $4.GetWalletUtxosRequest request);
  $async.Future<$4.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $4.ListUtxosRequest request);
  $async.Future<$4.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $4.RemoveFromMempoolRequest request);
  $async.Future<$4.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $4.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$4.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $4.GenerateMnemonicRequest request);
  $async.Future<$4.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $4.SetSeedFromMnemonicRequest request);
  $async.Future<$4.CallRawResponse> callRaw($pb.ServerContext ctx, $4.CallRawRequest request);
  $async.Future<$4.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $4.GetWalletAddressesRequest request);
  $async.Future<$4.OpenapiSchemaResponse> openapiSchema($pb.ServerContext ctx, $4.OpenapiSchemaRequest request);
  $async.Future<$4.CreateSwapResponse> createSwap($pb.ServerContext ctx, $4.CreateSwapRequest request);
  $async.Future<$4.ClaimSwapResponse> claimSwap($pb.ServerContext ctx, $4.ClaimSwapRequest request);
  $async.Future<$4.GetSwapStatusResponse> getSwapStatus($pb.ServerContext ctx, $4.GetSwapStatusRequest request);
  $async.Future<$4.ListSwapsResponse> listSwaps($pb.ServerContext ctx, $4.ListSwapsRequest request);
  $async.Future<$4.ListSwapsByRecipientResponse> listSwapsByRecipient($pb.ServerContext ctx, $4.ListSwapsByRecipientRequest request);
  $async.Future<$4.UpdateSwapL1TxidResponse> updateSwapL1Txid($pb.ServerContext ctx, $4.UpdateSwapL1TxidRequest request);
  $async.Future<$4.ReconstructSwapsResponse> reconstructSwaps($pb.ServerContext ctx, $4.ReconstructSwapsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $4.GetBalanceRequest();
      case 'GetBlockCount': return $4.GetBlockCountRequest();
      case 'Stop': return $4.StopRequest();
      case 'GetNewAddress': return $4.GetNewAddressRequest();
      case 'Withdraw': return $4.WithdrawRequest();
      case 'Transfer': return $4.TransferRequest();
      case 'GetSidechainWealth': return $4.GetSidechainWealthRequest();
      case 'CreateDeposit': return $4.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $4.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $4.ConnectPeerRequest();
      case 'ForgetPeer': return $4.ForgetPeerRequest();
      case 'ListPeers': return $4.ListPeersRequest();
      case 'Mine': return $4.MineRequest();
      case 'GetBlock': return $4.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $4.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $4.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $4.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $4.GetWalletUtxosRequest();
      case 'ListUtxos': return $4.ListUtxosRequest();
      case 'RemoveFromMempool': return $4.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $4.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $4.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $4.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $4.CallRawRequest();
      case 'GetWalletAddresses': return $4.GetWalletAddressesRequest();
      case 'OpenapiSchema': return $4.OpenapiSchemaRequest();
      case 'CreateSwap': return $4.CreateSwapRequest();
      case 'ClaimSwap': return $4.ClaimSwapRequest();
      case 'GetSwapStatus': return $4.GetSwapStatusRequest();
      case 'ListSwaps': return $4.ListSwapsRequest();
      case 'ListSwapsByRecipient': return $4.ListSwapsByRecipientRequest();
      case 'UpdateSwapL1Txid': return $4.UpdateSwapL1TxidRequest();
      case 'ReconstructSwaps': return $4.ReconstructSwapsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $4.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $4.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $4.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $4.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $4.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $4.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $4.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $4.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $4.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $4.ConnectPeerRequest);
      case 'ForgetPeer': return this.forgetPeer(ctx, request as $4.ForgetPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $4.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $4.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $4.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $4.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $4.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $4.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $4.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $4.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $4.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $4.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $4.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $4.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $4.CallRawRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $4.GetWalletAddressesRequest);
      case 'OpenapiSchema': return this.openapiSchema(ctx, request as $4.OpenapiSchemaRequest);
      case 'CreateSwap': return this.createSwap(ctx, request as $4.CreateSwapRequest);
      case 'ClaimSwap': return this.claimSwap(ctx, request as $4.ClaimSwapRequest);
      case 'GetSwapStatus': return this.getSwapStatus(ctx, request as $4.GetSwapStatusRequest);
      case 'ListSwaps': return this.listSwaps(ctx, request as $4.ListSwapsRequest);
      case 'ListSwapsByRecipient': return this.listSwapsByRecipient(ctx, request as $4.ListSwapsByRecipientRequest);
      case 'UpdateSwapL1Txid': return this.updateSwapL1Txid(ctx, request as $4.UpdateSwapL1TxidRequest);
      case 'ReconstructSwaps': return this.reconstructSwaps(ctx, request as $4.ReconstructSwapsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CoinShiftServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => CoinShiftServiceBase$messageJson;
}

