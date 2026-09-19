import 'dart:io';

import 'package:sidechain_core/settings/secure_store.dart';

/// Writes keys into a settings file. A test starts two of these at the same
/// time to prove that neither process drops the other one's keys.
Future<void> main(List<String> args) async {
  final store = FileStorage.fromDirectory(Directory(args[0]));
  final prefix = args[1];
  final count = int.parse(args[2]);
  for (var i = 0; i < count; i++) {
    await store.setString('$prefix-$i', '$i');
  }
}
