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
