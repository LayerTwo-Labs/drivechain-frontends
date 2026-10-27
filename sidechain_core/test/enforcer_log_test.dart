import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('enforcer_log_test');
  });
  tearDown(() => root.delete(recursive: true));

  void writeLog(List<String> dir, String name) {
    final file = File(path.joinAll([root.path, ...dir, name]));
    file.createSync(recursive: true);
  }

  test('reads the newest log of the eCash fork folder', () {
    writeLog(['ecash', 'mainnet', 'logs'], 'bip300301_enforcer.log.2026-10-26.1');
    writeLog(['ecash', 'mainnet', 'logs'], 'bip300301_enforcer.log.2026-10-26.3');
    writeLog(['ecash', 'mainnet', 'logs'], 'bip300301_enforcer.log.2026-10-25.9');

    expect(
      latestEnforcerLog(root.path, BitcoinNetwork.BITCOIN_NETWORK_ECASH),
      path.join(root.path, 'ecash', 'mainnet', 'logs', 'bip300301_enforcer.log.2026-10-26.3'),
    );
  });

  test('takes an older eCash fork folder when it holds the newest log', () {
    writeLog(['ecash', 'mainnet', 'logs'], 'bip300301_enforcer.log.2026-10-25.1');
    writeLog(['ecash-betanet', 'mainnet', 'logs'], 'bip300301_enforcer.log.2026-10-26.1');

    expect(
      latestEnforcerLog(root.path, BitcoinNetwork.BITCOIN_NETWORK_ECASH),
      path.join(root.path, 'ecash-betanet', 'mainnet', 'logs', 'bip300301_enforcer.log.2026-10-26.1'),
    );
  });

  test('keeps the logs of another network out', () {
    writeLog(['bitcoin', 'signet_13182df0', 'logs'], 'bip300301_enforcer.log.2026-10-26.1');
    writeLog(['bitcoin', 'mainnet', 'logs'], 'bip300301_enforcer.log.2026-10-27.1');
    writeLog(['ecash', 'mainnet', 'logs'], 'bip300301_enforcer.log.2026-10-28.1');

    expect(
      latestEnforcerLog(root.path, BitcoinNetwork.BITCOIN_NETWORK_SIGNET),
      path.join(root.path, 'bitcoin', 'signet_13182df0', 'logs', 'bip300301_enforcer.log.2026-10-26.1'),
    );
    expect(
      latestEnforcerLog(root.path, BitcoinNetwork.BITCOIN_NETWORK_MAINNET),
      path.join(root.path, 'bitcoin', 'mainnet', 'logs', 'bip300301_enforcer.log.2026-10-27.1'),
    );
  });

  test('still reads the logs folder of an older enforcer', () {
    writeLog(['logs'], 'bip300301_enforcer.log.2026-10-20.2');

    expect(
      latestEnforcerLog(root.path, BitcoinNetwork.BITCOIN_NETWORK_REGTEST),
      path.join(root.path, 'logs', 'bip300301_enforcer.log.2026-10-20.2'),
    );
  });

  test('returns null when no log file matches', () {
    writeLog(['ecash', 'mainnet', 'logs'], 'notes.txt');

    expect(latestEnforcerLog(root.path, BitcoinNetwork.BITCOIN_NETWORK_ECASH), isNull);
    expect(latestEnforcerLog(path.join(root.path, 'absent'), BitcoinNetwork.BITCOIN_NETWORK_ECASH), isNull);
  });
}
