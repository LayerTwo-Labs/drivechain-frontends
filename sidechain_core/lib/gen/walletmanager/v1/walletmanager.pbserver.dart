// This is a generated file - do not edit.
//
// Generated from walletmanager/v1/walletmanager.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'walletmanager.pb.dart' as $3;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$3.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $3.GetWalletStatusRequest request);
  $async.Future<$3.ListSidechainDepositsResponse> listSidechainDeposits(
      $pb.ServerContext ctx, $3.ListSidechainDepositsRequest request);
  $async.Future<$3.GetSidechainDepositTotalsResponse> getSidechainDepositTotals(
      $pb.ServerContext ctx, $3.GetSidechainDepositTotalsRequest request);
  $async.Future<$3.GetNodeModeResponse> getNodeMode($pb.ServerContext ctx, $3.GetNodeModeRequest request);
  $async.Future<$3.SetNodeModeResponse> setNodeMode($pb.ServerContext ctx, $3.SetNodeModeRequest request);
  $async.Future<$3.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $3.GenerateWalletRequest request);
  $async.Future<$3.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $3.UnlockWalletRequest request);
  $async.Future<$3.LockWalletResponse> lockWallet($pb.ServerContext ctx, $3.LockWalletRequest request);
  $async.Future<$3.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $3.EncryptWalletRequest request);
  $async.Future<$3.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $3.ChangePasswordRequest request);
  $async.Future<$3.RemoveEncryptionResponse> removeEncryption(
      $pb.ServerContext ctx, $3.RemoveEncryptionRequest request);
  $async.Future<$3.ListWalletsResponse> listWallets($pb.ServerContext ctx, $3.ListWalletsRequest request);
  $async.Future<$3.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $3.SwitchWalletRequest request);
  $async.Future<$3.UpdateWalletMetadataResponse> updateWalletMetadata(
      $pb.ServerContext ctx, $3.UpdateWalletMetadataRequest request);
  $async.Future<$3.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $3.DeleteWalletRequest request);
  $async.Future<$3.DeleteAllWalletsResponse> deleteAllWallets(
      $pb.ServerContext ctx, $3.DeleteAllWalletsRequest request);
  $async.Future<$3.ListWalletBackupsResponse> listWalletBackups(
      $pb.ServerContext ctx, $3.ListWalletBackupsRequest request);
  $async.Future<$3.RestoreWalletBackupResponse> restoreWalletBackup(
      $pb.ServerContext ctx, $3.RestoreWalletBackupRequest request);
  $async.Future<$3.RestoreWalletBackupProgressResponse> restoreWalletBackupStream(
      $pb.ServerContext ctx, $3.RestoreWalletBackupRequest request);
  $async.Future<$3.CreateWatchOnlyWalletResponse> createWatchOnlyWallet(
      $pb.ServerContext ctx, $3.CreateWatchOnlyWalletRequest request);
  $async.Future<$3.CreateElectrumWalletResponse> createElectrumWallet(
      $pb.ServerContext ctx, $3.CreateElectrumWalletRequest request);
  $async.Future<$3.CreateMultisigWalletResponse> createMultisigWallet(
      $pb.ServerContext ctx, $3.CreateMultisigWalletRequest request);
  $async.Future<$3.ParseMultisigConfigResponse> parseMultisigConfig(
      $pb.ServerContext ctx, $3.ParseMultisigConfigRequest request);
  $async.Future<$3.ValidateDescriptorResponse> validateDescriptor(
      $pb.ServerContext ctx, $3.ValidateDescriptorRequest request);
  $async.Future<$3.ValidateDerivationPathResponse> validateDerivationPath(
      $pb.ServerContext ctx, $3.ValidateDerivationPathRequest request);
  $async.Future<$3.ListDerivationPathsResponse> listDerivationPaths(
      $pb.ServerContext ctx, $3.ListDerivationPathsRequest request);
  $async.Future<$3.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet(
      $pb.ServerContext ctx, $3.CreateBitcoinCoreWalletRequest request);
  $async.Future<$3.EnsureCoreWalletsResponse> ensureCoreWallets(
      $pb.ServerContext ctx, $3.EnsureCoreWalletsRequest request);
  $async.Future<$3.GetBalanceResponse> getBalance($pb.ServerContext ctx, $3.GetBalanceRequest request);
  $async.Future<$3.RescanWalletResponse> rescanWallet($pb.ServerContext ctx, $3.RescanWalletRequest request);
  $async.Future<$3.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $3.EstimateFeeRequest request);
  $async.Future<$3.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $3.GetNewAddressRequest request);
  $async.Future<$3.SendTransactionResponse> sendTransaction($pb.ServerContext ctx, $3.SendTransactionRequest request);
  $async.Future<$3.PreviewSendResponse> previewSend($pb.ServerContext ctx, $3.PreviewSendRequest request);
  $async.Future<$1.Empty> setFrozenCoins($pb.ServerContext ctx, $3.SetFrozenCoinsRequest request);
  $async.Future<$3.CreateDepositResponse> createDeposit($pb.ServerContext ctx, $3.CreateDepositRequest request);
  $async.Future<$3.ListTransactionsResponse> listTransactions(
      $pb.ServerContext ctx, $3.ListTransactionsRequest request);
  $async.Future<$3.ListUnspentResponse> listUnspent($pb.ServerContext ctx, $3.ListUnspentRequest request);
  $async.Future<$3.ListReceiveAddressesResponse> listReceiveAddresses(
      $pb.ServerContext ctx, $3.ListReceiveAddressesRequest request);
  $async.Future<$3.GetTransactionDetailsResponse> getTransactionDetails(
      $pb.ServerContext ctx, $3.GetTransactionDetailsRequest request);
  $async.Future<$3.DecodeTransactionResponse> decodeTransaction(
      $pb.ServerContext ctx, $3.DecodeTransactionRequest request);
  $async.Future<$3.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $3.BumpFeeRequest request);
  $async.Future<$3.PreviewBumpFeeResponse> previewBumpFee($pb.ServerContext ctx, $3.PreviewBumpFeeRequest request);
  $async.Future<$3.CreateCpfpResponse> createCpfp($pb.ServerContext ctx, $3.CreateCpfpRequest request);
  $async.Future<$3.CancelTransactionResponse> cancelTransaction(
      $pb.ServerContext ctx, $3.CancelTransactionRequest request);
  $async.Future<$3.DeriveAddressesResponse> deriveAddresses($pb.ServerContext ctx, $3.DeriveAddressesRequest request);
  $async.Future<$3.ListEcxBurnsResponse> listEcxBurns($pb.ServerContext ctx, $3.ListEcxBurnsRequest request);
  $async.Future<$3.CreatePsbtResponse> createPsbt($pb.ServerContext ctx, $3.CreatePsbtRequest request);
  $async.Future<$3.SignPsbtResponse> signPsbt($pb.ServerContext ctx, $3.SignPsbtRequest request);
  $async.Future<$3.SignPsbtWithCosignerResponse> signPsbtWithCosigner(
      $pb.ServerContext ctx, $3.SignPsbtWithCosignerRequest request);
  $async.Future<$3.CombinePsbtResponse> combinePsbt($pb.ServerContext ctx, $3.CombinePsbtRequest request);
  $async.Future<$3.FinalizePsbtResponse> finalizePsbt($pb.ServerContext ctx, $3.FinalizePsbtRequest request);
  $async.Future<$3.MultisigPsbtStatusResponse> multisigPsbtStatus(
      $pb.ServerContext ctx, $3.MultisigPsbtStatusRequest request);
  $async.Future<$3.BroadcastTransactionResponse> broadcastTransaction(
      $pb.ServerContext ctx, $3.BroadcastTransactionRequest request);
  $async.Future<$3.GetAddressUnspentResponse> getAddressUnspent(
      $pb.ServerContext ctx, $3.GetAddressUnspentRequest request);
  $async.Future<$3.BroadcastElectrumTransactionResponse> broadcastElectrumTransaction(
      $pb.ServerContext ctx, $3.BroadcastElectrumTransactionRequest request);
  $async.Future<$3.EnumerateHardwareDevicesResponse> enumerateHardwareDevices(
      $pb.ServerContext ctx, $3.EnumerateHardwareDevicesRequest request);
  $async.Future<$3.GetHardwareXpubResponse> getHardwareXpub($pb.ServerContext ctx, $3.GetHardwareXpubRequest request);
  $async.Future<$3.SignPsbtWithDeviceResponse> signPsbtWithDevice(
      $pb.ServerContext ctx, $3.SignPsbtWithDeviceRequest request);
  $async.Future<$3.PromptDevicePinResponse> promptDevicePin($pb.ServerContext ctx, $3.PromptDevicePinRequest request);
  $async.Future<$3.SendDevicePinResponse> sendDevicePin($pb.ServerContext ctx, $3.SendDevicePinRequest request);
  $async.Future<$3.CloseDeviceResponse> closeDevice($pb.ServerContext ctx, $3.CloseDeviceRequest request);
  $async.Future<$3.DeriveKeystoreResponse> deriveKeystore($pb.ServerContext ctx, $3.DeriveKeystoreRequest request);
  $async.Future<$3.ExploreSeedResponse> exploreSeed($pb.ServerContext ctx, $3.ExploreSeedRequest request);
  $async.Future<$3.GenerateMnemonicResponse> generateMnemonic(
      $pb.ServerContext ctx, $3.GenerateMnemonicRequest request);
  $async.Future<$3.ValidateMnemonicResponse> validateMnemonic(
      $pb.ServerContext ctx, $3.ValidateMnemonicRequest request);
  $async.Future<$3.PreviewWalletFromEntropyResponse> previewWalletFromEntropy(
      $pb.ServerContext ctx, $3.PreviewWalletFromEntropyRequest request);
  $async.Future<$3.GetWalletSeedResponse> getWalletSeed($pb.ServerContext ctx, $3.GetWalletSeedRequest request);
  $async.Future<$3.ListCoreVariantsResponse> listCoreVariants(
      $pb.ServerContext ctx, $3.ListCoreVariantsRequest request);
  $async.Future<$3.GetCoreVariantResponse> getCoreVariant($pb.ServerContext ctx, $3.GetCoreVariantRequest request);
  $async.Future<$3.SetCoreVariantResponse> setCoreVariant($pb.ServerContext ctx, $3.SetCoreVariantRequest request);
  $async.Future<$3.GetElectrumServerResponse> getElectrumServer(
      $pb.ServerContext ctx, $3.GetElectrumServerRequest request);
  $async.Future<$3.SetElectrumServerResponse> setElectrumServer(
      $pb.ServerContext ctx, $3.SetElectrumServerRequest request);
  $async.Future<$3.GetTorConfigResponse> getTorConfig($pb.ServerContext ctx, $3.GetTorConfigRequest request);
  $async.Future<$3.SetTorConfigResponse> setTorConfig($pb.ServerContext ctx, $3.SetTorConfigRequest request);
  $async.Future<$3.WatchWalletDataResponse> watchWalletData($pb.ServerContext ctx, $1.Empty request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus':
        return $3.GetWalletStatusRequest();
      case 'ListSidechainDeposits':
        return $3.ListSidechainDepositsRequest();
      case 'GetSidechainDepositTotals':
        return $3.GetSidechainDepositTotalsRequest();
      case 'GetNodeMode':
        return $3.GetNodeModeRequest();
      case 'SetNodeMode':
        return $3.SetNodeModeRequest();
      case 'GenerateWallet':
        return $3.GenerateWalletRequest();
      case 'UnlockWallet':
        return $3.UnlockWalletRequest();
      case 'LockWallet':
        return $3.LockWalletRequest();
      case 'EncryptWallet':
        return $3.EncryptWalletRequest();
      case 'ChangePassword':
        return $3.ChangePasswordRequest();
      case 'RemoveEncryption':
        return $3.RemoveEncryptionRequest();
      case 'ListWallets':
        return $3.ListWalletsRequest();
      case 'SwitchWallet':
        return $3.SwitchWalletRequest();
      case 'UpdateWalletMetadata':
        return $3.UpdateWalletMetadataRequest();
      case 'DeleteWallet':
        return $3.DeleteWalletRequest();
      case 'DeleteAllWallets':
        return $3.DeleteAllWalletsRequest();
      case 'ListWalletBackups':
        return $3.ListWalletBackupsRequest();
      case 'RestoreWalletBackup':
        return $3.RestoreWalletBackupRequest();
      case 'RestoreWalletBackupStream':
        return $3.RestoreWalletBackupRequest();
      case 'CreateWatchOnlyWallet':
        return $3.CreateWatchOnlyWalletRequest();
      case 'CreateElectrumWallet':
        return $3.CreateElectrumWalletRequest();
      case 'CreateMultisigWallet':
        return $3.CreateMultisigWalletRequest();
      case 'ParseMultisigConfig':
        return $3.ParseMultisigConfigRequest();
      case 'ValidateDescriptor':
        return $3.ValidateDescriptorRequest();
      case 'ValidateDerivationPath':
        return $3.ValidateDerivationPathRequest();
      case 'ListDerivationPaths':
        return $3.ListDerivationPathsRequest();
      case 'CreateBitcoinCoreWallet':
        return $3.CreateBitcoinCoreWalletRequest();
      case 'EnsureCoreWallets':
        return $3.EnsureCoreWalletsRequest();
      case 'GetBalance':
        return $3.GetBalanceRequest();
      case 'RescanWallet':
        return $3.RescanWalletRequest();
      case 'EstimateFee':
        return $3.EstimateFeeRequest();
      case 'GetNewAddress':
        return $3.GetNewAddressRequest();
      case 'SendTransaction':
        return $3.SendTransactionRequest();
      case 'PreviewSend':
        return $3.PreviewSendRequest();
      case 'SetFrozenCoins':
        return $3.SetFrozenCoinsRequest();
      case 'CreateDeposit':
        return $3.CreateDepositRequest();
      case 'ListTransactions':
        return $3.ListTransactionsRequest();
      case 'ListUnspent':
        return $3.ListUnspentRequest();
      case 'ListReceiveAddresses':
        return $3.ListReceiveAddressesRequest();
      case 'GetTransactionDetails':
        return $3.GetTransactionDetailsRequest();
      case 'DecodeTransaction':
        return $3.DecodeTransactionRequest();
      case 'BumpFee':
        return $3.BumpFeeRequest();
      case 'PreviewBumpFee':
        return $3.PreviewBumpFeeRequest();
      case 'CreateCpfp':
        return $3.CreateCpfpRequest();
      case 'CancelTransaction':
        return $3.CancelTransactionRequest();
      case 'DeriveAddresses':
        return $3.DeriveAddressesRequest();
      case 'ListEcxBurns':
        return $3.ListEcxBurnsRequest();
      case 'CreatePsbt':
        return $3.CreatePsbtRequest();
      case 'SignPsbt':
        return $3.SignPsbtRequest();
      case 'SignPsbtWithCosigner':
        return $3.SignPsbtWithCosignerRequest();
      case 'CombinePsbt':
        return $3.CombinePsbtRequest();
      case 'FinalizePsbt':
        return $3.FinalizePsbtRequest();
      case 'MultisigPsbtStatus':
        return $3.MultisigPsbtStatusRequest();
      case 'BroadcastTransaction':
        return $3.BroadcastTransactionRequest();
      case 'GetAddressUnspent':
        return $3.GetAddressUnspentRequest();
      case 'BroadcastElectrumTransaction':
        return $3.BroadcastElectrumTransactionRequest();
      case 'EnumerateHardwareDevices':
        return $3.EnumerateHardwareDevicesRequest();
      case 'GetHardwareXpub':
        return $3.GetHardwareXpubRequest();
      case 'SignPsbtWithDevice':
        return $3.SignPsbtWithDeviceRequest();
      case 'PromptDevicePin':
        return $3.PromptDevicePinRequest();
      case 'SendDevicePin':
        return $3.SendDevicePinRequest();
      case 'CloseDevice':
        return $3.CloseDeviceRequest();
      case 'DeriveKeystore':
        return $3.DeriveKeystoreRequest();
      case 'ExploreSeed':
        return $3.ExploreSeedRequest();
      case 'GenerateMnemonic':
        return $3.GenerateMnemonicRequest();
      case 'ValidateMnemonic':
        return $3.ValidateMnemonicRequest();
      case 'PreviewWalletFromEntropy':
        return $3.PreviewWalletFromEntropyRequest();
      case 'GetWalletSeed':
        return $3.GetWalletSeedRequest();
      case 'ListCoreVariants':
        return $3.ListCoreVariantsRequest();
      case 'GetCoreVariant':
        return $3.GetCoreVariantRequest();
      case 'SetCoreVariant':
        return $3.SetCoreVariantRequest();
      case 'GetElectrumServer':
        return $3.GetElectrumServerRequest();
      case 'SetElectrumServer':
        return $3.SetElectrumServerRequest();
      case 'GetTorConfig':
        return $3.GetTorConfigRequest();
      case 'SetTorConfig':
        return $3.SetTorConfigRequest();
      case 'WatchWalletData':
        return $1.Empty();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall(
      $pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus':
        return getWalletStatus(ctx, request as $3.GetWalletStatusRequest);
      case 'ListSidechainDeposits':
        return listSidechainDeposits(ctx, request as $3.ListSidechainDepositsRequest);
      case 'GetSidechainDepositTotals':
        return getSidechainDepositTotals(ctx, request as $3.GetSidechainDepositTotalsRequest);
      case 'GetNodeMode':
        return getNodeMode(ctx, request as $3.GetNodeModeRequest);
      case 'SetNodeMode':
        return setNodeMode(ctx, request as $3.SetNodeModeRequest);
      case 'GenerateWallet':
        return generateWallet(ctx, request as $3.GenerateWalletRequest);
      case 'UnlockWallet':
        return unlockWallet(ctx, request as $3.UnlockWalletRequest);
      case 'LockWallet':
        return lockWallet(ctx, request as $3.LockWalletRequest);
      case 'EncryptWallet':
        return encryptWallet(ctx, request as $3.EncryptWalletRequest);
      case 'ChangePassword':
        return changePassword(ctx, request as $3.ChangePasswordRequest);
      case 'RemoveEncryption':
        return removeEncryption(ctx, request as $3.RemoveEncryptionRequest);
      case 'ListWallets':
        return listWallets(ctx, request as $3.ListWalletsRequest);
      case 'SwitchWallet':
        return switchWallet(ctx, request as $3.SwitchWalletRequest);
      case 'UpdateWalletMetadata':
        return updateWalletMetadata(ctx, request as $3.UpdateWalletMetadataRequest);
      case 'DeleteWallet':
        return deleteWallet(ctx, request as $3.DeleteWalletRequest);
      case 'DeleteAllWallets':
        return deleteAllWallets(ctx, request as $3.DeleteAllWalletsRequest);
      case 'ListWalletBackups':
        return listWalletBackups(ctx, request as $3.ListWalletBackupsRequest);
      case 'RestoreWalletBackup':
        return restoreWalletBackup(ctx, request as $3.RestoreWalletBackupRequest);
      case 'RestoreWalletBackupStream':
        return restoreWalletBackupStream(ctx, request as $3.RestoreWalletBackupRequest);
      case 'CreateWatchOnlyWallet':
        return createWatchOnlyWallet(ctx, request as $3.CreateWatchOnlyWalletRequest);
      case 'CreateElectrumWallet':
        return createElectrumWallet(ctx, request as $3.CreateElectrumWalletRequest);
      case 'CreateMultisigWallet':
        return createMultisigWallet(ctx, request as $3.CreateMultisigWalletRequest);
      case 'ParseMultisigConfig':
        return parseMultisigConfig(ctx, request as $3.ParseMultisigConfigRequest);
      case 'ValidateDescriptor':
        return validateDescriptor(ctx, request as $3.ValidateDescriptorRequest);
      case 'ValidateDerivationPath':
        return validateDerivationPath(ctx, request as $3.ValidateDerivationPathRequest);
      case 'ListDerivationPaths':
        return listDerivationPaths(ctx, request as $3.ListDerivationPathsRequest);
      case 'CreateBitcoinCoreWallet':
        return createBitcoinCoreWallet(ctx, request as $3.CreateBitcoinCoreWalletRequest);
      case 'EnsureCoreWallets':
        return ensureCoreWallets(ctx, request as $3.EnsureCoreWalletsRequest);
      case 'GetBalance':
        return getBalance(ctx, request as $3.GetBalanceRequest);
      case 'RescanWallet':
        return rescanWallet(ctx, request as $3.RescanWalletRequest);
      case 'EstimateFee':
        return estimateFee(ctx, request as $3.EstimateFeeRequest);
      case 'GetNewAddress':
        return getNewAddress(ctx, request as $3.GetNewAddressRequest);
      case 'SendTransaction':
        return sendTransaction(ctx, request as $3.SendTransactionRequest);
      case 'PreviewSend':
        return previewSend(ctx, request as $3.PreviewSendRequest);
      case 'SetFrozenCoins':
        return setFrozenCoins(ctx, request as $3.SetFrozenCoinsRequest);
      case 'CreateDeposit':
        return createDeposit(ctx, request as $3.CreateDepositRequest);
      case 'ListTransactions':
        return listTransactions(ctx, request as $3.ListTransactionsRequest);
      case 'ListUnspent':
        return listUnspent(ctx, request as $3.ListUnspentRequest);
      case 'ListReceiveAddresses':
        return listReceiveAddresses(ctx, request as $3.ListReceiveAddressesRequest);
      case 'GetTransactionDetails':
        return getTransactionDetails(ctx, request as $3.GetTransactionDetailsRequest);
      case 'DecodeTransaction':
        return decodeTransaction(ctx, request as $3.DecodeTransactionRequest);
      case 'BumpFee':
        return bumpFee(ctx, request as $3.BumpFeeRequest);
      case 'PreviewBumpFee':
        return previewBumpFee(ctx, request as $3.PreviewBumpFeeRequest);
      case 'CreateCpfp':
        return createCpfp(ctx, request as $3.CreateCpfpRequest);
      case 'CancelTransaction':
        return cancelTransaction(ctx, request as $3.CancelTransactionRequest);
      case 'DeriveAddresses':
        return deriveAddresses(ctx, request as $3.DeriveAddressesRequest);
      case 'ListEcxBurns':
        return listEcxBurns(ctx, request as $3.ListEcxBurnsRequest);
      case 'CreatePsbt':
        return createPsbt(ctx, request as $3.CreatePsbtRequest);
      case 'SignPsbt':
        return signPsbt(ctx, request as $3.SignPsbtRequest);
      case 'SignPsbtWithCosigner':
        return signPsbtWithCosigner(ctx, request as $3.SignPsbtWithCosignerRequest);
      case 'CombinePsbt':
        return combinePsbt(ctx, request as $3.CombinePsbtRequest);
      case 'FinalizePsbt':
        return finalizePsbt(ctx, request as $3.FinalizePsbtRequest);
      case 'MultisigPsbtStatus':
        return multisigPsbtStatus(ctx, request as $3.MultisigPsbtStatusRequest);
      case 'BroadcastTransaction':
        return broadcastTransaction(ctx, request as $3.BroadcastTransactionRequest);
      case 'GetAddressUnspent':
        return getAddressUnspent(ctx, request as $3.GetAddressUnspentRequest);
      case 'BroadcastElectrumTransaction':
        return broadcastElectrumTransaction(ctx, request as $3.BroadcastElectrumTransactionRequest);
      case 'EnumerateHardwareDevices':
        return enumerateHardwareDevices(ctx, request as $3.EnumerateHardwareDevicesRequest);
      case 'GetHardwareXpub':
        return getHardwareXpub(ctx, request as $3.GetHardwareXpubRequest);
      case 'SignPsbtWithDevice':
        return signPsbtWithDevice(ctx, request as $3.SignPsbtWithDeviceRequest);
      case 'PromptDevicePin':
        return promptDevicePin(ctx, request as $3.PromptDevicePinRequest);
      case 'SendDevicePin':
        return sendDevicePin(ctx, request as $3.SendDevicePinRequest);
      case 'CloseDevice':
        return closeDevice(ctx, request as $3.CloseDeviceRequest);
      case 'DeriveKeystore':
        return deriveKeystore(ctx, request as $3.DeriveKeystoreRequest);
      case 'ExploreSeed':
        return exploreSeed(ctx, request as $3.ExploreSeedRequest);
      case 'GenerateMnemonic':
        return generateMnemonic(ctx, request as $3.GenerateMnemonicRequest);
      case 'ValidateMnemonic':
        return validateMnemonic(ctx, request as $3.ValidateMnemonicRequest);
      case 'PreviewWalletFromEntropy':
        return previewWalletFromEntropy(ctx, request as $3.PreviewWalletFromEntropyRequest);
      case 'GetWalletSeed':
        return getWalletSeed(ctx, request as $3.GetWalletSeedRequest);
      case 'ListCoreVariants':
        return listCoreVariants(ctx, request as $3.ListCoreVariantsRequest);
      case 'GetCoreVariant':
        return getCoreVariant(ctx, request as $3.GetCoreVariantRequest);
      case 'SetCoreVariant':
        return setCoreVariant(ctx, request as $3.SetCoreVariantRequest);
      case 'GetElectrumServer':
        return getElectrumServer(ctx, request as $3.GetElectrumServerRequest);
      case 'SetElectrumServer':
        return setElectrumServer(ctx, request as $3.SetElectrumServerRequest);
      case 'GetTorConfig':
        return getTorConfig(ctx, request as $3.GetTorConfigRequest);
      case 'SetTorConfig':
        return setTorConfig(ctx, request as $3.SetTorConfigRequest);
      case 'WatchWalletData':
        return watchWalletData(ctx, request as $1.Empty);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson =>
      WalletManagerServiceBase$messageJson;
}
