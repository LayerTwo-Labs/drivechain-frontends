import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/config/sidechains.dart';

// The truthcoin node writes `truthcoin_dc` (truthcoin-dc app/cli.rs). A folder
// name that disagrees empties the log page, the wallet file list and the reset.
const _nodeDataDir = 'truthcoin_dc';

void main() {
  test('the shipped config names the folder the node writes', () {
    final config = json.decode(File('assets/chains_config.json').readAsStringSync()) as Map<String, dynamic>;
    final dirs = config['binaries']['truthcoin']['directories']['binary']['default'] as Map<String, dynamic>;

    for (final os in ['linux', 'macos', 'windows']) {
      expect(dirs[os], _nodeDataDir, reason: 'the $os folder must match the node');
    }
  });

  test('the fallback the app holds names the same folder', () {
    for (final perOs in Truthcoin().directories.binary.values) {
      for (final dir in perOs.values) {
        expect(dir, _nodeDataDir);
      }
    }
  });
}
