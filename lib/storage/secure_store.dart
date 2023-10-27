import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sidesail/storage/client_settings.dart';

class SecureStore implements KeyValueStore {
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> getString(String key) {
    final value = _storage.read(key: key);
    return value;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
