import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:sidechain_core/settings/client_settings.dart';
import 'package:thirds/blake3.dart';

class HashMapping {
  final String name;

  HashMapping({required this.name});

  Map<String, dynamic> toJson() => {'name': name};

  factory HashMapping.fromJson(Map<String, dynamic> json) {
    return HashMapping(name: json['name'] as String);
  }
}

class HashNameMappingSetting extends SettingValue<Map<String, HashMapping>> {
  HashNameMappingSetting({super.newValue});

  /// Every app reads and writes this mapping in the bitwindow store, so a name
  /// one app deciphers shows in the others.
  static BitwindowClientSettings get settings => GetIt.I.get<BitwindowClientSettings>();

  @override
  String get key => 'hash_name_mappings';

  @override
  Map<String, HashMapping> defaultValue() => {};

  @override
  String toJson() {
    final Map<String, Map<String, dynamic>> jsonMap = {};
    value.forEach((key, mapping) {
      jsonMap[key] = mapping.toJson();
    });
    return jsonEncode(jsonMap);
  }

  @override
  Map<String, HashMapping>? fromJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map) {
        final Map<String, HashMapping> result = {};
        decoded.forEach((key, value) {
          if (value is Map) {
            result[key] = HashMapping.fromJson(
              Map<String, dynamic>.from(value),
            );
          }
        });
        return result;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  SettingValue<Map<String, HashMapping>> withValue([
    Map<String, HashMapping>? value,
  ]) {
    return HashNameMappingSetting(newValue: value);
  }

  /// Get friendly name for a given hash
  String? nameFromHash(String hash) {
    return value[hash.toLowerCase()]?.name;
  }

  Future<void> saveMapping(String name) async {
    final clientSettings = settings;
    final hash = blake3Hex(utf8.encode(name));
    final currentValue = await clientSettings.getValue(this);
    final newMappings = Map<String, HashMapping>.from(currentValue.value);
    newMappings[hash] = HashMapping(name: name);
    await clientSettings.setValue(withValue(newMappings));
  }
}
