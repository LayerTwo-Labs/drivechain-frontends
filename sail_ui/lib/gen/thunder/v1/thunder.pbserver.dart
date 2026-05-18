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

import 'thunder.pb.dart' as $10;
import 'thunder.pbjson.dart';

export 'thunder.pb.dart';

abstract class ThunderServiceBase extends $pb.GeneratedService {
  $async.Future<$10.GetBalanceResponse> getBalance($pb.ServerContext ctx, $10.GetBalanceRequest request);
  $async.Future<$10.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $10.GetBlockCountRequest request);
  $async.Future<$10.StopResponse> stop($pb.ServerContext ctx, $10.StopRequest request);
  $async.Future<$10.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $10.GetNewAddressRequest request);
  $async.Future<$10.WithdrawResponse> withdraw($pb.ServerContext ctx, $10.WithdrawRequest request);
  $async.Future<$10.TransferResponse> transfer($pb.ServerContext ctx, $10.TransferRequest request);
  $async.Future<$10.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $10.GetSidechainWealthRequest request);
  $async.Future<$10.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $10.CreateDepositRequest request);
  $async.Future<$10.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $10.GetPendingWithdrawalBundleRequest request);
  $async.Future<$10.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $10.ConnectPeerRequest request);
  $async.Future<$10.ListPeersResponse> listPeers($pb.ServerContext ctx, $10.ListPeersRequest request);
  $async.Future<$10.MineResponse> mine($pb.ServerContext ctx, $10.MineRequest request);
  $async.Future<$10.GetBlockResponse> getBlock($pb.ServerContext ctx, $10.GetBlockRequest request);
  $async.Future<$10.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $10.GetBestMainchainBlockHashRequest request);
  $async.Future<$10.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $10.GetBestSidechainBlockHashRequest request);
  $async.Future<$10.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $10.GetBmmInclusionsRequest request);
  $async.Future<$10.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $10.GetWalletUtxosRequest request);
  $async.Future<$10.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $10.ListUtxosRequest request);
  $async.Future<$10.RemoveFromMempoolResponse> removeFromMempool(
      $pb.ServerContext ctx, $10.RemoveFromMempoolRequest request);
  $async.Future<$10.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $10.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$10.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $10.GenerateMnemonicRequest request);
  $async.Future<$10.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $10.SetSeedFromMnemonicRequest request);
  $async.Future<$10.CallRawResponse> callRaw($pb.ServerContext ctx, $10.CallRawRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $10.GetBalanceRequest();
      case 'GetBlockCount':
        return $10.GetBlockCountRequest();
      case 'Stop':
        return $10.StopRequest();
      case 'GetNewAddress':
        return $10.GetNewAddressRequest();
      case 'Withdraw':
        return $10.WithdrawRequest();
      case 'Transfer':
        return $10.TransferRequest();
      case 'GetSidechainWealth':
        return $10.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $10.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $10.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $10.ConnectPeerRequest();
      case 'ListPeers':
        return $10.ListPeersRequest();
      case 'Mine':
        return $10.MineRequest();
      case 'GetBlock':
        return $10.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $10.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $10.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $10.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $10.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $10.ListUtxosRequest();
      case 'RemoveFromMempool':
        return $10.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $10.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $10.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $10.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $10.CallRawRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return this.getBalance(ctx, request as $10.GetBalanceRequest);
      case 'GetBlockCount':
        return this.getBlockCount(ctx, request as $10.GetBlockCountRequest);
      case 'Stop':
        return this.stop(ctx, request as $10.StopRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $10.GetNewAddressRequest);
      case 'Withdraw':
        return this.withdraw(ctx, request as $10.WithdrawRequest);
      case 'Transfer':
        return this.transfer(ctx, request as $10.TransferRequest);
      case 'GetSidechainWealth':
        return this.getSidechainWealth(ctx, request as $10.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $10.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return this.getPendingWithdrawalBundle(ctx, request as $10.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return this.connectPeer(ctx, request as $10.ConnectPeerRequest);
      case 'ListPeers':
        return this.listPeers(ctx, request as $10.ListPeersRequest);
      case 'Mine':
        return this.mine(ctx, request as $10.MineRequest);
      case 'GetBlock':
        return this.getBlock(ctx, request as $10.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return this.getBestMainchainBlockHash(ctx, request as $10.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return this.getBestSidechainBlockHash(ctx, request as $10.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return this.getBmmInclusions(ctx, request as $10.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return this.getWalletUtxos(ctx, request as $10.GetWalletUtxosRequest);
      case 'ListUtxos':
        return this.listUtxos(ctx, request as $10.ListUtxosRequest);
      case 'RemoveFromMempool':
        return this.removeFromMempool(ctx, request as $10.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return this
            .getLatestFailedWithdrawalBundleHeight(ctx, request as $10.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return this.generateMnemonic(ctx, request as $10.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return this.setSeedFromMnemonic(ctx, request as $10.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return this.callRaw(ctx, request as $10.CallRawRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ThunderServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ThunderServiceBase$messageJson;
}
