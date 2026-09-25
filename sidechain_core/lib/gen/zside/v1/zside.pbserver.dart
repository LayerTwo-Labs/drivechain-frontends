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

import 'zside.pb.dart' as $20;
import 'zside.pbjson.dart';

export 'zside.pb.dart';

abstract class ZSideServiceBase extends $pb.GeneratedService {
  $async.Future<$20.GetBalanceResponse> getBalance($pb.ServerContext ctx, $20.GetBalanceRequest request);
  $async.Future<$20.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $20.GetBlockCountRequest request);
  $async.Future<$20.StopResponse> stop($pb.ServerContext ctx, $20.StopRequest request);
  $async.Future<$20.WithdrawResponse> withdraw($pb.ServerContext ctx, $20.WithdrawRequest request);
  $async.Future<$20.TransferResponse> transfer($pb.ServerContext ctx, $20.TransferRequest request);
  $async.Future<$20.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $20.GetSidechainWealthRequest request);
  $async.Future<$20.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $20.CreateDepositRequest request);
  $async.Future<$20.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $20.GetPendingWithdrawalBundleRequest request);
  $async.Future<$20.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $20.ConnectPeerRequest request);
  $async.Future<$20.ListPeersResponse> listPeers($pb.ServerContext ctx, $20.ListPeersRequest request);
  $async.Future<$20.MineResponse> mine($pb.ServerContext ctx, $20.MineRequest request);
  $async.Future<$20.GetBlockResponse> getBlock($pb.ServerContext ctx, $20.GetBlockRequest request);
  $async.Future<$20.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $20.GetBestMainchainBlockHashRequest request);
  $async.Future<$20.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $20.GetBestSidechainBlockHashRequest request);
  $async.Future<$20.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $20.GetBmmInclusionsRequest request);
  $async.Future<$20.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $20.GetWalletUtxosRequest request);
  $async.Future<$20.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $20.ListUtxosRequest request);
  $async.Future<$20.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $20.RemoveFromMempoolRequest request);
  $async.Future<$20.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $20.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$20.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $20.GenerateMnemonicRequest request);
  $async.Future<$20.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $20.SetSeedFromMnemonicRequest request);
  $async.Future<$20.CallRawResponse> callRaw($pb.ServerContext ctx, $20.CallRawRequest request);
  $async.Future<$20.GetNewShieldedAddressResponse> getNewShieldedAddress($pb.ServerContext ctx, $20.GetNewShieldedAddressRequest request);
  $async.Future<$20.GetNewTransparentAddressResponse> getNewTransparentAddress($pb.ServerContext ctx, $20.GetNewTransparentAddressRequest request);
  $async.Future<$20.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses($pb.ServerContext ctx, $20.GetShieldedWalletAddressesRequest request);
  $async.Future<$20.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses($pb.ServerContext ctx, $20.GetTransparentWalletAddressesRequest request);
  $async.Future<$20.ShieldResponse> shield($pb.ServerContext ctx, $20.ShieldRequest request);
  $async.Future<$20.UnshieldResponse> unshield($pb.ServerContext ctx, $20.UnshieldRequest request);
  $async.Future<$20.ShieldedTransferResponse> shieldedTransfer($pb.ServerContext ctx, $20.ShieldedTransferRequest request);
  $async.Future<$20.TransparentTransferResponse> transparentTransfer($pb.ServerContext ctx, $20.TransparentTransferRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $20.GetBalanceRequest();
      case 'GetBlockCount': return $20.GetBlockCountRequest();
      case 'Stop': return $20.StopRequest();
      case 'Withdraw': return $20.WithdrawRequest();
      case 'Transfer': return $20.TransferRequest();
      case 'GetSidechainWealth': return $20.GetSidechainWealthRequest();
      case 'CreateDeposit': return $20.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $20.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $20.ConnectPeerRequest();
      case 'ListPeers': return $20.ListPeersRequest();
      case 'Mine': return $20.MineRequest();
      case 'GetBlock': return $20.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $20.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $20.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $20.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $20.GetWalletUtxosRequest();
      case 'ListUtxos': return $20.ListUtxosRequest();
      case 'RemoveFromMempool': return $20.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $20.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $20.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $20.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $20.CallRawRequest();
      case 'GetNewShieldedAddress': return $20.GetNewShieldedAddressRequest();
      case 'GetNewTransparentAddress': return $20.GetNewTransparentAddressRequest();
      case 'GetShieldedWalletAddresses': return $20.GetShieldedWalletAddressesRequest();
      case 'GetTransparentWalletAddresses': return $20.GetTransparentWalletAddressesRequest();
      case 'Shield': return $20.ShieldRequest();
      case 'Unshield': return $20.UnshieldRequest();
      case 'ShieldedTransfer': return $20.ShieldedTransferRequest();
      case 'TransparentTransfer': return $20.TransparentTransferRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $20.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $20.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $20.StopRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $20.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $20.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $20.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $20.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $20.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $20.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $20.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $20.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $20.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $20.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $20.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $20.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $20.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $20.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $20.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $20.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $20.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $20.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $20.CallRawRequest);
      case 'GetNewShieldedAddress': return this.getNewShieldedAddress(ctx, request as $20.GetNewShieldedAddressRequest);
      case 'GetNewTransparentAddress': return this.getNewTransparentAddress(ctx, request as $20.GetNewTransparentAddressRequest);
      case 'GetShieldedWalletAddresses': return this.getShieldedWalletAddresses(ctx, request as $20.GetShieldedWalletAddressesRequest);
      case 'GetTransparentWalletAddresses': return this.getTransparentWalletAddresses(ctx, request as $20.GetTransparentWalletAddressesRequest);
      case 'Shield': return this.shield(ctx, request as $20.ShieldRequest);
      case 'Unshield': return this.unshield(ctx, request as $20.UnshieldRequest);
      case 'ShieldedTransfer': return this.shieldedTransfer(ctx, request as $20.ShieldedTransferRequest);
      case 'TransparentTransfer': return this.transparentTransfer(ctx, request as $20.TransparentTransferRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideServiceBase$messageJson;
}

