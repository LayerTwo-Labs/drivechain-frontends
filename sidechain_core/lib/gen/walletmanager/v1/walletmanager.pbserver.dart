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

import '../../google/protobuf/empty.pb.dart' as $5;
import 'walletmanager.pb.dart' as $6;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$6.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $6.GetWalletStatusRequest request);
  $async.Future<$6.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $6.ListSidechainDepositsRequest request);
  $async.Future<$6.GetSidechainDepositTotalsResponse> getSidechainDepositTotals($pb.ServerContext ctx, $6.GetSidechainDepositTotalsRequest request);
  $async.Future<$6.GetNodeModeResponse> getNodeMode($pb.ServerContext ctx, $6.GetNodeModeRequest request);
  $async.Future<$6.SetNodeModeResponse> setNodeMode($pb.ServerContext ctx, $6.SetNodeModeRequest request);
  $async.Future<$6.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $6.GenerateWalletRequest request);
  $async.Future<$6.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $6.UnlockWalletRequest request);
  $async.Future<$6.LockWalletResponse> lockWallet($pb.ServerContext ctx, $6.LockWalletRequest request);
  $async.Future<$6.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $6.EncryptWalletRequest request);
  $async.Future<$6.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $6.ChangePasswordRequest request);
  $async.Future<$6.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $6.RemoveEncryptionRequest request);
  $async.Future<$6.ListWalletsResponse> listWallets($pb.ServerContext ctx, $6.ListWalletsRequest request);
  $async.Future<$6.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $6.SwitchWalletRequest request);
  $async.Future<$6.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $6.UpdateWalletMetadataRequest request);
  $async.Future<$6.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $6.DeleteWalletRequest request);
  $async.Future<$6.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $6.DeleteAllWalletsRequest request);
  $async.Future<$6.ListWalletBackupsResponse> listWalletBackups($pb.ServerContext ctx, $6.ListWalletBackupsRequest request);
  $async.Future<$6.RestoreWalletBackupResponse> restoreWalletBackup($pb.ServerContext ctx, $6.RestoreWalletBackupRequest request);
  $async.Future<$6.RestoreWalletBackupProgressResponse> restoreWalletBackupStream($pb.ServerContext ctx, $6.RestoreWalletBackupRequest request);
  $async.Future<$6.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $6.CreateWatchOnlyWalletRequest request);
  $async.Future<$6.CreateElectrumWalletResponse> createElectrumWallet($pb.ServerContext ctx, $6.CreateElectrumWalletRequest request);
  $async.Future<$6.CreateMultisigWalletResponse> createMultisigWallet($pb.ServerContext ctx, $6.CreateMultisigWalletRequest request);
  $async.Future<$6.ParseMultisigConfigResponse> parseMultisigConfig($pb.ServerContext ctx, $6.ParseMultisigConfigRequest request);
  $async.Future<$6.ValidateDescriptorResponse> validateDescriptor($pb.ServerContext ctx, $6.ValidateDescriptorRequest request);
  $async.Future<$6.ValidateDerivationPathResponse> validateDerivationPath($pb.ServerContext ctx, $6.ValidateDerivationPathRequest request);
  $async.Future<$6.ListDerivationPathsResponse> listDerivationPaths($pb.ServerContext ctx, $6.ListDerivationPathsRequest request);
  $async.Future<$6.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $6.CreateBitcoinCoreWalletRequest request);
  $async.Future<$6.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $6.EnsureCoreWalletsRequest request);
  $async.Future<$6.GetBalanceResponse> getBalance($pb.ServerContext ctx, $6.GetBalanceRequest request);
  $async.Future<$6.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $6.RescanWalletRequest request);
  $async.Future<$6.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $6.EstimateFeeRequest request);
  $async.Future<$6.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $6.GetNewAddressRequest request);
  $async.Future<$6.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $6.SendTransactionRequest request);
  $async.Future<$6.PreviewSendResponse> previewSend($pb.ServerContext ctx, $6.PreviewSendRequest request);
  $async.Future<$5.Empty> setFrozenCoins($pb.ServerContext ctx, $6.SetFrozenCoinsRequest request);
  $async.Future<$6.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $6.CreateDepositRequest request);
  $async.Future<$6.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $6.ListTransactionsRequest request);
  $async.Future<$6.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $6.ListUnspentRequest request);
  $async.Future<$6.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $6.ListReceiveAddressesRequest request);
  $async.Future<$6.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $6.GetTransactionDetailsRequest request);
  $async.Future<$6.DecodeTransactionResponse> decodeTransaction($pb.ServerContext ctx, $6.DecodeTransactionRequest request);
  $async.Future<$6.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $6.BumpFeeRequest request);
  $async.Future<$6.PreviewBumpFeeResponse> previewBumpFee($pb.ServerContext ctx, $6.PreviewBumpFeeRequest request);
  $async.Future<$6.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $6.CreateCpfpRequest request);
  $async.Future<$6.CancelTransactionResponse> cancelTransaction($pb.ServerContext ctx, $6.CancelTransactionRequest request);
  $async.Future<$6.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $6.DeriveAddressesRequest request);
  $async.Future<$6.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $6.CreatePsbtRequest request);
  $async.Future<$6.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $6.SignPsbtRequest request);
  $async.Future<$6.SignPsbtWithCosignerResponse> signPsbtWithCosigner($pb.ServerContext ctx, $6.SignPsbtWithCosignerRequest request);
  $async.Future<$6.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $6.CombinePsbtRequest request);
  $async.Future<$6.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $6.FinalizePsbtRequest request);
  $async.Future<$6.MultisigPsbtStatusResponse> multisigPsbtStatus($pb.ServerContext ctx, $6.MultisigPsbtStatusRequest request);
  $async.Future<$6.BroadcastTransactionResponse> broadcastTransaction($pb.ServerContext ctx, $6.BroadcastTransactionRequest request);
  $async.Future<$6.GetAddressUnspentResponse> getAddressUnspent($pb.ServerContext ctx, $6.GetAddressUnspentRequest request);
  $async.Future<$6.BroadcastElectrumTransactionResponse> broadcastElectrumTransaction($pb.ServerContext ctx, $6.BroadcastElectrumTransactionRequest request);
  $async.Future<$6.EnumerateHardwareDevicesResponse> enumerateHardwareDevices($pb.ServerContext ctx, $6.EnumerateHardwareDevicesRequest request);
  $async.Future<$6.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $6.GetHardwareXpubRequest request);
  $async.Future<$6.SignPsbtWithDeviceResponse> signPsbtWithDevice($pb.ServerContext ctx, $6.SignPsbtWithDeviceRequest request);
  $async.Future<$6.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $6.PromptDevicePinRequest request);
  $async.Future<$6.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $6.SendDevicePinRequest request);
  $async.Future<$6.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $6.CloseDeviceRequest request);
  $async.Future<$6.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $6.DeriveKeystoreRequest request);
  $async.Future<$6.PreviewWalletFromEntropyResponse> previewWalletFromEntropy($pb.ServerContext ctx, $6.PreviewWalletFromEntropyRequest request);
  $async.Future<$6.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $6.GetWalletSeedRequest request);
  $async.Future<$6.ListCoreVariantsResponse> listCoreVariants($pb.ServerContext ctx, $6.ListCoreVariantsRequest request);
  $async.Future<$6.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $6.GetCoreVariantRequest request);
  $async.Future<$6.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $6.SetCoreVariantRequest request);
  $async.Future<$6.GetElectrumServerResponse> getElectrumServer($pb.ServerContext ctx, $6.GetElectrumServerRequest request);
  $async.Future<$6.SetElectrumServerResponse> setElectrumServer($pb.ServerContext ctx, $6.SetElectrumServerRequest request);
  $async.Future<$6.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $6.GetTorConfigRequest request);
  $async.Future<$6.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $6.SetTorConfigRequest request);
  $async.Future<$6.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $5.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $6.GetWalletStatusRequest();
      case 'ListSidechainDeposits': return $6.ListSidechainDepositsRequest();
      case 'GetSidechainDepositTotals': return $6.GetSidechainDepositTotalsRequest();
      case 'GetNodeMode': return $6.GetNodeModeRequest();
      case 'SetNodeMode': return $6.SetNodeModeRequest();
      case 'GenerateWallet': return $6.GenerateWalletRequest();
      case 'UnlockWallet': return $6.UnlockWalletRequest();
      case 'LockWallet': return $6.LockWalletRequest();
      case 'EncryptWallet': return $6.EncryptWalletRequest();
      case 'ChangePassword': return $6.ChangePasswordRequest();
      case 'RemoveEncryption': return $6.RemoveEncryptionRequest();
      case 'ListWallets': return $6.ListWalletsRequest();
      case 'SwitchWallet': return $6.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $6.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $6.DeleteWalletRequest();
      case 'DeleteAllWallets': return $6.DeleteAllWalletsRequest();
      case 'ListWalletBackups': return $6.ListWalletBackupsRequest();
      case 'RestoreWalletBackup': return $6.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream': return $6.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet': return $6.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet': return $6.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet': return $6.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig': return $6.ParseMultisigConfigRequest();
      case 'ValidateDescriptor': return $6.ValidateDescriptorRequest();
      case 'ValidateDerivationPath': return $6.ValidateDerivationPathRequest();
      case 'ListDerivationPaths': return $6.ListDerivationPathsRequest();
      case 'CreateBitcoinCoreWallet': return $6.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $6.EnsureCoreWalletsRequest();
      case 'GetBalance': return $6.GetBalanceRequest();
      case 'RescanWallet': return $6.RescanWalletRequest();
      case 'EstimateFee': return $6.EstimateFeeRequest();
      case 'GetNewAddress': return $6.GetNewAddressRequest();
      case 'SendTransaction': return $6.SendTransactionRequest();
      case 'PreviewSend': return $6.PreviewSendRequest();
      case 'SetFrozenCoins': return $6.SetFrozenCoinsRequest();
      case 'CreateDeposit': return $6.CreateDepositRequest();
      case 'ListTransactions': return $6.ListTransactionsRequest();
      case 'ListUnspent': return $6.ListUnspentRequest();
      case 'ListReceiveAddresses': return $6.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $6.GetTransactionDetailsRequest();
      case 'DecodeTransaction': return $6.DecodeTransactionRequest();
      case 'BumpFee': return $6.BumpFeeRequest();
      case 'PreviewBumpFee': return $6.PreviewBumpFeeRequest();
      case 'CreateCpfp': return $6.CreateCpfpRequest();
      case 'CancelTransaction': return $6.CancelTransactionRequest();
      case 'DeriveAddresses': return $6.DeriveAddressesRequest();
      case 'CreatePsbt': return $6.CreatePsbtRequest();
      case 'SignPsbt': return $6.SignPsbtRequest();
      case 'SignPsbtWithCosigner': return $6.SignPsbtWithCosignerRequest();
      case 'CombinePsbt': return $6.CombinePsbtRequest();
      case 'FinalizePsbt': return $6.FinalizePsbtRequest();
      case 'MultisigPsbtStatus': return $6.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction': return $6.BroadcastTransactionRequest();
      case 'GetAddressUnspent': return $6.GetAddressUnspentRequest();
      case 'BroadcastElectrumTransaction': return $6.BroadcastElectrumTransactionRequest();
      case 'EnumerateHardwareDevices': return $6.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub': return $6.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice': return $6.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin': return $6.PromptDevicePinRequest();
      case 'SendDevicePin': return $6.SendDevicePinRequest();
      case 'CloseDevice': return $6.CloseDeviceRequest();
      case 'DeriveKeystore': return $6.DeriveKeystoreRequest();
      case 'PreviewWalletFromEntropy': return $6.PreviewWalletFromEntropyRequest();
      case 'GetWalletSeed': return $6.GetWalletSeedRequest();
      case 'ListCoreVariants': return $6.ListCoreVariantsRequest();
      case 'GetCoreVariant': return $6.GetCoreVariantRequest();
      case 'SetCoreVariant': return $6.SetCoreVariantRequest();
      case 'GetElectrumServer': return $6.GetElectrumServerRequest();
      case 'SetElectrumServer': return $6.SetElectrumServerRequest();
      case 'GetTorConfig': return $6.GetTorConfigRequest();
      case 'SetTorConfig': return $6.SetTorConfigRequest();
      case 'WatchWalletData': return $5.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $6.GetWalletStatusRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $6.ListSidechainDepositsRequest);
      case 'GetSidechainDepositTotals': return this.getSidechainDepositTotals(ctx, request as $6.GetSidechainDepositTotalsRequest);
      case 'GetNodeMode': return this.getNodeMode(ctx, request as $6.GetNodeModeRequest);
      case 'SetNodeMode': return this.setNodeMode(ctx, request as $6.SetNodeModeRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $6.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $6.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $6.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $6.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $6.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $6.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $6.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $6.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $6.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $6.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $6.DeleteAllWalletsRequest);
      case 'ListWalletBackups': return this.listWalletBackups(ctx, request as $6.ListWalletBackupsRequest);
      case 'RestoreWalletBackup': return this.restoreWalletBackup(ctx, request as $6.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream': return this.restoreWalletBackupStream(ctx, request as $6.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $6.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet': return this.createElectrumWallet(ctx, request as $6.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet': return this.createMultisigWallet(ctx, request as $6.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig': return this.parseMultisigConfig(ctx, request as $6.ParseMultisigConfigRequest);
      case 'ValidateDescriptor': return this.validateDescriptor(ctx, request as $6.ValidateDescriptorRequest);
      case 'ValidateDerivationPath': return this.validateDerivationPath(ctx, request as $6.ValidateDerivationPathRequest);
      case 'ListDerivationPaths': return this.listDerivationPaths(ctx, request as $6.ListDerivationPathsRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $6.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $6.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $6.GetBalanceRequest);
      case 'RescanWallet': return this.rescanWallet(ctx, request as $6.RescanWalletRequest);
      case 'EstimateFee': return this.estimateFee(ctx, request as $6.EstimateFeeRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $6.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $6.SendTransactionRequest);
      case 'PreviewSend': return this.previewSend(ctx, request as $6.PreviewSendRequest);
      case 'SetFrozenCoins': return this.setFrozenCoins(ctx, request as $6.SetFrozenCoinsRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $6.CreateDepositRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $6.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $6.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $6.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $6.GetTransactionDetailsRequest);
      case 'DecodeTransaction': return this.decodeTransaction(ctx, request as $6.DecodeTransactionRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $6.BumpFeeRequest);
      case 'PreviewBumpFee': return this.previewBumpFee(ctx, request as $6.PreviewBumpFeeRequest);
      case 'CreateCpfp': return this.createCpfp(ctx, request as $6.CreateCpfpRequest);
      case 'CancelTransaction': return this.cancelTransaction(ctx, request as $6.CancelTransactionRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $6.DeriveAddressesRequest);
      case 'CreatePsbt': return this.createPsbt(ctx, request as $6.CreatePsbtRequest);
      case 'SignPsbt': return this.signPsbt(ctx, request as $6.SignPsbtRequest);
      case 'SignPsbtWithCosigner': return this.signPsbtWithCosigner(ctx, request as $6.SignPsbtWithCosignerRequest);
      case 'CombinePsbt': return this.combinePsbt(ctx, request as $6.CombinePsbtRequest);
      case 'FinalizePsbt': return this.finalizePsbt(ctx, request as $6.FinalizePsbtRequest);
      case 'MultisigPsbtStatus': return this.multisigPsbtStatus(ctx, request as $6.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction': return this.broadcastTransaction(ctx, request as $6.BroadcastTransactionRequest);
      case 'GetAddressUnspent': return this.getAddressUnspent(ctx, request as $6.GetAddressUnspentRequest);
      case 'BroadcastElectrumTransaction': return this.broadcastElectrumTransaction(ctx, request as $6.BroadcastElectrumTransactionRequest);
      case 'EnumerateHardwareDevices': return this.enumerateHardwareDevices(ctx, request as $6.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub': return this.getHardwareXpub(ctx, request as $6.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice': return this.signPsbtWithDevice(ctx, request as $6.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin': return this.promptDevicePin(ctx, request as $6.PromptDevicePinRequest);
      case 'SendDevicePin': return this.sendDevicePin(ctx, request as $6.SendDevicePinRequest);
      case 'CloseDevice': return this.closeDevice(ctx, request as $6.CloseDeviceRequest);
      case 'DeriveKeystore': return this.deriveKeystore(ctx, request as $6.DeriveKeystoreRequest);
      case 'PreviewWalletFromEntropy': return this.previewWalletFromEntropy(ctx, request as $6.PreviewWalletFromEntropyRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $6.GetWalletSeedRequest);
      case 'ListCoreVariants': return this.listCoreVariants(ctx, request as $6.ListCoreVariantsRequest);
      case 'GetCoreVariant': return this.getCoreVariant(ctx, request as $6.GetCoreVariantRequest);
      case 'SetCoreVariant': return this.setCoreVariant(ctx, request as $6.SetCoreVariantRequest);
      case 'GetElectrumServer': return this.getElectrumServer(ctx, request as $6.GetElectrumServerRequest);
      case 'SetElectrumServer': return this.setElectrumServer(ctx, request as $6.SetElectrumServerRequest);
      case 'GetTorConfig': return this.getTorConfig(ctx, request as $6.GetTorConfigRequest);
      case 'SetTorConfig': return this.setTorConfig(ctx, request as $6.SetTorConfigRequest);
      case 'WatchWalletData': return this.watchWalletData(ctx, request as $5.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

