import 'dart:io';

import 'package:bitwindow/models/bitcoin_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

enum ViewMode {
  settings,
  diff,
  raw,
}

class BitcoinConfigProvider extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();

  BitcoinConfig? originalConfig;
  BitcoinConfig? workingConfig;
  ConfigPreset currentPreset = ConfigPreset.custom;
  ViewMode viewMode = ViewMode.settings;
  String? errorMessage;
  bool isLoading = false;

  String get workingConfigText => workingConfig?.serialize() ?? '';
  String get originalConfigText => originalConfig?.serialize() ?? '';
  bool get hasUnsavedChanges => workingConfig != originalConfig;

  Future<void> loadConfig() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final confFile = await _getConfigPath();
      final file = File(confFile);

      String content = '';
      if (await file.exists()) {
        content = await file.readAsString();
      } else {
        // Use the default config if no file exists
        content = _getDefaultConfigContent();
      }

      originalConfig = BitcoinConfig.parse(content);
      workingConfig = BitcoinConfig.fromConfig(originalConfig!);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to load config: $e');
      errorMessage = 'Failed to load configuration: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _getConfigPath() async {
    return path.join(BitcoinCore().datadir(), 'bitwindow-bitcoin.conf');
  }

  String _getDefaultConfigContent() {
    final settingsProvider = GetIt.I.get<SettingsProvider>();
    final datadirLine = settingsProvider.bitcoinCoreDataDir != null
        ? 'datadir=${settingsProvider.bitcoinCoreDataDir}'
        : '';

    return '''# Generated code. Any changes to this file *will* get overwritten.
# source: bitwindow bitcoin config editor

# Common settings for all networks
rpcuser=user
rpcpassword=password
server=1
listen=1
txindex=1
zmqpubsequence=tcp://0.0.0.0:29000
rpcthreads=20
rpcworkqueue=100
rest=1
fallbackfee=0.00021
$datadirLine

# Mainnet-specific settings
[main]

# Testnet-specific settings
[test]

# Signet-specific settings
[signet]
addnode=172.105.148.135:38333
signetblocktime=60
signetchallenge=00141551188e5153533b4fdd555449e640d9cc129456
acceptnonstdtxn=1

# Regtest-specific settings
[regtest]
''';
  }

  void updateSetting(String key, dynamic value, {String? section}) {
    if (workingConfig == null) return;

    if (value == null || value.toString().isEmpty) {
      workingConfig!.removeSetting(key, section: section);
    } else {
      workingConfig!.setSetting(key, value.toString(), section: section);
    }

    currentPreset = ConfigPreset.custom;
    notifyListeners();
  }

  Future<void> saveConfig() async {
    if (workingConfig == null) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final confFile = await _getConfigPath();
      final file = File(confFile);
      // Write new config
      await file.writeAsString(workingConfig!.serialize());
      log.i('Saved config to $confFile');

      // Update original config to match
      originalConfig = BitcoinConfig.fromConfig(workingConfig!);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to save config: $e');
      errorMessage = 'Failed to save configuration: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  void applyPreset(ConfigPreset preset) {
    if (workingConfig == null) return;

    currentPreset = preset;
    final presetSettings = ConfigPresets.getPresetSettings(preset);

    // Clear existing global settings
    workingConfig!.globalSettings.clear();

    // Apply preset settings
    for (final entry in presetSettings.entries) {
      workingConfig!.setSetting(entry.key, entry.value);
    }

    // Add network-specific settings for certain presets
    if (preset == ConfigPreset.defaultPreset ||
        preset == ConfigPreset.performance ||
        preset == ConfigPreset.storageOptimized) {
      // Add signet configuration
      workingConfig!.setSetting('addnode', '172.105.148.135:38333', section: 'signet');
      workingConfig!.setSetting('signetblocktime', '60', section: 'signet');
      workingConfig!.setSetting('signetchallenge', '00141551188e5153533b4fdd555449e640d9cc129456', section: 'signet');
      workingConfig!.setSetting('acceptnonstdtxn', '1', section: 'signet');
    }

    // Add datadir if not on Windows
    if (!Platform.isWindows) {
      workingConfig!.setSetting('datadir', BitcoinCore().datadir());
    }

    // Add ZMQ settings
    workingConfig!.setSetting('zmqpubsequence', 'tcp://0.0.0.0:29000');

    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    viewMode = mode;
    notifyListeners();
  }

  void resetChanges() {
    if (originalConfig != null) {
      workingConfig = BitcoinConfig.fromConfig(originalConfig!);
      currentPreset = ConfigPreset.custom;
      notifyListeners();
    }
  }

  void updateFromRawText(String rawText) {
    try {
      workingConfig = BitcoinConfig.parse(rawText);
      currentPreset = ConfigPreset.custom;
      notifyListeners();
    } catch (e) {
      log.e('Failed to parse config from raw text: $e');
      // Keep the existing config if parsing fails
    }
  }

  String getDiff() {
    if (originalConfig == null || workingConfig == null) {
      return '';
    }

    final originalLines = originalConfig!.serialize().split('\n');
    final workingLines = workingConfig!.serialize().split('\n');

    final buffer = StringBuffer();
    int maxLines = originalLines.length > workingLines.length ? originalLines.length : workingLines.length;

    for (int i = 0; i < maxLines; i++) {
      final originalLine = i < originalLines.length ? originalLines[i] : '';
      final workingLine = i < workingLines.length ? workingLines[i] : '';

      if (originalLine != workingLine) {
        if (originalLine.isNotEmpty && workingLine.isEmpty) {
          buffer.writeln('- $originalLine');
        } else if (originalLine.isEmpty && workingLine.isNotEmpty) {
          buffer.writeln('+ $workingLine');
        } else {
          buffer.writeln('- $originalLine');
          buffer.writeln('+ $workingLine');
        }
      } else {
        buffer.writeln('  $originalLine');
      }
    }

    return buffer.toString();
  }
}
