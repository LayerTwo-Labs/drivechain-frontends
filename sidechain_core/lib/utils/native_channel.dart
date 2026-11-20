import 'package:flutter/services.dart';
import 'package:sidechain_core/utils/instance.dart';

/// The channel to the native side of the BitWindow phone app.
const nativeChannel = MethodChannel('com.layertwolabs.bitwindow/native');

/// Reads BITWINDOW_HOME from the iOS app, which makes the folder and keeps it out of backups.
Future<void> loadIosBitwindowHome() async {
  final home = await nativeChannel.invokeMethod<String>('backendHome');
  if (home == null || home.isEmpty) {
    throw StateError('the iOS app gave no backend home');
  }
  setBitwindowHome(home);
}
