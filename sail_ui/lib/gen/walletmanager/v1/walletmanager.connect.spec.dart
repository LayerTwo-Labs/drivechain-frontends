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
  /// Core or enforcer runs — chain data is served remotely via the datasource.
  static const createElectrumWallet = connect.Spec(
    '/$name/CreateElectrumWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreateElectrumWalletRequest.new,
    walletmanagerv1walletmanager.CreateElectrumWalletResponse.new,
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

  /// Test-sidechains toggle. When enabled, layer-2 binaries download/run from
  /// the alternative_download config (test builds) instead of the default.
  static const getTestSidechains = connect.Spec(
    '/$name/GetTestSidechains',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.GetTestSidechainsRequest.new,
    walletmanagerv1walletmanager.GetTestSidechainsResponse.new,
  );

  static const setTestSidechains = connect.Spec(
    '/$name/SetTestSidechains',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.SetTestSidechainsRequest.new,
    walletmanagerv1walletmanager.SetTestSidechainsResponse.new,
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
