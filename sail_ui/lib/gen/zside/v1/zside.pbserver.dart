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

import 'zside.pb.dart' as $16;
import 'zside.pbjson.dart';

export 'zside.pb.dart';

abstract class ZSideServiceBase extends $pb.GeneratedService {
  $async.Future<$16.GetBalanceResponse> getBalance($pb.ServerContext ctx, $16.GetBalanceRequest request);
  $async.Future<$16.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $16.GetBlockCountRequest request);
  $async.Future<$16.StopResponse> stop($pb.ServerContext ctx, $16.StopRequest request);
  $async.Future<$16.WithdrawResponse> withdraw($pb.ServerContext ctx, $16.WithdrawRequest request);
  $async.Future<$16.TransferResponse> transfer($pb.ServerContext ctx, $16.TransferRequest request);
  $async.Future<$16.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $16.GetSidechainWealthRequest request);
  $async.Future<$16.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $16.CreateDepositRequest request);
  $async.Future<$16.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $16.GetPendingWithdrawalBundleRequest request);
  $async.Future<$16.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $16.ConnectPeerRequest request);
  $async.Future<$16.ListPeersResponse> listPeers($pb.ServerContext ctx, $16.ListPeersRequest request);
  $async.Future<$16.MineResponse> mine($pb.ServerContext ctx, $16.MineRequest request);
  $async.Future<$16.GetBlockResponse> getBlock($pb.ServerContext ctx, $16.GetBlockRequest request);
  $async.Future<$16.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $16.GetBestMainchainBlockHashRequest request);
  $async.Future<$16.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $16.GetBestSidechainBlockHashRequest request);
  $async.Future<$16.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $16.GetBmmInclusionsRequest request);
  $async.Future<$16.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $16.GetWalletUtxosRequest request);
  $async.Future<$16.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $16.ListUtxosRequest request);
  $async.Future<$16.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $16.RemoveFromMempoolRequest request);
  $async.Future<$16.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $16.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$16.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $16.GenerateMnemonicRequest request);
  $async.Future<$16.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $16.SetSeedFromMnemonicRequest request);
  $async.Future<$16.CallRawResponse> callRaw($pb.ServerContext ctx, $16.CallRawRequest request);
  $async.Future<$16.GetNewShieldedAddressResponse> getNewShieldedAddress($pb.ServerContext ctx, $16.GetNewShieldedAddressRequest request);
  $async.Future<$16.GetNewTransparentAddressResponse> getNewTransparentAddress($pb.ServerContext ctx, $16.GetNewTransparentAddressRequest request);
  $async.Future<$16.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses($pb.ServerContext ctx, $16.GetShieldedWalletAddressesRequest request);
  $async.Future<$16.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses($pb.ServerContext ctx, $16.GetTransparentWalletAddressesRequest request);
  $async.Future<$16.ShieldResponse> shield($pb.ServerContext ctx, $16.ShieldRequest request);
  $async.Future<$16.UnshieldResponse> unshield($pb.ServerContext ctx, $16.UnshieldRequest request);
  $async.Future<$16.ShieldedTransferResponse> shieldedTransfer($pb.ServerContext ctx, $16.ShieldedTransferRequest request);
  $async.Future<$16.TransparentTransferResponse> transparentTransfer($pb.ServerContext ctx, $16.TransparentTransferRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $16.GetBalanceRequest();
      case 'GetBlockCount': return $16.GetBlockCountRequest();
      case 'Stop': return $16.StopRequest();
      case 'Withdraw': return $16.WithdrawRequest();
      case 'Transfer': return $16.TransferRequest();
      case 'GetSidechainWealth': return $16.GetSidechainWealthRequest();
      case 'CreateDeposit': return $16.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $16.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $16.ConnectPeerRequest();
      case 'ListPeers': return $16.ListPeersRequest();
      case 'Mine': return $16.MineRequest();
      case 'GetBlock': return $16.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $16.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $16.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $16.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $16.GetWalletUtxosRequest();
      case 'ListUtxos': return $16.ListUtxosRequest();
      case 'RemoveFromMempool': return $16.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $16.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $16.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $16.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $16.CallRawRequest();
      case 'GetNewShieldedAddress': return $16.GetNewShieldedAddressRequest();
      case 'GetNewTransparentAddress': return $16.GetNewTransparentAddressRequest();
      case 'GetShieldedWalletAddresses': return $16.GetShieldedWalletAddressesRequest();
      case 'GetTransparentWalletAddresses': return $16.GetTransparentWalletAddressesRequest();
      case 'Shield': return $16.ShieldRequest();
      case 'Unshield': return $16.UnshieldRequest();
      case 'ShieldedTransfer': return $16.ShieldedTransferRequest();
      case 'TransparentTransfer': return $16.TransparentTransferRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $16.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $16.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $16.StopRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $16.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $16.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $16.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $16.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $16.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $16.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $16.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $16.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $16.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $16.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $16.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $16.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $16.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $16.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $16.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $16.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $16.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $16.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $16.CallRawRequest);
      case 'GetNewShieldedAddress': return this.getNewShieldedAddress(ctx, request as $16.GetNewShieldedAddressRequest);
      case 'GetNewTransparentAddress': return this.getNewTransparentAddress(ctx, request as $16.GetNewTransparentAddressRequest);
      case 'GetShieldedWalletAddresses': return this.getShieldedWalletAddresses(ctx, request as $16.GetShieldedWalletAddressesRequest);
      case 'GetTransparentWalletAddresses': return this.getTransparentWalletAddresses(ctx, request as $16.GetTransparentWalletAddressesRequest);
      case 'Shield': return this.shield(ctx, request as $16.ShieldRequest);
      case 'Unshield': return this.unshield(ctx, request as $16.UnshieldRequest);
      case 'ShieldedTransfer': return this.shieldedTransfer(ctx, request as $16.ShieldedTransferRequest);
      case 'TransparentTransfer': return this.transparentTransfer(ctx, request as $16.TransparentTransferRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideServiceBase$messageJson;
}

