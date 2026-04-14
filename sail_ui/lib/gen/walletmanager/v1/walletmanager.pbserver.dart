//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
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

import '../../google/protobuf/empty.pb.dart' as $12;
import 'walletmanager.pb.dart' as $13;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$13.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $13.GetWalletStatusRequest request);
  $async.Future<$13.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $13.GenerateWalletRequest request);
  $async.Future<$13.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $13.UnlockWalletRequest request);
  $async.Future<$13.LockWalletResponse> lockWallet($pb.ServerContext ctx, $13.LockWalletRequest request);
  $async.Future<$13.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $13.EncryptWalletRequest request);
  $async.Future<$13.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $13.ChangePasswordRequest request);
  $async.Future<$13.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $13.RemoveEncryptionRequest request);
  $async.Future<$13.ListWalletsResponse> listWallets($pb.ServerContext ctx, $13.ListWalletsRequest request);
  $async.Future<$13.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $13.SwitchWalletRequest request);
  $async.Future<$13.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $13.UpdateWalletMetadataRequest request);
  $async.Future<$13.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $13.DeleteWalletRequest request);
  $async.Future<$13.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $13.DeleteAllWalletsRequest request);
  $async.Future<$13.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $13.CreateWatchOnlyWalletRequest request);
  $async.Future<$13.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $13.CreateBitcoinCoreWalletRequest request);
  $async.Future<$13.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $13.EnsureCoreWalletsRequest request);
  $async.Future<$13.GetBalanceResponse> getBalance($pb.ServerContext ctx, $13.GetBalanceRequest request);
  $async.Future<$13.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $13.GetNewAddressRequest request);
  $async.Future<$13.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $13.SendTransactionRequest request);
  $async.Future<$13.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $13.ListTransactionsRequest request);
  $async.Future<$13.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $13.ListUnspentRequest request);
  $async.Future<$13.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $13.ListReceiveAddressesRequest request);
  $async.Future<$13.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $13.GetTransactionDetailsRequest request);
  $async.Future<$13.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $13.BumpFeeRequest request);
  $async.Future<$13.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $13.DeriveAddressesRequest request);
  $async.Future<$13.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $13.GetWalletSeedRequest request);
  $async.Future<$13.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $12.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $13.GetWalletStatusRequest();
      case 'GenerateWallet': return $13.GenerateWalletRequest();
      case 'UnlockWallet': return $13.UnlockWalletRequest();
      case 'LockWallet': return $13.LockWalletRequest();
      case 'EncryptWallet': return $13.EncryptWalletRequest();
      case 'ChangePassword': return $13.ChangePasswordRequest();
      case 'RemoveEncryption': return $13.RemoveEncryptionRequest();
      case 'ListWallets': return $13.ListWalletsRequest();
      case 'SwitchWallet': return $13.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $13.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $13.DeleteWalletRequest();
      case 'DeleteAllWallets': return $13.DeleteAllWalletsRequest();
      case 'CreateWatchOnlyWallet': return $13.CreateWatchOnlyWalletRequest();
      case 'CreateBitcoinCoreWallet': return $13.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $13.EnsureCoreWalletsRequest();
      case 'GetBalance': return $13.GetBalanceRequest();
      case 'GetNewAddress': return $13.GetNewAddressRequest();
      case 'SendTransaction': return $13.SendTransactionRequest();
      case 'ListTransactions': return $13.ListTransactionsRequest();
      case 'ListUnspent': return $13.ListUnspentRequest();
      case 'ListReceiveAddresses': return $13.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $13.GetTransactionDetailsRequest();
      case 'BumpFee': return $13.BumpFeeRequest();
      case 'DeriveAddresses': return $13.DeriveAddressesRequest();
      case 'GetWalletSeed': return $13.GetWalletSeedRequest();
      case 'WatchWalletData': return $12.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $13.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $13.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $13.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $13.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $13.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $13.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $13.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $13.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $13.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $13.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $13.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $13.DeleteAllWalletsRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $13.CreateWatchOnlyWalletRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $13.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $13.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $13.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $13.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $13.SendTransactionRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $13.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $13.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $13.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $13.GetTransactionDetailsRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $13.BumpFeeRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $13.DeriveAddressesRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $13.GetWalletSeedRequest);
      case 'WatchWalletData': return this.watchWalletData(ctx, request as $12.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

