import 'package:bitwindow/widgets/datadir_network_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

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

NotificationItem _notice(
  String id, {
  bool read = false,
  String detected = 'betanet',
  String selected = 'alphanet',
}) => NotificationItem(
  id: id,
  title: 't',
  content: 'c',
  dialogType: DialogType.error,
  timestamp: DateTime.utc(2026, 9, 25),
  style: NotificationStyle.modalThenBanner,
  data: {'detected': detected, 'selected': selected},
  read: read,
);

void main() {
  final now = DateTime.utc(2026, 9, 25, 6);

  test('an empty history takes a fresh id', () {
    expect(datadirNoticeId(const [], 'betanet', 'alphanet', now), 'datadir-network-${now.microsecondsSinceEpoch}');
  });

  // The watcher polls every half minute, and a second entry per poll would
  // fill the bell list.
  test('an open notice keeps its id', () {
    final open = _notice('datadir-network-1');

    expect(datadirNoticeId([open], 'betanet', 'alphanet', now), open.id);
  });

  // A resolved mismatch leaves no entry, so the same pair takes a new id and
  // warns again. A warning that never returns leaves the balance wrong with no
  // sign.
  test('a pair with no entry takes a new id', () {
    final other = _notice('datadir-network-1', detected: 'bitcoin', selected: 'betanet');

    final id = datadirNoticeId([other], 'betanet', 'alphanet', now);

    expect(id, 'datadir-network-${now.microsecondsSinceEpoch}');
  });

  // Two free-form ids joined by a mark can read as another pair, so the lookup
  // reads the data rather than the id text.
  test('a pair that spells another one keeps its own notice', () {
    final first = _notice('datadir-network-1', detected: 'foo-bar', selected: 'baz');
    final second = _notice('datadir-network-2', detected: 'foo', selected: 'bar-baz');

    expect(datadirNoticeId([first, second], 'foo-bar', 'baz', now), 'datadir-network-1');
    expect(datadirNoticeId([first, second], 'foo', 'bar-baz', now), 'datadir-network-2');
  });

  // Core reads the blocks from blocksdir, so the editor can put another
  // chain under the app while the datadir stays.
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

  test('another pair takes its own id', () {
    final open = _notice('datadir-network-1');

    expect(datadirNoticeId([open], 'bitcoin', 'betanet', now), isNot(open.id));
  });

  // The ✕ dismisses the banner while the mismatch stands, and the entry stays,
  // so the modal never opens a second time.
  test('a dismissed notice of the same pair keeps its id', () {
    final dismissed = _notice('datadir-network-7', read: true);

    expect(datadirNoticeId([dismissed], 'betanet', 'alphanet', now), 'datadir-network-7');
  });
}
