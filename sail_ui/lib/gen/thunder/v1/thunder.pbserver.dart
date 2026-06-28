//
//  Generated code. Do not modify.
//  source: thunder/v1/thunder.proto
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

import 'thunder.pb.dart' as $11;
import 'thunder.pbjson.dart';

export 'thunder.pb.dart';

abstract class ThunderServiceBase extends $pb.GeneratedService {
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
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ThunderServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ThunderServiceBase$messageJson;
}

