import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  test('Elements fallback matches the published installer metadata', () {
    final document = jsonDecode(File('../sidechain_core/assets/chains_config.json').readAsStringSync());
    final entry = document['binaries']['liquid-signet'] as Map<String, dynamic>;
    final bundled = binaryFromJson('liquid-signet', entry) as Sidechain;
    final fallback = LiquidSignet();

    expect(fallback.registryKey, 'liquid-signet');
    expect(bundled.registryKey, fallback.registryKey);
    expect(fallback.slot, 24);
    expect(fallback.version, bundled.version);
    expect(fallback.metadata.downloadConfig.binary, 'elementsd');
    expect(fallback.metadata.downloadConfig.files, bundled.metadata.downloadConfig.files);
    expect(fallback.metadata.downloadConfig.baseUrl(), bundled.metadata.downloadConfig.baseUrl());
    expect(entry['dependencies'], ['bitcoind']);
  });
}
