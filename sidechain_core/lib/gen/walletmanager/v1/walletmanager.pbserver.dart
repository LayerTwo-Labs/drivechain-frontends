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

import '../../google/protobuf/empty.pb.dart' as $17;
import 'walletmanager.pb.dart' as $18;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$18.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $18.GetWalletStatusRequest request);
  $async.Future<$18.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $18.ListSidechainDepositsRequest request);
  $async.Future<$18.GetSidechainDepositTotalsResponse> getSidechainDepositTotals($pb.ServerContext ctx, $18.GetSidechainDepositTotalsRequest request);
  $async.Future<$18.GetNodeModeResponse> getNodeMode($pb.ServerContext ctx, $18.GetNodeModeRequest request);
  $async.Future<$18.SetNodeModeResponse> setNodeMode($pb.ServerContext ctx, $18.SetNodeModeRequest request);
  $async.Future<$18.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $18.GenerateWalletRequest request);
  $async.Future<$18.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $18.UnlockWalletRequest request);
  $async.Future<$18.LockWalletResponse> lockWallet($pb.ServerContext ctx, $18.LockWalletRequest request);
  $async.Future<$18.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $18.EncryptWalletRequest request);
  $async.Future<$18.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $18.ChangePasswordRequest request);
  $async.Future<$18.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $18.RemoveEncryptionRequest request);
  $async.Future<$18.ListWalletsResponse> listWallets($pb.ServerContext ctx, $18.ListWalletsRequest request);
  $async.Future<$18.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $18.SwitchWalletRequest request);
  $async.Future<$18.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $18.UpdateWalletMetadataRequest request);
  $async.Future<$18.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $18.DeleteWalletRequest request);
  $async.Future<$18.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $18.DeleteAllWalletsRequest request);
  $async.Future<$18.ListWalletBackupsResponse> listWalletBackups($pb.ServerContext ctx, $18.ListWalletBackupsRequest request);
  $async.Future<$18.RestoreWalletBackupResponse> restoreWalletBackup($pb.ServerContext ctx, $18.RestoreWalletBackupRequest request);
  $async.Future<$18.RestoreWalletBackupProgressResponse> restoreWalletBackupStream($pb.ServerContext ctx, $18.RestoreWalletBackupRequest request);
  $async.Future<$18.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $18.CreateWatchOnlyWalletRequest request);
  $async.Future<$18.CreateElectrumWalletResponse> createElectrumWallet($pb.ServerContext ctx, $18.CreateElectrumWalletRequest request);
  $async.Future<$18.CreateMultisigWalletResponse> createMultisigWallet($pb.ServerContext ctx, $18.CreateMultisigWalletRequest request);
  $async.Future<$18.ParseMultisigConfigResponse> parseMultisigConfig($pb.ServerContext ctx, $18.ParseMultisigConfigRequest request);
  $async.Future<$18.ValidateDescriptorResponse> validateDescriptor($pb.ServerContext ctx, $18.ValidateDescriptorRequest request);
  $async.Future<$18.ValidateDerivationPathResponse> validateDerivationPath($pb.ServerContext ctx, $18.ValidateDerivationPathRequest request);
  $async.Future<$18.ListDerivationPathsResponse> listDerivationPaths($pb.ServerContext ctx, $18.ListDerivationPathsRequest request);
  $async.Future<$18.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $18.CreateBitcoinCoreWalletRequest request);
  $async.Future<$18.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $18.EnsureCoreWalletsRequest request);
  $async.Future<$18.GetBalanceResponse> getBalance($pb.ServerContext ctx, $18.GetBalanceRequest request);
  $async.Future<$18.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $18.RescanWalletRequest request);
  $async.Future<$18.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $18.EstimateFeeRequest request);
  $async.Future<$18.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $18.GetNewAddressRequest request);
  $async.Future<$18.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $18.SendTransactionRequest request);
  $async.Future<$18.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $18.CreateDepositRequest request);
  $async.Future<$18.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $18.ListTransactionsRequest request);
  $async.Future<$18.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $18.ListUnspentRequest request);
  $async.Future<$18.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $18.ListReceiveAddressesRequest request);
  $async.Future<$18.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $18.GetTransactionDetailsRequest request);
  $async.Future<$18.DecodeTransactionResponse> decodeTransaction($pb.ServerContext ctx, $18.DecodeTransactionRequest request);
  $async.Future<$18.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $18.BumpFeeRequest request);
  $async.Future<$18.PreviewBumpFeeResponse> previewBumpFee($pb.ServerContext ctx, $18.PreviewBumpFeeRequest request);
  $async.Future<$18.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $18.CreateCpfpRequest request);
  $async.Future<$18.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $18.DeriveAddressesRequest request);
  $async.Future<$18.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $18.CreatePsbtRequest request);
  $async.Future<$18.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $18.SignPsbtRequest request);
  $async.Future<$18.SignPsbtWithCosignerResponse> signPsbtWithCosigner($pb.ServerContext ctx, $18.SignPsbtWithCosignerRequest request);
  $async.Future<$18.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $18.CombinePsbtRequest request);
  $async.Future<$18.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $18.FinalizePsbtRequest request);
  $async.Future<$18.MultisigPsbtStatusResponse> multisigPsbtStatus($pb.ServerContext ctx, $18.MultisigPsbtStatusRequest request);
  $async.Future<$18.BroadcastTransactionResponse> broadcastTransaction($pb.ServerContext ctx, $18.BroadcastTransactionRequest request);
  $async.Future<$18.GetAddressUnspentResponse> getAddressUnspent($pb.ServerContext ctx, $18.GetAddressUnspentRequest request);
  $async.Future<$18.BroadcastElectrumTransactionResponse> broadcastElectrumTransaction($pb.ServerContext ctx, $18.BroadcastElectrumTransactionRequest request);
  $async.Future<$18.EnumerateHardwareDevicesResponse> enumerateHardwareDevices($pb.ServerContext ctx, $18.EnumerateHardwareDevicesRequest request);
  $async.Future<$18.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $18.GetHardwareXpubRequest request);
  $async.Future<$18.SignPsbtWithDeviceResponse> signPsbtWithDevice($pb.ServerContext ctx, $18.SignPsbtWithDeviceRequest request);
  $async.Future<$18.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $18.PromptDevicePinRequest request);
  $async.Future<$18.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $18.SendDevicePinRequest request);
  $async.Future<$18.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $18.CloseDeviceRequest request);
  $async.Future<$18.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $18.DeriveKeystoreRequest request);
  $async.Future<$18.PreviewWalletFromEntropyResponse> previewWalletFromEntropy($pb.ServerContext ctx, $18.PreviewWalletFromEntropyRequest request);
  $async.Future<$18.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $18.GetWalletSeedRequest request);
  $async.Future<$18.ListCoreVariantsResponse> listCoreVariants($pb.ServerContext ctx, $18.ListCoreVariantsRequest request);
  $async.Future<$18.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $18.GetCoreVariantRequest request);
  $async.Future<$18.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $18.SetCoreVariantRequest request);
  $async.Future<$18.GetElectrumServerResponse> getElectrumServer($pb.ServerContext ctx, $18.GetElectrumServerRequest request);
  $async.Future<$18.SetElectrumServerResponse> setElectrumServer($pb.ServerContext ctx, $18.SetElectrumServerRequest request);
  $async.Future<$18.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $18.GetTorConfigRequest request);
  $async.Future<$18.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $18.SetTorConfigRequest request);
  $async.Future<$18.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $17.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $18.GetWalletStatusRequest();
      case 'ListSidechainDeposits': return $18.ListSidechainDepositsRequest();
      case 'GetSidechainDepositTotals': return $18.GetSidechainDepositTotalsRequest();
      case 'GetNodeMode': return $18.GetNodeModeRequest();
      case 'SetNodeMode': return $18.SetNodeModeRequest();
      case 'GenerateWallet': return $18.GenerateWalletRequest();
      case 'UnlockWallet': return $18.UnlockWalletRequest();
      case 'LockWallet': return $18.LockWalletRequest();
      case 'EncryptWallet': return $18.EncryptWalletRequest();
      case 'ChangePassword': return $18.ChangePasswordRequest();
      case 'RemoveEncryption': return $18.RemoveEncryptionRequest();
      case 'ListWallets': return $18.ListWalletsRequest();
      case 'SwitchWallet': return $18.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $18.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $18.DeleteWalletRequest();
      case 'DeleteAllWallets': return $18.DeleteAllWalletsRequest();
      case 'ListWalletBackups': return $18.ListWalletBackupsRequest();
      case 'RestoreWalletBackup': return $18.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream': return $18.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet': return $18.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet': return $18.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet': return $18.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig': return $18.ParseMultisigConfigRequest();
      case 'ValidateDescriptor': return $18.ValidateDescriptorRequest();
      case 'ValidateDerivationPath': return $18.ValidateDerivationPathRequest();
      case 'ListDerivationPaths': return $18.ListDerivationPathsRequest();
      case 'CreateBitcoinCoreWallet': return $18.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $18.EnsureCoreWalletsRequest();
      case 'GetBalance': return $18.GetBalanceRequest();
      case 'RescanWallet': return $18.RescanWalletRequest();
      case 'EstimateFee': return $18.EstimateFeeRequest();
      case 'GetNewAddress': return $18.GetNewAddressRequest();
      case 'SendTransaction': return $18.SendTransactionRequest();
      case 'CreateDeposit': return $18.CreateDepositRequest();
      case 'ListTransactions': return $18.ListTransactionsRequest();
      case 'ListUnspent': return $18.ListUnspentRequest();
      case 'ListReceiveAddresses': return $18.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $18.GetTransactionDetailsRequest();
      case 'DecodeTransaction': return $18.DecodeTransactionRequest();
      case 'BumpFee': return $18.BumpFeeRequest();
      case 'PreviewBumpFee': return $18.PreviewBumpFeeRequest();
      case 'CreateCpfp': return $18.CreateCpfpRequest();
      case 'DeriveAddresses': return $18.DeriveAddressesRequest();
      case 'CreatePsbt': return $18.CreatePsbtRequest();
      case 'SignPsbt': return $18.SignPsbtRequest();
      case 'SignPsbtWithCosigner': return $18.SignPsbtWithCosignerRequest();
      case 'CombinePsbt': return $18.CombinePsbtRequest();
      case 'FinalizePsbt': return $18.FinalizePsbtRequest();
      case 'MultisigPsbtStatus': return $18.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction': return $18.BroadcastTransactionRequest();
      case 'GetAddressUnspent': return $18.GetAddressUnspentRequest();
      case 'BroadcastElectrumTransaction': return $18.BroadcastElectrumTransactionRequest();
      case 'EnumerateHardwareDevices': return $18.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub': return $18.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice': return $18.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin': return $18.PromptDevicePinRequest();
      case 'SendDevicePin': return $18.SendDevicePinRequest();
      case 'CloseDevice': return $18.CloseDeviceRequest();
      case 'DeriveKeystore': return $18.DeriveKeystoreRequest();
      case 'PreviewWalletFromEntropy': return $18.PreviewWalletFromEntropyRequest();
      case 'GetWalletSeed': return $18.GetWalletSeedRequest();
      case 'ListCoreVariants': return $18.ListCoreVariantsRequest();
      case 'GetCoreVariant': return $18.GetCoreVariantRequest();
      case 'SetCoreVariant': return $18.SetCoreVariantRequest();
      case 'GetElectrumServer': return $18.GetElectrumServerRequest();
      case 'SetElectrumServer': return $18.SetElectrumServerRequest();
      case 'GetTorConfig': return $18.GetTorConfigRequest();
      case 'SetTorConfig': return $18.SetTorConfigRequest();
      case 'WatchWalletData': return $17.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $18.GetWalletStatusRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $18.ListSidechainDepositsRequest);
      case 'GetSidechainDepositTotals': return this.getSidechainDepositTotals(ctx, request as $18.GetSidechainDepositTotalsRequest);
      case 'GetNodeMode': return this.getNodeMode(ctx, request as $18.GetNodeModeRequest);
      case 'SetNodeMode': return this.setNodeMode(ctx, request as $18.SetNodeModeRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $18.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $18.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $18.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $18.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $18.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $18.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $18.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $18.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $18.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $18.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $18.DeleteAllWalletsRequest);
      case 'ListWalletBackups': return this.listWalletBackups(ctx, request as $18.ListWalletBackupsRequest);
      case 'RestoreWalletBackup': return this.restoreWalletBackup(ctx, request as $18.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream': return this.restoreWalletBackupStream(ctx, request as $18.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $18.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet': return this.createElectrumWallet(ctx, request as $18.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet': return this.createMultisigWallet(ctx, request as $18.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig': return this.parseMultisigConfig(ctx, request as $18.ParseMultisigConfigRequest);
      case 'ValidateDescriptor': return this.validateDescriptor(ctx, request as $18.ValidateDescriptorRequest);
      case 'ValidateDerivationPath': return this.validateDerivationPath(ctx, request as $18.ValidateDerivationPathRequest);
      case 'ListDerivationPaths': return this.listDerivationPaths(ctx, request as $18.ListDerivationPathsRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $18.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $18.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $18.GetBalanceRequest);
      case 'RescanWallet': return this.rescanWallet(ctx, request as $18.RescanWalletRequest);
      case 'EstimateFee': return this.estimateFee(ctx, request as $18.EstimateFeeRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $18.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $18.SendTransactionRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $18.CreateDepositRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $18.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $18.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $18.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $18.GetTransactionDetailsRequest);
      case 'DecodeTransaction': return this.decodeTransaction(ctx, request as $18.DecodeTransactionRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $18.BumpFeeRequest);
      case 'PreviewBumpFee': return this.previewBumpFee(ctx, request as $18.PreviewBumpFeeRequest);
      case 'CreateCpfp': return this.createCpfp(ctx, request as $18.CreateCpfpRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $18.DeriveAddressesRequest);
      case 'CreatePsbt': return this.createPsbt(ctx, request as $18.CreatePsbtRequest);
      case 'SignPsbt': return this.signPsbt(ctx, request as $18.SignPsbtRequest);
      case 'SignPsbtWithCosigner': return this.signPsbtWithCosigner(ctx, request as $18.SignPsbtWithCosignerRequest);
      case 'CombinePsbt': return this.combinePsbt(ctx, request as $18.CombinePsbtRequest);
      case 'FinalizePsbt': return this.finalizePsbt(ctx, request as $18.FinalizePsbtRequest);
      case 'MultisigPsbtStatus': return this.multisigPsbtStatus(ctx, request as $18.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction': return this.broadcastTransaction(ctx, request as $18.BroadcastTransactionRequest);
      case 'GetAddressUnspent': return this.getAddressUnspent(ctx, request as $18.GetAddressUnspentRequest);
      case 'BroadcastElectrumTransaction': return this.broadcastElectrumTransaction(ctx, request as $18.BroadcastElectrumTransactionRequest);
      case 'EnumerateHardwareDevices': return this.enumerateHardwareDevices(ctx, request as $18.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub': return this.getHardwareXpub(ctx, request as $18.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice': return this.signPsbtWithDevice(ctx, request as $18.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin': return this.promptDevicePin(ctx, request as $18.PromptDevicePinRequest);
      case 'SendDevicePin': return this.sendDevicePin(ctx, request as $18.SendDevicePinRequest);
      case 'CloseDevice': return this.closeDevice(ctx, request as $18.CloseDeviceRequest);
      case 'DeriveKeystore': return this.deriveKeystore(ctx, request as $18.DeriveKeystoreRequest);
      case 'PreviewWalletFromEntropy': return this.previewWalletFromEntropy(ctx, request as $18.PreviewWalletFromEntropyRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $18.GetWalletSeedRequest);
      case 'ListCoreVariants': return this.listCoreVariants(ctx, request as $18.ListCoreVariantsRequest);
      case 'GetCoreVariant': return this.getCoreVariant(ctx, request as $18.GetCoreVariantRequest);
      case 'SetCoreVariant': return this.setCoreVariant(ctx, request as $18.SetCoreVariantRequest);
      case 'GetElectrumServer': return this.getElectrumServer(ctx, request as $18.GetElectrumServerRequest);
      case 'SetElectrumServer': return this.setElectrumServer(ctx, request as $18.SetElectrumServerRequest);
      case 'GetTorConfig': return this.getTorConfig(ctx, request as $18.GetTorConfigRequest);
      case 'SetTorConfig': return this.setTorConfig(ctx, request as $18.SetTorConfigRequest);
      case 'WatchWalletData': return this.watchWalletData(ctx, request as $17.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

