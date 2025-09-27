import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

enum ViewMode {
  settings,
  diff,
  raw,
}

class BitcoinConfigEditorViewModel extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();
  final BitcoinConfProvider confProvider = GetIt.I.get<BitcoinConfProvider>();

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

      // Get content from ConfProvider
      final content = confProvider.getCurrentConfigContent();
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

      // Delegate to ConfProvider
      await confProvider.writeConfig(workingConfig!.serialize());

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
    if (preset == ConfigPreset.defaultPreset) {
      // Use the default config from ConfProvider
      final defaultContent = confProvider.getDefaultConfig();
      workingConfig = BitcoinConfig.parse(defaultContent);
    } else {
      if (workingConfig == null) return;

      final presetSettings = ConfigPresets.getPresetSettings(preset);

      // Clear existing global settings
      workingConfig!.globalSettings.clear();

      // Apply preset settings
      for (final entry in presetSettings.entries) {
        workingConfig!.setSetting(entry.key, entry.value);
      }

      // Add network-specific settings for certain presets
      if (preset == ConfigPreset.performance || preset == ConfigPreset.storageOptimized) {
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
    }

    currentPreset = preset;
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
