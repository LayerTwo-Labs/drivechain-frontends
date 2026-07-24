//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
//

import "package:connectrpc/connect.dart" as connect;
import "walletmanager.pb.dart" as walletmanagerv1walletmanager;
import "walletmanager.connect.spec.dart" as specs;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

extension type WalletManagerServiceClient (connect.Transport _transport) {
  /// Wallet lifecycle
  Future<walletmanagerv1walletmanager.GetWalletStatusResponse> getWalletStatus(
    walletmanagerv1walletmanager.GetWalletStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getWalletStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.GenerateWalletResponse> generateWallet(
    walletmanagerv1walletmanager.GenerateWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.generateWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.UnlockWalletResponse> unlockWallet(
    walletmanagerv1walletmanager.UnlockWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.unlockWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.LockWalletResponse> lockWallet(
    walletmanagerv1walletmanager.LockWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.lockWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.EncryptWalletResponse> encryptWallet(
    walletmanagerv1walletmanager.EncryptWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.encryptWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.ChangePasswordResponse> changePassword(
    walletmanagerv1walletmanager.ChangePasswordRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.changePassword,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.RemoveEncryptionResponse> removeEncryption(
    walletmanagerv1walletmanager.RemoveEncryptionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.removeEncryption,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.ListWalletsResponse> listWallets(
    walletmanagerv1walletmanager.ListWalletsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.listWallets,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SwitchWalletResponse> switchWallet(
    walletmanagerv1walletmanager.SwitchWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.switchWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.UpdateWalletMetadataResponse> updateWalletMetadata(
    walletmanagerv1walletmanager.UpdateWalletMetadataRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.updateWalletMetadata,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.DeleteWalletResponse> deleteWallet(
    walletmanagerv1walletmanager.DeleteWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.deleteWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.DeleteAllWalletsResponse> deleteAllWallets(
    walletmanagerv1walletmanager.DeleteAllWalletsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.deleteAllWallets,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.ListWalletBackupsResponse> listWalletBackups(
    walletmanagerv1walletmanager.ListWalletBackupsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.listWalletBackups,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.RestoreWalletBackupResponse> restoreWalletBackup(
    walletmanagerv1walletmanager.RestoreWalletBackupRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.restoreWalletBackup,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Stream<walletmanagerv1walletmanager.RestoreWalletBackupProgressResponse> restoreWalletBackupStream(
    walletmanagerv1walletmanager.RestoreWalletBackupRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.WalletManagerService.restoreWalletBackupStream,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.CreateWatchOnlyWalletResponse> createWatchOnlyWallet(
    walletmanagerv1walletmanager.CreateWatchOnlyWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.createWatchOnlyWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create an electrum wallet: keys are generated locally, but no local Bitcoin
  /// Core or enforcer runs — chain data is served remotely via the datasource.
  Future<walletmanagerv1walletmanager.CreateElectrumWalletResponse> createElectrumWallet(
    walletmanagerv1walletmanager.CreateElectrumWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.createElectrumWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.CreateMultisigWalletResponse> createMultisigWallet(
    walletmanagerv1walletmanager.CreateMultisigWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.createMultisigWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// ParseMultisigConfig parses a descriptor or a wallet-config file (Coldcard
  /// text / Sparrow / Specter / Caravan JSON) into an m-of-n policy + cosigners.
  Future<walletmanagerv1walletmanager.ParseMultisigConfigResponse> parseMultisigConfig(
    walletmanagerv1walletmanager.ParseMultisigConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.parseMultisigConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Core wallet management
  Future<walletmanagerv1walletmanager.CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet(
    walletmanagerv1walletmanager.CreateBitcoinCoreWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.createBitcoinCoreWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.EnsureCoreWalletsResponse> ensureCoreWallets(
    walletmanagerv1walletmanager.EnsureCoreWalletsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.ensureCoreWallets,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Bitcoin operations (proxied through Core RPC)
  Future<walletmanagerv1walletmanager.GetBalanceResponse> getBalance(
    walletmanagerv1walletmanager.GetBalanceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getBalance,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.RescanWalletResponse> rescanWallet(
    walletmanagerv1walletmanager.RescanWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.rescanWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.EstimateFeeResponse> estimateFee(
    walletmanagerv1walletmanager.EstimateFeeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.estimateFee,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.GetNewAddressResponse> getNewAddress(
    walletmanagerv1walletmanager.GetNewAddressRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getNewAddress,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SendTransactionResponse> sendTransaction(
    walletmanagerv1walletmanager.SendTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.sendTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.ListTransactionsResponse> listTransactions(
    walletmanagerv1walletmanager.ListTransactionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.listTransactions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.ListUnspentResponse> listUnspent(
    walletmanagerv1walletmanager.ListUnspentRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.listUnspent,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.ListReceiveAddressesResponse> listReceiveAddresses(
    walletmanagerv1walletmanager.ListReceiveAddressesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.listReceiveAddresses,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.GetTransactionDetailsResponse> getTransactionDetails(
    walletmanagerv1walletmanager.GetTransactionDetailsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getTransactionDetails,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.DecodeTransactionResponse> decodeTransaction(
    walletmanagerv1walletmanager.DecodeTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.decodeTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.BumpFeeResponse> bumpFee(
    walletmanagerv1walletmanager.BumpFeeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.bumpFee,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// CreateCpfp spends an unconfirmed wallet UTXO with a child transaction whose
  /// fee lifts the parent+child package to the target fee rate (CPFP).
  Future<walletmanagerv1walletmanager.CreateCpfpResponse> createCpfp(
    walletmanagerv1walletmanager.CreateCpfpRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.createCpfp,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.DeriveAddressesResponse> deriveAddresses(
    walletmanagerv1walletmanager.DeriveAddressesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.deriveAddresses,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PSBT (BIP174). CreatePsbt builds an unsigned PSBT for a send (works for
  /// watch-only wallets); SignPsbt adds this wallet's signatures; CombinePsbt
  /// merges cosigner PSBTs; FinalizePsbt extracts the raw transaction. Electrum
  /// wallets only.
  Future<walletmanagerv1walletmanager.CreatePsbtResponse> createPsbt(
    walletmanagerv1walletmanager.CreatePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.createPsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SignPsbtResponse> signPsbt(
    walletmanagerv1walletmanager.SignPsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.signPsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// SignPsbtWithCosigner signs a multisig PSBT with a single held cosigner's key
  /// (per-keystore signing), leaving the other legs for their own signers.
  Future<walletmanagerv1walletmanager.SignPsbtWithCosignerResponse> signPsbtWithCosigner(
    walletmanagerv1walletmanager.SignPsbtWithCosignerRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.signPsbtWithCosigner,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.CombinePsbtResponse> combinePsbt(
    walletmanagerv1walletmanager.CombinePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.combinePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.FinalizePsbtResponse> finalizePsbt(
    walletmanagerv1walletmanager.FinalizePsbtRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.finalizePsbt,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// MultisigPsbtStatus reports signing progress for a multisig wallet's PSBT:
  /// signature count, whether it can be finalized, and which cosigners signed.
  Future<walletmanagerv1walletmanager.MultisigPsbtStatusResponse> multisigPsbtStatus(
    walletmanagerv1walletmanager.MultisigPsbtStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.multisigPsbtStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// BroadcastTransaction broadcasts a finalized raw transaction over the
  /// wallet's chain source and returns its txid.
  Future<walletmanagerv1walletmanager.BroadcastTransactionResponse> broadcastTransaction(
    walletmanagerv1walletmanager.BroadcastTransactionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.broadcastTransaction,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// USB hardware wallets.
  Future<walletmanagerv1walletmanager.EnumerateHardwareDevicesResponse> enumerateHardwareDevices(
    walletmanagerv1walletmanager.EnumerateHardwareDevicesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.enumerateHardwareDevices,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.GetHardwareXpubResponse> getHardwareXpub(
    walletmanagerv1walletmanager.GetHardwareXpubRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getHardwareXpub,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SignPsbtWithDeviceResponse> signPsbtWithDevice(
    walletmanagerv1walletmanager.SignPsbtWithDeviceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.signPsbtWithDevice,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// PromptDevicePin shows the PIN matrix; SendDevicePin unlocks with it.
  Future<walletmanagerv1walletmanager.PromptDevicePinResponse> promptDevicePin(
    walletmanagerv1walletmanager.PromptDevicePinRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.promptDevicePin,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SendDevicePinResponse> sendDevicePin(
    walletmanagerv1walletmanager.SendDevicePinRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.sendDevicePin,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// CloseDevice releases the device so the next enumerate isn't blocked.
  Future<walletmanagerv1walletmanager.CloseDeviceResponse> closeDevice(
    walletmanagerv1walletmanager.CloseDeviceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.closeDevice,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// DeriveKeystore turns a keystore's intent into derived account key material.
  Future<walletmanagerv1walletmanager.DeriveKeystoreResponse> deriveKeystore(
    walletmanagerv1walletmanager.DeriveKeystoreRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.deriveKeystore,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Seed access for cheque engine
  Future<walletmanagerv1walletmanager.GetWalletSeedResponse> getWalletSeed(
    walletmanagerv1walletmanager.GetWalletSeedRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getWalletSeed,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Bitcoin Core variant selection (untouched / touched / knots).
  Future<walletmanagerv1walletmanager.ListCoreVariantsResponse> listCoreVariants(
    walletmanagerv1walletmanager.ListCoreVariantsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.listCoreVariants,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.GetCoreVariantResponse> getCoreVariant(
    walletmanagerv1walletmanager.GetCoreVariantRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getCoreVariant,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SetCoreVariantResponse> setCoreVariant(
    walletmanagerv1walletmanager.SetCoreVariantRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.setCoreVariant,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Test-sidechains toggle. When enabled, layer-2 binaries download/run from
  /// the alternative_download config (test builds) instead of the default.
  Future<walletmanagerv1walletmanager.GetTestSidechainsResponse> getTestSidechains(
    walletmanagerv1walletmanager.GetTestSidechainsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getTestSidechains,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SetTestSidechainsResponse> setTestSidechains(
    walletmanagerv1walletmanager.SetTestSidechainsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.setTestSidechains,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Electrum server (Esplora endpoint) selection for electrum wallets.
  Future<walletmanagerv1walletmanager.GetElectrumServerResponse> getElectrumServer(
    walletmanagerv1walletmanager.GetElectrumServerRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getElectrumServer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SetElectrumServerResponse> setElectrumServer(
    walletmanagerv1walletmanager.SetElectrumServerRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.setElectrumServer,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Tor SOCKS5 proxy routing for the electrum wallet's chain connections.
  Future<walletmanagerv1walletmanager.GetTorConfigResponse> getTorConfig(
    walletmanagerv1walletmanager.GetTorConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getTorConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SetTorConfigResponse> setTorConfig(
    walletmanagerv1walletmanager.SetTorConfigRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.setTorConfig,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Stream wallet state changes. Sends the full wallet state immediately,
  /// then again whenever wallets or balance change.
  Stream<walletmanagerv1walletmanager.WatchWalletDataResponse> watchWalletData(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.WalletManagerService.watchWalletData,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
