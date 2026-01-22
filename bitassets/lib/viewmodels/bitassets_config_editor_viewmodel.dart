import 'package:bitassets/models/bitassets_config.dart';
import 'package:bitassets/providers/bitassets_conf_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class BitassetsConfigEditorViewModel extends ChangeNotifier {
  final Logger log = GetIt.I.get<Logger>();
  final BitassetsConfProvider confProvider = GetIt.I.get<BitassetsConfProvider>();

  BitassetsConfig? originalConfig;
  BitassetsConfig? workingConfig;
  String? _rawConfigText;
  String? errorMessage;
  bool isLoading = false;
  bool _isDisposed = false;

  BitassetsConfigEditorViewModel() {
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
      originalConfig = BitassetsConfig.parse(content);
      workingConfig = BitassetsConfig.fromConfig(originalConfig!);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to load BitAssets config: $e');
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

      originalConfig = BitassetsConfig.parse(configText);
      workingConfig = BitassetsConfig.fromConfig(originalConfig!);
      _rawConfigText = null;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      log.e('Failed to save BitAssets config: $e');
      errorMessage = 'Failed to save configuration: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  void resetToDefault() {
    _rawConfigText = null;
    final defaultContent = confProvider.getDefaultConfig();
    workingConfig = BitassetsConfig.parse(defaultContent);
    notifyListeners();
  }

  void resetChanges() {
    if (originalConfig != null) {
      workingConfig = BitassetsConfig.fromConfig(originalConfig!);
      _rawConfigText = null;
      notifyListeners();
    }
  }

  void updateFromRawText(String rawText) {
    _rawConfigText = rawText;

    try {
      workingConfig = BitassetsConfig.parse(rawText);
    } catch (e) {
      log.d('BitAssets config parsing failed during editing (this is ok): $e');
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
