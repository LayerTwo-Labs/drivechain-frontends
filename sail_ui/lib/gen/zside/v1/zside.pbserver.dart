//
//  Generated code. Do not modify.
//  source: zside/v1/zside.proto
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

import 'zside.pb.dart' as $17;
import 'zside.pbjson.dart';

export 'zside.pb.dart';

abstract class ZSideServiceBase extends $pb.GeneratedService {
  $async.Future<$17.GetBalanceResponse> getBalance($pb.ServerContext ctx, $17.GetBalanceRequest request);
  $async.Future<$17.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $17.GetBlockCountRequest request);
  $async.Future<$17.StopResponse> stop($pb.ServerContext ctx, $17.StopRequest request);
  $async.Future<$17.WithdrawResponse> withdraw($pb.ServerContext ctx, $17.WithdrawRequest request);
  $async.Future<$17.TransferResponse> transfer($pb.ServerContext ctx, $17.TransferRequest request);
  $async.Future<$17.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $17.GetSidechainWealthRequest request);
  $async.Future<$17.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $17.CreateDepositRequest request);
  $async.Future<$17.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $17.GetPendingWithdrawalBundleRequest request);
  $async.Future<$17.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $17.ConnectPeerRequest request);
  $async.Future<$17.ListPeersResponse> listPeers($pb.ServerContext ctx, $17.ListPeersRequest request);
  $async.Future<$17.MineResponse> mine($pb.ServerContext ctx, $17.MineRequest request);
  $async.Future<$17.GetBlockResponse> getBlock($pb.ServerContext ctx, $17.GetBlockRequest request);
  $async.Future<$17.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $17.GetBestMainchainBlockHashRequest request);
  $async.Future<$17.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $17.GetBestSidechainBlockHashRequest request);
  $async.Future<$17.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $17.GetBmmInclusionsRequest request);
  $async.Future<$17.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $17.GetWalletUtxosRequest request);
  $async.Future<$17.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $17.ListUtxosRequest request);
  $async.Future<$17.RemoveFromMempoolResponse> removeFromMempool(
      $pb.ServerContext ctx, $17.RemoveFromMempoolRequest request);
  $async.Future<$17.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $17.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$17.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $17.GenerateMnemonicRequest request);
  $async.Future<$17.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $17.SetSeedFromMnemonicRequest request);
  $async.Future<$17.CallRawResponse> callRaw($pb.ServerContext ctx, $17.CallRawRequest request);
  $async.Future<$17.GetNewShieldedAddressResponse> getNewShieldedAddress(
      $pb.ServerContext ctx, $17.GetNewShieldedAddressRequest request);
  $async.Future<$17.GetNewTransparentAddressResponse> getNewTransparentAddress(
      $pb.ServerContext ctx, $17.GetNewTransparentAddressRequest request);
  $async.Future<$17.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses(
      $pb.ServerContext ctx, $17.GetShieldedWalletAddressesRequest request);
  $async.Future<$17.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses(
      $pb.ServerContext ctx, $17.GetTransparentWalletAddressesRequest request);
  $async.Future<$17.ShieldResponse> shield($pb.ServerContext ctx, $17.ShieldRequest request);
  $async.Future<$17.UnshieldResponse> unshield($pb.ServerContext ctx, $17.UnshieldRequest request);
  $async.Future<$17.ShieldedTransferResponse> shieldedTransfer(
      $pb.ServerContext ctx, $17.ShieldedTransferRequest request);
  $async.Future<$17.TransparentTransferResponse> transparentTransfer(
      $pb.ServerContext ctx, $17.TransparentTransferRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $17.GetBalanceRequest();
      case 'GetBlockCount':
        return $17.GetBlockCountRequest();
      case 'Stop':
        return $17.StopRequest();
      case 'Withdraw':
        return $17.WithdrawRequest();
      case 'Transfer':
        return $17.TransferRequest();
      case 'GetSidechainWealth':
        return $17.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $17.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $17.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $17.ConnectPeerRequest();
      case 'ListPeers':
        return $17.ListPeersRequest();
      case 'Mine':
        return $17.MineRequest();
      case 'GetBlock':
        return $17.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $17.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $17.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $17.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $17.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $17.ListUtxosRequest();
      case 'RemoveFromMempool':
        return $17.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $17.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $17.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $17.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $17.CallRawRequest();
      case 'GetNewShieldedAddress':
        return $17.GetNewShieldedAddressRequest();
      case 'GetNewTransparentAddress':
        return $17.GetNewTransparentAddressRequest();
      case 'GetShieldedWalletAddresses':
        return $17.GetShieldedWalletAddressesRequest();
      case 'GetTransparentWalletAddresses':
        return $17.GetTransparentWalletAddressesRequest();
      case 'Shield':
        return $17.ShieldRequest();
      case 'Unshield':
        return $17.UnshieldRequest();
      case 'ShieldedTransfer':
        return $17.ShieldedTransferRequest();
      case 'TransparentTransfer':
        return $17.TransparentTransferRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return this.getBalance(ctx, request as $17.GetBalanceRequest);
      case 'GetBlockCount':
        return this.getBlockCount(ctx, request as $17.GetBlockCountRequest);
      case 'Stop':
        return this.stop(ctx, request as $17.StopRequest);
      case 'Withdraw':
        return this.withdraw(ctx, request as $17.WithdrawRequest);
      case 'Transfer':
        return this.transfer(ctx, request as $17.TransferRequest);
      case 'GetSidechainWealth':
        return this.getSidechainWealth(ctx, request as $17.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $17.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return this.getPendingWithdrawalBundle(ctx, request as $17.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return this.connectPeer(ctx, request as $17.ConnectPeerRequest);
      case 'ListPeers':
        return this.listPeers(ctx, request as $17.ListPeersRequest);
      case 'Mine':
        return this.mine(ctx, request as $17.MineRequest);
      case 'GetBlock':
        return this.getBlock(ctx, request as $17.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return this.getBestMainchainBlockHash(ctx, request as $17.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return this.getBestSidechainBlockHash(ctx, request as $17.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return this.getBmmInclusions(ctx, request as $17.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return this.getWalletUtxos(ctx, request as $17.GetWalletUtxosRequest);
      case 'ListUtxos':
        return this.listUtxos(ctx, request as $17.ListUtxosRequest);
      case 'RemoveFromMempool':
        return this.removeFromMempool(ctx, request as $17.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return this
            .getLatestFailedWithdrawalBundleHeight(ctx, request as $17.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return this.generateMnemonic(ctx, request as $17.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return this.setSeedFromMnemonic(ctx, request as $17.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return this.callRaw(ctx, request as $17.CallRawRequest);
      case 'GetNewShieldedAddress':
        return this.getNewShieldedAddress(ctx, request as $17.GetNewShieldedAddressRequest);
      case 'GetNewTransparentAddress':
        return this.getNewTransparentAddress(ctx, request as $17.GetNewTransparentAddressRequest);
      case 'GetShieldedWalletAddresses':
        return this.getShieldedWalletAddresses(ctx, request as $17.GetShieldedWalletAddressesRequest);
      case 'GetTransparentWalletAddresses':
        return this.getTransparentWalletAddresses(ctx, request as $17.GetTransparentWalletAddressesRequest);
      case 'Shield':
        return this.shield(ctx, request as $17.ShieldRequest);
      case 'Unshield':
        return this.unshield(ctx, request as $17.UnshieldRequest);
      case 'ShieldedTransfer':
        return this.shieldedTransfer(ctx, request as $17.ShieldedTransferRequest);
      case 'TransparentTransfer':
        return this.transparentTransfer(ctx, request as $17.TransparentTransferRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideServiceBase$messageJson;
}
