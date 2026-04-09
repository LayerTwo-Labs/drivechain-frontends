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

import 'walletmanager.pb.dart' as $12;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$12.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $12.GetWalletStatusRequest request);
  $async.Future<$12.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $12.GenerateWalletRequest request);
  $async.Future<$12.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $12.UnlockWalletRequest request);
  $async.Future<$12.LockWalletResponse> lockWallet($pb.ServerContext ctx, $12.LockWalletRequest request);
  $async.Future<$12.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $12.EncryptWalletRequest request);
  $async.Future<$12.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $12.ChangePasswordRequest request);
  $async.Future<$12.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $12.RemoveEncryptionRequest request);
  $async.Future<$12.ListWalletsResponse> listWallets($pb.ServerContext ctx, $12.ListWalletsRequest request);
  $async.Future<$12.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $12.SwitchWalletRequest request);
  $async.Future<$12.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $12.UpdateWalletMetadataRequest request);
  $async.Future<$12.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $12.DeleteWalletRequest request);
  $async.Future<$12.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $12.DeleteAllWalletsRequest request);
  $async.Future<$12.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $12.CreateWatchOnlyWalletRequest request);
  $async.Future<$12.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $12.CreateBitcoinCoreWalletRequest request);
  $async.Future<$12.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $12.EnsureCoreWalletsRequest request);
  $async.Future<$12.GetBalanceResponse> getBalance($pb.ServerContext ctx, $12.GetBalanceRequest request);
  $async.Future<$12.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $12.GetNewAddressRequest request);
  $async.Future<$12.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $12.SendTransactionRequest request);
  $async.Future<$12.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $12.ListTransactionsRequest request);
  $async.Future<$12.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $12.ListUnspentRequest request);
  $async.Future<$12.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $12.ListReceiveAddressesRequest request);
  $async.Future<$12.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $12.GetTransactionDetailsRequest request);
  $async.Future<$12.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $12.BumpFeeRequest request);
  $async.Future<$12.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $12.DeriveAddressesRequest request);
  $async.Future<$12.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $12.GetWalletSeedRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $12.GetWalletStatusRequest();
      case 'GenerateWallet': return $12.GenerateWalletRequest();
      case 'UnlockWallet': return $12.UnlockWalletRequest();
      case 'LockWallet': return $12.LockWalletRequest();
      case 'EncryptWallet': return $12.EncryptWalletRequest();
      case 'ChangePassword': return $12.ChangePasswordRequest();
      case 'RemoveEncryption': return $12.RemoveEncryptionRequest();
      case 'ListWallets': return $12.ListWalletsRequest();
      case 'SwitchWallet': return $12.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $12.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $12.DeleteWalletRequest();
      case 'DeleteAllWallets': return $12.DeleteAllWalletsRequest();
      case 'CreateWatchOnlyWallet': return $12.CreateWatchOnlyWalletRequest();
      case 'CreateBitcoinCoreWallet': return $12.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $12.EnsureCoreWalletsRequest();
      case 'GetBalance': return $12.GetBalanceRequest();
      case 'GetNewAddress': return $12.GetNewAddressRequest();
      case 'SendTransaction': return $12.SendTransactionRequest();
      case 'ListTransactions': return $12.ListTransactionsRequest();
      case 'ListUnspent': return $12.ListUnspentRequest();
      case 'ListReceiveAddresses': return $12.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $12.GetTransactionDetailsRequest();
      case 'BumpFee': return $12.BumpFeeRequest();
      case 'DeriveAddresses': return $12.DeriveAddressesRequest();
      case 'GetWalletSeed': return $12.GetWalletSeedRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $12.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $12.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $12.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $12.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $12.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $12.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $12.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $12.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $12.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $12.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $12.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $12.DeleteAllWalletsRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $12.CreateWatchOnlyWalletRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $12.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $12.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $12.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $12.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $12.SendTransactionRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $12.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $12.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $12.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $12.GetTransactionDetailsRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $12.BumpFeeRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $12.DeriveAddressesRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $12.GetWalletSeedRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

