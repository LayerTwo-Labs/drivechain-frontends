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

import '../../google/protobuf/empty.pb.dart' as $21;
import 'walletmanager.pb.dart' as $22;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$22.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $22.GetWalletStatusRequest request);
  $async.Future<$22.ListSidechainDepositsResponse> listSidechainDeposits($pb.ServerContext ctx, $22.ListSidechainDepositsRequest request);
  $async.Future<$22.GetSidechainDepositTotalsResponse> getSidechainDepositTotals($pb.ServerContext ctx, $22.GetSidechainDepositTotalsRequest request);
  $async.Future<$22.GetNodeModeResponse> getNodeMode($pb.ServerContext ctx, $22.GetNodeModeRequest request);
  $async.Future<$22.SetNodeModeResponse> setNodeMode($pb.ServerContext ctx, $22.SetNodeModeRequest request);
  $async.Future<$22.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $22.GenerateWalletRequest request);
  $async.Future<$22.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $22.UnlockWalletRequest request);
  $async.Future<$22.LockWalletResponse> lockWallet($pb.ServerContext ctx, $22.LockWalletRequest request);
  $async.Future<$22.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $22.EncryptWalletRequest request);
  $async.Future<$22.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $22.ChangePasswordRequest request);
  $async.Future<$22.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $22.RemoveEncryptionRequest request);
  $async.Future<$22.ListWalletsResponse> listWallets($pb.ServerContext ctx, $22.ListWalletsRequest request);
  $async.Future<$22.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $22.SwitchWalletRequest request);
  $async.Future<$22.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $22.UpdateWalletMetadataRequest request);
  $async.Future<$22.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $22.DeleteWalletRequest request);
  $async.Future<$22.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $22.DeleteAllWalletsRequest request);
  $async.Future<$22.ListWalletBackupsResponse> listWalletBackups($pb.ServerContext ctx, $22.ListWalletBackupsRequest request);
  $async.Future<$22.RestoreWalletBackupResponse> restoreWalletBackup($pb.ServerContext ctx, $22.RestoreWalletBackupRequest request);
  $async.Future<$22.RestoreWalletBackupProgressResponse> restoreWalletBackupStream($pb.ServerContext ctx, $22.RestoreWalletBackupRequest request);
  $async.Future<$22.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $22.CreateWatchOnlyWalletRequest request);
  $async.Future<$22.CreateElectrumWalletResponse> createElectrumWallet($pb.ServerContext ctx, $22.CreateElectrumWalletRequest request);
  $async.Future<$22.CreateMultisigWalletResponse> createMultisigWallet($pb.ServerContext ctx, $22.CreateMultisigWalletRequest request);
  $async.Future<$22.ParseMultisigConfigResponse> parseMultisigConfig($pb.ServerContext ctx, $22.ParseMultisigConfigRequest request);
  $async.Future<$22.ValidateDescriptorResponse> validateDescriptor($pb.ServerContext ctx, $22.ValidateDescriptorRequest request);
  $async.Future<$22.ValidateDerivationPathResponse> validateDerivationPath($pb.ServerContext ctx, $22.ValidateDerivationPathRequest request);
  $async.Future<$22.ListDerivationPathsResponse> listDerivationPaths($pb.ServerContext ctx, $22.ListDerivationPathsRequest request);
  $async.Future<$22.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet($pb.ServerContext ctx, $22.CreateBitcoinCoreWalletRequest request);
  $async.Future<$22.EnsureCoreWalletsResponse> ensureCoreWallets($pb.ServerContext ctx, $22.EnsureCoreWalletsRequest request);
  $async.Future<$22.GetBalanceResponse> getBalance($pb.ServerContext ctx, $22.GetBalanceRequest request);
  $async.Future<$22.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $22.RescanWalletRequest request);
  $async.Future<$22.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $22.EstimateFeeRequest request);
  $async.Future<$22.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $22.GetNewAddressRequest request);
  $async.Future<$22.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $22.SendTransactionRequest request);
  $async.Future<$22.PreviewSendResponse> previewSend($pb.ServerContext ctx, $22.PreviewSendRequest request);
  $async.Future<$21.Empty> setFrozenCoins($pb.ServerContext ctx, $22.SetFrozenCoinsRequest request);
  $async.Future<$22.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $22.CreateDepositRequest request);
  $async.Future<$22.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $22.ListTransactionsRequest request);
  $async.Future<$22.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $22.ListUnspentRequest request);
  $async.Future<$22.ListReceiveAddressesResponse> listReceiveAddresses($pb.ServerContext ctx, $22.ListReceiveAddressesRequest request);
  $async.Future<$22.GetTransactionDetailsResponse> getTransactionDetails($pb.ServerContext ctx, $22.GetTransactionDetailsRequest request);
  $async.Future<$22.DecodeTransactionResponse> decodeTransaction($pb.ServerContext ctx, $22.DecodeTransactionRequest request);
  $async.Future<$22.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $22.BumpFeeRequest request);
  $async.Future<$22.PreviewBumpFeeResponse> previewBumpFee($pb.ServerContext ctx, $22.PreviewBumpFeeRequest request);
  $async.Future<$22.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $22.CreateCpfpRequest request);
  $async.Future<$22.CancelTransactionResponse> cancelTransaction($pb.ServerContext ctx, $22.CancelTransactionRequest request);
  $async.Future<$22.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $22.DeriveAddressesRequest request);
  $async.Future<$22.ListEcxBurnsResponse> listEcxBurns($pb.ServerContext ctx, $22.ListEcxBurnsRequest request);
  $async.Future<$22.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $22.CreatePsbtRequest request);
  $async.Future<$22.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $22.SignPsbtRequest request);
  $async.Future<$22.SignPsbtWithCosignerResponse> signPsbtWithCosigner($pb.ServerContext ctx, $22.SignPsbtWithCosignerRequest request);
  $async.Future<$22.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $22.CombinePsbtRequest request);
  $async.Future<$22.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $22.FinalizePsbtRequest request);
  $async.Future<$22.MultisigPsbtStatusResponse> multisigPsbtStatus($pb.ServerContext ctx, $22.MultisigPsbtStatusRequest request);
  $async.Future<$22.BroadcastTransactionResponse> broadcastTransaction($pb.ServerContext ctx, $22.BroadcastTransactionRequest request);
  $async.Future<$22.GetAddressUnspentResponse> getAddressUnspent($pb.ServerContext ctx, $22.GetAddressUnspentRequest request);
  $async.Future<$22.BroadcastElectrumTransactionResponse> broadcastElectrumTransaction($pb.ServerContext ctx, $22.BroadcastElectrumTransactionRequest request);
  $async.Future<$22.EnumerateHardwareDevicesResponse> enumerateHardwareDevices($pb.ServerContext ctx, $22.EnumerateHardwareDevicesRequest request);
  $async.Future<$22.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $22.GetHardwareXpubRequest request);
  $async.Future<$22.SignPsbtWithDeviceResponse> signPsbtWithDevice($pb.ServerContext ctx, $22.SignPsbtWithDeviceRequest request);
  $async.Future<$22.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $22.PromptDevicePinRequest request);
  $async.Future<$22.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $22.SendDevicePinRequest request);
  $async.Future<$22.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $22.CloseDeviceRequest request);
  $async.Future<$22.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $22.DeriveKeystoreRequest request);
  $async.Future<$22.ExploreSeedResponse> exploreSeed($pb.ServerContext ctx, $22.ExploreSeedRequest request);
  $async.Future<$22.GenerateMnemonicResponse> generateMnemonic($pb.ServerContext ctx, $22.GenerateMnemonicRequest request);
  $async.Future<$22.ValidateMnemonicResponse> validateMnemonic($pb.ServerContext ctx, $22.ValidateMnemonicRequest request);
  $async.Future<$22.PreviewWalletFromEntropyResponse> previewWalletFromEntropy($pb.ServerContext ctx, $22.PreviewWalletFromEntropyRequest request);
  $async.Future<$22.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $22.GetWalletSeedRequest request);
  $async.Future<$22.ListCoreVariantsResponse> listCoreVariants($pb.ServerContext ctx, $22.ListCoreVariantsRequest request);
  $async.Future<$22.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $22.GetCoreVariantRequest request);
  $async.Future<$22.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $22.SetCoreVariantRequest request);
  $async.Future<$22.GetElectrumServerResponse> getElectrumServer($pb.ServerContext ctx, $22.GetElectrumServerRequest request);
  $async.Future<$22.SetElectrumServerResponse> setElectrumServer($pb.ServerContext ctx, $22.SetElectrumServerRequest request);
  $async.Future<$22.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $22.GetTorConfigRequest request);
  $async.Future<$22.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $22.SetTorConfigRequest request);
  $async.Future<$22.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $21.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $22.GetWalletStatusRequest();
      case 'ListSidechainDeposits': return $22.ListSidechainDepositsRequest();
      case 'GetSidechainDepositTotals': return $22.GetSidechainDepositTotalsRequest();
      case 'GetNodeMode': return $22.GetNodeModeRequest();
      case 'SetNodeMode': return $22.SetNodeModeRequest();
      case 'GenerateWallet': return $22.GenerateWalletRequest();
      case 'UnlockWallet': return $22.UnlockWalletRequest();
      case 'LockWallet': return $22.LockWalletRequest();
      case 'EncryptWallet': return $22.EncryptWalletRequest();
      case 'ChangePassword': return $22.ChangePasswordRequest();
      case 'RemoveEncryption': return $22.RemoveEncryptionRequest();
      case 'ListWallets': return $22.ListWalletsRequest();
      case 'SwitchWallet': return $22.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $22.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $22.DeleteWalletRequest();
      case 'DeleteAllWallets': return $22.DeleteAllWalletsRequest();
      case 'ListWalletBackups': return $22.ListWalletBackupsRequest();
      case 'RestoreWalletBackup': return $22.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream': return $22.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet': return $22.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet': return $22.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet': return $22.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig': return $22.ParseMultisigConfigRequest();
      case 'ValidateDescriptor': return $22.ValidateDescriptorRequest();
      case 'ValidateDerivationPath': return $22.ValidateDerivationPathRequest();
      case 'ListDerivationPaths': return $22.ListDerivationPathsRequest();
      case 'CreateBitcoinCoreWallet': return $22.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets': return $22.EnsureCoreWalletsRequest();
      case 'GetBalance': return $22.GetBalanceRequest();
      case 'RescanWallet': return $22.RescanWalletRequest();
      case 'EstimateFee': return $22.EstimateFeeRequest();
      case 'GetNewAddress': return $22.GetNewAddressRequest();
      case 'SendTransaction': return $22.SendTransactionRequest();
      case 'PreviewSend': return $22.PreviewSendRequest();
      case 'SetFrozenCoins': return $22.SetFrozenCoinsRequest();
      case 'CreateDeposit': return $22.CreateDepositRequest();
      case 'ListTransactions': return $22.ListTransactionsRequest();
      case 'ListUnspent': return $22.ListUnspentRequest();
      case 'ListReceiveAddresses': return $22.ListReceiveAddressesRequest();
      case 'GetTransactionDetails': return $22.GetTransactionDetailsRequest();
      case 'DecodeTransaction': return $22.DecodeTransactionRequest();
      case 'BumpFee': return $22.BumpFeeRequest();
      case 'PreviewBumpFee': return $22.PreviewBumpFeeRequest();
      case 'CreateCpfp': return $22.CreateCpfpRequest();
      case 'CancelTransaction': return $22.CancelTransactionRequest();
      case 'DeriveAddresses': return $22.DeriveAddressesRequest();
      case 'ListEcxBurns': return $22.ListEcxBurnsRequest();
      case 'CreatePsbt': return $22.CreatePsbtRequest();
      case 'SignPsbt': return $22.SignPsbtRequest();
      case 'SignPsbtWithCosigner': return $22.SignPsbtWithCosignerRequest();
      case 'CombinePsbt': return $22.CombinePsbtRequest();
      case 'FinalizePsbt': return $22.FinalizePsbtRequest();
      case 'MultisigPsbtStatus': return $22.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction': return $22.BroadcastTransactionRequest();
      case 'GetAddressUnspent': return $22.GetAddressUnspentRequest();
      case 'BroadcastElectrumTransaction': return $22.BroadcastElectrumTransactionRequest();
      case 'EnumerateHardwareDevices': return $22.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub': return $22.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice': return $22.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin': return $22.PromptDevicePinRequest();
      case 'SendDevicePin': return $22.SendDevicePinRequest();
      case 'CloseDevice': return $22.CloseDeviceRequest();
      case 'DeriveKeystore': return $22.DeriveKeystoreRequest();
      case 'ExploreSeed': return $22.ExploreSeedRequest();
      case 'GenerateMnemonic': return $22.GenerateMnemonicRequest();
      case 'ValidateMnemonic': return $22.ValidateMnemonicRequest();
      case 'PreviewWalletFromEntropy': return $22.PreviewWalletFromEntropyRequest();
      case 'GetWalletSeed': return $22.GetWalletSeedRequest();
      case 'ListCoreVariants': return $22.ListCoreVariantsRequest();
      case 'GetCoreVariant': return $22.GetCoreVariantRequest();
      case 'SetCoreVariant': return $22.SetCoreVariantRequest();
      case 'GetElectrumServer': return $22.GetElectrumServerRequest();
      case 'SetElectrumServer': return $22.SetElectrumServerRequest();
      case 'GetTorConfig': return $22.GetTorConfigRequest();
      case 'SetTorConfig': return $22.SetTorConfigRequest();
      case 'WatchWalletData': return $21.Empty();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $22.GetWalletStatusRequest);
      case 'ListSidechainDeposits': return this.listSidechainDeposits(ctx, request as $22.ListSidechainDepositsRequest);
      case 'GetSidechainDepositTotals': return this.getSidechainDepositTotals(ctx, request as $22.GetSidechainDepositTotalsRequest);
      case 'GetNodeMode': return this.getNodeMode(ctx, request as $22.GetNodeModeRequest);
      case 'SetNodeMode': return this.setNodeMode(ctx, request as $22.SetNodeModeRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $22.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $22.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $22.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $22.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $22.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $22.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $22.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $22.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $22.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $22.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $22.DeleteAllWalletsRequest);
      case 'ListWalletBackups': return this.listWalletBackups(ctx, request as $22.ListWalletBackupsRequest);
      case 'RestoreWalletBackup': return this.restoreWalletBackup(ctx, request as $22.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream': return this.restoreWalletBackupStream(ctx, request as $22.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $22.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet': return this.createElectrumWallet(ctx, request as $22.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet': return this.createMultisigWallet(ctx, request as $22.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig': return this.parseMultisigConfig(ctx, request as $22.ParseMultisigConfigRequest);
      case 'ValidateDescriptor': return this.validateDescriptor(ctx, request as $22.ValidateDescriptorRequest);
      case 'ValidateDerivationPath': return this.validateDerivationPath(ctx, request as $22.ValidateDerivationPathRequest);
      case 'ListDerivationPaths': return this.listDerivationPaths(ctx, request as $22.ListDerivationPathsRequest);
      case 'CreateBitcoinCoreWallet': return this.createBitcoinCoreWallet(ctx, request as $22.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets': return this.ensureCoreWallets(ctx, request as $22.EnsureCoreWalletsRequest);
      case 'GetBalance': return this.getBalance(ctx, request as $22.GetBalanceRequest);
      case 'RescanWallet': return this.rescanWallet(ctx, request as $22.RescanWalletRequest);
      case 'EstimateFee': return this.estimateFee(ctx, request as $22.EstimateFeeRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $22.GetNewAddressRequest);
      case 'SendTransaction': return this.sendTransaction(ctx, request as $22.SendTransactionRequest);
      case 'PreviewSend': return this.previewSend(ctx, request as $22.PreviewSendRequest);
      case 'SetFrozenCoins': return this.setFrozenCoins(ctx, request as $22.SetFrozenCoinsRequest);
      case 'CreateDeposit': return this.createDeposit(ctx, request as $22.CreateDepositRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $22.ListTransactionsRequest);
      case 'ListUnspent': return this.listUnspent(ctx, request as $22.ListUnspentRequest);
      case 'ListReceiveAddresses': return this.listReceiveAddresses(ctx, request as $22.ListReceiveAddressesRequest);
      case 'GetTransactionDetails': return this.getTransactionDetails(ctx, request as $22.GetTransactionDetailsRequest);
      case 'DecodeTransaction': return this.decodeTransaction(ctx, request as $22.DecodeTransactionRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $22.BumpFeeRequest);
      case 'PreviewBumpFee': return this.previewBumpFee(ctx, request as $22.PreviewBumpFeeRequest);
      case 'CreateCpfp': return this.createCpfp(ctx, request as $22.CreateCpfpRequest);
      case 'CancelTransaction': return this.cancelTransaction(ctx, request as $22.CancelTransactionRequest);
      case 'DeriveAddresses': return this.deriveAddresses(ctx, request as $22.DeriveAddressesRequest);
      case 'ListEcxBurns': return this.listEcxBurns(ctx, request as $22.ListEcxBurnsRequest);
      case 'CreatePsbt': return this.createPsbt(ctx, request as $22.CreatePsbtRequest);
      case 'SignPsbt': return this.signPsbt(ctx, request as $22.SignPsbtRequest);
      case 'SignPsbtWithCosigner': return this.signPsbtWithCosigner(ctx, request as $22.SignPsbtWithCosignerRequest);
      case 'CombinePsbt': return this.combinePsbt(ctx, request as $22.CombinePsbtRequest);
      case 'FinalizePsbt': return this.finalizePsbt(ctx, request as $22.FinalizePsbtRequest);
      case 'MultisigPsbtStatus': return this.multisigPsbtStatus(ctx, request as $22.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction': return this.broadcastTransaction(ctx, request as $22.BroadcastTransactionRequest);
      case 'GetAddressUnspent': return this.getAddressUnspent(ctx, request as $22.GetAddressUnspentRequest);
      case 'BroadcastElectrumTransaction': return this.broadcastElectrumTransaction(ctx, request as $22.BroadcastElectrumTransactionRequest);
      case 'EnumerateHardwareDevices': return this.enumerateHardwareDevices(ctx, request as $22.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub': return this.getHardwareXpub(ctx, request as $22.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice': return this.signPsbtWithDevice(ctx, request as $22.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin': return this.promptDevicePin(ctx, request as $22.PromptDevicePinRequest);
      case 'SendDevicePin': return this.sendDevicePin(ctx, request as $22.SendDevicePinRequest);
      case 'CloseDevice': return this.closeDevice(ctx, request as $22.CloseDeviceRequest);
      case 'DeriveKeystore': return this.deriveKeystore(ctx, request as $22.DeriveKeystoreRequest);
      case 'ExploreSeed': return this.exploreSeed(ctx, request as $22.ExploreSeedRequest);
      case 'GenerateMnemonic': return this.generateMnemonic(ctx, request as $22.GenerateMnemonicRequest);
      case 'ValidateMnemonic': return this.validateMnemonic(ctx, request as $22.ValidateMnemonicRequest);
      case 'PreviewWalletFromEntropy': return this.previewWalletFromEntropy(ctx, request as $22.PreviewWalletFromEntropyRequest);
      case 'GetWalletSeed': return this.getWalletSeed(ctx, request as $22.GetWalletSeedRequest);
      case 'ListCoreVariants': return this.listCoreVariants(ctx, request as $22.ListCoreVariantsRequest);
      case 'GetCoreVariant': return this.getCoreVariant(ctx, request as $22.GetCoreVariantRequest);
      case 'SetCoreVariant': return this.setCoreVariant(ctx, request as $22.SetCoreVariantRequest);
      case 'GetElectrumServer': return this.getElectrumServer(ctx, request as $22.GetElectrumServerRequest);
      case 'SetElectrumServer': return this.setElectrumServer(ctx, request as $22.SetElectrumServerRequest);
      case 'GetTorConfig': return this.getTorConfig(ctx, request as $22.GetTorConfigRequest);
      case 'SetTorConfig': return this.setTorConfig(ctx, request as $22.SetTorConfigRequest);
      case 'WatchWalletData': return this.watchWalletData(ctx, request as $21.Empty);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

