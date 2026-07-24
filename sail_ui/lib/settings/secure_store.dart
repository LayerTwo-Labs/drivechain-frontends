import 'dart:convert';
import 'dart:io';

import 'package:sail_ui/utils/file_utils.dart';
import 'package:synchronized/synchronized.dart';

abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> delete(String key);

  static Future<KeyValueStore> create({Directory? dir}) async {
    return FileStorage.fromDirectory(
      dir ?? await applicationSupportDir(),
    );
  }
}

// Native implementation using file system
class FileStorage implements KeyValueStore {
  static final Map<String, Lock> _processLocks = {};

  static FileStorage fromDirectory(Directory dir) {
    final file = File('${dir.path}${Platform.pathSeparator}settings.json');
    return FileStorage._(file);
  }

  final File file;
  Map<String, String> _cache = {};
  bool _loaded = false;
  bool _loadedFromBackup = false;
  final Lock _processLock;

  FileStorage._(this.file)
    : _processLock = _processLocks.putIfAbsent(
        file.absolute.path,
        Lock.new,
      );

  Future<void> _ensureLoaded({bool refresh = false}) async {
    if (_loaded && !refresh) return;
    if (refresh) {
      _loaded = false;
      _loadedFromBackup = false;
      _cache = {};
    }
    final backup = File('${file.path}.bak');
    Object? primaryError;
    if (await file.exists()) {
      try {
        _cache = await _read(file);
        _loaded = true;
        return;
      } catch (error) {
        primaryError = error;
      }
    }
    if (await backup.exists()) {
      try {
        _cache = await _read(backup);
        _loaded = true;
        _loadedFromBackup = true;
        return;
      } catch (backupError) {
        throw FileSystemException(
          'Settings and its recovery copy are corrupt '
          '(primary: $primaryError, recovery: $backupError)',
          file.path,
        );
      }
    }
    if (primaryError != null) {
      throw FileSystemException(
        'Settings are corrupt and no recovery copy exists: $primaryError',
        file.path,
      );
    }
    _loaded = true;
  }

  Future<T> _withFileLock<T>(Future<T> Function() action) async {
    await file.parent.create(recursive: true);
    final lockFile = await File('${file.path}.lock').open(mode: FileMode.append);
    var locked = false;
    try {
      await lockFile.lock(FileLock.exclusive);
      locked = true;
      return await action();
    } finally {
      if (locked) await lockFile.unlock();
      await lockFile.close();
    }
  }

  Future<Map<String, String>> _read(File source) async {
    final decoded = jsonDecode(await source.readAsString());
    if (decoded is! Map) throw const FormatException('settings root is not an object');
    final result = <String, String>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String || entry.value is! String) {
        throw const FormatException('settings entry is not a string pair');
      }
      result[entry.key as String] = entry.value as String;
    }
    return result;
  }

  Future<void> _save() async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.next');
    final backup = File('${file.path}.bak');
    await temporary.writeAsString(jsonEncode(_cache), flush: true);
    try {
      if (await file.exists()) {
        if (_loadedFromBackup) {
          await file.delete();
        } else {
          if (await backup.exists()) await backup.delete();
          await file.rename(backup.path);
        }
      }
      await temporary.rename(file.path);
      _loadedFromBackup = false;
    } catch (_) {
      if (!await file.exists() && await backup.exists()) {
        await backup.rename(file.path);
      }
      rethrow;
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  @override
  Future<String?> getString(String key) => _processLock.synchronized(
    () => _withFileLock(() async {
      await _ensureLoaded(refresh: true);
      return _cache[key];
    }),
  );

  @override
  Future<void> setString(String key, String value) => _processLock.synchronized(
    () => _withFileLock(() async {
      await _ensureLoaded(refresh: true);
      final existed = _cache.containsKey(key);
      final previous = _cache[key];
      _cache[key] = value;
      try {
        await _save();
      } catch (_) {
        existed ? _cache[key] = previous! : _cache.remove(key);
        rethrow;
      }
    }),
  );

  @override
  Future<void> delete(String key) => _processLock.synchronized(
    () => _withFileLock(() async {
      await _ensureLoaded(refresh: true);
      if (!_cache.containsKey(key)) return;
      final previous = _cache.remove(key)!;
      try {
        await _save();
      } catch (_) {
        _cache[key] = previous;
        rethrow;
      }
    }),
  );
}
