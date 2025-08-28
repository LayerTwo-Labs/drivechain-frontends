import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:sail_ui/settings/client_settings.dart';
import 'package:thirds/blake3.dart';

class HashMapping {
  final String name;
  final bool isMine;

  HashMapping({required this.name, this.isMine = false});

  Map<String, dynamic> toJson() => {'name': name, 'isMine': isMine};

  factory HashMapping.fromJson(Map<String, dynamic> json) {
    return HashMapping(name: json['name'] as String, isMine: json['isMine'] as bool? ?? false);
  }
}

class HashNameMappingSetting extends SettingValue<Map<String, HashMapping>> {
  HashNameMappingSetting({super.newValue});

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
            result[key] = HashMapping.fromJson(Map<String, dynamic>.from(value));
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
  SettingValue<Map<String, HashMapping>> withValue([Map<String, HashMapping>? value]) {
    return HashNameMappingSetting(newValue: value);
  }

  /// Add a new hash-name mapping
  HashNameMappingSetting addMapping(String hash, String name, {bool isMine = false}) {
    final newMappings = Map<String, HashMapping>.from(value);
    newMappings[hash.toLowerCase()] = HashMapping(name: name.toLowerCase(), isMine: isMine);
    return HashNameMappingSetting(newValue: newMappings);
  }

  /// Get friendly name for a given hash
  String? nameFromHash(String hash) {
    return value[hash.toLowerCase()]?.name;
  }

  /// Get isMine flag for a given hash
  bool isMineFromHash(String hash) {
    return value[hash.toLowerCase()]?.isMine ?? false;
  }

  /// Save a new mapping with isMine flag
  Future<void> saveMapping(String name, {bool isMine = false}) async {
    final clientSettings = GetIt.I.get<ClientSettings>();
    final hash = blake3Hex(utf8.encode(name));
    final currentValue = await clientSettings.getValue(this);
    final newMappings = Map<String, HashMapping>.from(currentValue.value);
    newMappings[hash] = HashMapping(name: name, isMine: isMine);
    await clientSettings.setValue(withValue(newMappings));
  }
}
