// This is a generated file - do not edit.
//
// Generated from bitnames/v1/bitnames.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'bitnames.pb.dart' as $0;
import 'bitnames.pbjson.dart';

export 'bitnames.pb.dart';

abstract class BitnamesServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetBalanceResponse> getBalance($pb.ServerContext ctx, $0.GetBalanceRequest request);
  $async.Future<$0.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $0.GetBlockCountRequest request);
  $async.Future<$0.StopResponse> stop($pb.ServerContext ctx, $0.StopRequest request);
  $async.Future<$0.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $0.GetNewAddressRequest request);
  $async.Future<$0.WithdrawResponse> withdraw($pb.ServerContext ctx, $0.WithdrawRequest request);
  $async.Future<$0.TransferResponse> transfer($pb.ServerContext ctx, $0.TransferRequest request);
  $async.Future<$0.GetSidechainWealthResponse> getSidechainWealth(
      $pb.ServerContext ctx, $0.GetSidechainWealthRequest request);
  $async.Future<$0.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $0.CreateDepositRequest request);
  $async.Future<$0.GetPendingWithdrawalBundleResponse> getPendingWithdrawalBundle(
      $pb.ServerContext ctx, $0.GetPendingWithdrawalBundleRequest request);
  $async.Future<$0.ConnectPeerResponse> connectPeer($pb.ServerContext ctx, $0.ConnectPeerRequest request);
  $async.Future<$0.ListPeersResponse> listPeers($pb.ServerContext ctx, $0.ListPeersRequest request);
  $async.Future<$0.MineResponse> mine($pb.ServerContext ctx, $0.MineRequest request);
  $async.Future<$0.GetBlockResponse> getBlock($pb.ServerContext ctx, $0.GetBlockRequest request);
  $async.Future<$0.GetBestMainchainBlockHashResponse> getBestMainchainBlockHash(
      $pb.ServerContext ctx, $0.GetBestMainchainBlockHashRequest request);
  $async.Future<$0.GetBestSidechainBlockHashResponse> getBestSidechainBlockHash(
      $pb.ServerContext ctx, $0.GetBestSidechainBlockHashRequest request);
  $async.Future<$0.GetBmmInclusionsResponse> getBmmInclusions(
      $pb.ServerContext ctx, $0.GetBmmInclusionsRequest request);
  $async.Future<$0.GetWalletUtxosResponse> getWalletUtxos($pb.ServerContext ctx, $0.GetWalletUtxosRequest request);
  $async.Future<$0.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $0.ListUtxosRequest request);
  $async.Future<$0.GetLatestFailedWithdrawalBundleHeightResponse> getLatestFailedWithdrawalBundleHeight(
      $pb.ServerContext ctx, $0.GetLatestFailedWithdrawalBundleHeightRequest request);
  $async.Future<$0.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $0.GenerateMnemonicRequest request);
  $async.Future<$0.SetSeedFromMnemonicResponse> setSeedFromMnemonic(
      $pb.ServerContext ctx, $0.SetSeedFromMnemonicRequest request);
  $async.Future<$0.CallRawResponse> callRaw($pb.ServerContext ctx, $0.CallRawRequest request);
  $async.Future<$0.GetBitNameDataResponse> getBitNameData($pb.ServerContext ctx, $0.GetBitNameDataRequest request);
  $async.Future<$0.ListBitNamesResponse> listBitNames($pb.ServerContext ctx, $0.ListBitNamesRequest request);
  $async.Future<$0.RegisterBitNameResponse> registerBitName($pb.ServerContext ctx, $0.RegisterBitNameRequest request);
  $async.Future<$0.ReserveBitNameResponse> reserveBitName($pb.ServerContext ctx, $0.ReserveBitNameRequest request);
  $async.Future<$0.GetNewEncryptionKeyResponse> getNewEncryptionKey(
      $pb.ServerContext ctx, $0.GetNewEncryptionKeyRequest request);
  $async.Future<$0.GetNewVerifyingKeyResponse> getNewVerifyingKey(
      $pb.ServerContext ctx, $0.GetNewVerifyingKeyRequest request);
  $async.Future<$0.DecryptMsgResponse> decryptMsg($pb.ServerContext ctx, $0.DecryptMsgRequest request);
  $async.Future<$0.EncryptMsgResponse> encryptMsg($pb.ServerContext ctx, $0.EncryptMsgRequest request);
  $async.Future<$0.GetPaymailResponse> getPaymail($pb.ServerContext ctx, $0.GetPaymailRequest request);
  $async.Future<$0.GetPendingPaymailResponse> getPendingPaymail(
      $pb.ServerContext ctx, $0.GetPendingPaymailRequest request);
  $async.Future<$0.GetBitNameOwnerResponse> getBitNameOwner($pb.ServerContext ctx, $0.GetBitNameOwnerRequest request);
  $async.Future<$0.ResolveCommitResponse> resolveCommit($pb.ServerContext ctx, $0.ResolveCommitRequest request);
  $async.Future<$0.ReadCommitmentResponse> readCommitment($pb.ServerContext ctx, $0.ReadCommitmentRequest request);
  $async.Future<$0.SignArbitraryMsgResponse> signArbitraryMsg(
      $pb.ServerContext ctx, $0.SignArbitraryMsgRequest request);
  $async.Future<$0.SignArbitraryMsgAsAddrResponse> signArbitraryMsgAsAddr(
      $pb.ServerContext ctx, $0.SignArbitraryMsgAsAddrRequest request);
  $async.Future<$0.GetWalletAddressesResponse> getWalletAddresses(
      $pb.ServerContext ctx, $0.GetWalletAddressesRequest request);
  $async.Future<$0.MyUtxosResponse> myUtxos($pb.ServerContext ctx, $0.MyUtxosRequest request);
  $async.Future<$0.OpenapiSchemaResponse> openapiSchema($pb.ServerContext ctx, $0.OpenapiSchemaRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBalance':
        return $0.GetBalanceRequest();
      case 'GetBlockCount':
        return $0.GetBlockCountRequest();
      case 'Stop':
        return $0.StopRequest();
      case 'GetNewAddress':
        return $0.GetNewAddressRequest();
      case 'Withdraw':
        return $0.WithdrawRequest();
      case 'Transfer':
        return $0.TransferRequest();
      case 'GetSidechainWealth':
        return $0.GetSidechainWealthRequest();
      case 'CreateDeposit':
        return $0.CreateDepositRequest();
      case 'GetPendingWithdrawalBundle':
        return $0.GetPendingWithdrawalBundleRequest();
      case 'ConnectPeer':
        return $0.ConnectPeerRequest();
      case 'ListPeers':
        return $0.ListPeersRequest();
      case 'Mine':
        return $0.MineRequest();
      case 'GetBlock':
        return $0.GetBlockRequest();
      case 'GetBestMainchainBlockHash':
        return $0.GetBestMainchainBlockHashRequest();
      case 'GetBestSidechainBlockHash':
        return $0.GetBestSidechainBlockHashRequest();
      case 'GetBmmInclusions':
        return $0.GetBmmInclusionsRequest();
      case 'GetWalletUtxos':
        return $0.GetWalletUtxosRequest();
      case 'ListUtxos':
        return $0.ListUtxosRequest();
      case 'GetLatestFailedWithdrawalBundleHeight':
        return $0.GetLatestFailedWithdrawalBundleHeightRequest();
      case 'GenerateMnemonic':
        return $0.GenerateMnemonicRequest();
      case 'SetSeedFromMnemonic':
        return $0.SetSeedFromMnemonicRequest();
      case 'CallRaw':
        return $0.CallRawRequest();
      case 'GetBitNameData':
        return $0.GetBitNameDataRequest();
      case 'ListBitNames':
        return $0.ListBitNamesRequest();
      case 'RegisterBitName':
        return $0.RegisterBitNameRequest();
      case 'ReserveBitName':
        return $0.ReserveBitNameRequest();
      case 'GetNewEncryptionKey':
        return $0.GetNewEncryptionKeyRequest();
      case 'GetNewVerifyingKey':
        return $0.GetNewVerifyingKeyRequest();
      case 'DecryptMsg':
        return $0.DecryptMsgRequest();
      case 'EncryptMsg':
        return $0.EncryptMsgRequest();
      case 'GetPaymail':
        return $0.GetPaymailRequest();
      case 'GetPendingPaymail':
        return $0.GetPendingPaymailRequest();
      case 'GetBitNameOwner':
        return $0.GetBitNameOwnerRequest();
      case 'ResolveCommit':
        return $0.ResolveCommitRequest();
      case 'ReadCommitment':
        return $0.ReadCommitmentRequest();
      case 'SignArbitraryMsg':
        return $0.SignArbitraryMsgRequest();
      case 'SignArbitraryMsgAsAddr':
        return $0.SignArbitraryMsgAsAddrRequest();
      case 'GetWalletAddresses':
        return $0.GetWalletAddressesRequest();
      case 'MyUtxos':
        return $0.MyUtxosRequest();
      case 'OpenapiSchema':
        return $0.OpenapiSchemaRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBalance':
        return getBalance(ctx, request as $0.GetBalanceRequest);
      case 'GetBlockCount':
        return getBlockCount(ctx, request as $0.GetBlockCountRequest);
      case 'Stop':
        return stop(ctx, request as $0.StopRequest);
      case 'GetNewAddress':
        return getNewAddress(ctx, request as $0.GetNewAddressRequest);
      case 'Withdraw':
        return withdraw(ctx, request as $0.WithdrawRequest);
      case 'Transfer':
        return transfer(ctx, request as $0.TransferRequest);
      case 'GetSidechainWealth':
        return getSidechainWealth(ctx, request as $0.GetSidechainWealthRequest);
      case 'CreateDeposit':
        return createDeposit(ctx, request as $0.CreateDepositRequest);
      case 'GetPendingWithdrawalBundle':
        return getPendingWithdrawalBundle(ctx, request as $0.GetPendingWithdrawalBundleRequest);
      case 'ConnectPeer':
        return connectPeer(ctx, request as $0.ConnectPeerRequest);
      case 'ListPeers':
        return listPeers(ctx, request as $0.ListPeersRequest);
      case 'Mine':
        return mine(ctx, request as $0.MineRequest);
      case 'GetBlock':
        return getBlock(ctx, request as $0.GetBlockRequest);
      case 'GetBestMainchainBlockHash':
        return getBestMainchainBlockHash(ctx, request as $0.GetBestMainchainBlockHashRequest);
      case 'GetBestSidechainBlockHash':
        return getBestSidechainBlockHash(ctx, request as $0.GetBestSidechainBlockHashRequest);
      case 'GetBmmInclusions':
        return getBmmInclusions(ctx, request as $0.GetBmmInclusionsRequest);
      case 'GetWalletUtxos':
        return getWalletUtxos(ctx, request as $0.GetWalletUtxosRequest);
      case 'ListUtxos':
        return listUtxos(ctx, request as $0.ListUtxosRequest);
      case 'GetLatestFailedWithdrawalBundleHeight':
        return getLatestFailedWithdrawalBundleHeight(ctx, request as $0.GetLatestFailedWithdrawalBundleHeightRequest);
      case 'GenerateMnemonic':
        return generateMnemonic(ctx, request as $0.GenerateMnemonicRequest);
      case 'SetSeedFromMnemonic':
        return setSeedFromMnemonic(ctx, request as $0.SetSeedFromMnemonicRequest);
      case 'CallRaw':
        return callRaw(ctx, request as $0.CallRawRequest);
      case 'GetBitNameData':
        return getBitNameData(ctx, request as $0.GetBitNameDataRequest);
      case 'ListBitNames':
        return listBitNames(ctx, request as $0.ListBitNamesRequest);
      case 'RegisterBitName':
        return registerBitName(ctx, request as $0.RegisterBitNameRequest);
      case 'ReserveBitName':
        return reserveBitName(ctx, request as $0.ReserveBitNameRequest);
      case 'GetNewEncryptionKey':
        return getNewEncryptionKey(ctx, request as $0.GetNewEncryptionKeyRequest);
      case 'GetNewVerifyingKey':
        return getNewVerifyingKey(ctx, request as $0.GetNewVerifyingKeyRequest);
      case 'DecryptMsg':
        return decryptMsg(ctx, request as $0.DecryptMsgRequest);
      case 'EncryptMsg':
        return encryptMsg(ctx, request as $0.EncryptMsgRequest);
      case 'GetPaymail':
        return getPaymail(ctx, request as $0.GetPaymailRequest);
      case 'GetPendingPaymail':
        return getPendingPaymail(ctx, request as $0.GetPendingPaymailRequest);
      case 'GetBitNameOwner':
        return getBitNameOwner(ctx, request as $0.GetBitNameOwnerRequest);
      case 'ResolveCommit':
        return resolveCommit(ctx, request as $0.ResolveCommitRequest);
      case 'ReadCommitment':
        return readCommitment(ctx, request as $0.ReadCommitmentRequest);
      case 'SignArbitraryMsg':
        return signArbitraryMsg(ctx, request as $0.SignArbitraryMsgRequest);
      case 'SignArbitraryMsgAsAddr':
        return signArbitraryMsgAsAddr(ctx, request as $0.SignArbitraryMsgAsAddrRequest);
      case 'GetWalletAddresses':
        return getWalletAddresses(ctx, request as $0.GetWalletAddressesRequest);
      case 'MyUtxos':
        return myUtxos(ctx, request as $0.MyUtxosRequest);
      case 'OpenapiSchema':
        return openapiSchema(ctx, request as $0.OpenapiSchemaRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitnamesServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitnamesServiceBase$messageJson;
}
