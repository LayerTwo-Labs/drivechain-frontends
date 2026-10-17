import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:truthcoin/pages/market_creation_page.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/price_history_provider.dart';
import 'package:truthcoin/providers/voting_provider.dart';

import '../fixtures/test_data.dart';

import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

const _daaHeader = 'Will eCash use a different DAA than Bitcoin by Jan 1, 2027?';
const _blockTimeHeader = 'Will eCash avg block time be under 20 min by Jan 1, 2027?';

final _periods = [
  {
    'period_index': 21,
    'cheapest_available_slot_sats': 9,
    'cheapest_available_tier': 0,
    'slots_available_by_tier': [30, 30, 30, 30, 30],
  },
  {
    'period_index': 23,
    'cheapest_available_slot_sats': 18,
    'cheapest_available_tier': 0,
    'slots_available_by_tier': [20, 20, 20, 20, 20],
  },
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.slotListResponse = TestData.sampleSlotList;
    mockRpc.openPeriodsResponse = _periods;

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    final marketProvider = MarketProvider();
    GetIt.I.registerLazySingleton<MarketProvider>(() => marketProvider);
    GetIt.I.registerLazySingleton<PriceHistoryProvider>(() => PriceHistoryProvider());
    GetIt.I.registerLazySingleton<VotingProvider>(() => VotingProvider());

    final balanceProvider = BalanceProvider(connections: [mockRpc]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    await balanceProvider.fetch();
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  group('MarketCreationPage', () {
    testWidgets('renders market creation page', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      expect(find.byType(MarketCreationPage), findsOneWidget);
    });

    testWidgets('shows page title', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      expect(find.textContaining('Create'), findsWidgets);
    });

    testWidgets('shows every form section', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      expect(find.text('Question'), findsOneWidget);
      expect(find.text('Decisions'), findsOneWidget);
      expect(find.text('Liquidity and fee'), findsOneWidget);
    });

    testWidgets('shows the preview and the cost', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('What happens next'), findsOneWidget);
    });

    testWidgets('shows the create button', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      expect(find.text('Create market'), findsWidgets);
    });
    testWidgets('Add New Decision adds one more decision card', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      expect(find.text('New decision #1'), findsOneWidget);
      expect(find.text('New decision #2'), findsNothing);
      final periodLabels = find.text('Period 21 · 9 sats · 30 slots').evaluate().length;
      expect(periodLabels, greaterThan(0));

      final addButton = find.byWidgetPredicate((w) => w is SailButton && w.label == 'Add New Decision');
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('New decision #2'), findsOneWidget);
      expect(find.text('Period 21 · 9 sats · 30 slots'), findsNWidgets(periodLabels * 2));
      expect(find.text('Header'), findsNWidgets(2));
      expect(find.text('Option 0 label'), findsNWidgets(2));
      expect(find.text('Option 1 label'), findsNWidgets(2));
    });

    testWidgets('the Type tabs swap the rows below the header', (WidgetTester tester) async {
      await tester.pumpSailPage(const MarketCreationPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Scaled'));
      await tester.pumpAndSettle();
      expect(find.text('Min'), findsOneWidget);
      expect(find.text('Option 0 label'), findsNothing);

      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      expect(find.text('Option labels'), findsOneWidget);
      expect(find.text('Min'), findsNothing);
    });
  });

  group('MarketCreationViewModel decisions', () {
    Future<MarketCreationViewModel> readyModel() async {
      final model = MarketCreationViewModel();
      model.init();
      await model.loadSlots();
      await model.loadPeriods();
      model
        ..titleController.text = 'eCash DAA and Block Time by January 1, 2027'
        ..descriptionController.text = 'The voter reads the eCash chain.';
      return model;
    }

    test('the first card takes the first open period', () async {
      final model = await readyModel();

      expect(model.periods.map((p) => p.periodIndex), [21, 23]);
      expect(model.newDecisions.single.periodIndex, 21);

      model.dispose();
    });

    test('one decision gives the DimensionInput of the CLI example', () async {
      final model = await readyModel();
      model.newDecisions.first
        ..header.text = _daaHeader
        ..option0Label.text = 'No'
        ..option1Label.text = 'Yes';

      expect(
        model.dimensionInputs,
        '[{"type":"new","period_index":21,"decision_type":"binary","header":"$_daaHeader",'
        '"option_0_label":"No","option_1_label":"Yes"}]',
      );
      expect(model.canCreate, true);

      model.dispose();
    });

    test('two decisions give the dimensions-json of the CLI example', () async {
      final model = await readyModel();
      model.newDecisions.first
        ..header.text = _daaHeader
        ..option0Label.text = 'No'
        ..option1Label.text = 'Yes';
      model.addNewDecision();
      model.newDecisions.last
        ..header.text = _blockTimeHeader
        ..option0Label.text = 'No'
        ..option1Label.text = 'Yes';

      expect(
        model.dimensionInputs,
        '[{"type":"new","period_index":21,"decision_type":"binary","header":"$_daaHeader",'
        '"option_0_label":"No","option_1_label":"Yes"},'
        '{"type":"new","period_index":21,"decision_type":"binary","header":"$_blockTimeHeader",'
        '"option_0_label":"No","option_1_label":"Yes"}]',
      );
      expect(model.outcomeCount, 4);
      expect(model.canCreate, true);

      model.dispose();
    });

    test('an existing decision goes first, a blank card adds nothing', () async {
      final model = await readyModel();
      model.addExistingDecision('002a0001');
      model.addNewDecision();

      expect(model.dimensionInputs, '[{"type":"existing","id":"002a0001"}]');
      expect(model.listingFeeSats, 0);
      expect(model.canCreate, true);

      model.dispose();
    });

    test('the cost holds the listing fee of each picked period', () async {
      final model = await readyModel();
      model.newDecisions.first.header.text = _daaHeader;
      model.addNewDecision();
      model.setDecisionPeriod(model.newDecisions.last, 23);
      model.newDecisions.last.header.text = _blockTimeHeader;

      expect(model.listingFeeSats, 27);
      expect(model.totalCostSats, 100000 + 27 + 1000);

      model.dispose();
    });

    test('a card with an error or no decision at all blocks the market', () async {
      final model = await readyModel();
      expect(model.canCreate, false);

      model.newDecisions.first.option1Label.text = 'Yes';
      expect(model.newDecisions.first.error, 'Write a header.');
      expect(model.canCreate, false);

      model.newDecisions.first.header.text = _daaHeader;
      expect(model.canCreate, true);

      model.dispose();
    });

    test('Create market sends the dimensions and the initial liquidity', () async {
      final model = await readyModel();
      model.newDecisions.first.header.text = _daaHeader;
      model.liquidityController.text = '212400000';

      final txid = await GetIt.I.get<MarketProvider>().createMarket(
        title: model.titleController.text,
        description: model.descriptionController.text,
        dimensions: model.dimensionInputs,
        feeSats: 1000,
        initialLiquidity: int.parse(model.liquidityController.text),
      );

      expect(txid, 'test_create_txid');
      expect(
        mockRpc.lastMarketCreateDimensions,
        '[{"type":"new","period_index":21,"decision_type":"binary","header":"$_daaHeader"}]',
      );
      expect(mockRpc.lastMarketCreateInitialLiquidity, 212400000);

      model.dispose();
    });

    test('the picker lists every claimed decision', () async {
      mockRpc.slotListResponse = [
        ...TestData.sampleSlotList,
        {
          'decision_id_hex': '002a0004',
          'period_index': 42,
          'decision_index': 4,
          'state': 'Claimed',
          'decision': {
            'id': 'decision_004',
            'market_maker_pubkey_hash': 'abcd',
            'is_standard': true,
            'decision_type': {
              'Category': {
                'options': ['Alice', 'Bob', 'Carol'],
              },
            },
            'header': 'Who wins?',
          },
        },
      ];

      final model = await readyModel();
      expect(model.claimedSlots.map((s) => s.slotIdHex), containsAll(['002a0001', '002a0004']));

      model.addExistingDecision('002a0004');
      expect(model.outcomeCount, 3);

      model.addExistingDecision('002a0001');
      model.addExistingDecision('002a0001');
      expect(model.dimensionInputs, '[{"type":"existing","id":"002a0004"},{"type":"existing","id":"002a0001"}]');
      expect(model.outcomeCount, 6);
      expect(model.addableSlots.map((s) => s.slotIdHex), isNot(contains('002a0001')));

      model.removeExistingDecision('002a0004');
      expect(model.dimensionInputs, '[{"type":"existing","id":"002a0001"}]');

      mockRpc.slotListResponse = TestData.sampleSlotList;
      model.dispose();
    });
  });

  group('MarketCreationViewModel cost', () {
    test('the total uses the liquidity that the market takes', () {
      final model = MarketCreationViewModel()..liquidityController.text = '250000';

      expect(model.subsidySats, 250000);
      expect(model.totalCostSats, 251000);

      model.dispose();
    });

    test('beta mode asks for a calculation before it creates a market', () async {
      final model = MarketCreationViewModel();
      model.init();
      await model.loadSlots();
      model
        ..titleController.text = 'Will the price rise?'
        ..descriptionController.text = 'The voter reads the close.'
        ..addExistingDecision('002a0001')
        ..setLiquidityMethod(LiquidityMethod.beta);

      expect(model.subsidySats, null);
      expect(model.totalCostSats, null);
      expect(model.canCreate, false);

      await model.calculateLiquidityPreview();

      expect(model.subsidySats, isNotNull);
      expect(model.canCreate, true);

      model.dispose();
    });

    test('a late cost calculation never wins', () async {
      final model = MarketCreationViewModel();
      model.init();
      await model.loadSlots();
      model.addExistingDecision('002a0001');

      final pending = model.calculateLiquidityPreview();
      // The author edits beta while the node answers the old input.
      model.betaController.text = '9.0';
      model.onLiquidityInputChanged();
      await pending;

      expect(model.liquidityPreview, null);

      model.dispose();
    });

    test('an edit of a liquidity input drops the last calculation', () async {
      final model = MarketCreationViewModel();
      model.init();
      model.addExistingDecision('004008');
      await model.calculateLiquidityPreview();
      expect(model.liquidityPreview, isNotNull);

      model.liquidityController.text = '300000';
      model.onLiquidityInputChanged();

      expect(model.liquidityPreview, null);
      expect(model.subsidySats, 300000);
      expect(model.totalCostSats, 301000);

      model.dispose();
    });
  });
}
