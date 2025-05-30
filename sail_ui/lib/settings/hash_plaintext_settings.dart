import 'dart:convert';

import 'package:sail_ui/settings/client_settings.dart';

class HashNameMappingSetting extends SettingValue<Map<String, String>> {
  HashNameMappingSetting({super.newValue});

  @override
  String get key => 'hash_name_mappings';

  @override
  Map<String, String> defaultValue() => {};

  @override
  String toJson() {
    return jsonEncode(value);
  }

  @override
  Map<String, String>? fromJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map) {
        return Map<String, String>.from(decoded);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  SettingValue<Map<String, String>> withValue([Map<String, String>? value]) {
    return HashNameMappingSetting(newValue: value);
  }

  /// Add a new hash-name mapping
  HashNameMappingSetting addMapping(String hash, String name) {
    final newMappings = Map<String, String>.from(value);
    newMappings[hash.toLowerCase()] = name.toLowerCase();
    return HashNameMappingSetting(newValue: newMappings);
  }

  /// Get friendly name for a given hash
  String? nameFromHash(String hash) {
    return value[hash.toLowerCase()];
  }
}
