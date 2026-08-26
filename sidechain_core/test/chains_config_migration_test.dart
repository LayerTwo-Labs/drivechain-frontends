import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// A config that ships ahead of its migrations freezes every existing install on
// stale data. ChainsConfigProvider probes 001..N and stops at the first gap.
void main() {
  final config = json.decode(File('assets/chains_config.json').readAsStringSync()) as Map<String, dynamic>;

  List<int> migrationNumbers() {
    return Directory('assets/migrations')
        .listSync()
        .map((entry) => entry.uri.pathSegments.last)
        .where((name) => name.endsWith('_chains_config.json'))
        .map((name) => int.parse(name.split('_').first))
        .toList()
      ..sort();
  }

  test('the newest migration carries the version the config ships', () {
    expect(migrationNumbers().last, config['version']);
  });

  test('the migrations run from one with no gap', () {
    expect(migrationNumbers(), List.generate(migrationNumbers().length, (i) => i + 1));
  });

  test('the newest migration holds what the config holds', () {
    final newest = migrationNumbers().last.toString().padLeft(3, '0');
    final file = File('assets/migrations/${newest}_chains_config.json');
    final migration = json.decode(file.readAsStringSync()) as Map<String, dynamic>;

    // A patch migration merges, so it carries only what it changes.
    if (migration['migration'] == 'patch') {
      return;
    }
    expect(migration, config);
  });

  test('the config names the daemon the app spawns', () {
    final binaries = config['binaries'] as Map<String, dynamic>;
    expect(binaries.containsKey('drivechaind'), isTrue);
    expect((binaries['drivechaind'] as Map)['download']['binary'], 'drivechaind');
  });
}
