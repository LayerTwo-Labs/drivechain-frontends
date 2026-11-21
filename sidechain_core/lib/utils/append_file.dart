import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// A write-only file that the OS moves to its end before each write.
/// [FileMode.append] moves there only at open, so it overwrites other writers.
abstract interface class AppendFile {
  /// Opens [path] for append. Creates the file when it does not exist.
  factory AppendFile.open(String path) => Platform.isWindows ? _WindowsAppendFile(path) : _PosixAppendFile(path);

  /// Writes all of [bytes] at the end of the file.
  void write(List<int> bytes);

  void close();
}

/// The open(2) flags O_WRONLY | O_APPEND | O_CREAT | O_CLOEXEC on [os].
@visibleForTesting
int appendOpenFlags(String os) => switch (os) {
  'macos' || 'ios' => 0x1 | 0x8 | 0x200 | 0x1000000,
  _ => 0x1 | 0x400 | 0x40 | 0x80000,
};

typedef _OpenC = Int32 Function(Pointer<Utf8>, Int32, VarArgs<(Int32,)>);
typedef _OpenDart = int Function(Pointer<Utf8>, int, int);
typedef _WriteC = IntPtr Function(Int32, Pointer<Uint8>, Size);
typedef _WriteDart = int Function(int, Pointer<Uint8>, int);
typedef _CloseC = Int32 Function(Int32);
typedef _CloseDart = int Function(int);

class _PosixAppendFile implements AppendFile {
  static final _libc = DynamicLibrary.process();
  static final _open = _libc.lookupFunction<_OpenC, _OpenDart>('open');
  static final _write = _libc.lookupFunction<_WriteC, _WriteDart>('write');
  static final _close = _libc.lookupFunction<_CloseC, _CloseDart>('close');

  static final _flags = appendOpenFlags(Platform.operatingSystem);
  static const _mode = 0x1a4; // 0644

  _PosixAppendFile(this._path) : _fd = _openFd(_path);

  final String _path;
  final int _fd;

  static int _openFd(String path) {
    final name = path.toNativeUtf8();
    try {
      final fd = _open(name, _flags, _mode);
      if (fd < 0) {
        throw FileSystemException('Cannot open the file for append', path);
      }
      return fd;
    } finally {
      malloc.free(name);
    }
  }

  @override
  void write(List<int> bytes) {
    if (bytes.isEmpty) {
      return;
    }
    final buffer = malloc<Uint8>(bytes.length);
    try {
      buffer.asTypedList(bytes.length).setAll(0, bytes);
      var done = 0;
      while (done < bytes.length) {
        final n = _write(_fd, buffer + done, bytes.length - done);
        if (n < 0) {
          throw FileSystemException('Cannot write to the file', _path);
        }
        done += n;
      }
    } finally {
      malloc.free(buffer);
    }
  }

  @override
  void close() {
    if (_close(_fd) != 0) {
      throw FileSystemException('Cannot close the file', _path);
    }
  }
}

typedef _CreateFileC = IntPtr Function(Pointer<Utf16>, Uint32, Uint32, Pointer<Void>, Uint32, Uint32, IntPtr);
typedef _CreateFileDart = int Function(Pointer<Utf16>, int, int, Pointer<Void>, int, int, int);
typedef _WriteFileC = Int32 Function(IntPtr, Pointer<Uint8>, Uint32, Pointer<Uint32>, Pointer<Void>);
typedef _WriteFileDart = int Function(int, Pointer<Uint8>, int, Pointer<Uint32>, Pointer<Void>);
typedef _CloseHandleC = Int32 Function(IntPtr);
typedef _CloseHandleDart = int Function(int);

class _WindowsAppendFile implements AppendFile {
  static final _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final _createFile = _kernel32.lookupFunction<_CreateFileC, _CreateFileDart>('CreateFileW');
  static final _writeFile = _kernel32.lookupFunction<_WriteFileC, _WriteFileDart>('WriteFile');
  static final _closeHandle = _kernel32.lookupFunction<_CloseHandleC, _CloseHandleDart>('CloseHandle');

  static const _fileAppendData = 0x4;
  static const _synchronize = 0x100000;
  static const _shareReadWrite = 0x1 | 0x2;
  static const _openAlways = 4;
  static const _attributeNormal = 0x80;
  static const _invalidHandle = -1;

  _WindowsAppendFile(this._path) : _handle = _openHandle(_path);

  final String _path;
  final int _handle;

  static int _openHandle(String path) {
    final name = path.toNativeUtf16();
    try {
      final handle = _createFile(
        name,
        _fileAppendData | _synchronize,
        _shareReadWrite,
        nullptr,
        _openAlways,
        _attributeNormal,
        0,
      );
      if (handle == _invalidHandle) {
        throw FileSystemException('Cannot open the file for append', path);
      }
      return handle;
    } finally {
      malloc.free(name);
    }
  }

  @override
  void write(List<int> bytes) {
    if (bytes.isEmpty) {
      return;
    }
    final buffer = malloc<Uint8>(bytes.length);
    final written = malloc<Uint32>();
    try {
      buffer.asTypedList(bytes.length).setAll(0, bytes);
      var done = 0;
      while (done < bytes.length) {
        if (_writeFile(_handle, buffer + done, bytes.length - done, written, nullptr) == 0) {
          throw FileSystemException('Cannot write to the file', _path);
        }
        done += written.value;
      }
    } finally {
      malloc.free(buffer);
      malloc.free(written);
    }
  }

  @override
  void close() {
    if (_closeHandle(_handle) == 0) {
      throw FileSystemException('Cannot close the file', _path);
    }
  }
}
