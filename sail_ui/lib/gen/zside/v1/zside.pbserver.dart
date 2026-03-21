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

import 'zside.pb.dart' as $1;
import 'zside.pbjson.dart';

export 'zside.pb.dart';

abstract class ZSideServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetBalanceResponse> getBalance($pb.ServerContext ctx, $1.GetBalanceRequest request);
  $async.Future<$1.GetBalanceBreakdownResponse> getBalanceBreakdown($pb.ServerContext ctx, $1.GetBalanceBreakdownRequest request);
  $async.Future<$1.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $1.GetBlockCountRequest request);
  $async.Future<$1.StopResponse> stop($pb.ServerContext ctx, $1.StopRequest request);
  $async.Future<$1.GetNewTransparentAddressResponse> getNewTransparentAddress($pb.ServerContext ctx, $1.GetNewTransparentAddressRequest request);
  $async.Future<$1.GetNewShieldedAddressResponse> getNewShieldedAddress($pb.ServerContext ctx, $1.GetNewShieldedAddressRequest request);
  $async.Future<$1.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses($pb.ServerContext ctx, $1.GetShieldedWalletAddressesRequest request);
  $async.Future<$1.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses($pb.ServerContext ctx, $1.GetTransparentWalletAddressesRequest request);
  $async.Future<$1.WithdrawResponse> withdraw($pb.ServerContext ctx, $1.WithdrawRequest request);
  $async.Future<$1.TransparentTransferResponse> transparentTransfer($pb.ServerContext ctx, $1.TransparentTransferRequest request);
  $async.Future<$1.ShieldedTransferResponse> shieldedTransfer($pb.ServerContext ctx, $1.ShieldedTransferRequest request);
  $async.Future<$1.ShieldResponse> shield($pb.ServerContext ctx, $1.ShieldRequest request);
  $async.Future<$1.UnshieldResponse> unshield($pb.ServerContext ctx, $1.UnshieldRequest request);
  $async.Future<$1.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $1.GetSidechainWealthRequest request);
  $async.Future<$1.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $1.CreateDepositRequest request);
  $async.Future<$1.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $1.GetPendingWithdrawalBundleRequest request);
  $async.Future<$1.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $1.ConnectPeerRequest request);
  $async.Future<$1.ListPeersResponse> listPeers($pb.ServerContext ctx, $1.ListPeersRequest request);
  $async.Future<$1.MineResponse> mine($pb.ServerContext ctx, $1.MineRequest request);
  $async.Future<$1.GetBlockResponse> getBlock($pb.ServerContext ctx, $1.GetBlockRequest request);
  $async.Future<$1.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $1.GetBestMainchainBlockHashRequest request);
  $async.Future<$1.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $1.GetBestSidechainBlockHashRequest request);
  $async.Future<$1.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $1.GetBmmInclusionsRequest request);
  $async.Future<$1.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $1.GetWalletUtxosRequest request);
  $async.Future<$1.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $1.ListUtxosRequest request);
  $async.Future<$1.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $1.RemoveFromMempoolRequest request);
  $async.Future<$1.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $1.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$1.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $1.GenerateMnemonicRequest request);
  $async.Future<$1.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $1.SetSeedFromMnemonicRequest request);
  $async.Future<$1.CallRawResponse> callRaw($pb.ServerContext ctx, $1.CallRawRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $1.GetBalanceRequest();
      case 'GetBalanceBreakdown': return $1.GetBalanceBreakdownRequest();
      case 'GetBlockCount': return $1.GetBlockCountRequest();
      case 'Stop': return $1.StopRequest();
      case 'GetNewTransparentAddress': return $1.GetNewTransparentAddressRequest();
      case 'GetNewShieldedAddress': return $1.GetNewShieldedAddressRequest();
      case 'GetShieldedWalletAddresses': return $1.GetShieldedWalletAddressesRequest();
      case 'GetTransparentWalletAddresses': return $1.GetTransparentWalletAddressesRequest();
      case 'Withdraw': return $1.WithdrawRequest();
      case 'TransparentTransfer': return $1.TransparentTransferRequest();
      case 'ShieldedTransfer': return $1.ShieldedTransferRequest();
      case 'Shield': return $1.ShieldRequest();
      case 'Unshield': return $1.UnshieldRequest();
      case 'GetSidechainWealth': return $1.GetSidechainWealthRequest();
      case 'CreateDeposit': return $1.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $1.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $1.ConnectPeerRequest();
      case 'ListPeers': return $1.ListPeersRequest();
      case 'Mine': return $1.MineRequest();
      case 'GetBlock': return $1.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $1.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $1.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $1.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $1.GetWalletUtxosRequest();
      case 'ListUtxos': return $1.ListUtxosRequest();
      case 'RemoveFromMempool': return $1.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $1.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $1.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $1.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $1.CallRawRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $1.GetBalanceRequest);
      case 'GetBalanceBreakdown': return this.getBalanceBreakdown(ctx, request as $1.GetBalanceBreakdownRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $1.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $1.StopRequest);
      case 'GetNewTransparentAddress': return this.getNewTransparentAddress(ctx, request as $1.GetNewTransparentAddressRequest);
      case 'GetNewShieldedAddress': return this.getNewShieldedAddress(ctx, request as $1.GetNewShieldedAddressRequest);
      case 'GetShieldedWalletAddresses': return this.getShieldedWalletAddresses(ctx, request as $1.GetShieldedWalletAddressesRequest);
      case 'GetTransparentWalletAddresses': return this.getTransparentWalletAddresses(ctx, request as $1.GetTransparentWalletAddressesRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $1.WithdrawRequest);
      case 'TransparentTransfer': return this.transparentTransfer(ctx, request as $1.TransparentTransferRequest);
      case 'ShieldedTransfer': return this.shieldedTransfer(ctx, request as $1.ShieldedTransferRequest);
      case 'Shield': return this.shield(ctx, request as $1.ShieldRequest);
      case 'Unshield': return this.unshield(ctx, request as $1.UnshieldRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $1.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $1.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $1.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $1.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $1.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $1.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $1.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $1.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $1.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $1.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $1.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $1.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $1.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $1.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $1.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $1.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $1.CallRawRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideServiceBase$messageJson;
}

