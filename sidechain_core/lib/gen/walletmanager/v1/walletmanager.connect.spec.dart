//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
//

import "package:connectrpc/connect.dart" as connect;
import "walletmanager.pb.dart" as walletmanagerv1walletmanager;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

abstract final class WalletManagerService {
  /// Fully-qualified name of the WalletManagerService service.
  static const name = 'walletmanager.v1.WalletManagerService';

  /// Wallet lifecycle
  static const getWalletStatus = connect.Spec(
    '/$name/GetWalletStatus',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetWalletStatusRequest.new,
    walletmanagerv1walletmanager.GetWalletStatusResponse.new,
  );

  /// How much of Bitcoin this install runs. The frontend asks the user before
  /// it boots anything, and blocks until GetNodeMode reports a mode.
  /// Deposits this install made to a sidechain treasury. An M5 is an ordinary
  /// transaction on the wire, so the record comes from when we broadcast it.
  static const listSidechainDeposits = connect.Spec(
    '/$name/ListSidechainDeposits',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ListSidechainDepositsRequest.new,
    walletmanagerv1walletmanager.ListSidechainDepositsResponse.new,
  );

  static const getSidechainDepositTotals = connect.Spec(
    '/$name/GetSidechainDepositTotals',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetSidechainDepositTotalsRequest.new,
    walletmanagerv1walletmanager.GetSidechainDepositTotalsResponse.new,
  );

  static const getNodeMode = connect.Spec(
    '/$name/GetNodeMode',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetNodeModeRequest.new,
    walletmanagerv1walletmanager.GetNodeModeResponse.new,
  );

  static const setNodeMode = connect.Spec(
    '/$name/SetNodeMode',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SetNodeModeRequest.new,
    walletmanagerv1walletmanager.SetNodeModeResponse.new,
  );

  static const generateWallet = connect.Spec(
    '/$name/GenerateWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GenerateWalletRequest.new,
    walletmanagerv1walletmanager.GenerateWalletResponse.new,
  );

  static const unlockWallet = connect.Spec(
    '/$name/UnlockWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.UnlockWalletRequest.new,
    walletmanagerv1walletmanager.UnlockWalletResponse.new,
  );

  static const lockWallet = connect.Spec(
    '/$name/LockWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.LockWalletRequest.new,
    walletmanagerv1walletmanager.LockWalletResponse.new,
  );

  static const encryptWallet = connect.Spec(
    '/$name/EncryptWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.EncryptWalletRequest.new,
    walletmanagerv1walletmanager.EncryptWalletResponse.new,
  );

  static const changePassword = connect.Spec(
    '/$name/ChangePassword',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ChangePasswordRequest.new,
    walletmanagerv1walletmanager.ChangePasswordResponse.new,
  );

  static const removeEncryption = connect.Spec(
    '/$name/RemoveEncryption',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.RemoveEncryptionRequest.new,
    walletmanagerv1walletmanager.RemoveEncryptionResponse.new,
  );

  static const listWallets = connect.Spec(
    '/$name/ListWallets',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ListWalletsRequest.new,
    walletmanagerv1walletmanager.ListWalletsResponse.new,
  );

  static const switchWallet = connect.Spec(
    '/$name/SwitchWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SwitchWalletRequest.new,
    walletmanagerv1walletmanager.SwitchWalletResponse.new,
  );

  static const updateWalletMetadata = connect.Spec(
    '/$name/UpdateWalletMetadata',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.UpdateWalletMetadataRequest.new,
    walletmanagerv1walletmanager.UpdateWalletMetadataResponse.new,
  );

  static const deleteWallet = connect.Spec(
    '/$name/DeleteWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.DeleteWalletRequest.new,
    walletmanagerv1walletmanager.DeleteWalletResponse.new,
  );

  static const deleteAllWallets = connect.Spec(
    '/$name/DeleteAllWallets',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.DeleteAllWalletsRequest.new,
    walletmanagerv1walletmanager.DeleteAllWalletsResponse.new,
  );

  static const listWalletBackups = connect.Spec(
    '/$name/ListWalletBackups',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ListWalletBackupsRequest.new,
    walletmanagerv1walletmanager.ListWalletBackupsResponse.new,
  );

  static const restoreWalletBackup = connect.Spec(
    '/$name/RestoreWalletBackup',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.RestoreWalletBackupRequest.new,
    walletmanagerv1walletmanager.RestoreWalletBackupResponse.new,
  );

