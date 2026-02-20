import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:coinshift/models/coinshift_config.dart';
import 'package:coinshift/providers/coinshift_conf_provider.dart';

class CoinShiftConfigEditorViewModel extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();
  final CoinShiftConfProvider confProvider = GetIt.I.get<CoinShiftConfProvider>();

  CoinShiftConfig? originalConfig;
  CoinShiftConfig? workingConfig;
  String? _rawConfigText;
  String? errorMessage;
  bool isLoading = false;
  bool _isDisposed = false;

  CoinShiftConfigEditorViewModel() {
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
      originalConfig = CoinShiftConfig.parse(content);
      workingConfig = CoinShiftConfig.fromConfig(originalConfig!);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to load CoinShift config: $e');
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

      originalConfig = CoinShiftConfig.parse(configText);
      workingConfig = CoinShiftConfig.fromConfig(originalConfig!);
      _rawConfigText = null;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to save CoinShift config: $e');
      errorMessage = 'Failed to save configuration: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  void resetToDefault() {
    _rawConfigText = null;
    final defaultContent = confProvider.getDefaultConfig();
    workingConfig = CoinShiftConfig.parse(defaultContent);
    notifyListeners();
  }

  void resetChanges() {
    if (originalConfig != null) {
      workingConfig = CoinShiftConfig.fromConfig(originalConfig!);
      _rawConfigText = null;
      notifyListeners();
    }
  }

  void updateFromRawText(String rawText) {
    _rawConfigText = rawText;

    try {
      workingConfig = CoinShiftConfig.parse(rawText);
    } catch (e) {
      log.d('CoinShift config parsing failed during editing (this is ok): $e');
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
