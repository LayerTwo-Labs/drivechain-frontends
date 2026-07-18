import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

// First-run theme: the eCash builds (BITWINDOW_NETWORK=forknet or drynet2) default
// to the eCash theme; every other build defaults to Sail. A user's choice persists
// and overrides this.
const String _bitwindowNetwork = String.fromEnvironment('BITWINDOW_NETWORK');
const String defaultThemeStyleId = _bitwindowNetwork == 'forknet' || _bitwindowNetwork == 'drynet2' ? 'ecash' : 'sail';

// BitwindowSettings is a special kind of setting. It is *global* bitwindow
// settings that can be accessed by bitwindow (duh), but also all sidechains!
// magic
class BitwindowSettings {
  final bool paranoidMode;
  final String themeStyle;

  BitwindowSettings({this.paranoidMode = false, this.themeStyle = defaultThemeStyleId});

  Map<String, dynamic> toMap() {
    return {'paranoidMode': paranoidMode, 'themeStyle': themeStyle};
  }

  factory BitwindowSettings.fromMap(Map<String, dynamic> map) {
    return BitwindowSettings(
      paranoidMode: map['paranoidMode'] ?? false,
      themeStyle: map['themeStyle'] ?? defaultThemeStyleId,
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

  BitwindowSettings copyWith({bool? paranoidMode, String? themeStyle}) {
    return BitwindowSettings(
      paranoidMode: paranoidMode ?? this.paranoidMode,
      themeStyle: themeStyle ?? this.themeStyle,
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
