import 'dart:convert';
import 'dart:io';

abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> delete(String key);

  /// Reads one key, changes it, and writes it back as one step. A file store
  /// holds its lock across the whole step, so two apps that change one key at
  /// the same time keep both changes.
  Future<void> update(String key, String Function(String? current) change);

  static Future<KeyValueStore> create({required Directory dir}) async {
    return FileStorage.fromDirectory(dir);
  }
}

// Native implementation using file system
class FileStorage implements KeyValueStore {
  static FileStorage fromDirectory(Directory dir) {
    final file = File('${dir.path}${Platform.pathSeparator}settings.json');
    return FileStorage._(file);
  }

  final File file;
  Future<void> _writes = Future<void>.value();

  FileStorage._(this.file);

  // Another app writes this same file. A cached copy goes stale, and a write
  // from it drops what the other app saved.
  Future<Map<String, String>> _read() async {
    if (!await file.exists()) {
      return {};
    }
    try {
      return Map<String, String>.from(jsonDecode(await file.readAsString()));
    } catch (e) {
      // If file is corrupted, start fresh
      return {};
    }
  }

  // BitWindow and a sidechain app write this file from separate processes, so
  // the read, the change and the write go under one lock. The rename gives a
  // reader a whole file, never a half-written one.
  Future<void> _write(void Function(Map<String, String>) change) {
    final next = _writes.then((_) async {
      final lock = await File('${file.path}.lock').open(mode: FileMode.write);
      try {
        await lock.lock(FileLock.blockingExclusive);
        final values = await _read();
        change(values);
        final temp = File('${file.path}.$pid.tmp');
        await temp.writeAsString(jsonEncode(values));
        await temp.rename(file.path);
      } finally {
        await lock.close();
      }
    });
    _writes = next.catchError((Object _) {});
    return next;
  }

  @override
  Future<String?> getString(String key) async => (await _read())[key];

  @override
  Future<void> setString(String key, String value) {
    return _write((values) => values[key] = value);
  }

  @override
  Future<void> delete(String key) {
    return _write((values) => values.remove(key));
  }

  @override
  Future<void> update(String key, String Function(String? current) change) {
    return _write((values) => values[key] = change(values[key]));
  }
}
