import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  test('the apps build every binary but the external ones', () async {
    final appDir = await Directory.systemTemp.createTemp('chains_config_external');
    addTearDown(() => appDir.delete(recursive: true));
    await File('assets/chains_config.json').copy('${appDir.path}/chains_config.json');

    final provider = await ChainsConfigProvider.create(appDir: appDir, paranoidMode: true);
    addTearDown(provider.dispose);

    final config = json.decode(File('assets/chains_config.json').readAsStringSync()) as Map<String, dynamic>;
    final entries = (config['binaries'] as Map<String, dynamic>).values.cast<Map<String, dynamic>>();
    final internal = entries.where((e) => e['external'] != true);
    expect(internal.length, lessThan(entries.length));

    final binaries = provider.buildBinaries();
    expect(binaries.map((b) => b.name), isNot(contains('Solana')));
    expect(binaries, hasLength(internal.length));
  });
}
