import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sail_ui/sail_ui.dart';

/// Abstract wallet writer provider interface.
/// BitWindow uses FrontendWalletWriterProvider (file-based).
/// Thunder uses BackendWalletWriterProvider (via WalletManagerService RPC).
abstract class WalletWriterProvider extends ChangeNotifier {
  Directory get bitwindowAppDir;

  Future<void> init();
  Future<bool> hasExistingWallet();
  Future<WalletData?> loadWallet();
  Future<void> saveWallet(WalletData wallet);
  Future<Map<String, dynamic>> generateWallet({
    required String name,
    String? customMnemonic,
    String? passphrase,
  });
  Future<void> createBitcoinCoreWallet({
    required String name,
    required WalletGradient gradient,
  });
  Future<void> createWatchOnlyWallet({
    required String name,
    required String xpubOrDescriptor,
    required WalletGradient gradient,
  });
  Future<Map<String, dynamic>> generateWalletFromEntropy(
    List<int> entropy, {
    String? passphrase,
    bool doNotSave = false,
  });
  Future<void> saveMasterWallet(
    Map<String, dynamic> walletData, {
    required String name,
  });
  Future<Map<String, dynamic>?> loadMasterStarter();
  Future<String?> getL1Starter();
  Future<String?> getSidechainStarter(int sidechainSlot);
  Future<void> deleteAllWallets({
    Future<void> Function()? beforeBoot,
    void Function(String status)? onStatusUpdate,
  });
  Future<void> updateWalletMetadata(
    String walletId,
    String name,
    WalletGradient gradient,
  );
  Future<void> restartEnforcer();

  static WalletWriterProvider create({required Directory bitwindowAppDir}) {
    return BackendWalletWriterProvider(bitwindowAppDir: bitwindowAppDir);
  }
}
