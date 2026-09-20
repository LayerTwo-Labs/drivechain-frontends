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

import '../../google/protobuf/empty.pb.dart' as $18;
import 'walletmanager.pb.dart' as $19;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$19.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $19.GetWalletStatusRequest request);
  $async.Future<$19.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $19.ListSidechainDepositsRequest request);
  $async.Future<$19.GetSidechainDepositTotalsResponse> getSidechainDepositTotals($pb.ServerContext ctx, $19.GetSidechainDepositTotalsRequest request);
  $async.Future<$19.GetNodeModeResponse> getNodeMode($pb.ServerContext ctx, $19.GetNodeModeRequest request);
  $async.Future<$19.EnsureSidechainStarterResponse> ensureSidechainStarter($pb.ServerContext ctx, $19.EnsureSidechainStarterRequest request);
  $async.Future<$19.SetNodeModeResponse> setNodeMode($pb.ServerContext ctx, $19.SetNodeModeRequest request);
  $async.Future<$19.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $19.GenerateWalletRequest request);
  $async.Future<$19.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $19.UnlockWalletRequest request);
  $async.Future<$19.LockWalletResponse> lockWallet($pb.ServerContext ctx, $19.LockWalletRequest request);
  $async.Future<$19.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $19.EncryptWalletRequest request);
  $async.Future<$19.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $19.ChangePasswordRequest request);
  $async.Future<$19.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $19.RemoveEncryptionRequest request);
  $async.Future<$19.ListWalletsResponse> listWallets($pb.ServerContext ctx, $19.ListWalletsRequest request);
  $async.Future<$19.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $19.SwitchWalletRequest request);
  $async.Future<$19.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $19.UpdateWalletMetadataRequest request);
  $async.Future<$19.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $19.DeleteWalletRequest request);
  $async.Future<$19.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $19.DeleteAllWalletsRequest request);
  $async.Future<$19.ListWalletBackupsResponse> listWalletBackups($pb.ServerContext ctx, $19.ListWalletBackupsRequest request);
  $async.Future<$19.RestoreWalletBackupResponse> restoreWalletBackup($pb.ServerContext ctx, $19.RestoreWalletBackupRequest request);
  $async.Future<$19.RestoreWalletBackupProgressResponse> restoreWalletBackupStream($pb.ServerContext ctx, $19.RestoreWalletBackupRequest request);
  $async.Future<$19.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $19.CreateWatchOnlyWalletRequest request);
  $async.Future<$19.CreateElectrumWalletResponse> createElectrumWallet($pb.ServerContext ctx, $19.CreateElectrumWalletRequest request);
  $async.Future<$19.CreateMultisigWalletResponse> createMultisigWallet($pb.ServerContext ctx, $19.CreateMultisigWalletRequest request);
  $async.Future<$19.ParseMultisigConfigResponse> parseMultisigConfig($pb.ServerContext ctx, $19.ParseMultisigConfigRequest request);
  $async.Future<$19.ValidateDescriptorResponse> validateDescriptor($pb.ServerContext ctx, $19.ValidateDescriptorRequest request);
  $async.Future<$19.ValidateDerivationPathResponse> validateDerivationPath($pb.ServerContext ctx, $19.ValidateDerivationPathRequest request);
  $async.Future<$19.ListDerivationPathsResponse> listDerivationPaths($pb.ServerContext ctx, $19.ListDerivationPathsRequest request);
  $async.Future<$19.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $19.CreateBitcoinCoreWalletRequest request);
  $async.Future<$19.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $19.EnsureCoreWalletsRequest request);
  $async.Future<$19.GetBalanceResponse> getBalance($pb.ServerContext ctx, $19.GetBalanceRequest request);
  $async.Future<$19.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $19.RescanWalletRequest request);
  $async.Future<$19.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $19.EstimateFeeRequest request);
  $async.Future<$19.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $19.GetNewAddressRequest request);
  $async.Future<$19.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $19.SendTransactionRequest request);
  $async.Future<$18.Empty> setFrozenCoins($pb.ServerContext ctx, $19.SetFrozenCoinsRequest request);
  $async.Future<$19.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $19.CreateDepositRequest request);
  $async.Future<$19.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $19.ListTransactionsRequest request);
  $async.Future<$19.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $19.ListUnspentRequest request);
  $async.Future<$19.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $19.ListReceiveAddressesRequest request);
  $async.Future<$19.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $19.GetTransactionDetailsRequest request);
  $async.Future<$19.DecodeTransactionResponse> decodeTransaction($pb.ServerContext ctx, $19.DecodeTransactionRequest request);
  $async.Future<$19.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $19.BumpFeeRequest request);
  $async.Future<$19.PreviewBumpFeeResponse> previewBumpFee($pb.ServerContext ctx, $19.PreviewBumpFeeRequest request);
  $async.Future<$19.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $19.CreateCpfpRequest request);
  $async.Future<$19.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $19.DeriveAddressesRequest request);
  $async.Future<$19.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $19.CreatePsbtRequest request);
  $async.Future<$19.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $19.SignPsbtRequest request);
  $async.Future<$19.SignPsbtWithCosignerResponse> signPsbtWithCosigner($pb.ServerContext ctx, $19.SignPsbtWithCosignerRequest request);
  $async.Future<$19.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $19.CombinePsbtRequest request);
  $async.Future<$19.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $19.FinalizePsbtRequest request);
  $async.Future<$19.MultisigPsbtStatusResponse> multisigPsbtStatus($pb.ServerContext ctx, $19.MultisigPsbtStatusRequest request);
  $async.Future<$19.BroadcastTransactionResponse> broadcastTransaction($pb.ServerContext ctx, $19.BroadcastTransactionRequest request);
  $async.Future<$19.GetAddressUnspentResponse> getAddressUnspent($pb.ServerContext ctx, $19.GetAddressUnspentRequest request);
  $async.Future<$19.BroadcastElectrumTransactionResponse> broadcastElectrumTransaction($pb.ServerContext ctx, $19.BroadcastElectrumTransactionRequest request);
  $async.Future<$19.EnumerateHardwareDevicesResponse> enumerateHardwareDevices($pb.ServerContext ctx, $19.EnumerateHardwareDevicesRequest request);
  $async.Future<$19.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $19.GetHardwareXpubRequest request);
  $async.Future<$19.SignPsbtWithDeviceResponse> signPsbtWithDevice($pb.ServerContext ctx, $19.SignPsbtWithDeviceRequest request);
  $async.Future<$19.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $19.PromptDevicePinRequest request);
  $async.Future<$19.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $19.SendDevicePinRequest request);
  $async.Future<$19.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $19.CloseDeviceRequest request);
  $async.Future<$19.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $19.DeriveKeystoreRequest request);
  $async.Future<$19.PreviewWalletFromEntropyResponse> previewWalletFromEntropy($pb.ServerContext ctx, $19.PreviewWalletFromEntropyRequest request);
  $async.Future<$19.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $19.GetWalletSeedRequest request);
  $async.Future<$19.ListCoreVariantsResponse> listCoreVariants($pb.ServerContext ctx, $19.ListCoreVariantsRequest request);
  $async.Future<$19.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $19.GetCoreVariantRequest request);
  $async.Future<$19.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $19.SetCoreVariantRequest request);
  $async.Future<$19.GetElectrumServerResponse> getElectrumServer($pb.ServerContext ctx, $19.GetElectrumServerRequest request);
  $async.Future<$19.SetElectrumServerResponse> setElectrumServer($pb.ServerContext ctx, $19.SetElectrumServerRequest request);
  $async.Future<$19.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $19.GetTorConfigRequest request);
  $async.Future<$19.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $19.SetTorConfigRequest request);
  $async.Future<$19.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $18.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $19.GetWalletStatusRequest();
      case 'ListSidechainDeposits': return $19.ListSidechainDepositsRequest();
      case 'GetSidechainDepositTotals': return $19.GetSidechainDepositTotalsRequest();
      case 'GetNodeMode': return $19.GetNodeModeRequest();
      case 'EnsureSidechainStarter': return $19.EnsureSidechainStarterRequest();
      case 'SetNodeMode': return $19.SetNodeModeRequest();
      case 'GenerateWallet': return $19.GenerateWalletRequest();
      case 'UnlockWallet': return $19.UnlockWalletRequest();
      case 'LockWallet': return $19.LockWalletRequest();
      case 'EncryptWallet': return $19.EncryptWalletRequest();
      case 'ChangePassword': return $19.ChangePasswordRequest();
      case 'RemoveEncryption': return $19.RemoveEncryptionRequest();
      case 'ListWallets': return $19.ListWalletsRequest();
      case 'SwitchWallet': return $19.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $19.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $19.DeleteWalletRequest();
      case 'DeleteAllWallets': return $19.DeleteAllWalletsRequest();
      case 'ListWalletBackups': return $19.ListWalletBackupsRequest();
      case 'RestoreWalletBackup': return $19.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream': return $19.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet': return $19.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet': return $19.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet': return $19.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig': return $19.ParseMultisigConfigRequest();
      case 'ValidateDescriptor': return $19.ValidateDescriptorRequest();
      case 'ValidateDerivationPath': return $19.ValidateDerivationPathRequest();
      case 'ListDerivationPaths': return $19.ListDerivationPathsRequest();
      case 'CreateBitcoinCoreWallet': return $19.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $19.EnsureCoreWalletsRequest();
      case 'GetBalance': return $19.GetBalanceRequest();
      case 'RescanWallet': return $19.RescanWalletRequest();
      case 'EstimateFee': return $19.EstimateFeeRequest();
      case 'GetNewAddress': return $19.GetNewAddressRequest();
      case 'SendTransaction': return $19.SendTransactionRequest();
      case 'SetFrozenCoins': return $19.SetFrozenCoinsRequest();
      case 'CreateDeposit': return $19.CreateDepositRequest();
      case 'ListTransactions': return $19.ListTransactionsRequest();
      case 'ListUnspent': return $19.ListUnspentRequest();
      case 'ListReceiveAddresses': return $19.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $19.GetTransactionDetailsRequest();
      case 'DecodeTransaction': return $19.DecodeTransactionRequest();
      case 'BumpFee': return $19.BumpFeeRequest();
      case 'PreviewBumpFee': return $19.PreviewBumpFeeRequest();
      case 'CreateCpfp': return $19.CreateCpfpRequest();
      case 'DeriveAddresses': return $19.DeriveAddressesRequest();
      case 'CreatePsbt': return $19.CreatePsbtRequest();
      case 'SignPsbt': return $19.SignPsbtRequest();
      case 'SignPsbtWithCosigner': return $19.SignPsbtWithCosignerRequest();
      case 'CombinePsbt': return $19.CombinePsbtRequest();
      case 'FinalizePsbt': return $19.FinalizePsbtRequest();
      case 'MultisigPsbtStatus': return $19.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction': return $19.BroadcastTransactionRequest();
      case 'GetAddressUnspent': return $19.GetAddressUnspentRequest();
      case 'BroadcastElectrumTransaction': return $19.BroadcastElectrumTransactionRequest();
      case 'EnumerateHardwareDevices': return $19.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub': return $19.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice': return $19.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin': return $19.PromptDevicePinRequest();
      case 'SendDevicePin': return $19.SendDevicePinRequest();
      case 'CloseDevice': return $19.CloseDeviceRequest();
      case 'DeriveKeystore': return $19.DeriveKeystoreRequest();
      case 'PreviewWalletFromEntropy': return $19.PreviewWalletFromEntropyRequest();
      case 'GetWalletSeed': return $19.GetWalletSeedRequest();
      case 'ListCoreVariants': return $19.ListCoreVariantsRequest();
      case 'GetCoreVariant': return $19.GetCoreVariantRequest();
      case 'SetCoreVariant': return $19.SetCoreVariantRequest();
      case 'GetElectrumServer': return $19.GetElectrumServerRequest();
      case 'SetElectrumServer': return $19.SetElectrumServerRequest();
      case 'GetTorConfig': return $19.GetTorConfigRequest();
      case 'SetTorConfig': return $19.SetTorConfigRequest();
      case 'WatchWalletData': return $18.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $19.GetWalletStatusRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $19.ListSidechainDepositsRequest);
      case 'GetSidechainDepositTotals': return this.getSidechainDepositTotals(ctx, request as $19.GetSidechainDepositTotalsRequest);
      case 'GetNodeMode': return this.getNodeMode(ctx, request as $19.GetNodeModeRequest);
      case 'EnsureSidechainStarter': return this.ensureSidechainStarter(ctx, request as $19.EnsureSidechainStarterRequest);
      case 'SetNodeMode': return this.setNodeMode(ctx, request as $19.SetNodeModeRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $19.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $19.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $19.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $19.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $19.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $19.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $19.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $19.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $19.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $19.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $19.DeleteAllWalletsRequest);
      case 'ListWalletBackups': return this.listWalletBackups(ctx, request as $19.ListWalletBackupsRequest);
      case 'RestoreWalletBackup': return this.restoreWalletBackup(ctx, request as $19.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream': return this.restoreWalletBackupStream(ctx, request as $19.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $19.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet': return this.createElectrumWallet(ctx, request as $19.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet': return this.createMultisigWallet(ctx, request as $19.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig': return this.parseMultisigConfig(ctx, request as $19.ParseMultisigConfigRequest);
      case 'ValidateDescriptor': return this.validateDescriptor(ctx, request as $19.ValidateDescriptorRequest);
      case 'ValidateDerivationPath': return this.validateDerivationPath(ctx, request as $19.ValidateDerivationPathRequest);
      case 'ListDerivationPaths': return this.listDerivationPaths(ctx, request as $19.ListDerivationPathsRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $19.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $19.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $19.GetBalanceRequest);
      case 'RescanWallet': return this.rescanWallet(ctx, request as $19.RescanWalletRequest);
      case 'EstimateFee': return this.estimateFee(ctx, request as $19.EstimateFeeRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $19.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $19.SendTransactionRequest);
      case 'SetFrozenCoins': return this.setFrozenCoins(ctx, request as $19.SetFrozenCoinsRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $19.CreateDepositRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $19.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $19.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $19.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $19.GetTransactionDetailsRequest);
      case 'DecodeTransaction': return this.decodeTransaction(ctx, request as $19.DecodeTransactionRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $19.BumpFeeRequest);
      case 'PreviewBumpFee': return this.previewBumpFee(ctx, request as $19.PreviewBumpFeeRequest);
      case 'CreateCpfp': return this.createCpfp(ctx, request as $19.CreateCpfpRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $19.DeriveAddressesRequest);
      case 'CreatePsbt': return this.createPsbt(ctx, request as $19.CreatePsbtRequest);
      case 'SignPsbt': return this.signPsbt(ctx, request as $19.SignPsbtRequest);
      case 'SignPsbtWithCosigner': return this.signPsbtWithCosigner(ctx, request as $19.SignPsbtWithCosignerRequest);
      case 'CombinePsbt': return this.combinePsbt(ctx, request as $19.CombinePsbtRequest);
      case 'FinalizePsbt': return this.finalizePsbt(ctx, request as $19.FinalizePsbtRequest);
      case 'MultisigPsbtStatus': return this.multisigPsbtStatus(ctx, request as $19.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction': return this.broadcastTransaction(ctx, request as $19.BroadcastTransactionRequest);
      case 'GetAddressUnspent': return this.getAddressUnspent(ctx, request as $19.GetAddressUnspentRequest);
      case 'BroadcastElectrumTransaction': return this.broadcastElectrumTransaction(ctx, request as $19.BroadcastElectrumTransactionRequest);
      case 'EnumerateHardwareDevices': return this.enumerateHardwareDevices(ctx, request as $19.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub': return this.getHardwareXpub(ctx, request as $19.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice': return this.signPsbtWithDevice(ctx, request as $19.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin': return this.promptDevicePin(ctx, request as $19.PromptDevicePinRequest);
      case 'SendDevicePin': return this.sendDevicePin(ctx, request as $19.SendDevicePinRequest);
      case 'CloseDevice': return this.closeDevice(ctx, request as $19.CloseDeviceRequest);
      case 'DeriveKeystore': return this.deriveKeystore(ctx, request as $19.DeriveKeystoreRequest);
      case 'PreviewWalletFromEntropy': return this.previewWalletFromEntropy(ctx, request as $19.PreviewWalletFromEntropyRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $19.GetWalletSeedRequest);
      case 'ListCoreVariants': return this.listCoreVariants(ctx, request as $19.ListCoreVariantsRequest);
      case 'GetCoreVariant': return this.getCoreVariant(ctx, request as $19.GetCoreVariantRequest);
      case 'SetCoreVariant': return this.setCoreVariant(ctx, request as $19.SetCoreVariantRequest);
      case 'GetElectrumServer': return this.getElectrumServer(ctx, request as $19.GetElectrumServerRequest);
      case 'SetElectrumServer': return this.setElectrumServer(ctx, request as $19.SetElectrumServerRequest);
      case 'GetTorConfig': return this.getTorConfig(ctx, request as $19.GetTorConfigRequest);
      case 'SetTorConfig': return this.setTorConfig(ctx, request as $19.SetTorConfigRequest);
      case 'WatchWalletData': return this.watchWalletData(ctx, request as $18.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

