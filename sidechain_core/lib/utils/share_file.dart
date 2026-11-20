import 'package:flutter/services.dart';
import 'package:sidechain_core/utils/file_utils.dart';
import 'package:sidechain_core/utils/native_channel.dart';

class ShareFileException implements Exception {
  final String message;

  const ShareFileException(this.message);

  @override
  String toString() => message;
}

/// Opens the phone share sheet for the file at [path].
/// Throws [UnsupportedError] off a phone and [ShareFileException] when the phone cannot share the file.
Future<void> shareFile(String path, {OS? os}) async {
  final target = os ?? getOS();
  if (target != OS.android && target != OS.ios) {
    throw UnsupportedError('only a phone has a share sheet');
  }
  try {
    await nativeChannel.invokeMethod<void>('shareFile', path);
  } on PlatformException catch (e) {
    throw ShareFileException('the phone could not share "$path": ${e.message}');
  }
}