  static const restoreWalletBackupStream = connect.Spec(
    '/$name/RestoreWalletBackupStream',
    connect.StreamType.server,
    walletmanagerv1walletmanager.RestoreWalletBackupRequest.new,
    walletmanagerv1walletmanager.RestoreWalletBackupProgressResponse.new,
  );

  static const createWatchOnlyWallet = connect.Spec(
    '/$name/CreateWatchOnlyWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreateWatchOnlyWalletRequest.new,
    walletmanagerv1walletmanager.CreateWatchOnlyWalletResponse.new,
  );

  /// Create an electrum wallet: keys are generated locally, but no local Bitcoin
  /// Core or enforcer runs. The wallet reads its chain from Esplora.
  static const createElectrumWallet = connect.Spec(
    '/$name/CreateElectrumWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreateElectrumWalletRequest.new,
    walletmanagerv1walletmanager.CreateElectrumWalletResponse.new,
  );

  static const createMultisigWallet = connect.Spec(
    '/$name/CreateMultisigWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreateMultisigWalletRequest.new,
    walletmanagerv1walletmanager.CreateMultisigWalletResponse.new,
  );

  /// ParseMultisigConfig parses a descriptor or a wallet-config file (Coldcard
  /// text / Sparrow / Specter / Caravan JSON) into an m-of-n policy + cosigners.
  static const parseMultisigConfig = connect.Spec(
    '/$name/ParseMultisigConfig',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ParseMultisigConfigRequest.new,
    walletmanagerv1walletmanager.ParseMultisigConfigResponse.new,
  );

  /// ValidateDescriptor reads an output descriptor — single-sig or sortedmulti —
  /// into the script policy it encodes.
  static const validateDescriptor = connect.Spec(
    '/$name/ValidateDescriptor',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ValidateDescriptorRequest.new,
    walletmanagerv1walletmanager.ValidateDescriptorResponse.new,
  );

  /// ValidateDerivationPath canonicalises a BIP32 derivation path, or fails with
  /// the reason it is unusable.
  static const validateDerivationPath = connect.Spec(
    '/$name/ValidateDerivationPath',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ValidateDerivationPathRequest.new,
    walletmanagerv1walletmanager.ValidateDerivationPathResponse.new,
  );

  /// ListDerivationPaths returns the standard account paths for a policy on the
  /// network this backend runs.
  static const listDerivationPaths = connect.Spec(
    '/$name/ListDerivationPaths',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ListDerivationPathsRequest.new,
    walletmanagerv1walletmanager.ListDerivationPathsResponse.new,
  );

  /// Core wallet management
  static const createBitcoinCoreWallet = connect.Spec(
    '/$name/CreateBitcoinCoreWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreateBitcoinCoreWalletRequest.new,
    walletmanagerv1walletmanager.CreateBitcoinCoreWalletResponse.new,
  );

  static const ensureCoreWallets = connect.Spec(
    '/$name/EnsureCoreWallets',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.EnsureCoreWalletsRequest.new,
    walletmanagerv1walletmanager.EnsureCoreWalletsResponse.new,
  );

  /// Bitcoin operations (proxied through Core RPC)
  static const getBalance = connect.Spec(
    '/$name/GetBalance',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetBalanceRequest.new,
    walletmanagerv1walletmanager.GetBalanceResponse.new,
  );

  static const rescanWallet = connect.Spec(
    '/$name/RescanWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.RescanWalletRequest.new,
    walletmanagerv1walletmanager.RescanWalletResponse.new,
  );

  static const estimateFee = connect.Spec(
    '/$name/EstimateFee',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.EstimateFeeRequest.new,
    walletmanagerv1walletmanager.EstimateFeeResponse.new,
  );

  static const getNewAddress = connect.Spec(
    '/$name/GetNewAddress',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetNewAddressRequest.new,
    walletmanagerv1walletmanager.GetNewAddressResponse.new,
  );

  static const sendTransaction = connect.Spec(
    '/$name/SendTransaction',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SendTransactionRequest.new,
    walletmanagerv1walletmanager.SendTransactionResponse.new,
  );

  /// CreateDeposit funds a BIP300 M5 deposit to a sidechain from any wallet.
  static const createDeposit = connect.Spec(
    '/$name/CreateDeposit',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreateDepositRequest.new,
    walletmanagerv1walletmanager.CreateDepositResponse.new,
  );

  static const listTransactions = connect.Spec(
    '/$name/ListTransactions',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ListTransactionsRequest.new,
    walletmanagerv1walletmanager.ListTransactionsResponse.new,
  );

  static const listUnspent = connect.Spec(
    '/$name/ListUnspent',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ListUnspentRequest.new,
    walletmanagerv1walletmanager.ListUnspentResponse.new,
  );

