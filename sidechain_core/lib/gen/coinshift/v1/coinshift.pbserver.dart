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

import 'coinshift.pb.dart' as $5;
import 'coinshift.pbjson.dart';

export 'coinshift.pb.dart';

abstract class CoinShiftServiceBase extends $pb.GeneratedService {
  $async.Future<$5.GetBalanceResponse> getBalance($pb.ServerContext ctx, $5.GetBalanceRequest request);
  $async.Future<$5.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $5.GetBlockCountRequest request);
  $async.Future<$5.StopResponse> stop($pb.ServerContext ctx, $5.StopRequest request);
  $async.Future<$5.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $5.GetNewAddressRequest request);
  $async.Future<$5.WithdrawResponse> withdraw($pb.ServerContext ctx, $5.WithdrawRequest request);
  $async.Future<$5.TransferResponse> transfer($pb.ServerContext ctx, $5.TransferRequest request);
  $async.Future<$5.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $5.GetSidechainWealthRequest request);
  $async.Future<$5.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $5.CreateDepositRequest request);
  $async.Future<$5.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $5.GetPendingWithdrawalBundleRequest request);
  $async.Future<$5.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $5.ConnectPeerRequest request);
  $async.Future<$5.ForgetPeerResponse> forgetPeer($pb.ServerContext ctx, $5.ForgetPeerRequest request);
  $async.Future<$5.ListPeersResponse> listPeers($pb.ServerContext ctx, $5.ListPeersRequest request);
  $async.Future<$5.MineResponse> mine($pb.ServerContext ctx, $5.MineRequest request);
  $async.Future<$5.GetBlockResponse> getBlock($pb.ServerContext ctx, $5.GetBlockRequest request);
  $async.Future<$5.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $5.GetBestMainchainBlockHashRequest request);
  $async.Future<$5.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $5.GetBestSidechainBlockHashRequest request);
  $async.Future<$5.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $5.GetBmmInclusionsRequest request);
  $async.Future<$5.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $5.GetWalletUtxosRequest request);
  $async.Future<$5.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $5.ListUtxosRequest request);
  $async.Future<$5.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $5.RemoveFromMempoolRequest request);
  $async.Future<$5.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $5.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$5.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $5.GenerateMnemonicRequest request);
  $async.Future<$5.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $5.SetSeedFromMnemonicRequest request);
  $async.Future<$5.CallRawResponse> callRaw($pb.ServerContext ctx, $5.CallRawRequest request);
  $async.Future<$5.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $5.GetWalletAddressesRequest request);
  $async.Future<$5.OpenapiSchemaResponse> openapiSchema($pb.ServerContext ctx, $5.OpenapiSchemaRequest request);
  $async.Future<$5.CreateSwapResponse> createSwap($pb.ServerContext ctx, $5.CreateSwapRequest request);
  $async.Future<$5.ClaimSwapResponse> claimSwap($pb.ServerContext ctx, $5.ClaimSwapRequest request);
  $async.Future<$5.GetSwapStatusResponse> getSwapStatus($pb.ServerContext ctx, $5.GetSwapStatusRequest request);
  $async.Future<$5.ListSwapsResponse> listSwaps($pb.ServerContext ctx, $5.ListSwapsRequest request);
  $async.Future<$5.ListSwapsByRecipientResponse> listSwapsByRecipient($pb.ServerContext ctx, $5.ListSwapsByRecipientRequest request);
  $async.Future<$5.UpdateSwapL1TxidResponse> updateSwapL1Txid($pb.ServerContext ctx, $5.UpdateSwapL1TxidRequest request);
  $async.Future<$5.ReconstructSwapsResponse> reconstructSwaps($pb.ServerContext ctx, $5.ReconstructSwapsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $5.GetBalanceRequest();
      case 'GetBlockCount': return $5.GetBlockCountRequest();
      case 'Stop': return $5.StopRequest();
      case 'GetNewAddress': return $5.GetNewAddressRequest();
      case 'Withdraw': return $5.WithdrawRequest();
      case 'Transfer': return $5.TransferRequest();
      case 'GetSidechainWealth': return $5.GetSidechainWealthRequest();
      case 'CreateDeposit': return $5.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $5.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $5.ConnectPeerRequest();
      case 'ForgetPeer': return $5.ForgetPeerRequest();
      case 'ListPeers': return $5.ListPeersRequest();
      case 'Mine': return $5.MineRequest();
      case 'GetBlock': return $5.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $5.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $5.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $5.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $5.GetWalletUtxosRequest();
      case 'ListUtxos': return $5.ListUtxosRequest();
      case 'RemoveFromMempool': return $5.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $5.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $5.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $5.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $5.CallRawRequest();
      case 'GetWalletAddresses': return $5.GetWalletAddressesRequest();
      case 'OpenapiSchema': return $5.OpenapiSchemaRequest();
      case 'CreateSwap': return $5.CreateSwapRequest();
      case 'ClaimSwap': return $5.ClaimSwapRequest();
      case 'GetSwapStatus': return $5.GetSwapStatusRequest();
      case 'ListSwaps': return $5.ListSwapsRequest();
      case 'ListSwapsByRecipient': return $5.ListSwapsByRecipientRequest();
      case 'UpdateSwapL1Txid': return $5.UpdateSwapL1TxidRequest();
      case 'ReconstructSwaps': return $5.ReconstructSwapsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $5.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $5.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $5.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $5.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $5.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $5.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $5.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $5.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $5.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $5.ConnectPeerRequest);
      case 'ForgetPeer': return this.forgetPeer(ctx, request as $5.ForgetPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $5.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $5.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $5.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $5.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $5.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $5.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $5.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $5.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $5.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $5.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $5.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $5.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $5.CallRawRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $5.GetWalletAddressesRequest);
      case 'OpenapiSchema': return this.openapiSchema(ctx, request as $5.OpenapiSchemaRequest);
      case 'CreateSwap': return this.createSwap(ctx, request as $5.CreateSwapRequest);
      case 'ClaimSwap': return this.claimSwap(ctx, request as $5.ClaimSwapRequest);
      case 'GetSwapStatus': return this.getSwapStatus(ctx, request as $5.GetSwapStatusRequest);
      case 'ListSwaps': return this.listSwaps(ctx, request as $5.ListSwapsRequest);
      case 'ListSwapsByRecipient': return this.listSwapsByRecipient(ctx, request as $5.ListSwapsByRecipientRequest);
      case 'UpdateSwapL1Txid': return this.updateSwapL1Txid(ctx, request as $5.UpdateSwapL1TxidRequest);
      case 'ReconstructSwaps': return this.reconstructSwaps(ctx, request as $5.ReconstructSwapsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CoinShiftServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => CoinShiftServiceBase$messageJson;
}

