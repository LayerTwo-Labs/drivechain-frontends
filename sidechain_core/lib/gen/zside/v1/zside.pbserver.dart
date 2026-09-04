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

import 'zside.pb.dart' as $19;
import 'zside.pbjson.dart';

export 'zside.pb.dart';

abstract class ZSideServiceBase extends $pb.GeneratedService {
  $async.Future<$19.GetBalanceResponse> getBalance($pb.ServerContext ctx, $19.GetBalanceRequest request);
  $async.Future<$19.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $19.GetBlockCountRequest request);
  $async.Future<$19.StopResponse> stop($pb.ServerContext ctx, $19.StopRequest request);
  $async.Future<$19.WithdrawResponse> withdraw($pb.ServerContext ctx, $19.WithdrawRequest request);
  $async.Future<$19.TransferResponse> transfer($pb.ServerContext ctx, $19.TransferRequest request);
  $async.Future<$19.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $19.GetSidechainWealthRequest request);
  $async.Future<$19.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $19.CreateDepositRequest request);
  $async.Future<$19.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $19.GetPendingWithdrawalBundleRequest request);
  $async.Future<$19.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $19.ConnectPeerRequest request);
  $async.Future<$19.ListPeersResponse> listPeers($pb.ServerContext ctx, $19.ListPeersRequest request);
  $async.Future<$19.MineResponse> mine($pb.ServerContext ctx, $19.MineRequest request);
  $async.Future<$19.GetBlockResponse> getBlock($pb.ServerContext ctx, $19.GetBlockRequest request);
  $async.Future<$19.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $19.GetBestMainchainBlockHashRequest request);
  $async.Future<$19.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $19.GetBestSidechainBlockHashRequest request);
  $async.Future<$19.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $19.GetBmmInclusionsRequest request);
  $async.Future<$19.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $19.GetWalletUtxosRequest request);
  $async.Future<$19.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $19.ListUtxosRequest request);
  $async.Future<$19.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $19.RemoveFromMempoolRequest request);
  $async.Future<$19.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $19.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$19.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $19.GenerateMnemonicRequest request);
  $async.Future<$19.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $19.SetSeedFromMnemonicRequest request);
  $async.Future<$19.CallRawResponse> callRaw($pb.ServerContext ctx, $19.CallRawRequest request);
  $async.Future<$19.GetNewShieldedAddressResponse> getNewShieldedAddress($pb.ServerContext ctx, $19.GetNewShieldedAddressRequest request);
  $async.Future<$19.GetNewTransparentAddressResponse> getNewTransparentAddress($pb.ServerContext ctx, $19.GetNewTransparentAddressRequest request);
  $async.Future<$19.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses($pb.ServerContext ctx, $19.GetShieldedWalletAddressesRequest request);
  $async.Future<$19.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses($pb.ServerContext ctx, $19.GetTransparentWalletAddressesRequest request);
  $async.Future<$19.ShieldResponse> shield($pb.ServerContext ctx, $19.ShieldRequest request);
  $async.Future<$19.UnshieldResponse> unshield($pb.ServerContext ctx, $19.UnshieldRequest request);
  $async.Future<$19.ShieldedTransferResponse> shieldedTransfer($pb.ServerContext ctx, $19.ShieldedTransferRequest request);
  $async.Future<$19.TransparentTransferResponse> transparentTransfer($pb.ServerContext ctx, $19.TransparentTransferRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $19.GetBalanceRequest();
      case 'GetBlockCount': return $19.GetBlockCountRequest();
      case 'Stop': return $19.StopRequest();
      case 'Withdraw': return $19.WithdrawRequest();
      case 'Transfer': return $19.TransferRequest();
      case 'GetSidechainWealth': return $19.GetSidechainWealthRequest();
      case 'CreateDeposit': return $19.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $19.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $19.ConnectPeerRequest();
      case 'ListPeers': return $19.ListPeersRequest();
      case 'Mine': return $19.MineRequest();
      case 'GetBlock': return $19.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $19.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $19.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $19.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $19.GetWalletUtxosRequest();
      case 'ListUtxos': return $19.ListUtxosRequest();
      case 'RemoveFromMempool': return $19.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $19.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $19.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $19.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $19.CallRawRequest();
      case 'GetNewShieldedAddress': return $19.GetNewShieldedAddressRequest();
      case 'GetNewTransparentAddress': return $19.GetNewTransparentAddressRequest();
      case 'GetShieldedWalletAddresses': return $19.GetShieldedWalletAddressesRequest();
      case 'GetTransparentWalletAddresses': return $19.GetTransparentWalletAddressesRequest();
      case 'Shield': return $19.ShieldRequest();
      case 'Unshield': return $19.UnshieldRequest();
      case 'ShieldedTransfer': return $19.ShieldedTransferRequest();
      case 'TransparentTransfer': return $19.TransparentTransferRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $19.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $19.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $19.StopRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $19.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $19.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $19.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $19.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $19.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $19.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $19.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $19.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $19.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $19.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $19.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $19.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $19.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $19.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $19.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $19.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $19.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $19.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $19.CallRawRequest);
      case 'GetNewShieldedAddress': return this.getNewShieldedAddress(ctx, request as $19.GetNewShieldedAddressRequest);
      case 'GetNewTransparentAddress': return this.getNewTransparentAddress(ctx, request as $19.GetNewTransparentAddressRequest);
      case 'GetShieldedWalletAddresses': return this.getShieldedWalletAddresses(ctx, request as $19.GetShieldedWalletAddressesRequest);
      case 'GetTransparentWalletAddresses': return this.getTransparentWalletAddresses(ctx, request as $19.GetTransparentWalletAddressesRequest);
      case 'Shield': return this.shield(ctx, request as $19.ShieldRequest);
      case 'Unshield': return this.unshield(ctx, request as $19.UnshieldRequest);
      case 'ShieldedTransfer': return this.shieldedTransfer(ctx, request as $19.ShieldedTransferRequest);
      case 'TransparentTransfer': return this.transparentTransfer(ctx, request as $19.TransparentTransferRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideServiceBase$messageJson;
}

