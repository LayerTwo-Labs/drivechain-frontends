import 'dart:convert';

import 'package:sail_ui/sail_ui.dart';

class FavoriteAssetsSetting extends SettingValue<Set<String>> {
  FavoriteAssetsSetting({super.newValue});

  @override
  String get key => 'favorite_assets';

  @override
  Set<String> defaultValue() => {};

  @override
  Set<String>? fromJson(String jsonString) {
    try {
      final list = jsonDecode(jsonString) as List;
      return Set<String>.from(list.cast<String>());
    } catch (_) {
      return null;
    }
  }

  @override
  String toJson() {
    return jsonEncode(value.toList());
  }

  @override
  SettingValue<Set<String>> withValue([Set<String>? value]) {
    return FavoriteAssetsSetting(newValue: value);
  }
}
