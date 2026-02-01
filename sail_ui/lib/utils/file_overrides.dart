import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

/// Retries an async operation with exponential backoff on Windows.
Future<T> _withRetry<T>(Future<T> Function() op) async {
  if (!io.Platform.isWindows) return op();
  const maxRetries = 5;

  for (var attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await op();
    } on io.FileSystemException {
      if (attempt == maxRetries) rethrow;
      await Future.delayed(Duration(milliseconds: 100 * attempt));
    }
  }
  throw StateError('Unreachable');
}

/// File wrapper that retries async operations on Windows to handle temporary
/// file locks from antivirus, indexing services, or other processes.
class RetryFile implements io.File {
  RetryFile(this._delegate);
  final io.File _delegate;

  @override
  Future<io.File> copy(String newPath) => _withRetry(() => _delegate.copy(newPath));
  @override
  Future<io.File> create({bool recursive = false, bool exclusive = false}) =>
      _withRetry(() => _delegate.create(recursive: recursive, exclusive: exclusive));
  @override
  Future<io.FileSystemEntity> delete({bool recursive = false}) =>
      _withRetry(() => _delegate.delete(recursive: recursive));
  @override
  Future<bool> exists() => _withRetry(() => _delegate.exists());
  @override
  Future<DateTime> lastAccessed() => _withRetry(() => _delegate.lastAccessed());
  @override
  Future<DateTime> lastModified() => _withRetry(() => _delegate.lastModified());
  @override
  Future<int> length() => _withRetry(() => _delegate.length());
  @override
  Future<io.RandomAccessFile> open({io.FileMode mode = io.FileMode.read}) =>
      _withRetry(() => _delegate.open(mode: mode));
  @override
  Future<Uint8List> readAsBytes() => _withRetry(() => _delegate.readAsBytes());
  @override
  Future<List<String>> readAsLines({Encoding encoding = utf8}) =>
      _withRetry(() => _delegate.readAsLines(encoding: encoding));
  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      _withRetry(() => _delegate.readAsString(encoding: encoding));
  @override
  Future<io.File> rename(String newPath) async => RetryFile(await _withRetry(() => _delegate.rename(newPath)));
  @override
  Future<io.FileStat> stat() => _withRetry(() => _delegate.stat());
  @override
  Future<io.File> writeAsBytes(List<int> bytes, {io.FileMode mode = io.FileMode.write, bool flush = false}) =>
      _withRetry(() => _delegate.writeAsBytes(bytes, mode: mode, flush: flush));
  @override
  Future<io.File> writeAsString(
    String contents, {
    io.FileMode mode = io.FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) => _withRetry(() => _delegate.writeAsString(contents, mode: mode, encoding: encoding, flush: flush));
  @override
  Future setLastAccessed(DateTime time) => _withRetry(() => _delegate.setLastAccessed(time));
  @override
  Future setLastModified(DateTime time) => _withRetry(() => _delegate.setLastModified(time));
  @override
  Future<String> resolveSymbolicLinks() => _withRetry(() => _delegate.resolveSymbolicLinks());

  // Sync/getters - pass through
  @override
  io.File get absolute => RetryFile(_delegate.absolute);
  @override
  io.Directory get parent => RetryDirectory(_delegate.parent);
  @override
  String get path => _delegate.path;
  @override
  Uri get uri => _delegate.uri;
  @override
  bool get isAbsolute => _delegate.isAbsolute;
  @override
  Stream<List<int>> openRead([int? start, int? end]) => _delegate.openRead(start, end);
  @override
  io.IOSink openWrite({io.FileMode mode = io.FileMode.write, Encoding encoding = utf8}) =>
      _delegate.openWrite(mode: mode, encoding: encoding);
  @override
  Stream<io.FileSystemEvent> watch({int events = io.FileSystemEvent.all, bool recursive = false}) =>
      _delegate.watch(events: events, recursive: recursive);
  @override
  io.File copySync(String newPath) => _delegate.copySync(newPath);
  @override
  void createSync({bool recursive = false, bool exclusive = false}) =>
      _delegate.createSync(recursive: recursive, exclusive: exclusive);
  @override
  void deleteSync({bool recursive = false}) => _delegate.deleteSync(recursive: recursive);
  @override
  bool existsSync() => _delegate.existsSync();
  @override
  DateTime lastAccessedSync() => _delegate.lastAccessedSync();
  @override
  DateTime lastModifiedSync() => _delegate.lastModifiedSync();
  @override
  int lengthSync() => _delegate.lengthSync();
  @override
  io.RandomAccessFile openSync({io.FileMode mode = io.FileMode.read}) => _delegate.openSync(mode: mode);
  @override
  Uint8List readAsBytesSync() => _delegate.readAsBytesSync();
  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) => _delegate.readAsLinesSync(encoding: encoding);
  @override
  String readAsStringSync({Encoding encoding = utf8}) => _delegate.readAsStringSync(encoding: encoding);
  @override
  io.File renameSync(String newPath) => RetryFile(_delegate.renameSync(newPath));
  @override
  String resolveSymbolicLinksSync() => _delegate.resolveSymbolicLinksSync();
  @override
  void setLastAccessedSync(DateTime time) => _delegate.setLastAccessedSync(time);
  @override
  void setLastModifiedSync(DateTime time) => _delegate.setLastModifiedSync(time);
  @override
  io.FileStat statSync() => _delegate.statSync();
  @override
  void writeAsBytesSync(List<int> bytes, {io.FileMode mode = io.FileMode.write, bool flush = false}) =>
      _delegate.writeAsBytesSync(bytes, mode: mode, flush: flush);
  @override
  void writeAsStringSync(
    String contents, {
    io.FileMode mode = io.FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) => _delegate.writeAsStringSync(contents, mode: mode, encoding: encoding, flush: flush);
}

/// Directory wrapper that retries async operations on Windows.
class RetryDirectory implements io.Directory {
  RetryDirectory(this._delegate);
  final io.Directory _delegate;

