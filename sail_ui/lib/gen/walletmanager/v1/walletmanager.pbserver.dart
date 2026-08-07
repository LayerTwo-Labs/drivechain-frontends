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

import '../../google/protobuf/empty.pb.dart' as $15;
import 'walletmanager.pb.dart' as $16;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$16.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $16.GetWalletStatusRequest request);
  $async.Future<$16.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $16.GenerateWalletRequest request);
  $async.Future<$16.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $16.UnlockWalletRequest request);
  $async.Future<$16.LockWalletResponse> lockWallet($pb.ServerContext ctx, $16.LockWalletRequest request);
  $async.Future<$16.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $16.EncryptWalletRequest request);
  $async.Future<$16.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $16.ChangePasswordRequest request);
  $async.Future<$16.RemoveEncryptionResponse> removeEncryption(
      $pb.ServerContext ctx, $16.RemoveEncryptionRequest request);
  $async.Future<$16.ListWalletsResponse> listWallets($pb.ServerContext ctx, $16.ListWalletsRequest request);
  $async.Future<$16.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $16.SwitchWalletRequest request);
  $async.Future<$16.UpdateWalletMetadataResponse> updateWalletMetadata(
      $pb.ServerContext ctx, $16.UpdateWalletMetadataRequest request);
  $async.Future<$16.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $16.DeleteWalletRequest request);
  $async.Future<$16.DeleteAllWalletsResponse> deleteAllWallets(
      $pb.ServerContext ctx, $16.DeleteAllWalletsRequest request);
  $async.Future<$16.ListWalletBackupsResponse> listWalletBackups(
      $pb.ServerContext ctx, $16.ListWalletBackupsRequest request);
  $async.Future<$16.RestoreWalletBackupResponse> restoreWalletBackup(
      $pb.ServerContext ctx, $16.RestoreWalletBackupRequest request);
  $async.Future<$16.RestoreWalletBackupProgressResponse> restoreWalletBackupStream(
      $pb.ServerContext ctx, $16.RestoreWalletBackupRequest request);
  $async.Future<$16.CreateWatchOnlyWalletResponse> createWatchOnlyWallet(
      $pb.ServerContext ctx, $16.CreateWatchOnlyWalletRequest request);
  $async.Future<$16.CreateElectrumWalletResponse> createElectrumWallet(
      $pb.ServerContext ctx, $16.CreateElectrumWalletRequest request);
  $async.Future<$16.CreateMultisigWalletResponse> createMultisigWallet(
      $pb.ServerContext ctx, $16.CreateMultisigWalletRequest request);
  $async.Future<$16.ParseMultisigConfigResponse> parseMultisigConfig(
      $pb.ServerContext ctx, $16.ParseMultisigConfigRequest request);
  $async.Future<$16.ValidateDescriptorResponse> validateDescriptor(
      $pb.ServerContext ctx, $16.ValidateDescriptorRequest request);
  $async.Future<$16.ValidateDerivationPathResponse> validateDerivationPath(
      $pb.ServerContext ctx, $16.ValidateDerivationPathRequest request);
  $async.Future<$16.ListDerivationPathsResponse> listDerivationPaths(
      $pb.ServerContext ctx, $16.ListDerivationPathsRequest request);
  $async.Future<$16.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet(
      $pb.ServerContext ctx, $16.CreateBitcoinCoreWalletRequest request);
  $async.Future<$16.EnsureCoreWalletsResponse> ensureCoreWallets(
      $pb.ServerContext ctx, $16.EnsureCoreWalletsRequest request);
  $async.Future<$16.GetBalanceResponse> getBalance($pb.ServerContext ctx, $16.GetBalanceRequest request);
  $async.Future<$16.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $16.RescanWalletRequest request);
  $async.Future<$16.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $16.EstimateFeeRequest request);
  $async.Future<$16.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $16.GetNewAddressRequest request);
  $async.Future<$16.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $16.SendTransactionRequest request);
  $async.Future<$16.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $16.CreateDepositRequest request);
  $async.Future<$16.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $16.ListTransactionsRequest request);
  $async.Future<$16.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $16.ListUnspentRequest request);
  $async.Future<$16.ListReceiveAddressesResponse> listReceiveAddresses(
      $pb.ServerContext ctx, $16.ListReceiveAddressesRequest request);
  $async.Future<$16.GetTransactionDetailsResponse> getTransactionDetails(
      $pb.ServerContext ctx, $16.GetTransactionDetailsRequest request);
  $async.Future<$16.DecodeTransactionResponse> decodeTransaction(
      $pb.ServerContext ctx, $16.DecodeTransactionRequest request);
  $async.Future<$16.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $16.BumpFeeRequest request);
  $async.Future<$16.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $16.CreateCpfpRequest request);
  $async.Future<$16.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $16.DeriveAddressesRequest request);
  $async.Future<$16.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $16.CreatePsbtRequest request);
  $async.Future<$16.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $16.SignPsbtRequest request);
  $async.Future<$16.SignPsbtWithCosignerResponse> signPsbtWithCosigner(
      $pb.ServerContext ctx, $16.SignPsbtWithCosignerRequest request);
  $async.Future<$16.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $16.CombinePsbtRequest request);
  $async.Future<$16.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $16.FinalizePsbtRequest request);
  $async.Future<$16.MultisigPsbtStatusResponse> multisigPsbtStatus(
      $pb.ServerContext ctx, $16.MultisigPsbtStatusRequest request);
  $async.Future<$16.BroadcastTransactionResponse> broadcastTransaction(
      $pb.ServerContext ctx, $16.BroadcastTransactionRequest request);
  $async.Future<$16.GetAddressUnspentResponse> getAddressUnspent(
      $pb.ServerContext ctx, $16.GetAddressUnspentRequest request);
  $async.Future<$16.BroadcastElectrumTransactionResponse> broadcastElectrumTransaction(
      $pb.ServerContext ctx, $16.BroadcastElectrumTransactionRequest request);
  $async.Future<$16.EnumerateHardwareDevicesResponse> enumerateHardwareDevices(
      $pb.ServerContext ctx, $16.EnumerateHardwareDevicesRequest request);
  $async.Future<$16.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $16.GetHardwareXpubRequest request);
  $async.Future<$16.SignPsbtWithDeviceResponse> signPsbtWithDevice(
      $pb.ServerContext ctx, $16.SignPsbtWithDeviceRequest request);
  $async.Future<$16.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $16.PromptDevicePinRequest request);
  $async.Future<$16.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $16.SendDevicePinRequest request);
  $async.Future<$16.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $16.CloseDeviceRequest request);
  $async.Future<$16.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $16.DeriveKeystoreRequest request);
  $async.Future<$16.PreviewWalletFromEntropyResponse> previewWalletFromEntropy(
      $pb.ServerContext ctx, $16.PreviewWalletFromEntropyRequest request);
  $async.Future<$16.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $16.GetWalletSeedRequest request);
  $async.Future<$16.ListCoreVariantsResponse> listCoreVariants(
      $pb.ServerContext ctx, $16.ListCoreVariantsRequest request);
  $async.Future<$16.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $16.GetCoreVariantRequest request);
  $async.Future<$16.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $16.SetCoreVariantRequest request);
  $async.Future<$16.GetTestSidechainsResponse> getTestSidechains(
      $pb.ServerContext ctx, $16.GetTestSidechainsRequest request);
  $async.Future<$16.SetTestSidechainsResponse> setTestSidechains(
      $pb.ServerContext ctx, $16.SetTestSidechainsRequest request);
  $async.Future<$16.GetElectrumServerResponse> getElectrumServer(
      $pb.ServerContext ctx, $16.GetElectrumServerRequest request);
  $async.Future<$16.SetElectrumServerResponse> setElectrumServer(
      $pb.ServerContext ctx, $16.SetElectrumServerRequest request);
  $async.Future<$16.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $16.GetTorConfigRequest request);
  $async.Future<$16.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $16.SetTorConfigRequest request);
  $async.Future<$16.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $15.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus':
        return $16.GetWalletStatusRequest();
      case 'GenerateWallet':
        return $16.GenerateWalletRequest();
      case 'UnlockWallet':
        return $16.UnlockWalletRequest();
      case 'LockWallet':
        return $16.LockWalletRequest();
      case 'EncryptWallet':
        return $16.EncryptWalletRequest();
      case 'ChangePassword':
        return $16.ChangePasswordRequest();
      case 'RemoveEncryption':
        return $16.RemoveEncryptionRequest();
      case 'ListWallets':
        return $16.ListWalletsRequest();
      case 'SwitchWallet':
        return $16.SwitchWalletRequest();
      case 'UpdateWalletMetadata':
        return $16.UpdateWalletMetadataRequest();
      case 'DeleteWallet':
        return $16.DeleteWalletRequest();
      case 'DeleteAllWallets':
        return $16.DeleteAllWalletsRequest();
      case 'ListWalletBackups':
        return $16.ListWalletBackupsRequest();
      case 'RestoreWalletBackup':
        return $16.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream':
        return $16.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet':
        return $16.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet':
        return $16.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet':
        return $16.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig':
        return $16.ParseMultisigConfigRequest();
      case 'ValidateDescriptor':
        return $16.ValidateDescriptorRequest();
      case 'ValidateDerivationPath':
        return $16.ValidateDerivationPathRequest();
      case 'ListDerivationPaths':
        return $16.ListDerivationPathsRequest();
      case 'CreateBitcoinCoreWallet':
        return $16.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets':
        return $16.EnsureCoreWalletsRequest();
      case 'GetBalance':
        return $16.GetBalanceRequest();
      case 'RescanWallet':
        return $16.RescanWalletRequest();
      case 'EstimateFee':
        return $16.EstimateFeeRequest();
      case 'GetNewAddress':
        return $16.GetNewAddressRequest();
      case 'SendTransaction':
        return $16.SendTransactionRequest();
      case 'CreateDeposit':
        return $16.CreateDepositRequest();
      case 'ListTransactions':
        return $16.ListTransactionsRequest();
      case 'ListUnspent':
        return $16.ListUnspentRequest();
      case 'ListReceiveAddresses':
        return $16.ListReceiveAddressesRequest();
      case 'GetTransactionDetails':
        return $16.GetTransactionDetailsRequest();
      case 'DecodeTransaction':
        return $16.DecodeTransactionRequest();
      case 'BumpFee':
        return $16.BumpFeeRequest();
      case 'CreateCpfp':
        return $16.CreateCpfpRequest();
      case 'DeriveAddresses':
        return $16.DeriveAddressesRequest();
      case 'CreatePsbt':
        return $16.CreatePsbtRequest();
      case 'SignPsbt':
        return $16.SignPsbtRequest();
      case 'SignPsbtWithCosigner':
        return $16.SignPsbtWithCosignerRequest();
      case 'CombinePsbt':
        return $16.CombinePsbtRequest();
      case 'FinalizePsbt':
        return $16.FinalizePsbtRequest();
      case 'MultisigPsbtStatus':
        return $16.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction':
        return $16.BroadcastTransactionRequest();
      case 'GetAddressUnspent':
        return $16.GetAddressUnspentRequest();
      case 'BroadcastElectrumTransaction':
        return $16.BroadcastElectrumTransactionRequest();
      case 'EnumerateHardwareDevices':
        return $16.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub':
        return $16.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice':
        return $16.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin':
        return $16.PromptDevicePinRequest();
      case 'SendDevicePin':
        return $16.SendDevicePinRequest();
      case 'CloseDevice':
        return $16.CloseDeviceRequest();
      case 'DeriveKeystore':
        return $16.DeriveKeystoreRequest();
      case 'PreviewWalletFromEntropy':
        return $16.PreviewWalletFromEntropyRequest();
      case 'GetWalletSeed':
        return $16.GetWalletSeedRequest();
      case 'ListCoreVariants':
        return $16.ListCoreVariantsRequest();
      case 'GetCoreVariant':
        return $16.GetCoreVariantRequest();
      case 'SetCoreVariant':
        return $16.SetCoreVariantRequest();
      case 'GetTestSidechains':
        return $16.GetTestSidechainsRequest();
      case 'SetTestSidechains':
        return $16.SetTestSidechainsRequest();
      case 'GetElectrumServer':
        return $16.GetElectrumServerRequest();
      case 'SetElectrumServer':
        return $16.SetElectrumServerRequest();
      case 'GetTorConfig':
        return $16.GetTorConfigRequest();
      case 'SetTorConfig':
        return $16.SetTorConfigRequest();
      case 'WatchWalletData':
        return $15.Empty();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus':
        return this.getWalletStatus(ctx, request as $16.GetWalletStatusRequest);
      case 'GenerateWallet':
        return this.generateWallet(ctx, request as $16.GenerateWalletRequest);
      case 'UnlockWallet':
        return this.unlockWallet(ctx, request as $16.UnlockWalletRequest);
      case 'LockWallet':
        return this.lockWallet(ctx, request as $16.LockWalletRequest);
      case 'EncryptWallet':
        return this.encryptWallet(ctx, request as $16.EncryptWalletRequest);
      case 'ChangePassword':
        return this.changePassword(ctx, request as $16.ChangePasswordRequest);
      case 'RemoveEncryption':
        return this.removeEncryption(ctx, request as $16.RemoveEncryptionRequest);
      case 'ListWallets':
        return this.listWallets(ctx, request as $16.ListWalletsRequest);
      case 'SwitchWallet':
        return this.switchWallet(ctx, request as $16.SwitchWalletRequest);
      case 'UpdateWalletMetadata':
        return this.updateWalletMetadata(ctx, request as $16.UpdateWalletMetadataRequest);
      case 'DeleteWallet':
        return this.deleteWallet(ctx, request as $16.DeleteWalletRequest);
      case 'DeleteAllWallets':
        return this.deleteAllWallets(ctx, request as $16.DeleteAllWalletsRequest);
      case 'ListWalletBackups':
        return this.listWalletBackups(ctx, request as $16.ListWalletBackupsRequest);
      case 'RestoreWalletBackup':
        return this.restoreWalletBackup(ctx, request as $16.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream':
        return this.restoreWalletBackupStream(ctx, request as $16.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet':
        return this.createWatchOnlyWallet(ctx, request as $16.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet':
        return this.createElectrumWallet(ctx, request as $16.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet':
        return this.createMultisigWallet(ctx, request as $16.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig':
        return this.parseMultisigConfig(ctx, request as $16.ParseMultisigConfigRequest);
      case 'ValidateDescriptor':
        return this.validateDescriptor(ctx, request as $16.ValidateDescriptorRequest);
      case 'ValidateDerivationPath':
        return this.validateDerivationPath(ctx, request as $16.ValidateDerivationPathRequest);
      case 'ListDerivationPaths':
        return this.listDerivationPaths(ctx, request as $16.ListDerivationPathsRequest);
      case 'CreateBitcoinCoreWallet':
        return this.createBitcoinCoreWallet(ctx, request as $16.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets':
        return this.ensureCoreWallets(ctx, request as $16.EnsureCoreWalletsRequest);
      case 'GetBalance':
        return this.getBalance(ctx, request as $16.GetBalanceRequest);
      case 'RescanWallet':
        return this.rescanWallet(ctx, request as $16.RescanWalletRequest);
      case 'EstimateFee':
        return this.estimateFee(ctx, request as $16.EstimateFeeRequest);
      case 'GetNewAddress':
        return this.getNewAddress(ctx, request as $16.GetNewAddressRequest);
      case 'SendTransaction':
        return this.sendTransaction(ctx, request as $16.SendTransactionRequest);
      case 'CreateDeposit':
        return this.createDeposit(ctx, request as $16.CreateDepositRequest);
      case 'ListTransactions':
        return this.listTransactions(ctx, request as $16.ListTransactionsRequest);
      case 'ListUnspent':
        return this.listUnspent(ctx, request as $16.ListUnspentRequest);
      case 'ListReceiveAddresses':
        return this.listReceiveAddresses(ctx, request as $16.ListReceiveAddressesRequest);
      case 'GetTransactionDetails':
        return this.getTransactionDetails(ctx, request as $16.GetTransactionDetailsRequest);
      case 'DecodeTransaction':
        return this.decodeTransaction(ctx, request as $16.DecodeTransactionRequest);
      case 'BumpFee':
        return this.bumpFee(ctx, request as $16.BumpFeeRequest);
      case 'CreateCpfp':
        return this.createCpfp(ctx, request as $16.CreateCpfpRequest);
      case 'DeriveAddresses':
        return this.deriveAddresses(ctx, request as $16.DeriveAddressesRequest);
      case 'CreatePsbt':
        return this.createPsbt(ctx, request as $16.CreatePsbtRequest);
      case 'SignPsbt':
        return this.signPsbt(ctx, request as $16.SignPsbtRequest);
      case 'SignPsbtWithCosigner':
        return this.signPsbtWithCosigner(ctx, request as $16.SignPsbtWithCosignerRequest);
      case 'CombinePsbt':
        return this.combinePsbt(ctx, request as $16.CombinePsbtRequest);
      case 'FinalizePsbt':
        return this.finalizePsbt(ctx, request as $16.FinalizePsbtRequest);
      case 'MultisigPsbtStatus':
        return this.multisigPsbtStatus(ctx, request as $16.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction':
        return this.broadcastTransaction(ctx, request as $16.BroadcastTransactionRequest);
      case 'GetAddressUnspent':
        return this.getAddressUnspent(ctx, request as $16.GetAddressUnspentRequest);
      case 'BroadcastElectrumTransaction':
        return this.broadcastElectrumTransaction(ctx, request as $16.BroadcastElectrumTransactionRequest);
      case 'EnumerateHardwareDevices':
        return this.enumerateHardwareDevices(ctx, request as $16.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub':
        return this.getHardwareXpub(ctx, request as $16.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice':
        return this.signPsbtWithDevice(ctx, request as $16.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin':
        return this.promptDevicePin(ctx, request as $16.PromptDevicePinRequest);
      case 'SendDevicePin':
        return this.sendDevicePin(ctx, request as $16.SendDevicePinRequest);
      case 'CloseDevice':
        return this.closeDevice(ctx, request as $16.CloseDeviceRequest);
      case 'DeriveKeystore':
        return this.deriveKeystore(ctx, request as $16.DeriveKeystoreRequest);
      case 'PreviewWalletFromEntropy':
        return this.previewWalletFromEntropy(ctx, request as $16.PreviewWalletFromEntropyRequest);
      case 'GetWalletSeed':
        return this.getWalletSeed(ctx, request as $16.GetWalletSeedRequest);
      case 'ListCoreVariants':
        return this.listCoreVariants(ctx, request as $16.ListCoreVariantsRequest);
      case 'GetCoreVariant':
        return this.getCoreVariant(ctx, request as $16.GetCoreVariantRequest);
      case 'SetCoreVariant':
        return this.setCoreVariant(ctx, request as $16.SetCoreVariantRequest);
      case 'GetTestSidechains':
        return this.getTestSidechains(ctx, request as $16.GetTestSidechainsRequest);
      case 'SetTestSidechains':
        return this.setTestSidechains(ctx, request as $16.SetTestSidechainsRequest);
      case 'GetElectrumServer':
        return this.getElectrumServer(ctx, request as $16.GetElectrumServerRequest);
      case 'SetElectrumServer':
        return this.setElectrumServer(ctx, request as $16.SetElectrumServerRequest);
      case 'GetTorConfig':
        return this.getTorConfig(ctx, request as $16.GetTorConfigRequest);
      case 'SetTorConfig':
        return this.setTorConfig(ctx, request as $16.SetTorConfigRequest);
      case 'WatchWalletData':
        return this.watchWalletData(ctx, request as $15.Empty);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson =>
      WalletManagerServiceBase$messageJson;
}
