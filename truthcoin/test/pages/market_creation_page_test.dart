import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:sidechain_core/rpcs/bitcoind_connection.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/truthcoin_rpc.dart';
import 'package:sidechain_core/providers/balance_provider.dart';
import 'package:truthcoin/pages/market_creation_page.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/voting_provider.dart';

import '../fixtures/test_data.dart';

import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;

  setUpAll(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.slotListResponse = TestData.sampleSlotList;

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));

    final marketProvider = MarketProvider();
    GetIt.I.registerLazySingleton<MarketProvider>(() => marketProvider);
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
      expect(find.text('Outcomes'), findsOneWidget);
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
  });

  group('MarketCreationViewModel slots', () {
    test('the picker lists the slots the market type takes', () async {
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
                'options': ['Alice', 'Bob'],
              },
            },
            'header': 'Who wins?',
          },
        },
      ];

      final model = MarketCreationViewModel();
      model.init();
      await model.loadSlots();

      // A Yes/No market takes the binary slot only.
      expect(model.claimedSlots.map((s) => s.slotIdHex), ['002a0001']);
      expect(model.slotLabel(model.claimedSlots.first), contains('binary'));

      model.setMarketType(MarketType.categorical);
      expect(model.claimedSlots.map((s) => s.slotIdHex), ['002a0004']);
      expect(model.slotLabel(model.claimedSlots.first), contains('category'));

      model.setMarketType(MarketType.custom);
      expect(model.claimedSlots.length, 3);

      mockRpc.slotListResponse = TestData.sampleSlotList;
      model.dispose();
    });

    test('a typed slot of the wrong kind blocks the market', () async {
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
                'options': ['Alice', 'Bob'],
              },
            },
            'header': 'Who wins?',
          },
        },
      ];

      final model = MarketCreationViewModel();
      model.init();
      await model.loadSlots();
      model
        ..titleController.text = 'Will the price rise?'
        ..descriptionController.text = 'The voter reads the close.';

      // A category slot typed into the Yes/No tab.
      model.dimensionsController.text = '002a0004';
      expect(model.typedSlotError, contains('category'));
      expect(model.canCreate, false);

      // An id the node does not list.
      model.dimensionsController.text = 'ffffffff';
      expect(model.typedSlotError, contains('no claimed decision'));
      expect(model.canCreate, false);

      // The binary slot fits the Yes/No tab.
      model.dimensionsController.text = '002a0001';
      expect(model.typedSlotError, null);
      expect(model.canCreate, true);

      // The same category slot fits the many-outcome tab.
      model.setMarketType(MarketType.categorical);
      model.dimensionsController.text = '002a0004';
      expect(model.typedSlotError, null);

      mockRpc.slotListResponse = TestData.sampleSlotList;
      model.dispose();
    });

    test('a picked slot fills the dimension field', () async {
      final model = MarketCreationViewModel();
      model.init();
      await model.loadSlots();

      model.selectSlot('002a0001');
      expect(model.dimensionsController.text, '002a0001');
      expect(model.selectedSlotId, '002a0001');
      expect(model.effectiveDimensions, '[002a0001]');

      model.dimensionsController.text = '002a0009';
      model.onSlotTextChanged();
      expect(model.selectedSlotId, null);

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
        // A binary slot of the fixture, so the Yes/No tab takes it.
        ..titleController.text = 'Will the price rise?'
        ..descriptionController.text = 'The voter reads the close.'
        ..dimensionsController.text = '002a0001'
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
      model.dimensionsController.text = '002a0001';

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
      model.dimensionsController.text = '004008';
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

  group('MarketCreationViewModel.dimensionInputs', () {
    const twoExisting = '[{"type":"existing","id":"004008"},{"type":"existing","id":"004009"}]';

    test('a slot ID becomes an existing DimensionInput', () {
      final model = MarketCreationViewModel()..dimensionsController.text = '004008';

      expect(model.dimensionInputs, '[{"type":"existing","id":"004008"}]');
    });

    test('comma-separated slot IDs become one DimensionInput each', () {
      final model = MarketCreationViewModel()
        ..setMarketType(MarketType.custom)
        ..dimensionsController.text = '004008, 004009';

      expect(model.dimensionInputs, twoExisting);
    });

    test('bracket notation is flattened to existing references', () {
      final model = MarketCreationViewModel()
        ..setMarketType(MarketType.custom)
        ..dimensionsController.text = '[[004008,004009]]';

      expect(model.dimensionInputs, twoExisting);
    });

    test('a single DimensionInput object becomes a one-entry array', () {
      final model = MarketCreationViewModel()
        ..setMarketType(MarketType.custom)
        ..dimensionsController.text = '{"type":"existing","id":"004008"}';

      expect(model.dimensionInputs, '[{"type":"existing","id":"004008"}]');
    });

    test('DimensionInput JSON passes through', () {
      const dimensions = '[{"type":"new","period_index":3,"decision_type":"binary","header":"Rain?"}]';
      final model = MarketCreationViewModel()
        ..setMarketType(MarketType.custom)
        ..dimensionsController.text = dimensions;

      expect(model.dimensionInputs, dimensions);
    });
  });

  group('MarketCreationViewModel.effectiveDimensions', () {
    test('a categorical market takes one category decision', () async {
      mockRpc.slotListResponse = [
        {
          'decision_id_hex': '004008',
          'period_index': 42,
          'decision_index': 8,
          'state': 'Claimed',
          'decision': {
            'id': 'decision_008',
            'market_maker_pubkey_hash': 'abcd',
            'is_standard': true,
            'decision_type': {
              'Category': {
                'options': ['Thunder', 'BitNames'],
              },
            },
            'header': 'Which chain wins?',
          },
        },
      ];

      final model = MarketCreationViewModel();
      model.init();
      await model.loadSlots();
      model
        ..setMarketType(MarketType.categorical)
        ..titleController.text = 'Which chain wins?'
        ..descriptionController.text = 'The oracle reads the chain with the most coins.'
        ..dimensionsController.text = '004008';

      expect(model.canCreate, true);
      expect(model.effectiveDimensions, '[[004008]]');
      expect(model.dimensionInputs, '[{"type":"existing","id":"004008"}]');

      model.dimensionsController.text = '004008,004009';
      expect(model.canCreate, false);

      mockRpc.slotListResponse = TestData.sampleSlotList;
      model.dispose();
    });

    test('a new decision blocks the market, because its fee stays unknown', () {
      final model = MarketCreationViewModel()
        ..setMarketType(MarketType.custom)
        ..titleController.text = 'Will it rain?'
        ..descriptionController.text = 'The voter reads the weather report.'
        ..dimensionsController.text = '[{"type":"new","period_index":3,"decision_type":"binary","header":"Rain?"}]';

      expect(model.claimsNewDecision, true);
      expect(model.typedSlotError, contains('Claim the decision first'));
      expect(model.canCreate, false);

      model.dimensionsController.text = '[{"type":"existing","id":"004008"}]';
      expect(model.claimsNewDecision, false);
      expect(model.canCreate, true);

      model.dispose();
    });

    test('an empty decision list blocks a typed id', () async {
      GetIt.I.get<VotingProvider>().slots = [];

      final model = MarketCreationViewModel()
        ..titleController.text = 'Will the price rise?'
        ..descriptionController.text = 'The voter reads the close.'
        ..dimensionsController.text = '002a0001';

      expect(model.typedSlotError, contains('did not load'));
      expect(model.canCreate, false);

      model.dispose();
    });

    test('custom DimensionInput JSON previews its existing decisions', () {
      final model = MarketCreationViewModel()
        ..setMarketType(MarketType.custom)
        ..dimensionsController.text = '[{"type":"existing","id":"004008"},{"type":"existing","id":"004009"}]';

      expect(model.effectiveDimensions, '[004008,004009]');
    });

    test('a new decision has no ID to preview', () {
      final model = MarketCreationViewModel()
        ..setMarketType(MarketType.custom)
        ..dimensionsController.text = '[{"type":"new","period_index":3,"decision_type":"binary","header":"Rain?"}]';

      expect(model.effectiveDimensions, '');
    });
  });
}
