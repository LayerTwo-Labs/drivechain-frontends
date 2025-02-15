import 'package:sail_ui/settings/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsKeyValueStore implements KeyValueStore {
  final SharedPreferences _prefs;

  SharedPrefsKeyValueStore(this._prefs);

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  static Future<KeyValueStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsKeyValueStore(prefs);
  }
}
