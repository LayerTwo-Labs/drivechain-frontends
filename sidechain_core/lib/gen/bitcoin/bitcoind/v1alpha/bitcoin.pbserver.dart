// This is a generated file - do not edit.
//
// Generated from bitcoin/bitcoind/v1alpha/bitcoin.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $3;

import 'bitcoin.pb.dart' as $4;
import 'bitcoin.pbjson.dart';

export 'bitcoin.pb.dart';

abstract class BitcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$4.GetBlockchainInfoResponse> getBlockchainInfo(
      $pb.ServerContext ctx, $4.GetBlockchainInfoRequest request);
  $async.Future<$4.GetPeerInfoResponse> getPeerInfo($pb.ServerContext ctx, $4.GetPeerInfoRequest request);
  $async.Future<$4.GetNetworkInfoResponse> getNetworkInfo($pb.ServerContext ctx, $4.GetNetworkInfoRequest request);
  $async.Future<$4.GetNetTotalsResponse> getNetTotals($pb.ServerContext ctx, $4.GetNetTotalsRequest request);
  $async.Future<$4.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $4.GetTransactionRequest request);
  $async.Future<$4.ListSinceBlockResponse> listSinceBlock($pb.ServerContext ctx, $4.ListSinceBlockRequest request);
  $async.Future<$4.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $4.GetNewAddressRequest request);
  $async.Future<$4.GetWalletInfoResponse> getWalletInfo($pb.ServerContext ctx, $4.GetWalletInfoRequest request);
  $async.Future<$4.GetBalancesResponse> getBalances($pb.ServerContext ctx, $4.GetBalancesRequest request);
  $async.Future<$4.SendResponse> send($pb.ServerContext ctx, $4.SendRequest request);
  $async.Future<$4.SendToAddressResponse> sendToAddress($pb.ServerContext ctx, $4.SendToAddressRequest request);
  $async.Future<$4.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $4.BumpFeeRequest request);
  $async.Future<$4.EstimateSmartFeeResponse> estimateSmartFee(
      $pb.ServerContext ctx, $4.EstimateSmartFeeRequest request);
  $async.Future<$4.ImportDescriptorsResponse> importDescriptors(
      $pb.ServerContext ctx, $4.ImportDescriptorsRequest request);
  $async.Future<$4.ListDescriptorsResponse> listDescriptors($pb.ServerContext ctx, $4.ListDescriptorsRequest request);
  $async.Future<$4.ListWalletsResponse> listWallets($pb.ServerContext ctx, $3.Empty request);
  $async.Future<$4.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $4.ListUnspentRequest request);
  $async.Future<$4.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $4.ListTransactionsRequest request);
  $async.Future<$4.GetDescriptorInfoResponse> getDescriptorInfo(
      $pb.ServerContext ctx, $4.GetDescriptorInfoRequest request);
  $async.Future<$4.GetAddressInfoResponse> getAddressInfo($pb.ServerContext ctx, $4.GetAddressInfoRequest request);
  $async.Future<$4.GetRawMempoolResponse> getRawMempool($pb.ServerContext ctx, $4.GetRawMempoolRequest request);
  $async.Future<$4.GetRawTransactionResponse> getRawTransaction(
      $pb.ServerContext ctx, $4.GetRawTransactionRequest request);
  $async.Future<$4.DecodeRawTransactionResponse> decodeRawTransaction(
      $pb.ServerContext ctx, $4.DecodeRawTransactionRequest request);
  $async.Future<$4.CreateRawTransactionResponse> createRawTransaction(
      $pb.ServerContext ctx, $4.CreateRawTransactionRequest request);
  $async.Future<$4.SendRawTransactionResponse> sendRawTransaction(
      $pb.ServerContext ctx, $4.SendRawTransactionRequest request);
  $async.Future<$4.SignRawTransactionWithWalletResponse> signRawTransactionWithWallet(
      $pb.ServerContext ctx, $4.SignRawTransactionWithWalletRequest request);
  $async.Future<$4.GetBlockResponse> getBlock($pb.ServerContext ctx, $4.GetBlockRequest request);
  $async.Future<$4.GetBlockHashResponse> getBlockHash($pb.ServerContext ctx, $4.GetBlockHashRequest request);
  $async.Future<$4.CreateWalletResponse> createWallet($pb.ServerContext ctx, $4.CreateWalletRequest request);
  $async.Future<$4.LoadWalletResponse> loadWallet($pb.ServerContext ctx, $4.LoadWalletRequest request);
  $async.Future<$4.BackupWalletResponse> backupWallet($pb.ServerContext ctx, $4.BackupWalletRequest request);
  $async.Future<$4.UnloadWalletResponse> unloadWallet($pb.ServerContext ctx, $4.UnloadWalletRequest request);
  $async.Future<$4.RescanBlockchainResponse> rescanBlockchain(
      $pb.ServerContext ctx, $4.RescanBlockchainRequest request);
  $async.Future<$4.AbortRescanResponse> abortRescan($pb.ServerContext ctx, $4.AbortRescanRequest request);
  $async.Future<$4.KeyPoolRefillResponse> keyPoolRefill($pb.ServerContext ctx, $4.KeyPoolRefillRequest request);
  $async.Future<$4.GetAccountResponse> getAccount($pb.ServerContext ctx, $4.GetAccountRequest request);
  $async.Future<$4.SetAccountResponse> setAccount($pb.ServerContext ctx, $4.SetAccountRequest request);
  $async.Future<$4.GetAddressesByAccountResponse> getAddressesByAccount(
      $pb.ServerContext ctx, $4.GetAddressesByAccountRequest request);
  $async.Future<$4.ListAccountsResponse> listAccounts($pb.ServerContext ctx, $4.ListAccountsRequest request);
  $async.Future<$4.CreateMultisigResponse> createMultisig($pb.ServerContext ctx, $4.CreateMultisigRequest request);
  $async.Future<$4.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $4.CreatePsbtRequest request);
  $async.Future<$4.DecodePsbtResponse> decodePsbt($pb.ServerContext ctx, $4.DecodePsbtRequest request);
  $async.Future<$4.AnalyzePsbtResponse> analyzePsbt($pb.ServerContext ctx, $4.AnalyzePsbtRequest request);
  $async.Future<$4.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $4.CombinePsbtRequest request);
  $async.Future<$4.UtxoUpdatePsbtResponse> utxoUpdatePsbt($pb.ServerContext ctx, $4.UtxoUpdatePsbtRequest request);
  $async.Future<$4.JoinPsbtsResponse> joinPsbts($pb.ServerContext ctx, $4.JoinPsbtsRequest request);
  $async.Future<$4.TestMempoolAcceptResponse> testMempoolAccept(
      $pb.ServerContext ctx, $4.TestMempoolAcceptRequest request);
  $async.Future<$4.GetZmqNotificationsResponse> getZmqNotifications($pb.ServerContext ctx, $3.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockchainInfo':
        return $4.GetBlockchainInfoRequest();
      case 'GetPeerInfo':
        return $4.GetPeerInfoRequest();
      case 'GetNetworkInfo':
        return $4.GetNetworkInfoRequest();
      case 'GetNetTotals':
        return $4.GetNetTotalsRequest();
      case 'GetTransaction':
        return $4.GetTransactionRequest();
      case 'ListSinceBlock':
        return $4.ListSinceBlockRequest();
      case 'GetNewAddress':
        return $4.GetNewAddressRequest();
      case 'GetWalletInfo':
        return $4.GetWalletInfoRequest();
      case 'GetBalances':
        return $4.GetBalancesRequest();
      case 'Send':
        return $4.SendRequest();
      case 'SendToAddress':
        return $4.SendToAddressRequest();
      case 'BumpFee':
        return $4.BumpFeeRequest();
      case 'EstimateSmartFee':
        return $4.EstimateSmartFeeRequest();
      case 'ImportDescriptors':
        return $4.ImportDescriptorsRequest();
      case 'ListDescriptors':
        return $4.ListDescriptorsRequest();
      case 'ListWallets':
        return $3.Empty();
      case 'ListUnspent':
        return $4.ListUnspentRequest();
      case 'ListTransactions':
        return $4.ListTransactionsRequest();
      case 'GetDescriptorInfo':
        return $4.GetDescriptorInfoRequest();
      case 'GetAddressInfo':
        return $4.GetAddressInfoRequest();
      case 'GetRawMempool':
        return $4.GetRawMempoolRequest();
      case 'GetRawTransaction':
        return $4.GetRawTransactionRequest();
      case 'DecodeRawTransaction':
        return $4.DecodeRawTransactionRequest();
      case 'CreateRawTransaction':
        return $4.CreateRawTransactionRequest();
      case 'SendRawTransaction':
        return $4.SendRawTransactionRequest();
      case 'SignRawTransactionWithWallet':
        return $4.SignRawTransactionWithWalletRequest();
      case 'GetBlock':
        return $4.GetBlockRequest();
      case 'GetBlockHash':
        return $4.GetBlockHashRequest();
      case 'CreateWallet':
        return $4.CreateWalletRequest();
      case 'LoadWallet':
        return $4.LoadWalletRequest();
      case 'BackupWallet':
        return $4.BackupWalletRequest();
      case 'UnloadWallet':
        return $4.UnloadWalletRequest();
      case 'RescanBlockchain':
        return $4.RescanBlockchainRequest();
      case 'AbortRescan':
        return $4.AbortRescanRequest();
      case 'KeyPoolRefill':
        return $4.KeyPoolRefillRequest();
      case 'GetAccount':
        return $4.GetAccountRequest();
      case 'SetAccount':
        return $4.SetAccountRequest();
      case 'GetAddressesByAccount':
        return $4.GetAddressesByAccountRequest();
      case 'ListAccounts':
        return $4.ListAccountsRequest();
      case 'CreateMultisig':
        return $4.CreateMultisigRequest();
      case 'CreatePsbt':
        return $4.CreatePsbtRequest();
      case 'DecodePsbt':
        return $4.DecodePsbtRequest();
      case 'AnalyzePsbt':
        return $4.AnalyzePsbtRequest();
      case 'CombinePsbt':
        return $4.CombinePsbtRequest();
      case 'UtxoUpdatePsbt':
        return $4.UtxoUpdatePsbtRequest();
      case 'JoinPsbts':
        return $4.JoinPsbtsRequest();
      case 'TestMempoolAccept':
        return $4.TestMempoolAcceptRequest();
      case 'GetZmqNotifications':
        return $3.Empty();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockchainInfo':
        return getBlockchainInfo(ctx, request as $4.GetBlockchainInfoRequest);
      case 'GetPeerInfo':
        return getPeerInfo(ctx, request as $4.GetPeerInfoRequest);
      case 'GetNetworkInfo':
        return getNetworkInfo(ctx, request as $4.GetNetworkInfoRequest);
      case 'GetNetTotals':
        return getNetTotals(ctx, request as $4.GetNetTotalsRequest);
      case 'GetTransaction':
        return getTransaction(ctx, request as $4.GetTransactionRequest);
      case 'ListSinceBlock':
        return listSinceBlock(ctx, request as $4.ListSinceBlockRequest);
      case 'GetNewAddress':
        return getNewAddress(ctx, request as $4.GetNewAddressRequest);
      case 'GetWalletInfo':
        return getWalletInfo(ctx, request as $4.GetWalletInfoRequest);
      case 'GetBalances':
        return getBalances(ctx, request as $4.GetBalancesRequest);
      case 'Send':
        return send(ctx, request as $4.SendRequest);
      case 'SendToAddress':
        return sendToAddress(ctx, request as $4.SendToAddressRequest);
      case 'BumpFee':
        return bumpFee(ctx, request as $4.BumpFeeRequest);
      case 'EstimateSmartFee':
        return estimateSmartFee(ctx, request as $4.EstimateSmartFeeRequest);
      case 'ImportDescriptors':
        return importDescriptors(ctx, request as $4.ImportDescriptorsRequest);
      case 'ListDescriptors':
        return listDescriptors(ctx, request as $4.ListDescriptorsRequest);
      case 'ListWallets':
        return listWallets(ctx, request as $3.Empty);
      case 'ListUnspent':
        return listUnspent(ctx, request as $4.ListUnspentRequest);
      case 'ListTransactions':
        return listTransactions(ctx, request as $4.ListTransactionsRequest);
      case 'GetDescriptorInfo':
        return getDescriptorInfo(ctx, request as $4.GetDescriptorInfoRequest);
      case 'GetAddressInfo':
        return getAddressInfo(ctx, request as $4.GetAddressInfoRequest);
      case 'GetRawMempool':
        return getRawMempool(ctx, request as $4.GetRawMempoolRequest);
      case 'GetRawTransaction':
        return getRawTransaction(ctx, request as $4.GetRawTransactionRequest);
      case 'DecodeRawTransaction':
        return decodeRawTransaction(ctx, request as $4.DecodeRawTransactionRequest);
      case 'CreateRawTransaction':
        return createRawTransaction(ctx, request as $4.CreateRawTransactionRequest);
      case 'SendRawTransaction':
        return sendRawTransaction(ctx, request as $4.SendRawTransactionRequest);
      case 'SignRawTransactionWithWallet':
        return signRawTransactionWithWallet(ctx, request as $4.SignRawTransactionWithWalletRequest);
      case 'GetBlock':
        return getBlock(ctx, request as $4.GetBlockRequest);
      case 'GetBlockHash':
        return getBlockHash(ctx, request as $4.GetBlockHashRequest);
      case 'CreateWallet':
        return createWallet(ctx, request as $4.CreateWalletRequest);
      case 'LoadWallet':
        return loadWallet(ctx, request as $4.LoadWalletRequest);
      case 'BackupWallet':
        return backupWallet(ctx, request as $4.BackupWalletRequest);
      case 'UnloadWallet':
        return unloadWallet(ctx, request as $4.UnloadWalletRequest);
      case 'RescanBlockchain':
        return rescanBlockchain(ctx, request as $4.RescanBlockchainRequest);
      case 'AbortRescan':
        return abortRescan(ctx, request as $4.AbortRescanRequest);
      case 'KeyPoolRefill':
        return keyPoolRefill(ctx, request as $4.KeyPoolRefillRequest);
      case 'GetAccount':
        return getAccount(ctx, request as $4.GetAccountRequest);
      case 'SetAccount':
        return setAccount(ctx, request as $4.SetAccountRequest);
      case 'GetAddressesByAccount':
        return getAddressesByAccount(ctx, request as $4.GetAddressesByAccountRequest);
      case 'ListAccounts':
        return listAccounts(ctx, request as $4.ListAccountsRequest);
      case 'CreateMultisig':
        return createMultisig(ctx, request as $4.CreateMultisigRequest);
      case 'CreatePsbt':
        return createPsbt(ctx, request as $4.CreatePsbtRequest);
      case 'DecodePsbt':
        return decodePsbt(ctx, request as $4.DecodePsbtRequest);
      case 'AnalyzePsbt':
        return analyzePsbt(ctx, request as $4.AnalyzePsbtRequest);
      case 'CombinePsbt':
        return combinePsbt(ctx, request as $4.CombinePsbtRequest);
      case 'UtxoUpdatePsbt':
        return utxoUpdatePsbt(ctx, request as $4.UtxoUpdatePsbtRequest);
      case 'JoinPsbts':
        return joinPsbts(ctx, request as $4.JoinPsbtsRequest);
      case 'TestMempoolAccept':
        return testMempoolAccept(ctx, request as $4.TestMempoolAcceptRequest);
      case 'GetZmqNotifications':
        return getZmqNotifications(ctx, request as $3.Empty);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoinServiceBase$messageJson;
}
