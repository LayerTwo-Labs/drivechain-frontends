import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Settings provider that manages individual setting variables
/// with automatic persistence and change notification.
class SettingsProvider extends ChangeNotifier {
  ClientSettings get clientSettings => GetIt.I.get<ClientSettings>();
  BitwindowClientSettings get bitwindowClientSettings => GetIt.I.get<BitwindowClientSettings>();
  Logger get log => GetIt.I.get<Logger>();

  // Individual setting variables
  bool debugMode = false;
  bool useTestSidechains = false;
  BitwindowSettings bitwindowSettings = BitwindowSettings();
  SailFontValues font = SailFontValues.inter;

  // Convenience getters for individual bitwindow settings
  Network get network => bitwindowSettings.network;
  String? get bitcoinCoreDataDir => bitwindowSettings.bitcoinCoreDataDir;

  // Private constructor
  SettingsProvider._create();

  // Async factory
  static Future<SettingsProvider> create() async {
    final instance = SettingsProvider._create();
    await instance._loadAllSettings(); // Wait for settings to load to ensure correct initial state
    return instance;
  }

  /// Load all settings from storage
  Future<void> _loadAllSettings() async {
    await _loadDebugMode();
    await _loadUseTestSidechains();
    await _loadBitwindowSettings();
    await _loadFont();
  }

  /// Load debug mode setting
  Future<void> _loadDebugMode() async {
    final setting = DebugModeSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    debugMode = loadedSetting.value;
    notifyListeners();
  }

  /// Update debug mode setting
  Future<void> updateDebugMode(bool value) async {
    if (debugMode == value) {
      return;
    }

    try {
      debugMode = value;
      notifyListeners();
      final setting = DebugModeSetting(newValue: value);
      await clientSettings.setValue(setting);
    } catch (e) {
      // Revert on error
      debugMode = !value;
      notifyListeners();
      log.e('Failed to update debug mode', error: e);
      rethrow;
    }
  }

  /// Load use test sidechains setting
  Future<void> _loadUseTestSidechains() async {
    final setting = UseTestSidechainsSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    useTestSidechains = loadedSetting.value;
    notifyListeners();
  }

  /// Update use test sidechains setting
  Future<void> updateUseTestSidechains(bool value) async {
    if (useTestSidechains == value) {
      return;
    }

    try {
      useTestSidechains = value;
      notifyListeners();
      final setting = UseTestSidechainsSetting(newValue: value);
      await clientSettings.setValue(setting);

      // delete all binaries so we can redownload the correct ones
      final binaryProvider = GetIt.I.get<BinaryProvider>();
      final wipeOperations = binaryProvider.binaries
          .where((binary) => binary.chainLayer == 2)
          .map((binary) => binary.wipeAsset(binDir(binaryProvider.appDir.path)));
      await Future.wait(wipeOperations);
    } catch (e) {
      // Revert on error
      useTestSidechains = !value;
      notifyListeners();
      log.e('Failed to update use test sidechains', error: e);
      rethrow;
    }
  }

  /// Load bitwindow settings
  Future<void> _loadBitwindowSettings() async {
    final setting = BitwindowSettingValue();
    final loadedSetting = await bitwindowClientSettings.getValue(setting);
    bitwindowSettings = loadedSetting.value;
    notifyListeners();
  }

  /// Internal method to update bitwindow settings
  Future<void> _updateBitwindowSettings(BitwindowSettings value) async {
    final oldSettings = bitwindowSettings;
    try {
      bitwindowSettings = value;
      notifyListeners();
      final setting = BitwindowSettingValue(newValue: value);
      await bitwindowClientSettings.setValue(setting);
    } catch (e) {
      // Revert on error
      bitwindowSettings = oldSettings;
      notifyListeners();
      log.e('Failed to update bitwindow settings', error: e);
      rethrow;
    }
  }

  /// Update bitwindow network setting
  Future<void> updateBitwindowNetwork(Network network) async {
    if (bitwindowSettings.network == network) {
      return;
    }

    final oldNetwork = bitwindowSettings.network;
    final newSettings = bitwindowSettings.copyWith(network: network);
    await _updateBitwindowSettings(newSettings);

    // Regenerate bitcoin config for the new network
    _regenerateBitcoinConf();

    // When changing network, restart all services with data cleanup if needed
    final isMainnetChange = (oldNetwork == Network.NETWORK_MAINNET) != (network == Network.NETWORK_MAINNET);
    if (isMainnetChange) {
      log.i('Network changed from ${oldNetwork.name} to ${network.name}, restarting services...');
      await _restartServicesForMainnet();
    }
  }

  /// Update Bitcoin Core datadir setting
  Future<void> updateBitcoinCoreDataDir(String? dataDir) async {
    if (bitwindowSettings.bitcoinCoreDataDir == dataDir) {
      return;
    }

    final newSettings = bitwindowSettings.copyWith(bitcoinCoreDataDir: dataDir);
    await _updateBitwindowSettings(newSettings);

    // Regenerate bitcoin config to include the new datadir
    _regenerateBitcoinConf();
  }

  /// Regenerate bitcoin configuration file with current settings
  void _regenerateBitcoinConf() {
    try {
      // Call the static method to regenerate the config
      MainchainRPCLive.writeConfFileSync();
    } catch (e) {
      log.e('Failed to regenerate bitcoin config: $e');
    }
  }

  /// Restart all services when mainnet toggle changes
  Future<void> _restartServicesForMainnet() async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();

    final binaries = [
      BitcoinCore(),
      Enforcer(),
      BitWindow(),
    ];

    log.i('Stopping core, enforcer, and bitwindow...');
    final stopFutures = <Future>[];
    for (final binary in binaries) {
      stopFutures.add(binaryProvider.stop(binary));
    }
    await Future.wait(stopFutures);

    // Wait for processes to fully stop
    log.i('Waiting for processes to stop...');
    await Future.delayed(const Duration(seconds: 3));

    // Delete enforcer and bitwindow data
    log.i('Deleting enforcer and bitwindow data...');
    final enforcer = Enforcer();
    final bitwindow = BitWindow();
    await Future.wait([
      enforcer.wipeAppDir(),
      bitwindow.wipeAppDir(),
    ]);

    // Restart all services
    log.i('Restarting services...');
    final bitwindowBinary = binaryProvider.binaries.firstWhere((b) => b is BitWindow);
    await binaryProvider.startWithEnforcer(
      bitwindowBinary,
      bootExtraBinaryImmediately: true,
    );

    log.i('Service restart completed');
  }

  /// Load font setting
  Future<void> _loadFont() async {
    final setting = FontSetting();
    final loadedSetting = await clientSettings.getValue(setting);
    font = loadedSetting.value;
    notifyListeners();
  }

  /// Update font setting
  Future<void> updateFont(SailFontValues value) async {
    if (font == value) {
      return;
    }

    try {
      font = value;
      notifyListeners();
      final setting = FontSetting(newValue: value);
      await clientSettings.setValue(setting);
    } catch (e) {
      // Revert on error
      font = font == SailFontValues.inter ? SailFontValues.sourceCodePro : SailFontValues.inter;
      notifyListeners();
      log.e('Failed to update font', error: e);
      rethrow;
    }
  }
}
