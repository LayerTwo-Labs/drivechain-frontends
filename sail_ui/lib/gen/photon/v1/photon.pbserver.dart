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

import 'photon.pb.dart' as $9;
import 'photon.pbjson.dart';

export 'photon.pb.dart';

abstract class PhotonServiceBase extends $pb.GeneratedService {
  $async.Future<$9.GetBalanceResponse> getBalance($pb.ServerContext ctx, $9.GetBalanceRequest request);
  $async.Future<$9.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $9.GetBlockCountRequest request);
  $async.Future<$9.StopResponse> stop($pb.ServerContext ctx, $9.StopRequest request);
  $async.Future<$9.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $9.GetNewAddressRequest request);
  $async.Future<$9.WithdrawResponse> withdraw($pb.ServerContext ctx, $9.WithdrawRequest request);
  $async.Future<$9.TransferResponse> transfer($pb.ServerContext ctx, $9.TransferRequest request);
  $async.Future<$9.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $9.GetSidechainWealthRequest request);
  $async.Future<$9.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $9.CreateDepositRequest request);
  $async.Future<$9.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $9.GetPendingWithdrawalBundleRequest request);
  $async.Future<$9.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $9.ConnectPeerRequest request);
  $async.Future<$9.ForgetPeerResponse> forgetPeer($pb.ServerContext ctx, $9.ForgetPeerRequest request);
  $async.Future<$9.ListPeersResponse> listPeers($pb.ServerContext ctx, $9.ListPeersRequest request);
  $async.Future<$9.MineResponse> mine($pb.ServerContext ctx, $9.MineRequest request);
  $async.Future<$9.GetBlockResponse> getBlock($pb.ServerContext ctx, $9.GetBlockRequest request);
  $async.Future<$9.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $9.GetBestMainchainBlockHashRequest request);
  $async.Future<$9.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $9.GetBestSidechainBlockHashRequest request);
  $async.Future<$9.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $9.GetBmmInclusionsRequest request);
  $async.Future<$9.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $9.GetWalletUtxosRequest request);
  $async.Future<$9.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $9.ListUtxosRequest request);
  $async.Future<$9.RemoveFromMempoolResponse> removeFromMempool(
      $pb.ServerContext ctx, $9.RemoveFromMempoolRequest request);
  $async.Future<$9.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $9.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$9.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $9.GenerateMnemonicRequest request);
  $async.Future<$9.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $9.SetSeedFromMnemonicRequest request);
  $async.Future<$9.CallRawResponse> callRaw($pb.ServerContext ctx, $9.CallRawRequest request);
  $async.Future<$9.GetWalletAddressesResponse> getWalletAddresses(
      $pb.ServerContext ctx, $9.GetWalletAddressesRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $9.GetBalanceRequest();
      case 'GetBlockCount':
        return $9.GetBlockCountRequest();
      case 'Stop':
        return $9.StopRequest();
      case 'GetNewAddress':
        return $9.GetNewAddressRequest();
      case 'Withdraw':
        return $9.WithdrawRequest();
      case 'Transfer':
        return $9.TransferRequest();
      case 'GetSidechainWealth':
        return $9.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $9.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $9.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $9.ConnectPeerRequest();
      case 'ForgetPeer':
        return $9.ForgetPeerRequest();
      case 'ListPeers':
        return $9.ListPeersRequest();
      case 'Mine':
        return $9.MineRequest();
      case 'GetBlock':
        return $9.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $9.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $9.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $9.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $9.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $9.ListUtxosRequest();
      case 'RemoveFromMempool':
        return $9.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $9.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $9.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $9.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $9.CallRawRequest();
      case 'GetWalletAddresses':
        return $9.GetWalletAddressesRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return this.getBalance(ctx, request as $9.GetBalanceRequest);
      case 'GetBlockCount':
        return this.getBlockCount(ctx, request as $9.GetBlockCountRequest);
      case 'Stop':
        return this.stop(ctx, request as $9.StopRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $9.GetNewAddressRequest);
      case 'Withdraw':
        return this.withdraw(ctx, request as $9.WithdrawRequest);
      case 'Transfer':
        return this.transfer(ctx, request as $9.TransferRequest);
      case 'GetSidechainWealth':
        return this.getSidechainWealth(ctx, request as $9.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $9.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return this.getPendingWithdrawalBundle(ctx, request as $9.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return this.connectPeer(ctx, request as $9.ConnectPeerRequest);
      case 'ForgetPeer':
        return this.forgetPeer(ctx, request as $9.ForgetPeerRequest);
      case 'ListPeers':
        return this.listPeers(ctx, request as $9.ListPeersRequest);
      case 'Mine':
        return this.mine(ctx, request as $9.MineRequest);
      case 'GetBlock':
        return this.getBlock(ctx, request as $9.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return this.getBestMainchainBlockHash(ctx, request as $9.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return this.getBestSidechainBlockHash(ctx, request as $9.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return this.getBmmInclusions(ctx, request as $9.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return this.getWalletUtxos(ctx, request as $9.GetWalletUtxosRequest);
      case 'ListUtxos':
        return this.listUtxos(ctx, request as $9.ListUtxosRequest);
      case 'RemoveFromMempool':
        return this.removeFromMempool(ctx, request as $9.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return this
            .getLatestFailedWithdrawalBundleHeight(ctx, request as $9.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return this.generateMnemonic(ctx, request as $9.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return this.setSeedFromMnemonic(ctx, request as $9.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return this.callRaw(ctx, request as $9.CallRawRequest);
      case 'GetWalletAddresses':
        return this.getWalletAddresses(ctx, request as $9.GetWalletAddressesRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => PhotonServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => PhotonServiceBase$messageJson;
}
