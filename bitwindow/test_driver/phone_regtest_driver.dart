import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Writes each screenshot of the phone regtest test to PHONE_QA_SHOTS.
Future<void> main() async {
  final dir = Directory(Platform.environment['PHONE_QA_SHOTS'] ?? 'build/phone-qa');
  await dir.create(recursive: true);
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      await File('${dir.path}/$name.png').writeAsBytes(bytes);
      return true;
    },
  );
}
