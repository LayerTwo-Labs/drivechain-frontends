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

import '../../google/protobuf/empty.pb.dart' as $2;
import 'walletmanager.pb.dart' as $3;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$3.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $3.GetWalletStatusRequest request);
  $async.Future<$3.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $3.ListSidechainDepositsRequest request);
  $async.Future<$3.GetNodeModeResponse> getNodeMode($pb.ServerContext ctx, $3.GetNodeModeRequest request);
  $async.Future<$3.SetNodeModeResponse> setNodeMode($pb.ServerContext ctx, $3.SetNodeModeRequest request);
  $async.Future<$3.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $3.GenerateWalletRequest request);
  $async.Future<$3.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $3.UnlockWalletRequest request);
  $async.Future<$3.LockWalletResponse> lockWallet($pb.ServerContext ctx, $3.LockWalletRequest request);
  $async.Future<$3.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $3.EncryptWalletRequest request);
  $async.Future<$3.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $3.ChangePasswordRequest request);
  $async.Future<$3.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $3.RemoveEncryptionRequest request);
  $async.Future<$3.ListWalletsResponse> listWallets($pb.ServerContext ctx, $3.ListWalletsRequest request);
  $async.Future<$3.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $3.SwitchWalletRequest request);
  $async.Future<$3.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $3.UpdateWalletMetadataRequest request);
  $async.Future<$3.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $3.DeleteWalletRequest request);
  $async.Future<$3.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $3.DeleteAllWalletsRequest request);
  $async.Future<$3.ListWalletBackupsResponse> listWalletBackups($pb.ServerContext ctx, $3.ListWalletBackupsRequest request);
  $async.Future<$3.RestoreWalletBackupResponse> restoreWalletBackup($pb.ServerContext ctx, $3.RestoreWalletBackupRequest request);
  $async.Future<$3.RestoreWalletBackupProgressResponse> restoreWalletBackupStream($pb.ServerContext ctx, $3.RestoreWalletBackupRequest request);
  $async.Future<$3.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $3.CreateWatchOnlyWalletRequest request);
  $async.Future<$3.CreateElectrumWalletResponse> createElectrumWallet($pb.ServerContext ctx, $3.CreateElectrumWalletRequest request);
  $async.Future<$3.CreateMultisigWalletResponse> createMultisigWallet($pb.ServerContext ctx, $3.CreateMultisigWalletRequest request);
  $async.Future<$3.ParseMultisigConfigResponse> parseMultisigConfig($pb.ServerContext ctx, $3.ParseMultisigConfigRequest request);
  $async.Future<$3.ValidateDescriptorResponse> validateDescriptor($pb.ServerContext ctx, $3.ValidateDescriptorRequest request);
  $async.Future<$3.ValidateDerivationPathResponse> validateDerivationPath($pb.ServerContext ctx, $3.ValidateDerivationPathRequest request);
  $async.Future<$3.ListDerivationPathsResponse> listDerivationPaths($pb.ServerContext ctx, $3.ListDerivationPathsRequest request);
  $async.Future<$3.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $3.CreateBitcoinCoreWalletRequest request);
  $async.Future<$3.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $3.EnsureCoreWalletsRequest request);
  $async.Future<$3.GetBalanceResponse> getBalance($pb.ServerContext ctx, $3.GetBalanceRequest request);
  $async.Future<$3.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $3.RescanWalletRequest request);
  $async.Future<$3.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $3.EstimateFeeRequest request);
  $async.Future<$3.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $3.GetNewAddressRequest request);
  $async.Future<$3.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $3.SendTransactionRequest request);
  $async.Future<$3.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $3.CreateDepositRequest request);
  $async.Future<$3.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $3.ListTransactionsRequest request);
  $async.Future<$3.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $3.ListUnspentRequest request);
  $async.Future<$3.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $3.ListReceiveAddressesRequest request);
  $async.Future<$3.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $3.GetTransactionDetailsRequest request);
  $async.Future<$3.DecodeTransactionResponse> decodeTransaction($pb.ServerContext ctx, $3.DecodeTransactionRequest request);
  $async.Future<$3.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $3.BumpFeeRequest request);
  $async.Future<$3.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $3.CreateCpfpRequest request);
  $async.Future<$3.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $3.DeriveAddressesRequest request);
  $async.Future<$3.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $3.CreatePsbtRequest request);
  $async.Future<$3.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $3.SignPsbtRequest request);
  $async.Future<$3.SignPsbtWithCosignerResponse> signPsbtWithCosigner($pb.ServerContext ctx, $3.SignPsbtWithCosignerRequest request);
  $async.Future<$3.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $3.CombinePsbtRequest request);
  $async.Future<$3.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $3.FinalizePsbtRequest request);
  $async.Future<$3.MultisigPsbtStatusResponse> multisigPsbtStatus($pb.ServerContext ctx, $3.MultisigPsbtStatusRequest request);
  $async.Future<$3.BroadcastTransactionResponse> broadcastTransaction($pb.ServerContext ctx, $3.BroadcastTransactionRequest request);
  $async.Future<$3.GetAddressUnspentResponse> getAddressUnspent($pb.ServerContext ctx, $3.GetAddressUnspentRequest request);
  $async.Future<$3.BroadcastElectrumTransactionResponse> broadcastElectrumTransaction($pb.ServerContext ctx, $3.BroadcastElectrumTransactionRequest request);
  $async.Future<$3.EnumerateHardwareDevicesResponse> enumerateHardwareDevices($pb.ServerContext ctx, $3.EnumerateHardwareDevicesRequest request);
  $async.Future<$3.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $3.GetHardwareXpubRequest request);
  $async.Future<$3.SignPsbtWithDeviceResponse> signPsbtWithDevice($pb.ServerContext ctx, $3.SignPsbtWithDeviceRequest request);
  $async.Future<$3.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $3.PromptDevicePinRequest request);
  $async.Future<$3.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $3.SendDevicePinRequest request);
  $async.Future<$3.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $3.CloseDeviceRequest request);
  $async.Future<$3.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $3.DeriveKeystoreRequest request);
  $async.Future<$3.PreviewWalletFromEntropyResponse> previewWalletFromEntropy($pb.ServerContext ctx, $3.PreviewWalletFromEntropyRequest request);
  $async.Future<$3.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $3.GetWalletSeedRequest request);
  $async.Future<$3.ListCoreVariantsResponse> listCoreVariants($pb.ServerContext ctx, $3.ListCoreVariantsRequest request);
  $async.Future<$3.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $3.GetCoreVariantRequest request);
  $async.Future<$3.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $3.SetCoreVariantRequest request);
  $async.Future<$3.GetElectrumServerResponse> getElectrumServer($pb.ServerContext ctx, $3.GetElectrumServerRequest request);
  $async.Future<$3.SetElectrumServerResponse> setElectrumServer($pb.ServerContext ctx, $3.SetElectrumServerRequest request);
  $async.Future<$3.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $3.GetTorConfigRequest request);
  $async.Future<$3.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $3.SetTorConfigRequest request);
  $async.Future<$3.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $2.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $3.GetWalletStatusRequest();
      case 'ListSidechainDeposits': return $3.ListSidechainDepositsRequest();
      case 'GetNodeMode': return $3.GetNodeModeRequest();
      case 'SetNodeMode': return $3.SetNodeModeRequest();
      case 'GenerateWallet': return $3.GenerateWalletRequest();
      case 'UnlockWallet': return $3.UnlockWalletRequest();
      case 'LockWallet': return $3.LockWalletRequest();
      case 'EncryptWallet': return $3.EncryptWalletRequest();
      case 'ChangePassword': return $3.ChangePasswordRequest();
      case 'RemoveEncryption': return $3.RemoveEncryptionRequest();
      case 'ListWallets': return $3.ListWalletsRequest();
      case 'SwitchWallet': return $3.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $3.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $3.DeleteWalletRequest();
      case 'DeleteAllWallets': return $3.DeleteAllWalletsRequest();
      case 'ListWalletBackups': return $3.ListWalletBackupsRequest();
      case 'RestoreWalletBackup': return $3.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream': return $3.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet': return $3.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet': return $3.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet': return $3.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig': return $3.ParseMultisigConfigRequest();
      case 'ValidateDescriptor': return $3.ValidateDescriptorRequest();
      case 'ValidateDerivationPath': return $3.ValidateDerivationPathRequest();
      case 'ListDerivationPaths': return $3.ListDerivationPathsRequest();
      case 'CreateBitcoinCoreWallet': return $3.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $3.EnsureCoreWalletsRequest();
      case 'GetBalance': return $3.GetBalanceRequest();
      case 'RescanWallet': return $3.RescanWalletRequest();
      case 'EstimateFee': return $3.EstimateFeeRequest();
      case 'GetNewAddress': return $3.GetNewAddressRequest();
      case 'SendTransaction': return $3.SendTransactionRequest();
      case 'CreateDeposit': return $3.CreateDepositRequest();
      case 'ListTransactions': return $3.ListTransactionsRequest();
      case 'ListUnspent': return $3.ListUnspentRequest();
      case 'ListReceiveAddresses': return $3.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $3.GetTransactionDetailsRequest();
      case 'DecodeTransaction': return $3.DecodeTransactionRequest();
      case 'BumpFee': return $3.BumpFeeRequest();
      case 'CreateCpfp': return $3.CreateCpfpRequest();
      case 'DeriveAddresses': return $3.DeriveAddressesRequest();
      case 'CreatePsbt': return $3.CreatePsbtRequest();
      case 'SignPsbt': return $3.SignPsbtRequest();
      case 'SignPsbtWithCosigner': return $3.SignPsbtWithCosignerRequest();
      case 'CombinePsbt': return $3.CombinePsbtRequest();
      case 'FinalizePsbt': return $3.FinalizePsbtRequest();
      case 'MultisigPsbtStatus': return $3.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction': return $3.BroadcastTransactionRequest();
      case 'GetAddressUnspent': return $3.GetAddressUnspentRequest();
      case 'BroadcastElectrumTransaction': return $3.BroadcastElectrumTransactionRequest();
      case 'EnumerateHardwareDevices': return $3.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub': return $3.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice': return $3.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin': return $3.PromptDevicePinRequest();
      case 'SendDevicePin': return $3.SendDevicePinRequest();
      case 'CloseDevice': return $3.CloseDeviceRequest();
      case 'DeriveKeystore': return $3.DeriveKeystoreRequest();
      case 'PreviewWalletFromEntropy': return $3.PreviewWalletFromEntropyRequest();
      case 'GetWalletSeed': return $3.GetWalletSeedRequest();
      case 'ListCoreVariants': return $3.ListCoreVariantsRequest();
      case 'GetCoreVariant': return $3.GetCoreVariantRequest();
      case 'SetCoreVariant': return $3.SetCoreVariantRequest();
      case 'GetElectrumServer': return $3.GetElectrumServerRequest();
      case 'SetElectrumServer': return $3.SetElectrumServerRequest();
      case 'GetTorConfig': return $3.GetTorConfigRequest();
      case 'SetTorConfig': return $3.SetTorConfigRequest();
      case 'WatchWalletData': return $2.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $3.GetWalletStatusRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $3.ListSidechainDepositsRequest);
      case 'GetNodeMode': return this.getNodeMode(ctx, request as $3.GetNodeModeRequest);
      case 'SetNodeMode': return this.setNodeMode(ctx, request as $3.SetNodeModeRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $3.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $3.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $3.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $3.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $3.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $3.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $3.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $3.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $3.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $3.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $3.DeleteAllWalletsRequest);
      case 'ListWalletBackups': return this.listWalletBackups(ctx, request as $3.ListWalletBackupsRequest);
      case 'RestoreWalletBackup': return this.restoreWalletBackup(ctx, request as $3.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream': return this.restoreWalletBackupStream(ctx, request as $3.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $3.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet': return this.createElectrumWallet(ctx, request as $3.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet': return this.createMultisigWallet(ctx, request as $3.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig': return this.parseMultisigConfig(ctx, request as $3.ParseMultisigConfigRequest);
      case 'ValidateDescriptor': return this.validateDescriptor(ctx, request as $3.ValidateDescriptorRequest);
      case 'ValidateDerivationPath': return this.validateDerivationPath(ctx, request as $3.ValidateDerivationPathRequest);
      case 'ListDerivationPaths': return this.listDerivationPaths(ctx, request as $3.ListDerivationPathsRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $3.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $3.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $3.GetBalanceRequest);
      case 'RescanWallet': return this.rescanWallet(ctx, request as $3.RescanWalletRequest);
      case 'EstimateFee': return this.estimateFee(ctx, request as $3.EstimateFeeRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $3.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $3.SendTransactionRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $3.CreateDepositRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $3.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $3.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $3.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $3.GetTransactionDetailsRequest);
      case 'DecodeTransaction': return this.decodeTransaction(ctx, request as $3.DecodeTransactionRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $3.BumpFeeRequest);
      case 'CreateCpfp': return this.createCpfp(ctx, request as $3.CreateCpfpRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $3.DeriveAddressesRequest);
      case 'CreatePsbt': return this.createPsbt(ctx, request as $3.CreatePsbtRequest);
      case 'SignPsbt': return this.signPsbt(ctx, request as $3.SignPsbtRequest);
      case 'SignPsbtWithCosigner': return this.signPsbtWithCosigner(ctx, request as $3.SignPsbtWithCosignerRequest);
      case 'CombinePsbt': return this.combinePsbt(ctx, request as $3.CombinePsbtRequest);
      case 'FinalizePsbt': return this.finalizePsbt(ctx, request as $3.FinalizePsbtRequest);
      case 'MultisigPsbtStatus': return this.multisigPsbtStatus(ctx, request as $3.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction': return this.broadcastTransaction(ctx, request as $3.BroadcastTransactionRequest);
      case 'GetAddressUnspent': return this.getAddressUnspent(ctx, request as $3.GetAddressUnspentRequest);
      case 'BroadcastElectrumTransaction': return this.broadcastElectrumTransaction(ctx, request as $3.BroadcastElectrumTransactionRequest);
      case 'EnumerateHardwareDevices': return this.enumerateHardwareDevices(ctx, request as $3.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub': return this.getHardwareXpub(ctx, request as $3.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice': return this.signPsbtWithDevice(ctx, request as $3.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin': return this.promptDevicePin(ctx, request as $3.PromptDevicePinRequest);
      case 'SendDevicePin': return this.sendDevicePin(ctx, request as $3.SendDevicePinRequest);
      case 'CloseDevice': return this.closeDevice(ctx, request as $3.CloseDeviceRequest);
      case 'DeriveKeystore': return this.deriveKeystore(ctx, request as $3.DeriveKeystoreRequest);
      case 'PreviewWalletFromEntropy': return this.previewWalletFromEntropy(ctx, request as $3.PreviewWalletFromEntropyRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $3.GetWalletSeedRequest);
      case 'ListCoreVariants': return this.listCoreVariants(ctx, request as $3.ListCoreVariantsRequest);
      case 'GetCoreVariant': return this.getCoreVariant(ctx, request as $3.GetCoreVariantRequest);
      case 'SetCoreVariant': return this.setCoreVariant(ctx, request as $3.SetCoreVariantRequest);
      case 'GetElectrumServer': return this.getElectrumServer(ctx, request as $3.GetElectrumServerRequest);
      case 'SetElectrumServer': return this.setElectrumServer(ctx, request as $3.SetElectrumServerRequest);
      case 'GetTorConfig': return this.getTorConfig(ctx, request as $3.GetTorConfigRequest);
      case 'SetTorConfig': return this.setTorConfig(ctx, request as $3.SetTorConfigRequest);
      case 'WatchWalletData': return this.watchWalletData(ctx, request as $2.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

