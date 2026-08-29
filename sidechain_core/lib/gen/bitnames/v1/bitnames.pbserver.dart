//
//  Generated code. Do not modify.
//  source: bitnames/v1/bitnames.proto
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

import 'bitnames.pb.dart' as $2;
import 'bitnames.pbjson.dart';

export 'bitnames.pb.dart';

abstract class BitnamesServiceBase extends $pb.GeneratedService {
  $async.Future<$2.GetBalanceResponse> getBalance($pb.ServerContext ctx, $2.GetBalanceRequest request);
  $async.Future<$2.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $2.GetBlockCountRequest request);
  $async.Future<$2.StopResponse> stop($pb.ServerContext ctx, $2.StopRequest request);
  $async.Future<$2.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $2.GetNewAddressRequest request);
  $async.Future<$2.WithdrawResponse> withdraw($pb.ServerContext ctx, $2.WithdrawRequest request);
  $async.Future<$2.TransferResponse> transfer($pb.ServerContext ctx, $2.TransferRequest request);
  $async.Future<$2.GetSidechainWealthResponse> getSidechainWealth($pb.ServerContext ctx, $2.GetSidechainWealthRequest request);
  $async.Future<$2.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $2.CreateDepositRequest request);
  $async.Future<$2.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle($pb.ServerContext ctx, $2.GetPendingWithdrawalBundleRequest request);
  $async.Future<$2.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $2.ConnectPeerRequest request);
  $async.Future<$2.ListPeersResponse> listPeers($pb.ServerContext ctx, $2.ListPeersRequest request);
  $async.Future<$2.MineResponse> mine($pb.ServerContext ctx, $2.MineRequest request);
  $async.Future<$2.GetBlockResponse> getBlock($pb.ServerContext ctx, $2.GetBlockRequest request);
  $async.Future<$2.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash($pb.ServerContext ctx, $2.GetBestMainchainBlockHashRequest request);
  $async.Future<$2.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash($pb.ServerContext ctx, $2.GetBestSidechainBlockHashRequest request);
  $async.Future<$2.GetBmmInclusionsResponse> getBmmInclusions($pb.ServerContext ctx, $2.GetBmmInclusionsRequest request);
  $async.Future<$2.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $2.GetWalletUtxosRequest request);
  $async.Future<$2.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $2.ListUtxosRequest request);
  $async.Future<$2.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight($pb.ServerContext ctx, $2.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$2.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $2.GenerateMnemonicRequest request);
  $async.Future<$2.SetSeedFromMnemonicResponse> setSeedFromMnemonic($pb.ServerContext ctx, $2.SetSeedFromMnemonicRequest request);
  $async.Future<$2.CallRawResponse> callRaw($pb.ServerContext ctx, $2.CallRawRequest request);
  $async.Future<$2.GetBitNameDataResponse> getBitNameData($pb.ServerContext ctx, $2.GetBitNameDataRequest request);
  $async.Future<$2.ListBitNamesResponse> listBitNames($pb.ServerContext ctx, $2.ListBitNamesRequest request);
  $async.Future<$2.RegisterBitNameResponse> registerBitName($pb.ServerContext ctx, $2.RegisterBitNameRequest request);
  $async.Future<$2.ReserveBitNameResponse> reserveBitName($pb.ServerContext ctx, $2.ReserveBitNameRequest request);
  $async.Future<$2.GetNewEncryptionKeyResponse> getNewEncryptionKey($pb.ServerContext ctx, $2.GetNewEncryptionKeyRequest request);
  $async.Future<$2.GetNewVerifyingKeyResponse> getNewVerifyingKey($pb.ServerContext ctx, $2.GetNewVerifyingKeyRequest request);
  $async.Future<$2.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $2.DecryptMsgRequest request);
  $async.Future<$2.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $2.EncryptMsgRequest request);
  $async.Future<$2.GetPaymailResponse> getPaymail($pb.ServerContext ctx, $2.GetPaymailRequest request);
  $async.Future<$2.ResolveCommitResponse> resolveCommit($pb.ServerContext ctx, $2.ResolveCommitRequest request);
  $async.Future<$2.SignArbitraryMsgResponse> signArbitraryMsg($pb.ServerContext ctx, $2.SignArbitraryMsgRequest request);
  $async.Future<$2.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr($pb.ServerContext ctx, $2.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$2.GetWalletAddressesResponse> getWalletAddresses($pb.ServerContext ctx, $2.GetWalletAddressesRequest request);
  $async.Future<$2.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $2.MyUtxosRequest request);
  $async.Future<$2.OpenapiSchemaResponse> openapiSchema($pb.ServerContext ctx, $2.OpenapiSchemaRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance': return $2.GetBalanceRequest();
      case 'GetBlockCount': return $2.GetBlockCountRequest();
      case 'Stop': return $2.StopRequest();
      case 'GetNewAddress': return $2.GetNewAddressRequest();
      case 'Withdraw': return $2.WithdrawRequest();
      case 'Transfer': return $2.TransferRequest();
      case 'GetSidechainWealth': return $2.GetSidechainWealthRequest();
      case 'CreateDeposit': return $2.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle': return $2.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer': return $2.ConnectPeerRequest();
      case 'ListPeers': return $2.ListPeersRequest();
      case 'Mine': return $2.MineRequest();
      case 'GetBlock': return $2.GetBlockRequest();
      case 'GetBestMainchainBlockHash': return $2.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash': return $2.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions': return $2.GetBmmInclusionsRequest();
      case 'GetWalletUtxos': return $2.GetWalletUtxosRequest();
      case 'ListUtxos': return $2.ListUtxosRequest();
      case 'GetLatestFailedWithdrawalBundleHeight': return $2.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic': return $2.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic': return $2.SetSeedFromMnemonicRequest();
      case 'CallRaw': return $2.CallRawRequest();
      case 'GetBitNameData': return $2.GetBitNameDataRequest();
      case 'ListBitNames': return $2.ListBitNamesRequest();
      case 'RegisterBitName': return $2.RegisterBitNameRequest();
      case 'ReserveBitName': return $2.ReserveBitNameRequest();
      case 'GetNewEncryptionKey': return $2.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey': return $2.GetNewVerifyingKeyRequest();
      case 'DecryptMsg': return $2.DecryptMsgRequest();
      case 'EncryptMsg': return $2.EncryptMsgRequest();
      case 'GetPaymail': return $2.GetPaymailRequest();
      case 'ResolveCommit': return $2.ResolveCommitRequest();
      case 'SignArbitraryMsg': return $2.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr': return $2.SignArbitraryMsgAsAddrRequest();
      case 'GetWalletAddresses': return $2.GetWalletAddressesRequest();
      case 'MyUtxos': return $2.MyUtxosRequest();
      case 'OpenapiSchema': return $2.OpenapiSchemaRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance': return this.getBalance(ctx, request as $2.GetBalanceRequest);
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $2.GetBlockCountRequest);
      case 'Stop': return this.stop(ctx, request as $2.StopRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $2.GetNewAddressRequest);
      case 'Withdraw': return this.withdraw(ctx, request as $2.WithdrawRequest);
      case 'Transfer': return this.transfer(ctx, request as $2.TransferRequest);
      case 'GetSidechainWealth': return this.getSidechainWealth(ctx, request as $2.GetSidechainWealthRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $2.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle': return this.getPendingWithdrawalBundle(ctx, request as $2.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer': return this.connectPeer(ctx, request as $2.ConnectPeerRequest);
      case 'ListPeers': return this.listPeers(ctx, request as $2.ListPeersRequest);
      case 'Mine': return this.mine(ctx, request as $2.MineRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $2.GetBlockRequest);
      case 'GetBestMainchainBlockHash': return this.getBestMainchainBlockHash(ctx, request as $2.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash': return this.getBestSidechainBlockHash(ctx, request as $2.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions': return this.getBmmInclusions(ctx, request as $2.GetBmmInclusionsRequest);
      case 'GetWalletUtxos': return this.getWalletUtxos(ctx, request as $2.GetWalletUtxosRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $2.ListUtxosRequest);
      case 'GetLatestFailedWithdrawalBundleHeight': return this.getLatestFailedWithdrawalBundleHeight(ctx, request as $2.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $2.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic': return this.setSeedFromMnemonic(ctx, request as $2.SetSeedFromMnemonicRequest);
      case 'CallRaw': return this.callRaw(ctx, request as $2.CallRawRequest);
      case 'GetBitNameData': return this.getBitNameData(ctx, request as $2.GetBitNameDataRequest);
      case 'ListBitNames': return this.listBitNames(ctx, request as $2.ListBitNamesRequest);
      case 'RegisterBitName': return this.registerBitName(ctx, request as $2.RegisterBitNameRequest);
      case 'ReserveBitName': return this.reserveBitName(ctx, request as $2.ReserveBitNameRequest);
      case 'GetNewEncryptionKey': return this.getNewEncryptionKey(ctx, request as $2.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey': return this.getNewVerifyingKey(ctx, request as $2.GetNewVerifyingKeyRequest);
      case 'DecryptMsg': return this.decryptMsg(ctx, request as $2.DecryptMsgRequest);
      case 'EncryptMsg': return this.encryptMsg(ctx, request as $2.EncryptMsgRequest);
      case 'GetPaymail': return this.getPaymail(ctx, request as $2.GetPaymailRequest);
      case 'ResolveCommit': return this.resolveCommit(ctx, request as $2.ResolveCommitRequest);
      case 'SignArbitraryMsg': return this.signArbitraryMsg(ctx, request as $2.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr': return this.signArbitraryMsgAsAddr(ctx, request as $2.SignArbitraryMsgAsAddrRequest);
      case 'GetWalletAddresses': return this.getWalletAddresses(ctx, request as $2.GetWalletAddressesRequest);
      case 'MyUtxos': return this.myUtxos(ctx, request as $2.MyUtxosRequest);
      case 'OpenapiSchema': return this.openapiSchema(ctx, request as $2.OpenapiSchemaRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitnamesServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitnamesServiceBase$messageJson;
}

