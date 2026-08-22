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

import '../../google/protobuf/empty.pb.dart' as $16;
import 'walletmanager.pb.dart' as $17;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$17.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $17.GetWalletStatusRequest request);
  $async.Future<$17.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $17.GenerateWalletRequest request);
  $async.Future<$17.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $17.UnlockWalletRequest request);
  $async.Future<$17.LockWalletResponse> lockWallet($pb.ServerContext ctx, $17.LockWalletRequest request);
  $async.Future<$17.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $17.EncryptWalletRequest request);
  $async.Future<$17.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $17.ChangePasswordRequest request);
  $async.Future<$17.RemoveEncryptionResponse> removeEncryption(
      $pb.ServerContext ctx, $17.RemoveEncryptionRequest request);
  $async.Future<$17.ListWalletsResponse> listWallets($pb.ServerContext ctx, $17.ListWalletsRequest request);
  $async.Future<$17.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $17.SwitchWalletRequest request);
  $async.Future<$17.UpdateWalletMetadataResponse> updateWalletMetadata(
      $pb.ServerContext ctx, $17.UpdateWalletMetadataRequest request);
  $async.Future<$17.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $17.DeleteWalletRequest request);
  $async.Future<$17.DeleteAllWalletsResponse> deleteAllWallets(
      $pb.ServerContext ctx, $17.DeleteAllWalletsRequest request);
  $async.Future<$17.ListWalletBackupsResponse> listWalletBackups(
      $pb.ServerContext ctx, $17.ListWalletBackupsRequest request);
  $async.Future<$17.RestoreWalletBackupResponse> restoreWalletBackup(
      $pb.ServerContext ctx, $17.RestoreWalletBackupRequest request);
  $async.Future<$17.RestoreWalletBackupProgressResponse> restoreWalletBackupStream(
      $pb.ServerContext ctx, $17.RestoreWalletBackupRequest request);
  $async.Future<$17.SwapEnforcerWalletProgressResponse> swapEnforcerWallet(
      $pb.ServerContext ctx, $17.SwapEnforcerWalletRequest request);
  $async.Future<$17.CreateWatchOnlyWalletResponse> createWatchOnlyWallet(
      $pb.ServerContext ctx, $17.CreateWatchOnlyWalletRequest request);
  $async.Future<$17.CreateElectrumWalletResponse> createElectrumWallet(
      $pb.ServerContext ctx, $17.CreateElectrumWalletRequest request);
  $async.Future<$17.CreateMultisigWalletResponse> createMultisigWallet(
      $pb.ServerContext ctx, $17.CreateMultisigWalletRequest request);
  $async.Future<$17.ParseMultisigConfigResponse> parseMultisigConfig(
      $pb.ServerContext ctx, $17.ParseMultisigConfigRequest request);
  $async.Future<$17.ValidateDescriptorResponse> validateDescriptor(
      $pb.ServerContext ctx, $17.ValidateDescriptorRequest request);
  $async.Future<$17.ValidateDerivationPathResponse> validateDerivationPath(
      $pb.ServerContext ctx, $17.ValidateDerivationPathRequest request);
  $async.Future<$17.ListDerivationPathsResponse> listDerivationPaths(
      $pb.ServerContext ctx, $17.ListDerivationPathsRequest request);
  $async.Future<$17.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet(
      $pb.ServerContext ctx, $17.CreateBitcoinCoreWalletRequest request);
  $async.Future<$17.EnsureCoreWalletsResponse> ensureCoreWallets(
      $pb.ServerContext ctx, $17.EnsureCoreWalletsRequest request);
  $async.Future<$17.GetBalanceResponse> getBalance($pb.ServerContext ctx, $17.GetBalanceRequest request);
  $async.Future<$17.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $17.RescanWalletRequest request);
  $async.Future<$17.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $17.EstimateFeeRequest request);
  $async.Future<$17.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $17.GetNewAddressRequest request);
  $async.Future<$17.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $17.SendTransactionRequest request);
  $async.Future<$17.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $17.CreateDepositRequest request);
  $async.Future<$17.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $17.ListTransactionsRequest request);
  $async.Future<$17.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $17.ListUnspentRequest request);
  $async.Future<$17.ListReceiveAddressesResponse> listReceiveAddresses(
      $pb.ServerContext ctx, $17.ListReceiveAddressesRequest request);
  $async.Future<$17.GetTransactionDetailsResponse> getTransactionDetails(
      $pb.ServerContext ctx, $17.GetTransactionDetailsRequest request);
  $async.Future<$17.DecodeTransactionResponse> decodeTransaction(
      $pb.ServerContext ctx, $17.DecodeTransactionRequest request);
  $async.Future<$17.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $17.BumpFeeRequest request);
  $async.Future<$17.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $17.CreateCpfpRequest request);
  $async.Future<$17.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $17.DeriveAddressesRequest request);
  $async.Future<$17.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $17.CreatePsbtRequest request);
  $async.Future<$17.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $17.SignPsbtRequest request);
  $async.Future<$17.SignPsbtWithCosignerResponse> signPsbtWithCosigner(
      $pb.ServerContext ctx, $17.SignPsbtWithCosignerRequest request);
  $async.Future<$17.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $17.CombinePsbtRequest request);
  $async.Future<$17.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $17.FinalizePsbtRequest request);
  $async.Future<$17.MultisigPsbtStatusResponse> multisigPsbtStatus(
      $pb.ServerContext ctx, $17.MultisigPsbtStatusRequest request);
  $async.Future<$17.BroadcastTransactionResponse> broadcastTransaction(
      $pb.ServerContext ctx, $17.BroadcastTransactionRequest request);
  $async.Future<$17.GetAddressUnspentResponse> getAddressUnspent(
      $pb.ServerContext ctx, $17.GetAddressUnspentRequest request);
  $async.Future<$17.BroadcastElectrumTransactionResponse> broadcastElectrumTransaction(
      $pb.ServerContext ctx, $17.BroadcastElectrumTransactionRequest request);
  $async.Future<$17.EnumerateHardwareDevicesResponse> enumerateHardwareDevices(
      $pb.ServerContext ctx, $17.EnumerateHardwareDevicesRequest request);
  $async.Future<$17.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $17.GetHardwareXpubRequest request);
  $async.Future<$17.SignPsbtWithDeviceResponse> signPsbtWithDevice(
      $pb.ServerContext ctx, $17.SignPsbtWithDeviceRequest request);
  $async.Future<$17.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $17.PromptDevicePinRequest request);
  $async.Future<$17.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $17.SendDevicePinRequest request);
  $async.Future<$17.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $17.CloseDeviceRequest request);
  $async.Future<$17.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $17.DeriveKeystoreRequest request);
  $async.Future<$17.PreviewWalletFromEntropyResponse> previewWalletFromEntropy(
      $pb.ServerContext ctx, $17.PreviewWalletFromEntropyRequest request);
  $async.Future<$17.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $17.GetWalletSeedRequest request);
  $async.Future<$17.ListCoreVariantsResponse> listCoreVariants(
      $pb.ServerContext ctx, $17.ListCoreVariantsRequest request);
  $async.Future<$17.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $17.GetCoreVariantRequest request);
  $async.Future<$17.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $17.SetCoreVariantRequest request);
  $async.Future<$17.GetElectrumServerResponse> getElectrumServer(
      $pb.ServerContext ctx, $17.GetElectrumServerRequest request);
  $async.Future<$17.SetElectrumServerResponse> setElectrumServer(
      $pb.ServerContext ctx, $17.SetElectrumServerRequest request);
  $async.Future<$17.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $17.GetTorConfigRequest request);
  $async.Future<$17.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $17.SetTorConfigRequest request);
  $async.Future<$17.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $16.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus':
        return $17.GetWalletStatusRequest();
      case 'GenerateWallet':
        return $17.GenerateWalletRequest();
      case 'UnlockWallet':
        return $17.UnlockWalletRequest();
      case 'LockWallet':
        return $17.LockWalletRequest();
      case 'EncryptWallet':
        return $17.EncryptWalletRequest();
      case 'ChangePassword':
        return $17.ChangePasswordRequest();
      case 'RemoveEncryption':
        return $17.RemoveEncryptionRequest();
      case 'ListWallets':
        return $17.ListWalletsRequest();
      case 'SwitchWallet':
        return $17.SwitchWalletRequest();
      case 'UpdateWalletMetadata':
        return $17.UpdateWalletMetadataRequest();
      case 'DeleteWallet':
        return $17.DeleteWalletRequest();
      case 'DeleteAllWallets':
        return $17.DeleteAllWalletsRequest();
      case 'ListWalletBackups':
        return $17.ListWalletBackupsRequest();
      case 'RestoreWalletBackup':
        return $17.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream':
        return $17.RestoreWalletBackupRequest();
      case 'SwapEnforcerWallet':
        return $17.SwapEnforcerWalletRequest();
      case 'CreateWatchOnlyWallet':
        return $17.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet':
        return $17.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet':
        return $17.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig':
        return $17.ParseMultisigConfigRequest();
      case 'ValidateDescriptor':
        return $17.ValidateDescriptorRequest();
      case 'ValidateDerivationPath':
        return $17.ValidateDerivationPathRequest();
      case 'ListDerivationPaths':
        return $17.ListDerivationPathsRequest();
      case 'CreateBitcoinCoreWallet':
        return $17.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets':
        return $17.EnsureCoreWalletsRequest();
      case 'GetBalance':
        return $17.GetBalanceRequest();
      case 'RescanWallet':
        return $17.RescanWalletRequest();
      case 'EstimateFee':
        return $17.EstimateFeeRequest();
      case 'GetNewAddress':
        return $17.GetNewAddressRequest();
      case 'SendTransaction':
        return $17.SendTransactionRequest();
      case 'CreateDeposit':
        return $17.CreateDepositRequest();
      case 'ListTransactions':
        return $17.ListTransactionsRequest();
      case 'ListUnspent':
        return $17.ListUnspentRequest();
      case 'ListReceiveAddresses':
        return $17.ListReceiveAddressesRequest();
      case 'GetTransactionDetails':
        return $17.GetTransactionDetailsRequest();
      case 'DecodeTransaction':
        return $17.DecodeTransactionRequest();
      case 'BumpFee':
        return $17.BumpFeeRequest();
      case 'CreateCpfp':
        return $17.CreateCpfpRequest();
      case 'DeriveAddresses':
        return $17.DeriveAddressesRequest();
      case 'CreatePsbt':
        return $17.CreatePsbtRequest();
      case 'SignPsbt':
        return $17.SignPsbtRequest();
      case 'SignPsbtWithCosigner':
        return $17.SignPsbtWithCosignerRequest();
      case 'CombinePsbt':
        return $17.CombinePsbtRequest();
      case 'FinalizePsbt':
        return $17.FinalizePsbtRequest();
      case 'MultisigPsbtStatus':
        return $17.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction':
        return $17.BroadcastTransactionRequest();
      case 'GetAddressUnspent':
        return $17.GetAddressUnspentRequest();
      case 'BroadcastElectrumTransaction':
        return $17.BroadcastElectrumTransactionRequest();
      case 'EnumerateHardwareDevices':
        return $17.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub':
        return $17.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice':
        return $17.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin':
        return $17.PromptDevicePinRequest();
      case 'SendDevicePin':
        return $17.SendDevicePinRequest();
      case 'CloseDevice':
        return $17.CloseDeviceRequest();
      case 'DeriveKeystore':
        return $17.DeriveKeystoreRequest();
      case 'PreviewWalletFromEntropy':
        return $17.PreviewWalletFromEntropyRequest();
      case 'GetWalletSeed':
        return $17.GetWalletSeedRequest();
      case 'ListCoreVariants':
        return $17.ListCoreVariantsRequest();
      case 'GetCoreVariant':
        return $17.GetCoreVariantRequest();
      case 'SetCoreVariant':
        return $17.SetCoreVariantRequest();
      case 'GetElectrumServer':
        return $17.GetElectrumServerRequest();
      case 'SetElectrumServer':
        return $17.SetElectrumServerRequest();
      case 'GetTorConfig':
        return $17.GetTorConfigRequest();
      case 'SetTorConfig':
        return $17.SetTorConfigRequest();
      case 'WatchWalletData':
        return $16.Empty();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus':
        return this.getWalletStatus(ctx, request as $17.GetWalletStatusRequest);
      case 'GenerateWallet':
        return this.generateWallet(ctx, request as $17.GenerateWalletRequest);
      case 'UnlockWallet':
        return this.unlockWallet(ctx, request as $17.UnlockWalletRequest);
      case 'LockWallet':
        return this.lockWallet(ctx, request as $17.LockWalletRequest);
      case 'EncryptWallet':
        return this.encryptWallet(ctx, request as $17.EncryptWalletRequest);
      case 'ChangePassword':
        return this.changePassword(ctx, request as $17.ChangePasswordRequest);
      case 'RemoveEncryption':
        return this.removeEncryption(ctx, request as $17.RemoveEncryptionRequest);
      case 'ListWallets':
        return this.listWallets(ctx, request as $17.ListWalletsRequest);
      case 'SwitchWallet':
        return this.switchWallet(ctx, request as $17.SwitchWalletRequest);
      case 'UpdateWalletMetadata':
        return this.updateWalletMetadata(ctx, request as $17.UpdateWalletMetadataRequest);
      case 'DeleteWallet':
        return this.deleteWallet(ctx, request as $17.DeleteWalletRequest);
      case 'DeleteAllWallets':
        return this.deleteAllWallets(ctx, request as $17.DeleteAllWalletsRequest);
      case 'ListWalletBackups':
        return this.listWalletBackups(ctx, request as $17.ListWalletBackupsRequest);
      case 'RestoreWalletBackup':
        return this.restoreWalletBackup(ctx, request as $17.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream':
        return this.restoreWalletBackupStream(ctx, request as $17.RestoreWalletBackupRequest);
      case 'SwapEnforcerWallet':
        return this.swapEnforcerWallet(ctx, request as $17.SwapEnforcerWalletRequest);
      case 'CreateWatchOnlyWallet':
        return this.createWatchOnlyWallet(ctx, request as $17.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet':
        return this.createElectrumWallet(ctx, request as $17.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet':
        return this.createMultisigWallet(ctx, request as $17.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig':
        return this.parseMultisigConfig(ctx, request as $17.ParseMultisigConfigRequest);
      case 'ValidateDescriptor':
        return this.validateDescriptor(ctx, request as $17.ValidateDescriptorRequest);
      case 'ValidateDerivationPath':
        return this.validateDerivationPath(ctx, request as $17.ValidateDerivationPathRequest);
      case 'ListDerivationPaths':
        return this.listDerivationPaths(ctx, request as $17.ListDerivationPathsRequest);
      case 'CreateBitcoinCoreWallet':
        return this.createBitcoinCoreWallet(ctx, request as $17.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets':
        return this.ensureCoreWallets(ctx, request as $17.EnsureCoreWalletsRequest);
      case 'GetBalance':
        return this.getBalance(ctx, request as $17.GetBalanceRequest);
      case 'RescanWallet':
        return this.rescanWallet(ctx, request as $17.RescanWalletRequest);
      case 'EstimateFee':
        return this.estimateFee(ctx, request as $17.EstimateFeeRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $17.GetNewAddressRequest);
      case 'SendTransaction':
        return this.sendTransaction(ctx, request as $17.SendTransactionRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $17.CreateDepositRequest);
      case 'ListTransactions':
        return this.listTransactions(ctx, request as $17.ListTransactionsRequest);
      case 'ListUnspent':
        return this.listUnspent(ctx, request as $17.ListUnspentRequest);
      case 'ListReceiveAddresses':
        return this.listReceiveAddresses(ctx, request as $17.ListReceiveAddressesRequest);
      case 'GetTransactionDetails':
        return this.getTransactionDetails(ctx, request as $17.GetTransactionDetailsRequest);
      case 'DecodeTransaction':
        return this.decodeTransaction(ctx, request as $17.DecodeTransactionRequest);
      case 'BumpFee':
        return this.bumpFee(ctx, request as $17.BumpFeeRequest);
      case 'CreateCpfp':
        return this.createCpfp(ctx, request as $17.CreateCpfpRequest);
      case 'DeriveAddresses':
        return this.deriveAddresses(ctx, request as $17.DeriveAddressesRequest);
      case 'CreatePsbt':
        return this.createPsbt(ctx, request as $17.CreatePsbtRequest);
      case 'SignPsbt':
        return this.signPsbt(ctx, request as $17.SignPsbtRequest);
      case 'SignPsbtWithCosigner':
        return this.signPsbtWithCosigner(ctx, request as $17.SignPsbtWithCosignerRequest);
      case 'CombinePsbt':
        return this.combinePsbt(ctx, request as $17.CombinePsbtRequest);
      case 'FinalizePsbt':
        return this.finalizePsbt(ctx, request as $17.FinalizePsbtRequest);
      case 'MultisigPsbtStatus':
        return this.multisigPsbtStatus(ctx, request as $17.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction':
        return this.broadcastTransaction(ctx, request as $17.BroadcastTransactionRequest);
      case 'GetAddressUnspent':
        return this.getAddressUnspent(ctx, request as $17.GetAddressUnspentRequest);
      case 'BroadcastElectrumTransaction':
        return this.broadcastElectrumTransaction(ctx, request as $17.BroadcastElectrumTransactionRequest);
      case 'EnumerateHardwareDevices':
        return this.enumerateHardwareDevices(ctx, request as $17.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub':
        return this.getHardwareXpub(ctx, request as $17.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice':
        return this.signPsbtWithDevice(ctx, request as $17.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin':
        return this.promptDevicePin(ctx, request as $17.PromptDevicePinRequest);
      case 'SendDevicePin':
        return this.sendDevicePin(ctx, request as $17.SendDevicePinRequest);
      case 'CloseDevice':
        return this.closeDevice(ctx, request as $17.CloseDeviceRequest);
      case 'DeriveKeystore':
        return this.deriveKeystore(ctx, request as $17.DeriveKeystoreRequest);
      case 'PreviewWalletFromEntropy':
        return this.previewWalletFromEntropy(ctx, request as $17.PreviewWalletFromEntropyRequest);
      case 'GetWalletSeed':
        return this.getWalletSeed(ctx, request as $17.GetWalletSeedRequest);
      case 'ListCoreVariants':
        return this.listCoreVariants(ctx, request as $17.ListCoreVariantsRequest);
      case 'GetCoreVariant':
        return this.getCoreVariant(ctx, request as $17.GetCoreVariantRequest);
      case 'SetCoreVariant':
        return this.setCoreVariant(ctx, request as $17.SetCoreVariantRequest);
      case 'GetElectrumServer':
        return this.getElectrumServer(ctx, request as $17.GetElectrumServerRequest);
      case 'SetElectrumServer':
        return this.setElectrumServer(ctx, request as $17.SetElectrumServerRequest);
      case 'GetTorConfig':
        return this.getTorConfig(ctx, request as $17.GetTorConfigRequest);
      case 'SetTorConfig':
        return this.setTorConfig(ctx, request as $17.SetTorConfigRequest);
      case 'WatchWalletData':
        return this.watchWalletData(ctx, request as $16.Empty);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson =>
      WalletManagerServiceBase$messageJson;
}
