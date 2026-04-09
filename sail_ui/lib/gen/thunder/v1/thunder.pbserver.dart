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

import 'thunder.pb.dart' as $8;
import 'thunder.pbjson.dart';

export 'thunder.pb.dart';

abstract class ThunderServiceBase extends $pb.GeneratedService {
  $async.Future<$8.GetBalanceResponse> getBalance($pb.ServerContext ctx, $8.GetBalanceRequest request);
  $async.Future<$8.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $8.GetBlockCountRequest request);
  $async.Future<$8.StopResponse> stop($pb.ServerContext ctx, $8.StopRequest request);
  $async.Future<$8.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $8.GetNewAddressRequest request);
  $async.Future<$8.WithdrawResponse> withdraw($pb.ServerContext ctx, $8.WithdrawRequest request);
  $async.Future<$8.TransferResponse> transfer($pb.ServerContext ctx, $8.TransferRequest request);
  $async.Future<$8.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $8.GetSidechainWealthRequest request);
  $async.Future<$8.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $8.CreateDepositRequest request);
  $async.Future<$8.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $8.GetPendingWithdrawalBundleRequest request);
  $async.Future<$8.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $8.ConnectPeerRequest request);
  $async.Future<$8.ListPeersResponse> listPeers($pb.ServerContext ctx, $8.ListPeersRequest request);
  $async.Future<$8.MineResponse> mine($pb.ServerContext ctx, $8.MineRequest request);
  $async.Future<$8.GetBlockResponse> getBlock($pb.ServerContext ctx, $8.GetBlockRequest request);
  $async.Future<$8.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $8.GetBestMainchainBlockHashRequest request);
  $async.Future<$8.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $8.GetBestSidechainBlockHashRequest request);
  $async.Future<$8.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $8.GetBmmInclusionsRequest request);
  $async.Future<$8.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $8.GetWalletUtxosRequest request);
  $async.Future<$8.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $8.ListUtxosRequest request);
  $async.Future<$8.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $8.RemoveFromMempoolRequest request);
  $async.Future<$8.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $8.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$8.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $8.GenerateMnemonicRequest request);
  $async.Future<$8.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $8.SetSeedFromMnemonicRequest request);
  $async.Future<$8.CallRawResponse> callRaw($pb.ServerContext ctx, $8.CallRawRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $8.GetBalanceRequest();
      case 'GetBlockCount': return $8.GetBlockCountRequest();
      case 'Stop': return $8.StopRequest();
      case 'GetNewAddress': return $8.GetNewAddressRequest();
      case 'Withdraw': return $8.WithdrawRequest();
      case 'Transfer': return $8.TransferRequest();
      case 'GetSidechainWealth': return $8.GetSidechainWealthRequest();
      case 'CreateDeposit': return $8.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $8.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $8.ConnectPeerRequest();
      case 'ListPeers': return $8.ListPeersRequest();
      case 'Mine': return $8.MineRequest();
      case 'GetBlock': return $8.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $8.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $8.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $8.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $8.GetWalletUtxosRequest();
      case 'ListUtxos': return $8.ListUtxosRequest();
      case 'RemoveFromMempool': return $8.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $8.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $8.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $8.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $8.CallRawRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $8.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $8.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $8.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $8.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $8.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $8.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $8.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $8.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $8.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $8.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $8.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $8.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $8.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $8.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $8.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $8.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $8.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $8.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $8.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $8.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $8.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $8.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $8.CallRawRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ThunderServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ThunderServiceBase$messageJson;
}

