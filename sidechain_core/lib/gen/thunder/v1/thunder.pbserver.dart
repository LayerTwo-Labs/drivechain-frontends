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

import 'thunder.pb.dart' as $16;
import 'thunder.pbjson.dart';

export 'thunder.pb.dart';

abstract class ThunderServiceBase extends $pb.GeneratedService {
  $async.Future<$16.GetBalanceResponse> getBalance($pb.ServerContext ctx, $16.GetBalanceRequest request);
  $async.Future<$16.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $16.GetBlockCountRequest request);
  $async.Future<$16.StopResponse> stop($pb.ServerContext ctx, $16.StopRequest request);
  $async.Future<$16.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $16.GetNewAddressRequest request);
  $async.Future<$16.WithdrawResponse> withdraw($pb.ServerContext ctx, $16.WithdrawRequest request);
  $async.Future<$16.TransferResponse> transfer($pb.ServerContext ctx, $16.TransferRequest request);
  $async.Future<$16.TransferManyResponse> transferMany($pb.ServerContext ctx, $16.TransferManyRequest request);
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
  $async.Future<$16.ListWalletTransactionsResponse> listWalletTransactions($pb.ServerContext ctx, $16.ListWalletTransactionsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $16.GetBalanceRequest();
      case 'GetBlockCount': return $16.GetBlockCountRequest();
      case 'Stop': return $16.StopRequest();
      case 'GetNewAddress': return $16.GetNewAddressRequest();
      case 'Withdraw': return $16.WithdrawRequest();
      case 'Transfer': return $16.TransferRequest();
      case 'TransferMany': return $16.TransferManyRequest();
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
      case 'ListWalletTransactions': return $16.ListWalletTransactionsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $16.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $16.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $16.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $16.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $16.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $16.TransferRequest);
      case 'TransferMany': return this.transferMany(ctx, request as $16.TransferManyRequest);
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
      case 'ListWalletTransactions': return this.listWalletTransactions(ctx, request as $16.ListWalletTransactionsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ThunderServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ThunderServiceBase$messageJson;
}

