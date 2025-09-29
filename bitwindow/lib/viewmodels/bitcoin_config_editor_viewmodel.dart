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
  String? _rawConfigText; // Store raw text separately for manual editing
  ConfigPreset currentPreset = ConfigPreset.custom;
  ViewMode viewMode = ViewMode.settings;
  String? errorMessage;
  bool isLoading = false;

  String get workingConfigText => _rawConfigText ?? workingConfig?.serialize() ?? '';
  String get originalConfigText => originalConfig?.serialize() ?? '';
  bool get hasUnsavedChanges {
    // Check both structured config and raw text changes
    if (_rawConfigText != null) {
      return _rawConfigText != originalConfigText;
    }
    return workingConfig != originalConfig;
  }

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

    // Clear raw text when updating via structured settings
    _rawConfigText = null;
    currentPreset = ConfigPreset.custom;
    notifyListeners();
  }

  Future<void> saveConfig() async {
    if (workingConfig == null && _rawConfigText == null) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Use raw text if available, otherwise use structured config
      final configText = _rawConfigText ?? workingConfig!.serialize();

      // Delegate to ConfProvider
      await confProvider.writeConfig(configText);

      // Parse the saved config to update our structured representation
      originalConfig = BitcoinConfig.parse(configText);
      workingConfig = BitcoinConfig.fromConfig(originalConfig!);
      _rawConfigText = null; // Clear raw text after saving

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
    // Clear raw text when applying preset
    _rawConfigText = null;

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
      _rawConfigText = null; // Clear any raw text edits
      currentPreset = ConfigPreset.custom;
      notifyListeners();
    }
  }

  void updateFromRawText(String rawText) {
    // Store the raw text exactly as entered by the user
    _rawConfigText = rawText;
    currentPreset = ConfigPreset.custom;

    // Try to parse for validation purposes, but keep the raw text regardless
    try {
      workingConfig = BitcoinConfig.parse(rawText);
    } catch (e) {
      // Parsing failed but we still keep the raw text for user editing
      log.d('Config parsing failed during editing (this is ok): $e');
    }

    notifyListeners();
  }

  String getDiff() {
    if (originalConfig == null) {
      return '';
    }

    final originalLines = originalConfig!.serialize().split('\n');

    // Use raw text if available, otherwise use structured config
    final workingText = _rawConfigText ?? workingConfig?.serialize() ?? '';
    final workingLines = workingText.split('\n');

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
