import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

MetadataConfig _metadata(DownloadConfig? app) => MetadataConfig(
  downloadConfig: const DownloadConfig(binary: 'daemon', files: {}),
  alternativeDownloadConfig: app,
  updateable: false,
  remoteTimestamp: null,
  downloadedTimestamp: null,
  binaryPath: null,
);

void main() {
  test('native wallet availability is specific to this platform and a ready release', () {
    final seed = jsonDecode(File('assets/chains_config.json').readAsStringSync()) as Map<String, dynamic>;
    final entry = (seed['binaries'] as Map<String, dynamic>)['liquid-signet'] as Map<String, dynamic>;
    final native = entry['native_wallet'] as Map<String, dynamic>;
    native['ready'] = true;
    native['binary'] = {OS.current.name: 'wallet/bin/wallet'};
    native['files'] = {'${OS.current.name}-${currentArch()}': 'bundle.zip'};
    expect(binaryFromJson('liquid-signet', entry).metadata.hasNativeWalletForThisOS, isTrue);
    native['ui'] = 'elements-qt';
    expect(binaryFromJson('liquid-signet', entry).metadata.hasNativeWalletForThisOS, isFalse);
    native['ui'] = 'blue-current';
    native['files'] = {'unsupported-platform': 'bundle.zip'};
    expect(binaryFromJson('liquid-signet', entry).metadata.hasNativeWalletForThisOS, isFalse);
    native['files'] = {'${OS.current.name}-${currentArch()}': 'bundle.zip'};
    native['ready'] = false;
    expect(binaryFromJson('liquid-signet', entry).metadata.hasNativeWalletForThisOS, isFalse);
  });
  test('a native wallet retains its window capability through status refresh', () {
    final metadata = MetadataConfig(
      downloadConfig: const DownloadConfig(binary: 'elementsd', files: {}),
      hasNativeWalletForThisOS: true,
      updateable: false,
      remoteTimestamp: null,
      downloadedTimestamp: null,
      binaryPath: null,
    );
    expect(metadata.hasNativeWalletForThisOS, isTrue);
    expect(
      metadata
          .copyWith(remoteTimestamp: null, downloadedTimestamp: null, binaryPath: null, updateable: false)
          .hasNativeWalletForThisOS,
      isTrue,
    );
    expect(metadata.hasAlternativeDownloadForThisOS, isFalse);
  });
  test('an app with a file for this OS can open a window', () {
    final metadata = _metadata(
      DownloadConfig(
        binary: 'app',
        files: {
          BitcoinNetwork.BITCOIN_NETWORK_SIGNET: {OS.current: 'app.zip'},
        },
      ),
    );
    expect(metadata.hasAlternativeDownloadForThisOS, isTrue);
  });

  test('an app with no file for this OS cannot open a window', () {
    final metadata = _metadata(
      DownloadConfig(
        binary: 'app',
        files: {
          BitcoinNetwork.BITCOIN_NETWORK_SIGNET: {OS.current: ''},
        },
      ),
    );
    expect(metadata.hasAlternativeDownloadForThisOS, isFalse);
  });

  test('a chain with no app cannot open a window', () {
    expect(_metadata(null).hasAlternativeDownloadForThisOS, isFalse);
  });
}
