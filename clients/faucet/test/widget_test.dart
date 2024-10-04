import 'package:faucet/app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() async {
  testWidgets('can build page', (WidgetTester tester) async {
    // Access the TransactionsProvider instance using GetIt

    // Build our app and trigger a frame.
    await tester.pumpSailPage(
      const FaucetPage(
        title: 'faucet',
      ),
    );
  });
}
