import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
// Import appropriate storage implementation
import 'package:sail_ui/settings/web_storage.dart' if (dart.library.html) 'web_storage_impl.dart';

abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> delete(String key);

  // Factory constructor that returns appropriate implementation
  static Future<KeyValueStore> create({Directory? dir}) async {
    if (kIsWeb) {
      return WebStorage();
    } else {
      return FileStorage.fromDirectory(dir ?? await getApplicationSupportDirectory());
    }
  }
}

// Web implementation using localStorage
class WebStorage implements KeyValueStore {
  @override
  Future<String?> getString(String key) async {
    if (kIsWeb) {
      return window.localStorage[key];
    }
    return null;
  }

  @override
  Future<void> setString(String key, String value) async {
    if (kIsWeb) {
      window.localStorage[key] = value;
    }
  }

  @override
  Future<void> delete(String key) async {
    if (kIsWeb) {
      window.localStorage.remove(key);
    }
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
