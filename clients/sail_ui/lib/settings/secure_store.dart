import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> delete(String key);

  static Future<KeyValueStore> create({Directory? dir}) async {
    return FileStorage.fromDirectory(dir ?? await getApplicationSupportDirectory());
  }
}

// Native implementation using file system
class FileStorage implements KeyValueStore {
  static FileStorage fromDirectory(Directory dir) {
    final file = File('${dir.path}${Platform.pathSeparator}settings.json');
    return FileStorage._(file);
  }

  final File file;
  Map<String, String> _cache = {};
  bool _loaded = false;

  FileStorage._(this.file);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;

    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        _cache = Map<String, String>.from(jsonDecode(contents));
      } catch (e) {
        // If file is corrupted, start fresh
        _cache = {};
      }
    }
    _loaded = true;
  }

  Future<void> _save() async {
    await file.writeAsString(jsonEncode(_cache));
  }

  @override
  Future<String?> getString(String key) async {
    await _ensureLoaded();
    return _cache[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    await _ensureLoaded();
    _cache[key] = value;
    await _save();
  }

  @override
  Future<void> delete(String key) async {
    await _ensureLoaded();
    _cache.remove(key);
    await _save();
  }
}
