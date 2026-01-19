import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class EnforcerConfigEditorViewModel extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();
  final EnforcerConfProvider confProvider = GetIt.I.get<EnforcerConfProvider>();

  EnforcerConfig? originalConfig;
  EnforcerConfig? workingConfig;
  String? _rawConfigText;
  EnforcerConfigPreset currentPreset = EnforcerConfigPreset.custom;
  String? errorMessage;
  bool isLoading = false;
  bool _isDisposed = false;

  EnforcerConfigEditorViewModel() {
    confProvider.addListener(_onConfProviderChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    confProvider.removeListener(_onConfProviderChanged);
    super.dispose();
  }

  void _onConfProviderChanged() {
    if (_isDisposed) return;
    _rawConfigText = null;
    currentPreset = EnforcerConfigPreset.custom;
    loadConfig();
  }

  String get workingConfigText => _rawConfigText ?? workingConfig?.serialize() ?? '';
  String get originalConfigText => originalConfig?.serialize() ?? '';

  bool get hasUnsavedChanges {
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

      final content = confProvider.getCurrentConfigContent();
      originalConfig = EnforcerConfig.parse(content);
      workingConfig = EnforcerConfig.fromConfig(originalConfig!);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to load enforcer config: $e');
      errorMessage = 'Failed to load configuration: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSetting(String key, dynamic value) {
    if (workingConfig == null) return;

    if (value == null || value.toString().isEmpty) {
      workingConfig!.removeSetting(key);
    } else {
      workingConfig!.setSetting(key, value.toString());
    }

    _rawConfigText = null;
    currentPreset = EnforcerConfigPreset.custom;
    notifyListeners();
  }

  Future<void> saveConfig() async {
    if (workingConfig == null && _rawConfigText == null) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final configText = _rawConfigText ?? workingConfig!.serialize();
      await confProvider.writeConfig(configText);

      originalConfig = EnforcerConfig.parse(configText);
      workingConfig = EnforcerConfig.fromConfig(originalConfig!);
      _rawConfigText = null;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to save enforcer config: $e');
      errorMessage = 'Failed to save configuration: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  void applyPreset(EnforcerConfigPreset preset) {
    _rawConfigText = null;

    if (preset == EnforcerConfigPreset.defaultPreset) {
      final defaultContent = confProvider.getDefaultConfig();
      workingConfig = EnforcerConfig.parse(defaultContent);
    } else {
      if (workingConfig == null) return;

      final presetSettings = EnforcerConfigPresets.getPresetSettings(preset);

      workingConfig!.settings.clear();

      for (final entry in presetSettings.entries) {
        workingConfig!.setSetting(entry.key, entry.value);
      }
    }

    currentPreset = preset;
    notifyListeners();
  }

  void resetChanges() {
    if (originalConfig != null) {
      workingConfig = EnforcerConfig.fromConfig(originalConfig!);
      _rawConfigText = null;
      currentPreset = EnforcerConfigPreset.custom;
      notifyListeners();
    }
  }

  void updateFromRawText(String rawText) {
    _rawConfigText = rawText;
    currentPreset = EnforcerConfigPreset.custom;

    try {
      workingConfig = EnforcerConfig.parse(rawText);
    } catch (e) {
      log.d('Enforcer config parsing failed during editing (this is ok): $e');
    }

    notifyListeners();
  }

  String getDiff() {
    if (originalConfig == null) {
      return '';
    }

    final originalLines = originalConfig!.serialize().split('\n');
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
