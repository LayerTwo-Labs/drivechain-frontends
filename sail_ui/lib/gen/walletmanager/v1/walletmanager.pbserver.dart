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

import 'walletmanager.pb.dart' as $5;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$5.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $5.GetWalletStatusRequest request);
  $async.Future<$5.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $5.GenerateWalletRequest request);
  $async.Future<$5.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $5.UnlockWalletRequest request);
  $async.Future<$5.LockWalletResponse> lockWallet($pb.ServerContext ctx, $5.LockWalletRequest request);
  $async.Future<$5.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $5.EncryptWalletRequest request);
  $async.Future<$5.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $5.ChangePasswordRequest request);
  $async.Future<$5.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $5.RemoveEncryptionRequest request);
  $async.Future<$5.ListWalletsResponse> listWallets($pb.ServerContext ctx, $5.ListWalletsRequest request);
  $async.Future<$5.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $5.SwitchWalletRequest request);
  $async.Future<$5.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $5.UpdateWalletMetadataRequest request);
  $async.Future<$5.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $5.DeleteWalletRequest request);
  $async.Future<$5.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $5.DeleteAllWalletsRequest request);
  $async.Future<$5.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $5.CreateWatchOnlyWalletRequest request);
  $async.Future<$5.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $5.CreateBitcoinCoreWalletRequest request);
  $async.Future<$5.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $5.EnsureCoreWalletsRequest request);
  $async.Future<$5.GetBalanceResponse> getBalance($pb.ServerContext ctx, $5.GetBalanceRequest request);
  $async.Future<$5.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $5.GetNewAddressRequest request);
  $async.Future<$5.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $5.SendTransactionRequest request);
  $async.Future<$5.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $5.ListTransactionsRequest request);
  $async.Future<$5.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $5.ListUnspentRequest request);
  $async.Future<$5.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $5.ListReceiveAddressesRequest request);
  $async.Future<$5.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $5.GetTransactionDetailsRequest request);
  $async.Future<$5.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $5.BumpFeeRequest request);
  $async.Future<$5.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $5.DeriveAddressesRequest request);
  $async.Future<$5.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $5.GetWalletSeedRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $5.GetWalletStatusRequest();
      case 'GenerateWallet': return $5.GenerateWalletRequest();
      case 'UnlockWallet': return $5.UnlockWalletRequest();
      case 'LockWallet': return $5.LockWalletRequest();
      case 'EncryptWallet': return $5.EncryptWalletRequest();
      case 'ChangePassword': return $5.ChangePasswordRequest();
      case 'RemoveEncryption': return $5.RemoveEncryptionRequest();
      case 'ListWallets': return $5.ListWalletsRequest();
      case 'SwitchWallet': return $5.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $5.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $5.DeleteWalletRequest();
      case 'DeleteAllWallets': return $5.DeleteAllWalletsRequest();
      case 'CreateWatchOnlyWallet': return $5.CreateWatchOnlyWalletRequest();
      case 'CreateBitcoinCoreWallet': return $5.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $5.EnsureCoreWalletsRequest();
      case 'GetBalance': return $5.GetBalanceRequest();
      case 'GetNewAddress': return $5.GetNewAddressRequest();
      case 'SendTransaction': return $5.SendTransactionRequest();
      case 'ListTransactions': return $5.ListTransactionsRequest();
      case 'ListUnspent': return $5.ListUnspentRequest();
      case 'ListReceiveAddresses': return $5.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $5.GetTransactionDetailsRequest();
      case 'BumpFee': return $5.BumpFeeRequest();
      case 'DeriveAddresses': return $5.DeriveAddressesRequest();
      case 'GetWalletSeed': return $5.GetWalletSeedRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $5.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $5.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $5.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $5.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $5.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $5.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $5.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $5.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $5.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $5.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $5.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $5.DeleteAllWalletsRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $5.CreateWatchOnlyWalletRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $5.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $5.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $5.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $5.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $5.SendTransactionRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $5.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $5.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $5.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $5.GetTransactionDetailsRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $5.BumpFeeRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $5.DeriveAddressesRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $5.GetWalletSeedRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

