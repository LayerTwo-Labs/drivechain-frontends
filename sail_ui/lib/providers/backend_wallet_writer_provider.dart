import 'dart:io';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.connect.client.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

/// RPC-backed wallet writer. Calls WalletManagerService on thunderd.
class BackendWalletWriterProvider extends WalletWriterProvider {
  final Logger _logger = GetIt.I.get<Logger>();
  late WalletManagerServiceClient _client;
  @override
  final Directory bitwindowAppDir;

  BackendWalletWriterProvider({required this.bitwindowAppDir}) {
    _initClient();
  }

  void _initClient() {
    final transport = connect.Transport(
      baseUrl: 'http://localhost:30400',
      codec: const ProtoCodec(),
      httpClient: createHttpClient(),
    );
    _client = WalletManagerServiceClient(transport);
  }

  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();

  @override
  Future<void> init() async {
    _logger.i('init: Backend wallet writer provider initialized');
    _walletReader.addListener(notifyListeners);
  }

  @override
  Future<bool> hasExistingWallet() async {
    return _walletReader.hasWallet();
  }

  @override
  Future<WalletData?> loadWallet() async {
    return _walletReader.activeWallet;
  }

  @override
  Future<void> saveWallet(WalletData wallet) async {
    await _walletReader.updateWallet(wallet);
  }

  @override
  Future<Map<String, dynamic>> generateWallet({
    required String name,
    String? customMnemonic,
    String? passphrase,
  }) async {
    try {
      final resp = await _client.generateWallet(
        wmpb.GenerateWalletRequest(
          name: name,
          customMnemonic: customMnemonic ?? '',
          passphrase: passphrase ?? '',
        ),
      );

      _logger.i(
        'generateWallet: wallet generated via backend, id=${resp.walletId}',
      );

      // Reload wallet reader to pick up the new wallet
      await _walletReader.init();
      notifyListeners();

      return {'wallet_id': resp.walletId, 'mnemonic': resp.mnemonic};
    } catch (e) {
      _logger.e('generateWallet: failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> createBitcoinCoreWallet({
    required String name,
    required WalletGradient gradient,
  }) async {
    final result = await generateWallet(name: name);
    final walletId = result['wallet_id'] as String?;
    if (walletId != null) {
      await updateWalletMetadata(walletId, name, gradient);
    }
  }

  @override
  Future<void> createWatchOnlyWallet({
    required String name,
    required String xpubOrDescriptor,
    required WalletGradient gradient,
  }) async {
    try {
      final resp = await _client.createWatchOnlyWallet(
        wmpb.CreateWatchOnlyWalletRequest(
          name: name,
          xpubOrDescriptor: xpubOrDescriptor,
          gradientJson: gradient.toJsonString(),
        ),
      );

      _logger.i(
        'createWatchOnlyWallet: created via backend, id=${resp.walletId}',
      );

      await _walletReader.init();
      notifyListeners();
    } catch (e) {
      _logger.e('createWatchOnlyWallet: failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> generateWalletFromEntropy(
    List<int> entropy, {
    String? passphrase,
    bool doNotSave = false,
  }) async {
    // Backend handles key derivation internally
    _logger.w(
      'generateWalletFromEntropy: delegating to generateWallet in backend mode',
    );
    return generateWallet(name: 'Enforcer Wallet', passphrase: passphrase);
  }

  @override
  Future<void> saveMasterWallet(
    Map<String, dynamic> walletData, {
    required String name,
  }) async {
    // Backend handles this internally during generateWallet
    _logger.w('saveMasterWallet: handled internally by backend generateWallet');
  }

  @override
  Future<Map<String, dynamic>?> loadMasterStarter() async {
    final wallet = await loadWallet();
    if (wallet != null) {
      return {
        'mnemonic': wallet.master.mnemonic,
        'seed_hex': wallet.master.seedHex,
        'master_key': wallet.master.masterKey,
        'chain_code': wallet.master.chainCode,
        'bip39_binary': wallet.master.bip39Binary,
        'bip39_checksum': wallet.master.bip39Checksum,
        'bip39_checksum_hex': wallet.master.bip39ChecksumHex,
        'name': wallet.master.name,
      };
    }
    return null;
  }

  @override
  Future<String?> getL1Starter() async {
    return _walletReader.getL1Mnemonic();
  }

  @override
  Future<String?> getSidechainStarter(int sidechainSlot) async {
    return _walletReader.getSidechainMnemonic(sidechainSlot);
  }

  @override
  Future<void> deleteAllWallets({
    Future<void> Function()? beforeBoot,
    void Function(String status)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('Deleting wallets via backend');
      await _client.deleteAllWallets(wmpb.DeleteAllWalletsRequest());
      _walletReader.clearState();
      onStatusUpdate?.call('Reset complete');

      if (beforeBoot != null) {
        await beforeBoot();
      }
    } catch (e) {
      _logger.e('deleteAllWallets: failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateWalletMetadata(
    String walletId,
    String name,
    WalletGradient gradient,
  ) async {
    try {
      await _client.updateWalletMetadata(
        wmpb.UpdateWalletMetadataRequest(
          walletId: walletId,
          name: name,
          gradientJson: gradient.toJsonString(),
        ),
      );
      await _walletReader.init();
    } catch (e) {
      _logger.e('updateWalletMetadata: failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> restartEnforcer() async {
    // In backend mode, the orchestrator handles binary lifecycle.
    // The Go OnWalletGenerated callback triggers enforcer restart.
    _logger.i('restartEnforcer: handled by Go orchestrator in backend mode');
  }

  @override
  void dispose() {
    _walletReader.removeListener(notifyListeners);
    super.dispose();
  }
}
