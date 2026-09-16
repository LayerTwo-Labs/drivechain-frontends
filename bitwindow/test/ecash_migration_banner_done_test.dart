import 'package:bitwindow/widgets/ecash_upgrade_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

ECashMigrationStatus _complete({String toId = 'betanet', bool complete = true}) =>
    ECashMigrationStatus(jobId: 'job-1', fromId: 'alphanet', toId: toId, complete: complete);

void main() {
  group('migrationBannerIsDone', () {
    test('the target network is open, so the offer ends', () {
      expect(migrationBannerIsDone(_complete(), BitcoinNetwork.BITCOIN_NETWORK_ECASH, 'betanet'), isTrue);
    });

    test('the user still runs the source, so the offer stands', () {
      expect(migrationBannerIsDone(_complete(), BitcoinNetwork.BITCOIN_NETWORK_ECASH, 'alphanet'), isFalse);
    });

    test('an unfinished migration keeps its banner', () {
      expect(
        migrationBannerIsDone(_complete(complete: false), BitcoinNetwork.BITCOIN_NETWORK_ECASH, 'betanet'),
        isFalse,
      );
    });

    test('an unknown active network keeps the banner', () {
      expect(migrationBannerIsDone(_complete(), BitcoinNetwork.BITCOIN_NETWORK_ECASH, ''), isFalse);
    });

    test('another network is open, so a betanet pick alone does not end the offer', () {
      expect(migrationBannerIsDone(_complete(), BitcoinNetwork.BITCOIN_NETWORK_REGTEST, 'betanet'), isFalse);
    });
  });
}
