import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sail_ui/sail_ui.dart';

/// Abstract wallet reader provider interface.
/// BitWindow uses FrontendWalletReaderProvider (file-based).
/// Thunder uses BackendWalletReaderProvider (via WalletManagerService RPC).
abstract class WalletReaderProvider extends ChangeNotifier {
  Directory get bitwindowAppDir;
  List<WalletData> get wallets;
  String? get activeWalletId;
  set activeWalletId(String? value);
  WalletData? get activeWallet;
  WalletData? get enforcerWallet;
  List<WalletMetadata> get availableWallets;
  String? get unlockedPassword;
  bool get isWalletUnlocked;
  bool get isWalletLocked;

  Future<void> init();
  File getWalletFile();
  Future<bool> hasWallet();
  Future<bool> isWalletEncrypted();
  Future<bool> unlockWallet(String password);
  Future<void> lockWallet();
  Future<void> encryptWallet(String password);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> removeEncryption(String password);
  Future<void> updateWallet(WalletData wallet);
  String? getL1Mnemonic();
  String? getSidechainMnemonic(int slot);
  Future<File> writeEnforcerL1Starter();
  Future<File> writeSidechainStarter(int slot);
  Future<void> cleanupStarterFiles();
  Future<void> switchWallet(String walletId);
  Future<void> removeWalletFromList(String walletId);
  Future<void> updateWalletMetadata(
    String walletId,
    String name,
    WalletGradient gradient,
  );
  void clearState();

  static WalletReaderProvider create(Directory bitwindowAppDir) {
    return BackendWalletReaderProvider(bitwindowAppDir);
  }
}
