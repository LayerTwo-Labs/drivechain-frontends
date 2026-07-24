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

import '../../google/protobuf/empty.pb.dart' as $14;
import 'walletmanager.pb.dart' as $15;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$15.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $15.GetWalletStatusRequest request);
  $async.Future<$15.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $15.GenerateWalletRequest request);
  $async.Future<$15.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $15.UnlockWalletRequest request);
  $async.Future<$15.LockWalletResponse> lockWallet($pb.ServerContext ctx, $15.LockWalletRequest request);
  $async.Future<$15.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $15.EncryptWalletRequest request);
  $async.Future<$15.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $15.ChangePasswordRequest request);
  $async.Future<$15.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $15.RemoveEncryptionRequest request);
  $async.Future<$15.ListWalletsResponse> listWallets($pb.ServerContext ctx, $15.ListWalletsRequest request);
  $async.Future<$15.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $15.SwitchWalletRequest request);
  $async.Future<$15.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $15.UpdateWalletMetadataRequest request);
  $async.Future<$15.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $15.DeleteWalletRequest request);
  $async.Future<$15.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $15.DeleteAllWalletsRequest request);
  $async.Future<$15.ListWalletBackupsResponse> listWalletBackups($pb.ServerContext ctx, $15.ListWalletBackupsRequest request);
  $async.Future<$15.RestoreWalletBackupResponse> restoreWalletBackup($pb.ServerContext ctx, $15.RestoreWalletBackupRequest request);
  $async.Future<$15.RestoreWalletBackupProgressResponse> restoreWalletBackupStream($pb.ServerContext ctx, $15.RestoreWalletBackupRequest request);
  $async.Future<$15.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $15.CreateWatchOnlyWalletRequest request);
  $async.Future<$15.CreateElectrumWalletResponse> createElectrumWallet($pb.ServerContext ctx, $15.CreateElectrumWalletRequest request);
  $async.Future<$15.CreateMultisigWalletResponse> createMultisigWallet($pb.ServerContext ctx, $15.CreateMultisigWalletRequest request);
  $async.Future<$15.ParseMultisigConfigResponse> parseMultisigConfig($pb.ServerContext ctx, $15.ParseMultisigConfigRequest request);
  $async.Future<$15.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $15.CreateBitcoinCoreWalletRequest request);
  $async.Future<$15.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $15.EnsureCoreWalletsRequest request);
  $async.Future<$15.GetBalanceResponse> getBalance($pb.ServerContext ctx, $15.GetBalanceRequest request);
  $async.Future<$15.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $15.RescanWalletRequest request);
  $async.Future<$15.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $15.EstimateFeeRequest request);
  $async.Future<$15.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $15.GetNewAddressRequest request);
  $async.Future<$15.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $15.SendTransactionRequest request);
  $async.Future<$15.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $15.ListTransactionsRequest request);
  $async.Future<$15.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $15.ListUnspentRequest request);
  $async.Future<$15.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $15.ListReceiveAddressesRequest request);
  $async.Future<$15.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $15.GetTransactionDetailsRequest request);
  $async.Future<$15.DecodeTransactionResponse> decodeTransaction($pb.ServerContext ctx, $15.DecodeTransactionRequest request);
  $async.Future<$15.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $15.BumpFeeRequest request);
  $async.Future<$15.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $15.CreateCpfpRequest request);
  $async.Future<$15.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $15.DeriveAddressesRequest request);
  $async.Future<$15.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $15.CreatePsbtRequest request);
  $async.Future<$15.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $15.SignPsbtRequest request);
  $async.Future<$15.SignPsbtWithCosignerResponse> signPsbtWithCosigner($pb.ServerContext ctx, $15.SignPsbtWithCosignerRequest request);
  $async.Future<$15.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $15.CombinePsbtRequest request);
  $async.Future<$15.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $15.FinalizePsbtRequest request);
  $async.Future<$15.MultisigPsbtStatusResponse> multisigPsbtStatus($pb.ServerContext ctx, $15.MultisigPsbtStatusRequest request);
  $async.Future<$15.BroadcastTransactionResponse> broadcastTransaction($pb.ServerContext ctx, $15.BroadcastTransactionRequest request);
  $async.Future<$15.EnumerateHardwareDevicesResponse> enumerateHardwareDevices($pb.ServerContext ctx, $15.EnumerateHardwareDevicesRequest request);
  $async.Future<$15.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $15.GetHardwareXpubRequest request);
  $async.Future<$15.SignPsbtWithDeviceResponse> signPsbtWithDevice($pb.ServerContext ctx, $15.SignPsbtWithDeviceRequest request);
  $async.Future<$15.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $15.PromptDevicePinRequest request);
  $async.Future<$15.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $15.SendDevicePinRequest request);
  $async.Future<$15.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $15.CloseDeviceRequest request);
  $async.Future<$15.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $15.DeriveKeystoreRequest request);
  $async.Future<$15.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $15.GetWalletSeedRequest request);
  $async.Future<$15.ListCoreVariantsResponse> listCoreVariants($pb.ServerContext ctx, $15.ListCoreVariantsRequest request);
  $async.Future<$15.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $15.GetCoreVariantRequest request);
  $async.Future<$15.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $15.SetCoreVariantRequest request);
  $async.Future<$15.GetTestSidechainsResponse> getTestSidechains($pb.ServerContext ctx, $15.GetTestSidechainsRequest request);
  $async.Future<$15.SetTestSidechainsResponse> setTestSidechains($pb.ServerContext ctx, $15.SetTestSidechainsRequest request);
  $async.Future<$15.GetElectrumServerResponse> getElectrumServer($pb.ServerContext ctx, $15.GetElectrumServerRequest request);
  $async.Future<$15.SetElectrumServerResponse> setElectrumServer($pb.ServerContext ctx, $15.SetElectrumServerRequest request);
  $async.Future<$15.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $15.GetTorConfigRequest request);
  $async.Future<$15.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $15.SetTorConfigRequest request);
  $async.Future<$15.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $14.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $15.GetWalletStatusRequest();
      case 'GenerateWallet': return $15.GenerateWalletRequest();
      case 'UnlockWallet': return $15.UnlockWalletRequest();
      case 'LockWallet': return $15.LockWalletRequest();
      case 'EncryptWallet': return $15.EncryptWalletRequest();
      case 'ChangePassword': return $15.ChangePasswordRequest();
      case 'RemoveEncryption': return $15.RemoveEncryptionRequest();
      case 'ListWallets': return $15.ListWalletsRequest();
      case 'SwitchWallet': return $15.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $15.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $15.DeleteWalletRequest();
      case 'DeleteAllWallets': return $15.DeleteAllWalletsRequest();
      case 'ListWalletBackups': return $15.ListWalletBackupsRequest();
      case 'RestoreWalletBackup': return $15.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream': return $15.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet': return $15.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet': return $15.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet': return $15.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig': return $15.ParseMultisigConfigRequest();
      case 'CreateBitcoinCoreWallet': return $15.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $15.EnsureCoreWalletsRequest();
      case 'GetBalance': return $15.GetBalanceRequest();
      case 'RescanWallet': return $15.RescanWalletRequest();
      case 'EstimateFee': return $15.EstimateFeeRequest();
      case 'GetNewAddress': return $15.GetNewAddressRequest();
      case 'SendTransaction': return $15.SendTransactionRequest();
      case 'ListTransactions': return $15.ListTransactionsRequest();
      case 'ListUnspent': return $15.ListUnspentRequest();
      case 'ListReceiveAddresses': return $15.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $15.GetTransactionDetailsRequest();
      case 'DecodeTransaction': return $15.DecodeTransactionRequest();
      case 'BumpFee': return $15.BumpFeeRequest();
      case 'CreateCpfp': return $15.CreateCpfpRequest();
      case 'DeriveAddresses': return $15.DeriveAddressesRequest();
      case 'CreatePsbt': return $15.CreatePsbtRequest();
      case 'SignPsbt': return $15.SignPsbtRequest();
      case 'SignPsbtWithCosigner': return $15.SignPsbtWithCosignerRequest();
      case 'CombinePsbt': return $15.CombinePsbtRequest();
      case 'FinalizePsbt': return $15.FinalizePsbtRequest();
      case 'MultisigPsbtStatus': return $15.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction': return $15.BroadcastTransactionRequest();
      case 'EnumerateHardwareDevices': return $15.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub': return $15.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice': return $15.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin': return $15.PromptDevicePinRequest();
      case 'SendDevicePin': return $15.SendDevicePinRequest();
      case 'CloseDevice': return $15.CloseDeviceRequest();
      case 'DeriveKeystore': return $15.DeriveKeystoreRequest();
      case 'GetWalletSeed': return $15.GetWalletSeedRequest();
      case 'ListCoreVariants': return $15.ListCoreVariantsRequest();
      case 'GetCoreVariant': return $15.GetCoreVariantRequest();
      case 'SetCoreVariant': return $15.SetCoreVariantRequest();
      case 'GetTestSidechains': return $15.GetTestSidechainsRequest();
      case 'SetTestSidechains': return $15.SetTestSidechainsRequest();
      case 'GetElectrumServer': return $15.GetElectrumServerRequest();
      case 'SetElectrumServer': return $15.SetElectrumServerRequest();
      case 'GetTorConfig': return $15.GetTorConfigRequest();
      case 'SetTorConfig': return $15.SetTorConfigRequest();
      case 'WatchWalletData': return $14.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $15.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $15.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $15.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $15.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $15.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $15.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $15.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $15.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $15.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $15.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $15.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $15.DeleteAllWalletsRequest);
      case 'ListWalletBackups': return this.listWalletBackups(ctx, request as $15.ListWalletBackupsRequest);
      case 'RestoreWalletBackup': return this.restoreWalletBackup(ctx, request as $15.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream': return this.restoreWalletBackupStream(ctx, request as $15.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $15.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet': return this.createElectrumWallet(ctx, request as $15.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet': return this.createMultisigWallet(ctx, request as $15.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig': return this.parseMultisigConfig(ctx, request as $15.ParseMultisigConfigRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $15.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $15.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $15.GetBalanceRequest);
      case 'RescanWallet': return this.rescanWallet(ctx, request as $15.RescanWalletRequest);
      case 'EstimateFee': return this.estimateFee(ctx, request as $15.EstimateFeeRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $15.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $15.SendTransactionRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $15.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $15.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $15.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $15.GetTransactionDetailsRequest);
      case 'DecodeTransaction': return this.decodeTransaction(ctx, request as $15.DecodeTransactionRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $15.BumpFeeRequest);
      case 'CreateCpfp': return this.createCpfp(ctx, request as $15.CreateCpfpRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $15.DeriveAddressesRequest);
      case 'CreatePsbt': return this.createPsbt(ctx, request as $15.CreatePsbtRequest);
      case 'SignPsbt': return this.signPsbt(ctx, request as $15.SignPsbtRequest);
      case 'SignPsbtWithCosigner': return this.signPsbtWithCosigner(ctx, request as $15.SignPsbtWithCosignerRequest);
      case 'CombinePsbt': return this.combinePsbt(ctx, request as $15.CombinePsbtRequest);
      case 'FinalizePsbt': return this.finalizePsbt(ctx, request as $15.FinalizePsbtRequest);
      case 'MultisigPsbtStatus': return this.multisigPsbtStatus(ctx, request as $15.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction': return this.broadcastTransaction(ctx, request as $15.BroadcastTransactionRequest);
      case 'EnumerateHardwareDevices': return this.enumerateHardwareDevices(ctx, request as $15.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub': return this.getHardwareXpub(ctx, request as $15.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice': return this.signPsbtWithDevice(ctx, request as $15.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin': return this.promptDevicePin(ctx, request as $15.PromptDevicePinRequest);
      case 'SendDevicePin': return this.sendDevicePin(ctx, request as $15.SendDevicePinRequest);
      case 'CloseDevice': return this.closeDevice(ctx, request as $15.CloseDeviceRequest);
      case 'DeriveKeystore': return this.deriveKeystore(ctx, request as $15.DeriveKeystoreRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $15.GetWalletSeedRequest);
      case 'ListCoreVariants': return this.listCoreVariants(ctx, request as $15.ListCoreVariantsRequest);
      case 'GetCoreVariant': return this.getCoreVariant(ctx, request as $15.GetCoreVariantRequest);
      case 'SetCoreVariant': return this.setCoreVariant(ctx, request as $15.SetCoreVariantRequest);
      case 'GetTestSidechains': return this.getTestSidechains(ctx, request as $15.GetTestSidechainsRequest);
      case 'SetTestSidechains': return this.setTestSidechains(ctx, request as $15.SetTestSidechainsRequest);
      case 'GetElectrumServer': return this.getElectrumServer(ctx, request as $15.GetElectrumServerRequest);
      case 'SetElectrumServer': return this.setElectrumServer(ctx, request as $15.SetElectrumServerRequest);
      case 'GetTorConfig': return this.getTorConfig(ctx, request as $15.GetTorConfigRequest);
      case 'SetTorConfig': return this.setTorConfig(ctx, request as $15.SetTorConfigRequest);
      case 'WatchWalletData': return this.watchWalletData(ctx, request as $14.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

