import 'package:bitwindow/sidechains/truthcoin_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('truthcoin links listen only where the app links plugin runs', () {
    for (final os in ['macos', 'windows', 'linux']) {
      expect(truthcoinLinksServe(os), isTrue, reason: os);
    }
    for (final os in ['ios', 'android']) {
      expect(truthcoinLinksServe(os), isFalse, reason: os);
    }
  });
}
