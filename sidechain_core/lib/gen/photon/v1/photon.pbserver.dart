//
//  Generated code. Do not modify.
//  source: photon/v1/photon.proto
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

import 'photon.pb.dart' as $12;
import 'photon.pbjson.dart';

export 'photon.pb.dart';

abstract class PhotonServiceBase extends $pb.GeneratedService {
  $async.Future<$12.GetBalanceResponse> getBalance($pb.ServerContext ctx, $12.GetBalanceRequest request);
  $async.Future<$12.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $12.GetBlockCountRequest request);
  $async.Future<$12.StopResponse> stop($pb.ServerContext ctx, $12.StopRequest request);
  $async.Future<$12.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $12.GetNewAddressRequest request);
  $async.Future<$12.WithdrawResponse> withdraw($pb.ServerContext ctx, $12.WithdrawRequest request);
  $async.Future<$12.TransferResponse> transfer($pb.ServerContext ctx, $12.TransferRequest request);
  $async.Future<$12.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $12.GetSidechainWealthRequest request);
  $async.Future<$12.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $12.CreateDepositRequest request);
  $async.Future<$12.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $12.GetPendingWithdrawalBundleRequest request);
  $async.Future<$12.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $12.ConnectPeerRequest request);
  $async.Future<$12.ForgetPeerResponse> forgetPeer($pb.ServerContext ctx, $12.ForgetPeerRequest request);
  $async.Future<$12.ListPeersResponse> listPeers($pb.ServerContext ctx, $12.ListPeersRequest request);
  $async.Future<$12.MineResponse> mine($pb.ServerContext ctx, $12.MineRequest request);
  $async.Future<$12.GetBlockResponse> getBlock($pb.ServerContext ctx, $12.GetBlockRequest request);
  $async.Future<$12.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $12.GetBestMainchainBlockHashRequest request);
  $async.Future<$12.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $12.GetBestSidechainBlockHashRequest request);
  $async.Future<$12.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $12.GetBmmInclusionsRequest request);
  $async.Future<$12.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $12.GetWalletUtxosRequest request);
  $async.Future<$12.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $12.ListUtxosRequest request);
  $async.Future<$12.RemoveFromMempoolResponse> removeFromMempool(
      $pb.ServerContext ctx, $12.RemoveFromMempoolRequest request);
  $async.Future<$12.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $12.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$12.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $12.GenerateMnemonicRequest request);
  $async.Future<$12.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $12.SetSeedFromMnemonicRequest request);
  $async.Future<$12.CallRawResponse> callRaw($pb.ServerContext ctx, $12.CallRawRequest request);
  $async.Future<$12.GetWalletAddressesResponse> getWalletAddresses(
      $pb.ServerContext ctx, $12.GetWalletAddressesRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $12.GetBalanceRequest();
      case 'GetBlockCount':
        return $12.GetBlockCountRequest();
      case 'Stop':
        return $12.StopRequest();
      case 'GetNewAddress':
        return $12.GetNewAddressRequest();
      case 'Withdraw':
        return $12.WithdrawRequest();
      case 'Transfer':
        return $12.TransferRequest();
      case 'GetSidechainWealth':
        return $12.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $12.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $12.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $12.ConnectPeerRequest();
      case 'ForgetPeer':
        return $12.ForgetPeerRequest();
      case 'ListPeers':
        return $12.ListPeersRequest();
      case 'Mine':
        return $12.MineRequest();
      case 'GetBlock':
        return $12.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $12.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $12.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $12.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $12.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $12.ListUtxosRequest();
      case 'RemoveFromMempool':
        return $12.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $12.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $12.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $12.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $12.CallRawRequest();
      case 'GetWalletAddresses':
        return $12.GetWalletAddressesRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return this.getBalance(ctx, request as $12.GetBalanceRequest);
      case 'GetBlockCount':
        return this.getBlockCount(ctx, request as $12.GetBlockCountRequest);
      case 'Stop':
        return this.stop(ctx, request as $12.StopRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $12.GetNewAddressRequest);
      case 'Withdraw':
        return this.withdraw(ctx, request as $12.WithdrawRequest);
      case 'Transfer':
        return this.transfer(ctx, request as $12.TransferRequest);
      case 'GetSidechainWealth':
        return this.getSidechainWealth(ctx, request as $12.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $12.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return this.getPendingWithdrawalBundle(ctx, request as $12.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return this.connectPeer(ctx, request as $12.ConnectPeerRequest);
      case 'ForgetPeer':
        return this.forgetPeer(ctx, request as $12.ForgetPeerRequest);
      case 'ListPeers':
        return this.listPeers(ctx, request as $12.ListPeersRequest);
      case 'Mine':
        return this.mine(ctx, request as $12.MineRequest);
      case 'GetBlock':
        return this.getBlock(ctx, request as $12.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return this.getBestMainchainBlockHash(ctx, request as $12.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return this.getBestSidechainBlockHash(ctx, request as $12.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return this.getBmmInclusions(ctx, request as $12.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return this.getWalletUtxos(ctx, request as $12.GetWalletUtxosRequest);
      case 'ListUtxos':
        return this.listUtxos(ctx, request as $12.ListUtxosRequest);
      case 'RemoveFromMempool':
        return this.removeFromMempool(ctx, request as $12.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return this
            .getLatestFailedWithdrawalBundleHeight(ctx, request as $12.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return this.generateMnemonic(ctx, request as $12.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return this.setSeedFromMnemonic(ctx, request as $12.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return this.callRaw(ctx, request as $12.CallRawRequest);
      case 'GetWalletAddresses':
        return this.getWalletAddresses(ctx, request as $12.GetWalletAddressesRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => PhotonServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => PhotonServiceBase$messageJson;
}
