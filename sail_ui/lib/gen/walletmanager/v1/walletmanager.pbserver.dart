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

import 'walletmanager.pb.dart' as $9;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$9.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $9.GetWalletStatusRequest request);
  $async.Future<$9.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $9.GenerateWalletRequest request);
  $async.Future<$9.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $9.UnlockWalletRequest request);
  $async.Future<$9.LockWalletResponse> lockWallet($pb.ServerContext ctx, $9.LockWalletRequest request);
  $async.Future<$9.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $9.EncryptWalletRequest request);
  $async.Future<$9.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $9.ChangePasswordRequest request);
  $async.Future<$9.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $9.RemoveEncryptionRequest request);
  $async.Future<$9.ListWalletsResponse> listWallets($pb.ServerContext ctx, $9.ListWalletsRequest request);
  $async.Future<$9.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $9.SwitchWalletRequest request);
  $async.Future<$9.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $9.UpdateWalletMetadataRequest request);
  $async.Future<$9.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $9.DeleteWalletRequest request);
  $async.Future<$9.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $9.DeleteAllWalletsRequest request);
  $async.Future<$9.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $9.CreateWatchOnlyWalletRequest request);
  $async.Future<$9.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $9.CreateBitcoinCoreWalletRequest request);
  $async.Future<$9.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $9.EnsureCoreWalletsRequest request);
  $async.Future<$9.GetBalanceResponse> getBalance($pb.ServerContext ctx, $9.GetBalanceRequest request);
  $async.Future<$9.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $9.GetNewAddressRequest request);
  $async.Future<$9.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $9.SendTransactionRequest request);
  $async.Future<$9.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $9.ListTransactionsRequest request);
  $async.Future<$9.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $9.ListUnspentRequest request);
  $async.Future<$9.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $9.ListReceiveAddressesRequest request);
  $async.Future<$9.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $9.GetTransactionDetailsRequest request);
  $async.Future<$9.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $9.BumpFeeRequest request);
  $async.Future<$9.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $9.DeriveAddressesRequest request);
  $async.Future<$9.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $9.GetWalletSeedRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $9.GetWalletStatusRequest();
      case 'GenerateWallet': return $9.GenerateWalletRequest();
      case 'UnlockWallet': return $9.UnlockWalletRequest();
      case 'LockWallet': return $9.LockWalletRequest();
      case 'EncryptWallet': return $9.EncryptWalletRequest();
      case 'ChangePassword': return $9.ChangePasswordRequest();
      case 'RemoveEncryption': return $9.RemoveEncryptionRequest();
      case 'ListWallets': return $9.ListWalletsRequest();
      case 'SwitchWallet': return $9.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $9.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $9.DeleteWalletRequest();
      case 'DeleteAllWallets': return $9.DeleteAllWalletsRequest();
      case 'CreateWatchOnlyWallet': return $9.CreateWatchOnlyWalletRequest();
      case 'CreateBitcoinCoreWallet': return $9.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $9.EnsureCoreWalletsRequest();
      case 'GetBalance': return $9.GetBalanceRequest();
      case 'GetNewAddress': return $9.GetNewAddressRequest();
      case 'SendTransaction': return $9.SendTransactionRequest();
      case 'ListTransactions': return $9.ListTransactionsRequest();
      case 'ListUnspent': return $9.ListUnspentRequest();
      case 'ListReceiveAddresses': return $9.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $9.GetTransactionDetailsRequest();
      case 'BumpFee': return $9.BumpFeeRequest();
      case 'DeriveAddresses': return $9.DeriveAddressesRequest();
      case 'GetWalletSeed': return $9.GetWalletSeedRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $9.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $9.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $9.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $9.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $9.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $9.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $9.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $9.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $9.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $9.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $9.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $9.DeleteAllWalletsRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $9.CreateWatchOnlyWalletRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $9.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $9.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $9.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $9.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $9.SendTransactionRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $9.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $9.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $9.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $9.GetTransactionDetailsRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $9.BumpFeeRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $9.DeriveAddressesRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $9.GetWalletSeedRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

