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

import 'zside.pb.dart' as $18;
import 'zside.pbjson.dart';

export 'zside.pb.dart';

abstract class ZSideServiceBase extends $pb.GeneratedService {
  $async.Future<$18.GetBalanceResponse> getBalance($pb.ServerContext ctx, $18.GetBalanceRequest request);
  $async.Future<$18.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $18.GetBlockCountRequest request);
  $async.Future<$18.StopResponse> stop($pb.ServerContext ctx, $18.StopRequest request);
  $async.Future<$18.WithdrawResponse> withdraw($pb.ServerContext ctx, $18.WithdrawRequest request);
  $async.Future<$18.TransferResponse> transfer($pb.ServerContext ctx, $18.TransferRequest request);
  $async.Future<$18.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $18.GetSidechainWealthRequest request);
  $async.Future<$18.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $18.CreateDepositRequest request);
  $async.Future<$18.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $18.GetPendingWithdrawalBundleRequest request);
  $async.Future<$18.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $18.ConnectPeerRequest request);
  $async.Future<$18.ListPeersResponse> listPeers($pb.ServerContext ctx, $18.ListPeersRequest request);
  $async.Future<$18.MineResponse> mine($pb.ServerContext ctx, $18.MineRequest request);
  $async.Future<$18.GetBlockResponse> getBlock($pb.ServerContext ctx, $18.GetBlockRequest request);
  $async.Future<$18.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $18.GetBestMainchainBlockHashRequest request);
  $async.Future<$18.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $18.GetBestSidechainBlockHashRequest request);
  $async.Future<$18.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $18.GetBmmInclusionsRequest request);
  $async.Future<$18.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $18.GetWalletUtxosRequest request);
  $async.Future<$18.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $18.ListUtxosRequest request);
  $async.Future<$18.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $18.RemoveFromMempoolRequest request);
  $async.Future<$18.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $18.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$18.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $18.GenerateMnemonicRequest request);
  $async.Future<$18.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $18.SetSeedFromMnemonicRequest request);
  $async.Future<$18.CallRawResponse> callRaw($pb.ServerContext ctx, $18.CallRawRequest request);
  $async.Future<$18.GetNewShieldedAddressResponse> getNewShieldedAddress($pb.ServerContext ctx, $18.GetNewShieldedAddressRequest request);
  $async.Future<$18.GetNewTransparentAddressResponse> getNewTransparentAddress($pb.ServerContext ctx, $18.GetNewTransparentAddressRequest request);
  $async.Future<$18.GetShieldedWalletAddressesResponse> getShieldedWalletAddresses($pb.ServerContext ctx, $18.GetShieldedWalletAddressesRequest request);
  $async.Future<$18.GetTransparentWalletAddressesResponse> getTransparentWalletAddresses($pb.ServerContext ctx, $18.GetTransparentWalletAddressesRequest request);
  $async.Future<$18.ShieldResponse> shield($pb.ServerContext ctx, $18.ShieldRequest request);
  $async.Future<$18.UnshieldResponse> unshield($pb.ServerContext ctx, $18.UnshieldRequest request);
  $async.Future<$18.ShieldedTransferResponse> shieldedTransfer($pb.ServerContext ctx, $18.ShieldedTransferRequest request);
  $async.Future<$18.TransparentTransferResponse> transparentTransfer($pb.ServerContext ctx, $18.TransparentTransferRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $18.GetBalanceRequest();
      case 'GetBlockCount': return $18.GetBlockCountRequest();
      case 'Stop': return $18.StopRequest();
      case 'Withdraw': return $18.WithdrawRequest();
      case 'Transfer': return $18.TransferRequest();
      case 'GetSidechainWealth': return $18.GetSidechainWealthRequest();
      case 'CreateDeposit': return $18.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $18.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $18.ConnectPeerRequest();
      case 'ListPeers': return $18.ListPeersRequest();
      case 'Mine': return $18.MineRequest();
      case 'GetBlock': return $18.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $18.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $18.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $18.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $18.GetWalletUtxosRequest();
      case 'ListUtxos': return $18.ListUtxosRequest();
      case 'RemoveFromMempool': return $18.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $18.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $18.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $18.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $18.CallRawRequest();
      case 'GetNewShieldedAddress': return $18.GetNewShieldedAddressRequest();
      case 'GetNewTransparentAddress': return $18.GetNewTransparentAddressRequest();
      case 'GetShieldedWalletAddresses': return $18.GetShieldedWalletAddressesRequest();
      case 'GetTransparentWalletAddresses': return $18.GetTransparentWalletAddressesRequest();
      case 'Shield': return $18.ShieldRequest();
      case 'Unshield': return $18.UnshieldRequest();
      case 'ShieldedTransfer': return $18.ShieldedTransferRequest();
      case 'TransparentTransfer': return $18.TransparentTransferRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $18.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $18.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $18.StopRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $18.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $18.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $18.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $18.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $18.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $18.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $18.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $18.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $18.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $18.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $18.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $18.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $18.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $18.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $18.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $18.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $18.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $18.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $18.CallRawRequest);
      case 'GetNewShieldedAddress': return this.getNewShieldedAddress(ctx, request as $18.GetNewShieldedAddressRequest);
      case 'GetNewTransparentAddress': return this.getNewTransparentAddress(ctx, request as $18.GetNewTransparentAddressRequest);
      case 'GetShieldedWalletAddresses': return this.getShieldedWalletAddresses(ctx, request as $18.GetShieldedWalletAddressesRequest);
      case 'GetTransparentWalletAddresses': return this.getTransparentWalletAddresses(ctx, request as $18.GetTransparentWalletAddressesRequest);
      case 'Shield': return this.shield(ctx, request as $18.ShieldRequest);
      case 'Unshield': return this.unshield(ctx, request as $18.UnshieldRequest);
      case 'ShieldedTransfer': return this.shieldedTransfer(ctx, request as $18.ShieldedTransferRequest);
      case 'TransparentTransfer': return this.transparentTransfer(ctx, request as $18.TransparentTransferRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ZSideServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ZSideServiceBase$messageJson;
}

