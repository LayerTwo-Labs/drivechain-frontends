//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
//

import "package:connectrpc/connect.dart" as connect;
import "walletmanager.pb.dart" as walletmanagerv1walletmanager;

abstract final class WalletManagerService {
  /// Fully-qualified name of the WalletManagerService service.
  static const name = 'walletmanager.v1.WalletManagerService';

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
}
