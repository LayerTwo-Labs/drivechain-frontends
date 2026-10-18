import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:truthcoin/widgets/homepage_widget_catalog.dart';

import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;

  setUp(() async {
    mockRpc = await setupMarketVotingTests();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('a position load failure shows the error', (tester) async {
    mockRpc.shouldThrowOnMarketPositions = true;
    final widget = TruthcoinWidgetCatalog.getCatalogMap()['positions_summary']!;

    await tester.pumpSailPage(widget.builder({}));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load positions'), findsOneWidget);
  });

  testWidgets('a wallet address failure shows the error', (tester) async {
    mockRpc.shouldThrowOnWalletAddresses = true;
    final widget = TruthcoinWidgetCatalog.getCatalogMap()['positions_summary']!;

    await tester.pumpSailPage(widget.builder({}));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load wallet addresses'), findsOneWidget);
  });
}
