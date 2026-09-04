//
//  Generated code. Do not modify.
//  source: thunder/v1/thunder.proto
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

import 'thunder.pb.dart' as $14;
import 'thunder.pbjson.dart';

export 'thunder.pb.dart';

abstract class ThunderServiceBase extends $pb.GeneratedService {
  $async.Future<$14.GetBalanceResponse> getBalance($pb.ServerContext ctx, $14.GetBalanceRequest request);
  $async.Future<$14.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $14.GetBlockCountRequest request);
  $async.Future<$14.StopResponse> stop($pb.ServerContext ctx, $14.StopRequest request);
  $async.Future<$14.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $14.GetNewAddressRequest request);
  $async.Future<$14.WithdrawResponse> withdraw($pb.ServerContext ctx, $14.WithdrawRequest request);
  $async.Future<$14.TransferResponse> transfer($pb.ServerContext ctx, $14.TransferRequest request);
  $async.Future<$14.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $14.GetSidechainWealthRequest request);
  $async.Future<$14.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $14.CreateDepositRequest request);
  $async.Future<$14.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $14.GetPendingWithdrawalBundleRequest request);
  $async.Future<$14.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $14.ConnectPeerRequest request);
  $async.Future<$14.ListPeersResponse> listPeers($pb.ServerContext ctx, $14.ListPeersRequest request);
  $async.Future<$14.MineResponse> mine($pb.ServerContext ctx, $14.MineRequest request);
  $async.Future<$14.GetBlockResponse> getBlock($pb.ServerContext ctx, $14.GetBlockRequest request);
  $async.Future<$14.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $14.GetBestMainchainBlockHashRequest request);
  $async.Future<$14.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $14.GetBestSidechainBlockHashRequest request);
  $async.Future<$14.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $14.GetBmmInclusionsRequest request);
  $async.Future<$14.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $14.GetWalletUtxosRequest request);
  $async.Future<$14.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $14.ListUtxosRequest request);
  $async.Future<$14.RemoveFromMempoolResponse> removeFromMempool($pb.ServerContext ctx, $14.RemoveFromMempoolRequest request);
  $async.Future<$14.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $14.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$14.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $14.GenerateMnemonicRequest request);
  $async.Future<$14.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $14.SetSeedFromMnemonicRequest request);
  $async.Future<$14.CallRawResponse> callRaw($pb.ServerContext ctx, $14.CallRawRequest request);
  $async.Future<$14.ListWalletTransactionsResponse> listWalletTransactions($pb.ServerContext ctx, $14.ListWalletTransactionsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $14.GetBalanceRequest();
      case 'GetBlockCount': return $14.GetBlockCountRequest();
      case 'Stop': return $14.StopRequest();
      case 'GetNewAddress': return $14.GetNewAddressRequest();
      case 'Withdraw': return $14.WithdrawRequest();
      case 'Transfer': return $14.TransferRequest();
      case 'GetSidechainWealth': return $14.GetSidechainWealthRequest();
      case 'CreateDeposit': return $14.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $14.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $14.ConnectPeerRequest();
      case 'ListPeers': return $14.ListPeersRequest();
      case 'Mine': return $14.MineRequest();
      case 'GetBlock': return $14.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $14.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $14.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $14.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $14.GetWalletUtxosRequest();
      case 'ListUtxos': return $14.ListUtxosRequest();
      case 'RemoveFromMempool': return $14.RemoveFromMempoolRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $14.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $14.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $14.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $14.CallRawRequest();
      case 'ListWalletTransactions': return $14.ListWalletTransactionsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $14.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $14.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $14.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $14.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $14.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $14.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $14.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $14.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $14.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $14.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $14.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $14.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $14.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $14.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $14.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $14.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $14.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $14.ListUtxosRequest);
      case 'RemoveFromMempool': return this.removeFromMempool(ctx, request as $14.RemoveFromMempoolRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $14.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $14.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $14.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $14.CallRawRequest);
      case 'ListWalletTransactions': return this.listWalletTransactions(ctx, request as $14.ListWalletTransactionsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ThunderServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ThunderServiceBase$messageJson;
}

