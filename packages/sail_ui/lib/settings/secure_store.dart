import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> delete(String key);
}

class Storage implements KeyValueStore {
  final SharedPreferences preferences;

  Storage({
    required this.preferences,
  });

  @override
  Future<String?> getString(String key) async {
    final value = preferences.getString(key);
    return value;
  }

  @override
  Future<void> setString(String key, String value) async {
    await preferences.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await preferences.remove(key);
  }
}