  static const listReceiveAddresses = connect.Spec(
    '/$name/ListReceiveAddresses',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ListReceiveAddressesRequest.new,
    walletmanagerv1walletmanager.ListReceiveAddressesResponse.new,
  );

  static const getTransactionDetails = connect.Spec(
    '/$name/GetTransactionDetails',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetTransactionDetailsRequest.new,
    walletmanagerv1walletmanager.GetTransactionDetailsResponse.new,
  );

  static const decodeTransaction = connect.Spec(
    '/$name/DecodeTransaction',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.DecodeTransactionRequest.new,
    walletmanagerv1walletmanager.DecodeTransactionResponse.new,
  );

  static const bumpFee = connect.Spec(
    '/$name/BumpFee',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.BumpFeeRequest.new,
    walletmanagerv1walletmanager.BumpFeeResponse.new,
  );

  /// PreviewBumpFee reports what a fee bump costs, and which output pays it,
  /// without broadcasting anything.
  static const previewBumpFee = connect.Spec(
    '/$name/PreviewBumpFee',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.PreviewBumpFeeRequest.new,
    walletmanagerv1walletmanager.PreviewBumpFeeResponse.new,
  );

  /// CreateCpfp spends an unconfirmed wallet UTXO with a child transaction whose
  /// fee lifts the parent+child package to the target fee rate (CPFP).
  static const createCpfp = connect.Spec(
    '/$name/CreateCpfp',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreateCpfpRequest.new,
    walletmanagerv1walletmanager.CreateCpfpResponse.new,
  );

  static const deriveAddresses = connect.Spec(
    '/$name/DeriveAddresses',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.DeriveAddressesRequest.new,
    walletmanagerv1walletmanager.DeriveAddressesResponse.new,
  );

  /// PSBT (BIP174). CreatePsbt builds an unsigned PSBT for a send (works for
  /// watch-only wallets); SignPsbt adds this wallet's signatures; CombinePsbt
  /// merges cosigner PSBTs; FinalizePsbt extracts the raw transaction. Electrum
  /// wallets only.
  static const createPsbt = connect.Spec(
    '/$name/CreatePsbt',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreatePsbtRequest.new,
    walletmanagerv1walletmanager.CreatePsbtResponse.new,
  );

  static const signPsbt = connect.Spec(
    '/$name/SignPsbt',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SignPsbtRequest.new,
    walletmanagerv1walletmanager.SignPsbtResponse.new,
  );

  /// SignPsbtWithCosigner signs a multisig PSBT with a single held cosigner's key
  /// (per-keystore signing), leaving the other legs for their own signers.
  static const signPsbtWithCosigner = connect.Spec(
    '/$name/SignPsbtWithCosigner',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SignPsbtWithCosignerRequest.new,
    walletmanagerv1walletmanager.SignPsbtWithCosignerResponse.new,
  );

  static const combinePsbt = connect.Spec(
    '/$name/CombinePsbt',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CombinePsbtRequest.new,
    walletmanagerv1walletmanager.CombinePsbtResponse.new,
  );

  static const finalizePsbt = connect.Spec(
    '/$name/FinalizePsbt',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.FinalizePsbtRequest.new,
    walletmanagerv1walletmanager.FinalizePsbtResponse.new,
  );

  /// MultisigPsbtStatus reports signing progress for a multisig wallet's PSBT:
  /// signature count, whether it can be finalized, and which cosigners signed.
  static const multisigPsbtStatus = connect.Spec(
    '/$name/MultisigPsbtStatus',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.MultisigPsbtStatusRequest.new,
    walletmanagerv1walletmanager.MultisigPsbtStatusResponse.new,
  );

  /// BroadcastTransaction broadcasts a finalized raw transaction over the
  /// wallet's chain source and returns its txid.
  static const broadcastTransaction = connect.Spec(
    '/$name/BroadcastTransaction',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.BroadcastTransactionRequest.new,
    walletmanagerv1walletmanager.BroadcastTransactionResponse.new,
  );

  /// Address reads that belong to no wallet — cheque addresses, whose funds are
  /// not the user's to spend. Always electrum-backed, whatever wallet is active.
  static const getAddressUnspent = connect.Spec(
    '/$name/GetAddressUnspent',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetAddressUnspentRequest.new,
    walletmanagerv1walletmanager.GetAddressUnspentResponse.new,
  );

  static const broadcastElectrumTransaction = connect.Spec(
    '/$name/BroadcastElectrumTransaction',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.BroadcastElectrumTransactionRequest.new,
    walletmanagerv1walletmanager.BroadcastElectrumTransactionResponse.new,
  );