  @override
  Future<io.Directory> create({bool recursive = false}) => _withRetry(() => _delegate.create(recursive: recursive));
  @override
  Future<io.Directory> createTemp([String? prefix]) => _withRetry(() => _delegate.createTemp(prefix));
  @override
  Future<io.FileSystemEntity> delete({bool recursive = false}) =>
      _withRetry(() => _delegate.delete(recursive: recursive));
  @override
  Future<bool> exists() => _withRetry(() => _delegate.exists());
  @override
  Future<io.Directory> rename(String newPath) async =>
      RetryDirectory(await _withRetry(() => _delegate.rename(newPath)));
  @override
  Future<io.FileStat> stat() => _withRetry(() => _delegate.stat());
  @override
  Future<String> resolveSymbolicLinks() => _withRetry(() => _delegate.resolveSymbolicLinks());

  // Sync/getters - pass through
  @override
  io.Directory get absolute => RetryDirectory(_delegate.absolute);
  @override
  io.Directory get parent => RetryDirectory(_delegate.parent);
  @override
  String get path => _delegate.path;
  @override
  Uri get uri => _delegate.uri;
  @override
  bool get isAbsolute => _delegate.isAbsolute;
  @override
  Stream<io.FileSystemEntity> list({bool recursive = false, bool followLinks = true}) =>
      _delegate.list(recursive: recursive, followLinks: followLinks);
  @override
  Stream<io.FileSystemEvent> watch({int events = io.FileSystemEvent.all, bool recursive = false}) =>
      _delegate.watch(events: events, recursive: recursive);
  @override
  void createSync({bool recursive = false}) => _delegate.createSync(recursive: recursive);
  @override
  io.Directory createTempSync([String? prefix]) => _delegate.createTempSync(prefix);
  @override
  void deleteSync({bool recursive = false}) => _delegate.deleteSync(recursive: recursive);
  @override
  bool existsSync() => _delegate.existsSync();
  @override
  List<io.FileSystemEntity> listSync({bool recursive = false, bool followLinks = true}) =>
      _delegate.listSync(recursive: recursive, followLinks: followLinks);
  @override
  io.Directory renameSync(String newPath) => RetryDirectory(_delegate.renameSync(newPath));
  @override
  String resolveSymbolicLinksSync() => _delegate.resolveSymbolicLinksSync();
  @override
  io.FileStat statSync() => _delegate.statSync();
}

/// Wraps [body] with IOOverrides that retry file/directory operations on Windows.
/// On non-Windows platforms, simply calls [body] directly.
R withWindowsFileRetry<R>(R Function() body) {
  if (!io.Platform.isWindows) return body();

  return io.IOOverrides.runZoned(
    body,
    createFile: (path) => RetryFile(io.File(path)),
    createDirectory: (path) => RetryDirectory(io.Directory(path)),
  );
}
