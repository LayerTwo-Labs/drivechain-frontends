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

import 'bitnames.pb.dart' as $1;
import 'bitnames.pbjson.dart';

export 'bitnames.pb.dart';

abstract class BitnamesServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetBalanceResponse> getBalance($pb.ServerContext ctx, $1.GetBalanceRequest request);
  $async.Future<$1.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $1.GetBlockCountRequest request);
  $async.Future<$1.StopResponse> stop($pb.ServerContext ctx, $1.StopRequest request);
  $async.Future<$1.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $1.GetNewAddressRequest request);
  $async.Future<$1.WithdrawResponse> withdraw($pb.ServerContext ctx, $1.WithdrawRequest request);
  $async.Future<$1.TransferResponse> transfer($pb.ServerContext ctx, $1.TransferRequest request);
  $async.Future<$1.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $1.GetSidechainWealthRequest request);
  $async.Future<$1.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $1.CreateDepositRequest request);
  $async.Future<$1.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $1.GetPendingWithdrawalBundleRequest request);
  $async.Future<$1.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $1.ConnectPeerRequest request);
  $async.Future<$1.ListPeersResponse> listPeers($pb.ServerContext ctx, $1.ListPeersRequest request);
  $async.Future<$1.MineResponse> mine($pb.ServerContext ctx, $1.MineRequest request);
  $async.Future<$1.GetBlockResponse> getBlock($pb.ServerContext ctx, $1.GetBlockRequest request);
  $async.Future<$1.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $1.GetBestMainchainBlockHashRequest request);
  $async.Future<$1.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $1.GetBestSidechainBlockHashRequest request);
  $async.Future<$1.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $1.GetBmmInclusionsRequest request);
  $async.Future<$1.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $1.GetWalletUtxosRequest request);
  $async.Future<$1.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $1.ListUtxosRequest request);
  $async.Future<$1.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $1.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$1.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $1.GenerateMnemonicRequest request);
  $async.Future<$1.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $1.SetSeedFromMnemonicRequest request);
  $async.Future<$1.CallRawResponse> callRaw($pb.ServerContext ctx, $1.CallRawRequest request);
  $async.Future<$1.GetBitNameDataResponse> getBitNameData($pb.ServerContext ctx, $1.GetBitNameDataRequest request);
  $async.Future<$1.ListBitNamesResponse> listBitNames($pb.ServerContext ctx, $1.ListBitNamesRequest request);
  $async.Future<$1.RegisterBitNameResponse> registerBitName($pb.ServerContext ctx, $1.RegisterBitNameRequest request);
  $async.Future<$1.ReserveBitNameResponse> reserveBitName($pb.ServerContext ctx, $1.ReserveBitNameRequest request);
  $async.Future<$1.GetNewEncryptionKeyResponse> getNewEncryptionKey(
      $pb.ServerContext ctx, $1.GetNewEncryptionKeyRequest request);
  $async.Future<$1.GetNewVerifyingKeyResponse> getNewVerifyingKey(
      $pb.ServerContext ctx, $1.GetNewVerifyingKeyRequest request);
  $async.Future<$1.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $1.DecryptMsgRequest request);
  $async.Future<$1.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $1.EncryptMsgRequest request);
  $async.Future<$1.GetPaymailResponse> getPaymail($pb.ServerContext ctx, $1.GetPaymailRequest request);
  $async.Future<$1.ResolveCommitResponse> resolveCommit($pb.ServerContext ctx, $1.ResolveCommitRequest request);
  $async.Future<$1.SignArbitraryMsgResponse> signArbitraryMsg(
      $pb.ServerContext ctx, $1.SignArbitraryMsgRequest request);
  $async.Future<$1.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
      $pb.ServerContext ctx, $1.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$1.GetWalletAddressesResponse> getWalletAddresses(
      $pb.ServerContext ctx, $1.GetWalletAddressesRequest request);
  $async.Future<$1.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $1.MyUtxosRequest request);
  $async.Future<$1.OpenapiSchemaResponse> openapiSchema($pb.ServerContext ctx, $1.OpenapiSchemaRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $1.GetBalanceRequest();
      case 'GetBlockCount':
        return $1.GetBlockCountRequest();
      case 'Stop':
        return $1.StopRequest();
      case 'GetNewAddress':
        return $1.GetNewAddressRequest();
      case 'Withdraw':
        return $1.WithdrawRequest();
      case 'Transfer':
        return $1.TransferRequest();
      case 'GetSidechainWealth':
        return $1.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $1.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $1.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $1.ConnectPeerRequest();
      case 'ListPeers':
        return $1.ListPeersRequest();
      case 'Mine':
        return $1.MineRequest();
      case 'GetBlock':
        return $1.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $1.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $1.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $1.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $1.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $1.ListUtxosRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $1.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $1.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $1.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $1.CallRawRequest();
      case 'GetBitNameData':
        return $1.GetBitNameDataRequest();
      case 'ListBitNames':
        return $1.ListBitNamesRequest();
      case 'RegisterBitName':
        return $1.RegisterBitNameRequest();
      case 'ReserveBitName':
        return $1.ReserveBitNameRequest();
      case 'GetNewEncryptionKey':
        return $1.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey':
        return $1.GetNewVerifyingKeyRequest();
      case 'DecryptMsg':
        return $1.DecryptMsgRequest();
      case 'EncryptMsg':
        return $1.EncryptMsgRequest();
      case 'GetPaymail':
        return $1.GetPaymailRequest();
      case 'ResolveCommit':
        return $1.ResolveCommitRequest();
      case 'SignArbitraryMsg':
        return $1.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr':
        return $1.SignArbitraryMsgAsAddrRequest();
      case 'GetWalletAddresses':
        return $1.GetWalletAddressesRequest();
      case 'MyUtxos':
        return $1.MyUtxosRequest();
      case 'OpenapiSchema':
        return $1.OpenapiSchemaRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return this.getBalance(ctx, request as $1.GetBalanceRequest);
      case 'GetBlockCount':
        return this.getBlockCount(ctx, request as $1.GetBlockCountRequest);
      case 'Stop':
        return this.stop(ctx, request as $1.StopRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $1.GetNewAddressRequest);
      case 'Withdraw':
        return this.withdraw(ctx, request as $1.WithdrawRequest);
      case 'Transfer':
        return this.transfer(ctx, request as $1.TransferRequest);
      case 'GetSidechainWealth':
        return this.getSidechainWealth(ctx, request as $1.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $1.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return this.getPendingWithdrawalBundle(ctx, request as $1.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return this.connectPeer(ctx, request as $1.ConnectPeerRequest);
      case 'ListPeers':
        return this.listPeers(ctx, request as $1.ListPeersRequest);
      case 'Mine':
        return this.mine(ctx, request as $1.MineRequest);
      case 'GetBlock':
        return this.getBlock(ctx, request as $1.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return this.getBestMainchainBlockHash(ctx, request as $1.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return this.getBestSidechainBlockHash(ctx, request as $1.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return this.getBmmInclusions(ctx, request as $1.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return this.getWalletUtxos(ctx, request as $1.GetWalletUtxosRequest);
      case 'ListUtxos':
        return this.listUtxos(ctx, request as $1.ListUtxosRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return this
            .getLatestFailedWithdrawalBundleHeight(ctx, request as $1.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return this.generateMnemonic(ctx, request as $1.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return this.setSeedFromMnemonic(ctx, request as $1.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return this.callRaw(ctx, request as $1.CallRawRequest);
      case 'GetBitNameData':
        return this.getBitNameData(ctx, request as $1.GetBitNameDataRequest);
      case 'ListBitNames':
        return this.listBitNames(ctx, request as $1.ListBitNamesRequest);
      case 'RegisterBitName':
        return this.registerBitName(ctx, request as $1.RegisterBitNameRequest);
      case 'ReserveBitName':
        return this.reserveBitName(ctx, request as $1.ReserveBitNameRequest);
      case 'GetNewEncryptionKey':
        return this.getNewEncryptionKey(ctx, request as $1.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey':
        return this.getNewVerifyingKey(ctx, request as $1.GetNewVerifyingKeyRequest);
      case 'DecryptMsg':
        return this.decryptMsg(ctx, request as $1.DecryptMsgRequest);
      case 'EncryptMsg':
        return this.encryptMsg(ctx, request as $1.EncryptMsgRequest);
      case 'GetPaymail':
        return this.getPaymail(ctx, request as $1.GetPaymailRequest);
      case 'ResolveCommit':
        return this.resolveCommit(ctx, request as $1.ResolveCommitRequest);
      case 'SignArbitraryMsg':
        return this.signArbitraryMsg(ctx, request as $1.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr':
        return this.signArbitraryMsgAsAddr(ctx, request as $1.SignArbitraryMsgAsAddrRequest);
      case 'GetWalletAddresses':
        return this.getWalletAddresses(ctx, request as $1.GetWalletAddressesRequest);
      case 'MyUtxos':
        return this.myUtxos(ctx, request as $1.MyUtxosRequest);
      case 'OpenapiSchema':
        return this.openapiSchema(ctx, request as $1.OpenapiSchemaRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitnamesServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitnamesServiceBase$messageJson;
}
