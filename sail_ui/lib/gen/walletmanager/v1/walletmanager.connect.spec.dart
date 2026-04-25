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

  static const createWatchOnlyWallet = connect.Spec(
    '/$name/CreateWatchOnlyWallet',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.CreateWatchOnlyWalletRequest.new,
    walletmanagerv1walletmanager.CreateWatchOnlyWalletResponse.new,
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

  static const bumpFee = connect.Spec(
    '/$name/BumpFee',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.BumpFeeRequest.new,
    walletmanagerv1walletmanager.BumpFeeResponse.new,
  );

  static const deriveAddresses = connect.Spec(
    '/$name/DeriveAddresses',
    connect.StreamType.unary,
    walletmanagerv1walletmanager.DeriveAddressesRequest.new,
    walletmanagerv1walletmanager.DeriveAddressesResponse.new,
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

  /// Stream wallet state changes. Sends the full wallet state immediately,
  /// then again whenever wallets or balance change.
  static const watchWalletData = connect.Spec(
    '/$name/WatchWalletData',
    connect.StreamType.server,
    googleprotobufempty.Empty.new,
    walletmanagerv1walletmanager.WatchWalletDataResponse.new,
  );
}
