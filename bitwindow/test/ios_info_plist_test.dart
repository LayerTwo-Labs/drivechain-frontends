import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the iOS app declares why it uses the camera', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final usage = RegExp(r'<key>NSCameraUsageDescription</key>\s*<string>([^<]+)</string>').firstMatch(plist);
    expect(usage, isNotNull);
    expect(usage!.group(1)!.trim(), isNotEmpty);
  });
}
