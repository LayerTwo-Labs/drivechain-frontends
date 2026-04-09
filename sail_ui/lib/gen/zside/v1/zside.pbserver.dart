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

import 'zside.pb.dart' as $13;
import 'zside.pbjson.dart';

export 'zside.pb.dart';

abstract class ZSideServiceBase extends $pb.GeneratedService {
  $async.Future<$13.GetBalanceResponse> getBalance($pb.ServerContext ctx, $13.GetBalanceRequest request);
  $async.Future<$13.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $13.GetBlockCountRequest request);
  $async.Future<$13.StopResponse> stop($pb.ServerContext ctx, $13.StopRequest request);
  $async.Future<$13.WithdrawResponse> withdraw($pb.ServerContext ctx, $13.WithdrawRequest request);
  $async.Future<$13.TransferResponse> transfer($pb.ServerContext ctx, $13.TransferRequest request);
  $async.Future<$13.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $13.GetSidechainWealthRequest request);
  $async.Future<$13.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $13.CreateDepositRequest request);
  $async.Future<$13.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $13.GetPendingWithdrawalBundleRequest request);
  $async.Future<$13.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $13.ConnectPeerRequest request);
  $async.Future<$13.ListPeersResponse> listPeers($pb.ServerContext ctx, $13.ListPeersRequest request);
  $async.Future<$13.MineResponse> mine($pb.ServerContext ctx, $13.MineRequest request);
  $async.Future<$13.GetBlockResponse> getBlock($pb.ServerContext ctx, $13.GetBlockRequest request);
  $async.Future<$13.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $13.GetBestMainchainBlockHashRequest request);
  $async.Future<$13.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $13.GetBestSidechainBlockHashRequest request);
  $async.Future<$13.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $13.GetBmmInclusionsRequest request);
  $async.Future<$13.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $13.GetWalletUtxosRequest request);
  $async.Future<$13.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $13.ListUtxosRequest request);
  $async.Future<$13.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $13.RemoveFromMempoolRequest request);
  $async.Future<$13.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $13.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$13.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $13.GenerateMnemonicRequest request);
  $async.Future<$13.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $13.SetSeedFromMnemonicRequest request);
  $async.Future<$13.CallRawResponse> callRaw($pb.ServerContext ctx, $13.CallRawRequest request);
  $async.Future<$13.GetNewShieldedAddressResponse> getNewShieldedAddress($pb.ServerContext ctx, $13.GetNewShieldedAddressRequest request);
  $async.Future<$13.GetNewTransparentAddressResponse> getNewTransparentAddress($pb.ServerContext ctx, $13.GetNewTransparentAddressRequest request);
  $async.Future<$13.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses($pb.ServerContext ctx, $13.GetShieldedWalletAddressesRequest request);
  $async.Future<$13.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses($pb.ServerContext ctx, $13.GetTransparentWalletAddressesRequest request);
  $async.Future<$13.ShieldResponse> shield($pb.ServerContext ctx, $13.ShieldRequest request);
  $async.Future<$13.UnshieldResponse> unshield($pb.ServerContext ctx, $13.UnshieldRequest request);
  $async.Future<$13.ShieldedTransferResponse> shieldedTransfer($pb.ServerContext ctx, $13.ShieldedTransferRequest request);
  $async.Future<$13.TransparentTransferResponse> transparentTransfer($pb.ServerContext ctx, $13.TransparentTransferRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $13.GetBalanceRequest();
      case 'GetBlockCount': return $13.GetBlockCountRequest();
      case 'Stop': return $13.StopRequest();
      case 'Withdraw': return $13.WithdrawRequest();
      case 'Transfer': return $13.TransferRequest();
      case 'GetSidechainWealth': return $13.GetSidechainWealthRequest();
      case 'CreateDeposit': return $13.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $13.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $13.ConnectPeerRequest();
      case 'ListPeers': return $13.ListPeersRequest();
      case 'Mine': return $13.MineRequest();
      case 'GetBlock': return $13.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $13.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $13.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $13.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $13.GetWalletUtxosRequest();
      case 'ListUtxos': return $13.ListUtxosRequest();
      case 'RemoveFromMempool': return $13.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $13.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $13.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $13.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $13.CallRawRequest();
      case 'GetNewShieldedAddress': return $13.GetNewShieldedAddressRequest();
      case 'GetNewTransparentAddress': return $13.GetNewTransparentAddressRequest();
      case 'GetShieldedWalletAddresses': return $13.GetShieldedWalletAddressesRequest();
      case 'GetTransparentWalletAddresses': return $13.GetTransparentWalletAddressesRequest();
      case 'Shield': return $13.ShieldRequest();
      case 'Unshield': return $13.UnshieldRequest();
      case 'ShieldedTransfer': return $13.ShieldedTransferRequest();
      case 'TransparentTransfer': return $13.TransparentTransferRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $13.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $13.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $13.StopRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $13.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $13.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $13.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $13.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $13.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $13.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $13.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $13.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $13.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $13.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $13.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $13.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $13.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $13.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $13.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $13.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $13.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $13.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $13.CallRawRequest);
      case 'GetNewShieldedAddress': return this.getNewShieldedAddress(ctx, request as $13.GetNewShieldedAddressRequest);
      case 'GetNewTransparentAddress': return this.getNewTransparentAddress(ctx, request as $13.GetNewTransparentAddressRequest);
      case 'GetShieldedWalletAddresses': return this.getShieldedWalletAddresses(ctx, request as $13.GetShieldedWalletAddressesRequest);
      case 'GetTransparentWalletAddresses': return this.getTransparentWalletAddresses(ctx, request as $13.GetTransparentWalletAddressesRequest);
      case 'Shield': return this.shield(ctx, request as $13.ShieldRequest);
      case 'Unshield': return this.unshield(ctx, request as $13.UnshieldRequest);
      case 'ShieldedTransfer': return this.shieldedTransfer(ctx, request as $13.ShieldedTransferRequest);
      case 'TransparentTransfer': return this.transparentTransfer(ctx, request as $13.TransparentTransferRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideServiceBase$messageJson;
}

