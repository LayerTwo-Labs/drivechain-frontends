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

import 'thunder.pb.dart' as $0;
import 'thunder.pbjson.dart';

export 'thunder.pb.dart';

abstract class ThunderServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetBalanceResponse> getBalance($pb.ServerContext ctx, $0.GetBalanceRequest request);
  $async.Future<$0.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $0.GetBlockCountRequest request);
  $async.Future<$0.StopResponse> stop($pb.ServerContext ctx, $0.StopRequest request);
  $async.Future<$0.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $0.GetNewAddressRequest request);
  $async.Future<$0.WithdrawResponse> withdraw($pb.ServerContext ctx, $0.WithdrawRequest request);
  $async.Future<$0.TransferResponse> transfer($pb.ServerContext ctx, $0.TransferRequest request);
  $async.Future<$0.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $0.GetSidechainWealthRequest request);
  $async.Future<$0.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $0.CreateDepositRequest request);
  $async.Future<$0.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $0.GetPendingWithdrawalBundleRequest request);
  $async.Future<$0.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $0.ConnectPeerRequest request);
  $async.Future<$0.ListPeersResponse> listPeers($pb.ServerContext ctx, $0.ListPeersRequest request);
  $async.Future<$0.MineResponse> mine($pb.ServerContext ctx, $0.MineRequest request);
  $async.Future<$0.GetBlockResponse> getBlock($pb.ServerContext ctx, $0.GetBlockRequest request);
  $async.Future<$0.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $0.GetBestMainchainBlockHashRequest request);
  $async.Future<$0.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $0.GetBestSidechainBlockHashRequest request);
  $async.Future<$0.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $0.GetBmmInclusionsRequest request);
  $async.Future<$0.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $0.GetWalletUtxosRequest request);
  $async.Future<$0.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $0.ListUtxosRequest request);
  $async.Future<$0.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $0.RemoveFromMempoolRequest request);
  $async.Future<$0.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $0.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$0.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $0.GenerateMnemonicRequest request);
  $async.Future<$0.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $0.SetSeedFromMnemonicRequest request);
  $async.Future<$0.CallRawResponse> callRaw($pb.ServerContext ctx, $0.CallRawRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $0.GetBalanceRequest();
      case 'GetBlockCount': return $0.GetBlockCountRequest();
      case 'Stop': return $0.StopRequest();
      case 'GetNewAddress': return $0.GetNewAddressRequest();
      case 'Withdraw': return $0.WithdrawRequest();
      case 'Transfer': return $0.TransferRequest();
      case 'GetSidechainWealth': return $0.GetSidechainWealthRequest();
      case 'CreateDeposit': return $0.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $0.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $0.ConnectPeerRequest();
      case 'ListPeers': return $0.ListPeersRequest();
      case 'Mine': return $0.MineRequest();
      case 'GetBlock': return $0.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $0.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $0.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $0.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $0.GetWalletUtxosRequest();
      case 'ListUtxos': return $0.ListUtxosRequest();
      case 'RemoveFromMempool': return $0.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $0.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $0.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $0.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $0.CallRawRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $0.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $0.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $0.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $0.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $0.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $0.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $0.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $0.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $0.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $0.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $0.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $0.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $0.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $0.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $0.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $0.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $0.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $0.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $0.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $0.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $0.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $0.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $0.CallRawRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ThunderServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ThunderServiceBase$messageJson;
}

