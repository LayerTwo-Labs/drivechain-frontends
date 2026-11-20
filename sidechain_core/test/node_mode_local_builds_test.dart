import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/providers/node_mode_provider.dart';

void main() {
  test('desktop builds run the local backends', () {
    for (final abi in [Abi.macosArm64, Abi.macosX64, Abi.linuxX64, Abi.windowsX64]) {
      expect(hasLocalBuilds(abi), isTrue, reason: '$abi');
    }
  });

  test('Linux arm64 and Android have no local backends', () {
    for (final abi in [Abi.linuxArm64, Abi.androidArm64, Abi.androidArm, Abi.androidX64]) {
      expect(hasLocalBuilds(abi), isFalse, reason: '$abi');
    }
  });
}