  /// USB hardware wallets.
  static const enumerateHardwareDevices = connect.Spec(
    '/$name/EnumerateHardwareDevices',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.EnumerateHardwareDevicesRequest.new,
    walletmanagerv1walletmanager.EnumerateHardwareDevicesResponse.new,
  );

  static const getHardwareXpub = connect.Spec(
    '/$name/GetHardwareXpub',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetHardwareXpubRequest.new,
    walletmanagerv1walletmanager.GetHardwareXpubResponse.new,
  );

  static const signPsbtWithDevice = connect.Spec(
    '/$name/SignPsbtWithDevice',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SignPsbtWithDeviceRequest.new,
    walletmanagerv1walletmanager.SignPsbtWithDeviceResponse.new,
  );

  /// PromptDevicePin shows the PIN matrix; SendDevicePin unlocks with it.
  static const promptDevicePin = connect.Spec(
    '/$name/PromptDevicePin',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.PromptDevicePinRequest.new,
    walletmanagerv1walletmanager.PromptDevicePinResponse.new,
  );

  static const sendDevicePin = connect.Spec(
    '/$name/SendDevicePin',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SendDevicePinRequest.new,
    walletmanagerv1walletmanager.SendDevicePinResponse.new,
  );

  /// CloseDevice releases the device so the next enumerate isn't blocked.
  static const closeDevice = connect.Spec(
    '/$name/CloseDevice',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CloseDeviceRequest.new,
    walletmanagerv1walletmanager.CloseDeviceResponse.new,
  );

  /// DeriveKeystore turns a keystore's intent into derived account key material.
  static const deriveKeystore = connect.Spec(
    '/$name/DeriveKeystore',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.DeriveKeystoreRequest.new,
    walletmanagerv1walletmanager.DeriveKeystoreResponse.new,
  );

  /// PreviewWalletFromEntropy derives a wallet without saving it, so a caller can
  /// show the words while the user is still choosing their entropy.
  static const previewWalletFromEntropy = connect.Spec(
    '/$name/PreviewWalletFromEntropy',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.PreviewWalletFromEntropyRequest.new,
    walletmanagerv1walletmanager.PreviewWalletFromEntropyResponse.new,
  );

  /// Seed access for cheque engine
  static const getWalletSeed = connect.Spec(
    '/$name/GetWalletSeed',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetWalletSeedRequest.new,
    walletmanagerv1walletmanager.GetWalletSeedResponse.new,
  );

  /// Bitcoin Core variant selection (untouched / touched / knots).
  static const listCoreVariants = connect.Spec(
    '/$name/ListCoreVariants',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.ListCoreVariantsRequest.new,
    walletmanagerv1walletmanager.ListCoreVariantsResponse.new,
  );

  static const getCoreVariant = connect.Spec(
    '/$name/GetCoreVariant',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetCoreVariantRequest.new,
    walletmanagerv1walletmanager.GetCoreVariantResponse.new,
  );

  static const setCoreVariant = connect.Spec(
    '/$name/SetCoreVariant',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SetCoreVariantRequest.new,
    walletmanagerv1walletmanager.SetCoreVariantResponse.new,
  );

  /// Electrum server (Esplora endpoint) selection for electrum wallets.
  static const getElectrumServer = connect.Spec(
    '/$name/GetElectrumServer',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetElectrumServerRequest.new,
    walletmanagerv1walletmanager.GetElectrumServerResponse.new,
  );

  static const setElectrumServer = connect.Spec(
    '/$name/SetElectrumServer',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SetElectrumServerRequest.new,
    walletmanagerv1walletmanager.SetElectrumServerResponse.new,
  );

  /// Tor SOCKS5 proxy routing for the electrum wallet's chain connections.
  static const getTorConfig = connect.Spec(
    '/$name/GetTorConfig',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetTorConfigRequest.new,
    walletmanagerv1walletmanager.GetTorConfigResponse.new,
  );

  static const setTorConfig = connect.Spec(
    '/$name/SetTorConfig',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SetTorConfigRequest.new,
    walletmanagerv1walletmanager.SetTorConfigResponse.new,
  );

  /// Stream wallet state changes. Sends the full wallet state immediately,
  /// then again whenever wallets or balance change.
  static const watchWalletData = connect.Spec(
    '/$name/WatchWalletData',
    connect.StreamType.server,
    googleprotobufempty.Empty.new,
    walletmanagerv1walletmanager.WatchWalletDataResponse.new,
  );
}
