import 'dart:io';

/// True on a platform where the app owns an OS window (macOS, Linux, Windows).
bool get hasDesktopWindow => Platform.isMacOS || Platform.isLinux || Platform.isWindows;

/// True on a phone (Android, iOS).
bool get isMobile => Platform.isAndroid || Platform.isIOS;
