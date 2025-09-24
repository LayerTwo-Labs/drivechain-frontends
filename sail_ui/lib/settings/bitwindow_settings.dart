import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

// BitwindowSettings is a special kind of setting. It is *global* bitwindow
// settings that can be accessed by bitwindow (duh), but also all sidechains!
// magic
class BitwindowSettings {
  final Network network;
  // Add more settings fields here as needed in the future

  BitwindowSettings({
    this.network = Network.NETWORK_SIGNET,
  });

  Map<String, dynamic> toMap() {
    return {
      'network': network.name,
    };
  }

  factory BitwindowSettings.fromMap(Map<String, dynamic> map) {
    return BitwindowSettings(
      network: Network.values.firstWhere(
        (e) => e.name == map['network'],
        orElse: () => Network.NETWORK_SIGNET,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory BitwindowSettings.fromJson(String source) {
    try {
      return BitwindowSettings.fromMap(json.decode(source));
    } catch (e) {
      // Return default if parsing fails
      return BitwindowSettings();
    }
  }

  BitwindowSettings copyWith({
    Network? network,
  }) {
    return BitwindowSettings(
      network: network ?? this.network,
    );
  }
}

class BitwindowSettingValue extends SettingValue<BitwindowSettings> {
  BitwindowSettingValue({super.newValue});

  @override
  String get key => 'bitwindow_settings';

  @override
  BitwindowSettings defaultValue() => BitwindowSettings();

  @override
  String toJson() {
    return value.toJson();
  }

  @override
  BitwindowSettings? fromJson(String jsonString) {
    return BitwindowSettings.fromJson(jsonString);
  }

  @override
  SettingValue<BitwindowSettings> withValue([BitwindowSettings? value]) {
    return BitwindowSettingValue(newValue: value);
  }
}

/// Factory function to create a BitwindowClientSettings instance that stores data
/// in Bitwindow's application directory. This allows other applications
/// to access Bitwindow's global settings.
Future<BitwindowClientSettings> createBitwindowClientSettings({
  required Directory bitwindowAppDir,
  required Logger log,
}) async {
  final bitwindowStorage = await KeyValueStore.create(dir: bitwindowAppDir);
  return BitwindowClientSettings(store: bitwindowStorage, log: log);
}
