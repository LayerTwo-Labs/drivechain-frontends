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

import '../../google/protobuf/empty.pb.dart' as $13;
import 'walletmanager.pb.dart' as $14;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$14.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $14.GetWalletStatusRequest request);
  $async.Future<$14.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $14.GenerateWalletRequest request);
  $async.Future<$14.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $14.UnlockWalletRequest request);
  $async.Future<$14.LockWalletResponse> lockWallet($pb.ServerContext ctx, $14.LockWalletRequest request);
  $async.Future<$14.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $14.EncryptWalletRequest request);
  $async.Future<$14.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $14.ChangePasswordRequest request);
  $async.Future<$14.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $14.RemoveEncryptionRequest request);
  $async.Future<$14.ListWalletsResponse> listWallets($pb.ServerContext ctx, $14.ListWalletsRequest request);
  $async.Future<$14.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $14.SwitchWalletRequest request);
  $async.Future<$14.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $14.UpdateWalletMetadataRequest request);
  $async.Future<$14.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $14.DeleteWalletRequest request);
  $async.Future<$14.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $14.DeleteAllWalletsRequest request);
  $async.Future<$14.ListWalletBackupsResponse> listWalletBackups($pb.ServerContext ctx, $14.ListWalletBackupsRequest request);
  $async.Future<$14.RestoreWalletBackupResponse> restoreWalletBackup($pb.ServerContext ctx, $14.RestoreWalletBackupRequest request);
  $async.Future<$14.RestoreWalletBackupProgressResponse> restoreWalletBackupStream($pb.ServerContext ctx, $14.RestoreWalletBackupRequest request);
  $async.Future<$14.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $14.CreateWatchOnlyWalletRequest request);
  $async.Future<$14.CreateElectrumWalletResponse> createElectrumWallet($pb.ServerContext ctx, $14.CreateElectrumWalletRequest request);
  $async.Future<$14.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $14.CreateBitcoinCoreWalletRequest request);
  $async.Future<$14.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $14.EnsureCoreWalletsRequest request);
  $async.Future<$14.GetBalanceResponse> getBalance($pb.ServerContext ctx, $14.GetBalanceRequest request);
  $async.Future<$14.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $14.GetNewAddressRequest request);
  $async.Future<$14.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $14.SendTransactionRequest request);
  $async.Future<$14.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $14.ListTransactionsRequest request);
  $async.Future<$14.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $14.ListUnspentRequest request);
  $async.Future<$14.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $14.ListReceiveAddressesRequest request);
  $async.Future<$14.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $14.GetTransactionDetailsRequest request);
  $async.Future<$14.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $14.BumpFeeRequest request);
  $async.Future<$14.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $14.CreateCpfpRequest request);
  $async.Future<$14.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $14.DeriveAddressesRequest request);
  $async.Future<$14.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $14.CreatePsbtRequest request);
  $async.Future<$14.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $14.SignPsbtRequest request);
  $async.Future<$14.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $14.CombinePsbtRequest request);
  $async.Future<$14.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $14.FinalizePsbtRequest request);
  $async.Future<$14.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $14.GetWalletSeedRequest request);
  $async.Future<$14.ListCoreVariantsResponse> listCoreVariants($pb.ServerContext ctx, $14.ListCoreVariantsRequest request);
  $async.Future<$14.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $14.GetCoreVariantRequest request);
  $async.Future<$14.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $14.SetCoreVariantRequest request);
  $async.Future<$14.GetTestSidechainsResponse> getTestSidechains($pb.ServerContext ctx, $14.GetTestSidechainsRequest request);
  $async.Future<$14.SetTestSidechainsResponse> setTestSidechains($pb.ServerContext ctx, $14.SetTestSidechainsRequest request);
  $async.Future<$14.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $13.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $14.GetWalletStatusRequest();
      case 'GenerateWallet': return $14.GenerateWalletRequest();
      case 'UnlockWallet': return $14.UnlockWalletRequest();
      case 'LockWallet': return $14.LockWalletRequest();
      case 'EncryptWallet': return $14.EncryptWalletRequest();
      case 'ChangePassword': return $14.ChangePasswordRequest();
      case 'RemoveEncryption': return $14.RemoveEncryptionRequest();
      case 'ListWallets': return $14.ListWalletsRequest();
      case 'SwitchWallet': return $14.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $14.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $14.DeleteWalletRequest();
      case 'DeleteAllWallets': return $14.DeleteAllWalletsRequest();
      case 'ListWalletBackups': return $14.ListWalletBackupsRequest();
      case 'RestoreWalletBackup': return $14.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream': return $14.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet': return $14.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet': return $14.CreateElectrumWalletRequest();
      case 'CreateBitcoinCoreWallet': return $14.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $14.EnsureCoreWalletsRequest();
      case 'GetBalance': return $14.GetBalanceRequest();
      case 'GetNewAddress': return $14.GetNewAddressRequest();
      case 'SendTransaction': return $14.SendTransactionRequest();
      case 'ListTransactions': return $14.ListTransactionsRequest();
      case 'ListUnspent': return $14.ListUnspentRequest();
      case 'ListReceiveAddresses': return $14.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $14.GetTransactionDetailsRequest();
      case 'BumpFee': return $14.BumpFeeRequest();
      case 'CreateCpfp': return $14.CreateCpfpRequest();
      case 'DeriveAddresses': return $14.DeriveAddressesRequest();
      case 'CreatePsbt': return $14.CreatePsbtRequest();
      case 'SignPsbt': return $14.SignPsbtRequest();
      case 'CombinePsbt': return $14.CombinePsbtRequest();
      case 'FinalizePsbt': return $14.FinalizePsbtRequest();
      case 'GetWalletSeed': return $14.GetWalletSeedRequest();
      case 'ListCoreVariants': return $14.ListCoreVariantsRequest();
      case 'GetCoreVariant': return $14.GetCoreVariantRequest();
      case 'SetCoreVariant': return $14.SetCoreVariantRequest();
      case 'GetTestSidechains': return $14.GetTestSidechainsRequest();
      case 'SetTestSidechains': return $14.SetTestSidechainsRequest();
      case 'WatchWalletData': return $13.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $14.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $14.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $14.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $14.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $14.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $14.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $14.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $14.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $14.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $14.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $14.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $14.DeleteAllWalletsRequest);
      case 'ListWalletBackups': return this.listWalletBackups(ctx, request as $14.ListWalletBackupsRequest);
      case 'RestoreWalletBackup': return this.restoreWalletBackup(ctx, request as $14.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream': return this.restoreWalletBackupStream(ctx, request as $14.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $14.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet': return this.createElectrumWallet(ctx, request as $14.CreateElectrumWalletRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $14.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $14.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $14.GetBalanceRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $14.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $14.SendTransactionRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $14.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $14.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $14.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $14.GetTransactionDetailsRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $14.BumpFeeRequest);
      case 'CreateCpfp': return this.createCpfp(ctx, request as $14.CreateCpfpRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $14.DeriveAddressesRequest);
      case 'CreatePsbt': return this.createPsbt(ctx, request as $14.CreatePsbtRequest);
      case 'SignPsbt': return this.signPsbt(ctx, request as $14.SignPsbtRequest);
      case 'CombinePsbt': return this.combinePsbt(ctx, request as $14.CombinePsbtRequest);
      case 'FinalizePsbt': return this.finalizePsbt(ctx, request as $14.FinalizePsbtRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $14.GetWalletSeedRequest);
      case 'ListCoreVariants': return this.listCoreVariants(ctx, request as $14.ListCoreVariantsRequest);
      case 'GetCoreVariant': return this.getCoreVariant(ctx, request as $14.GetCoreVariantRequest);
      case 'SetCoreVariant': return this.setCoreVariant(ctx, request as $14.SetCoreVariantRequest);
      case 'GetTestSidechains': return this.getTestSidechains(ctx, request as $14.GetTestSidechainsRequest);
      case 'SetTestSidechains': return this.setTestSidechains(ctx, request as $14.SetTestSidechainsRequest);
      case 'WatchWalletData': return this.watchWalletData(ctx, request as $13.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

