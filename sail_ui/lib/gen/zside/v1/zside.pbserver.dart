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

import 'zside.pb.dart' as $15;
import 'zside.pbjson.dart';

export 'zside.pb.dart';

abstract class ZSideServiceBase extends $pb.GeneratedService {
  $async.Future<$15.GetBalanceResponse> getBalance($pb.ServerContext ctx, $15.GetBalanceRequest request);
  $async.Future<$15.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $15.GetBlockCountRequest request);
  $async.Future<$15.StopResponse> stop($pb.ServerContext ctx, $15.StopRequest request);
  $async.Future<$15.WithdrawResponse> withdraw($pb.ServerContext ctx, $15.WithdrawRequest request);
  $async.Future<$15.TransferResponse> transfer($pb.ServerContext ctx, $15.TransferRequest request);
  $async.Future<$15.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $15.GetSidechainWealthRequest request);
  $async.Future<$15.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $15.CreateDepositRequest request);
  $async.Future<$15.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $15.GetPendingWithdrawalBundleRequest request);
  $async.Future<$15.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $15.ConnectPeerRequest request);
  $async.Future<$15.ListPeersResponse> listPeers($pb.ServerContext ctx, $15.ListPeersRequest request);
  $async.Future<$15.MineResponse> mine($pb.ServerContext ctx, $15.MineRequest request);
  $async.Future<$15.GetBlockResponse> getBlock($pb.ServerContext ctx, $15.GetBlockRequest request);
  $async.Future<$15.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $15.GetBestMainchainBlockHashRequest request);
  $async.Future<$15.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $15.GetBestSidechainBlockHashRequest request);
  $async.Future<$15.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $15.GetBmmInclusionsRequest request);
  $async.Future<$15.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $15.GetWalletUtxosRequest request);
  $async.Future<$15.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $15.ListUtxosRequest request);
  $async.Future<$15.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $15.RemoveFromMempoolRequest request);
  $async.Future<$15.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $15.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$15.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $15.GenerateMnemonicRequest request);
  $async.Future<$15.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $15.SetSeedFromMnemonicRequest request);
  $async.Future<$15.CallRawResponse> callRaw($pb.ServerContext ctx, $15.CallRawRequest request);
  $async.Future<$15.GetNewShieldedAddressResponse> getNewShieldedAddress($pb.ServerContext ctx, $15.GetNewShieldedAddressRequest request);
  $async.Future<$15.GetNewTransparentAddressResponse> getNewTransparentAddress($pb.ServerContext ctx, $15.GetNewTransparentAddressRequest request);
  $async.Future<$15.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses($pb.ServerContext ctx, $15.GetShieldedWalletAddressesRequest request);
  $async.Future<$15.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses($pb.ServerContext ctx, $15.GetTransparentWalletAddressesRequest request);
  $async.Future<$15.ShieldResponse> shield($pb.ServerContext ctx, $15.ShieldRequest request);
  $async.Future<$15.UnshieldResponse> unshield($pb.ServerContext ctx, $15.UnshieldRequest request);
  $async.Future<$15.ShieldedTransferResponse> shieldedTransfer($pb.ServerContext ctx, $15.ShieldedTransferRequest request);
  $async.Future<$15.TransparentTransferResponse> transparentTransfer($pb.ServerContext ctx, $15.TransparentTransferRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $15.GetBalanceRequest();
      case 'GetBlockCount': return $15.GetBlockCountRequest();
      case 'Stop': return $15.StopRequest();
      case 'Withdraw': return $15.WithdrawRequest();
      case 'Transfer': return $15.TransferRequest();
      case 'GetSidechainWealth': return $15.GetSidechainWealthRequest();
      case 'CreateDeposit': return $15.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $15.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $15.ConnectPeerRequest();
      case 'ListPeers': return $15.ListPeersRequest();
      case 'Mine': return $15.MineRequest();
      case 'GetBlock': return $15.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $15.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $15.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $15.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $15.GetWalletUtxosRequest();
      case 'ListUtxos': return $15.ListUtxosRequest();
      case 'RemoveFromMempool': return $15.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $15.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $15.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $15.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $15.CallRawRequest();
      case 'GetNewShieldedAddress': return $15.GetNewShieldedAddressRequest();
      case 'GetNewTransparentAddress': return $15.GetNewTransparentAddressRequest();
      case 'GetShieldedWalletAddresses': return $15.GetShieldedWalletAddressesRequest();
      case 'GetTransparentWalletAddresses': return $15.GetTransparentWalletAddressesRequest();
      case 'Shield': return $15.ShieldRequest();
      case 'Unshield': return $15.UnshieldRequest();
      case 'ShieldedTransfer': return $15.ShieldedTransferRequest();
      case 'TransparentTransfer': return $15.TransparentTransferRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $15.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $15.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $15.StopRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $15.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $15.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $15.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $15.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $15.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $15.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $15.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $15.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $15.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $15.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $15.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $15.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $15.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $15.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $15.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $15.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $15.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $15.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $15.CallRawRequest);
      case 'GetNewShieldedAddress': return this.getNewShieldedAddress(ctx, request as $15.GetNewShieldedAddressRequest);
      case 'GetNewTransparentAddress': return this.getNewTransparentAddress(ctx, request as $15.GetNewTransparentAddressRequest);
      case 'GetShieldedWalletAddresses': return this.getShieldedWalletAddresses(ctx, request as $15.GetShieldedWalletAddressesRequest);
      case 'GetTransparentWalletAddresses': return this.getTransparentWalletAddresses(ctx, request as $15.GetTransparentWalletAddressesRequest);
      case 'Shield': return this.shield(ctx, request as $15.ShieldRequest);
      case 'Unshield': return this.unshield(ctx, request as $15.UnshieldRequest);
      case 'ShieldedTransfer': return this.shieldedTransfer(ctx, request as $15.ShieldedTransferRequest);
      case 'TransparentTransfer': return this.transparentTransfer(ctx, request as $15.TransparentTransferRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideServiceBase$messageJson;
}

