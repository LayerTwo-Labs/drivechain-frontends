import 'package:sail_ui/sail_ui.dart';

class MockStore implements KeyValueStore {
  final _db = {};

  @override
  Future<String?> getString(String key) async => _db[key];

  @override
  Future<void> setString(String key, String value) async {
    _db[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _db[key] = null;
  }
}
