import 'package:bitwindow/widgets/datadir_network_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// Holds the four values the watch key reads. No backend, no network.
class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  _FakeConf({this.dataDir = '/home/u/.bitcoin', String? blocksDir}) {
    if (blocksDir != null) {
      currentConfig = BitcoinConfig()..setSetting('blocksdir', blocksDir, section: 'main');
    }
  }

  final String dataDir;

  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  String ecashNetworkId = 'betanet';

  @override
  BitcoinConfig? currentConfig;

  @override
  String? get detectedDataDir => dataDir;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeNodeMode extends ChangeNotifier implements NodeModeProvider {
  _FakeNodeMode(this.mode);

  @override
  wmpb.NodeMode mode;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  // Core reads the blocks from blocksdir, so the editor can put another chain
  // under the app while the datadir stays.
  test('a blocksdir change makes a new watch key', () {
    final before = datadirWatchKey(_FakeConf(blocksDir: '/mnt/alpha/blocks'));
    final after = datadirWatchKey(_FakeConf(blocksDir: '/mnt/beta/blocks'));

    expect(before, isNot(after));
  });

  test('a blocksdir taken away makes a new watch key', () {
    expect(datadirWatchKey(_FakeConf(blocksDir: '/mnt/beta/blocks')), isNot(datadirWatchKey(_FakeConf())));
  });

  test('the same config makes the same watch key', () {
    expect(datadirWatchKey(_FakeConf(blocksDir: '/mnt/beta')), datadirWatchKey(_FakeConf(blocksDir: '/mnt/beta')));
  });

  test('a datadir change makes a new watch key', () {
    expect(datadirWatchKey(_FakeConf(dataDir: '/a')), isNot(datadirWatchKey(_FakeConf(dataDir: '/b'))));
  });

  // Light mode reads no blocks, and a move to full mode makes them count again.
  // A key that misses the mode would keep the warning quiet after that move.
  test('a node mode change makes a new watch key', () {
    final conf = _FakeConf();
    final light = _FakeNodeMode(wmpb.NodeMode.NODE_MODE_LIGHT);
    final full = _FakeNodeMode(wmpb.NodeMode.NODE_MODE_FULL);

    expect(datadirWatchKey(conf, light), isNot(datadirWatchKey(conf, full)));
    expect(datadirWatchKey(conf, light), datadirWatchKey(conf, _FakeNodeMode(wmpb.NodeMode.NODE_MODE_LIGHT)));
  });
}
