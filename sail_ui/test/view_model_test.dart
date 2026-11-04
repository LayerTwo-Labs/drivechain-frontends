import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/viewmodels/view_model.dart';

class CounterModel extends BaseViewModel {
  int count = 0;
  int disposeCalls = 0;

  void increment() {
    count++;
    notifyListeners();
  }

  @override
  void dispose() {
    disposeCalls++;
    super.dispose();
  }
}

class CountLabel extends ViewModelWidget<CounterModel> {
  const CountLabel({super.key, super.reactive});

  @override
  Widget build(BuildContext context, CounterModel viewModel) => Text('widget ${viewModel.count}');
}

Widget host(Widget child) => Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('BaseViewModel', () {
    test('keeps busy state per key and notifies on each change', () {
      final model = CounterModel();
      var notified = 0;
      model.addListener(() => notified++);

      model.setBusy(true);
      model.setBusyForObject('send', true);

      expect(model.isBusy, isTrue);
      expect(model.busy('send'), isTrue);
      expect(model.busy('other'), isFalse);
      expect(model.anyObjectsBusy, isTrue);
      expect(notified, 2);

      model.setBusy(false);
      model.setBusyForObject('send', false);
      expect(model.anyObjectsBusy, isFalse);
    });

    test('keeps error state per key, and clearErrors drops all of it', () {
      final model = CounterModel();

      model.setError('model failed');
      model.setErrorForObject('blockchain', 'rpc failed');

      expect(model.hasError, isTrue);
      expect(model.modelError, 'model failed');
      expect(model.hasErrorForKey('blockchain'), isTrue);
      expect(model.error('blockchain'), 'rpc failed');
      expect(model.hasErrorForKey('proposal'), isFalse);

      model.clearErrors();
      expect(model.hasError, isFalse);
      expect(model.hasErrorForKey('blockchain'), isFalse);
    });

    test('a call after dispose does not notify and does not throw', () {
      final model = CounterModel()..dispose();

      expect(model.disposed, isTrue);
      expect(() => model.setBusy(true), returnsNormally);
      expect(() => model.rebuildUi(), returnsNormally);
    });
  });

  group('ViewModelBuilder', () {
    testWidgets('reactive rebuilds the builder when the model notifies', (tester) async {
      late CounterModel model;
      await tester.pumpWidget(
        host(
          ViewModelBuilder<CounterModel>.reactive(
            viewModelBuilder: () => model = CounterModel(),
            builder: (context, viewModel, child) => Text('count ${viewModel.count}'),
          ),
        ),
      );
      expect(find.text('count 0'), findsOneWidget);

      model.increment();
      await tester.pump();
      expect(find.text('count 1'), findsOneWidget);
    });

    testWidgets('nonReactive builds again only when the parent builds again', (tester) async {
      late CounterModel model;
      await tester.pumpWidget(
        host(
          ViewModelBuilder<CounterModel>.nonReactive(
            viewModelBuilder: () => model = CounterModel(),
            builder: (context, viewModel, child) => Text('count ${viewModel.count}'),
          ),
        ),
      );

      model.increment();
      await tester.pump();
      expect(find.text('count 0'), findsOneWidget);
    });

    testWidgets('builds the model one time and calls onViewModelReady one time', (tester) async {
      var built = 0;
      var ready = 0;
      Widget tree(String label) => host(
        ViewModelBuilder<CounterModel>.reactive(
          viewModelBuilder: () {
            built++;
            return CounterModel();
          },
          onViewModelReady: (_) => ready++,
          builder: (context, viewModel, child) => Text(label),
        ),
      );

      await tester.pumpWidget(tree('a'));
      await tester.pumpWidget(tree('b'));

      expect(find.text('b'), findsOneWidget);
      expect(built, 1);
      expect(ready, 1);
    });

    testWidgets('passes staticChild to the builder', (tester) async {
      await tester.pumpWidget(
        host(
          ViewModelBuilder<CounterModel>.reactive(
            viewModelBuilder: CounterModel.new,
            staticChild: const Text('static'),
            builder: (context, viewModel, child) => child!,
          ),
        ),
      );
      expect(find.text('static'), findsOneWidget);
    });

    testWidgets('disposes the model on unmount, then calls onDispose with it', (tester) async {
      final model = CounterModel();
      CounterModel? disposedModel;
      var disposeCallsAtOnDispose = -1;
      await tester.pumpWidget(
        host(
          ViewModelBuilder<CounterModel>.reactive(
            viewModelBuilder: () => model,
            onDispose: (viewModel) {
              disposedModel = viewModel;
              disposeCallsAtOnDispose = viewModel.disposeCalls;
            },
            builder: (context, viewModel, child) => const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(host(const SizedBox()));

      expect(model.disposeCalls, 1);
      expect(disposedModel, same(model));
      expect(disposeCallsAtOnDispose, 1);
    });

    testWidgets('keeps the model alive when disposeViewModel is false', (tester) async {
      final model = CounterModel();
      await tester.pumpWidget(
        host(
          ViewModelBuilder<CounterModel>.reactive(
            viewModelBuilder: () => model,
            disposeViewModel: false,
            builder: (context, viewModel, child) => const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(host(const SizedBox()));

      expect(model.disposeCalls, 0);
      expect(model.disposed, isFalse);
    });

    testWidgets('fireOnViewModelReadyOnce skips a second builder on the same model', (tester) async {
      final shared = CounterModel();
      var ready = 0;
      Widget builder() => ViewModelBuilder<CounterModel>.reactive(
        viewModelBuilder: () => shared,
        disposeViewModel: false,
        fireOnViewModelReadyOnce: true,
        onViewModelReady: (_) => ready++,
        builder: (context, viewModel, child) => const SizedBox(),
      );

      await tester.pumpWidget(host(builder()));
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpWidget(host(builder()));

      expect(ready, 1);
    });
  });

  group('ViewModelWidget', () {
    testWidgets('reactive rebuilds when the model notifies', (tester) async {
      late CounterModel model;
      await tester.pumpWidget(
        host(
          ViewModelBuilder<CounterModel>.nonReactive(
            viewModelBuilder: () => model = CounterModel(),
            builder: (context, viewModel, child) => const CountLabel(),
          ),
        ),
      );

      model.increment();
      await tester.pump();
      expect(find.text('widget 1'), findsOneWidget);
    });

    testWidgets('reactive false does not rebuild when the model notifies', (tester) async {
      late CounterModel model;
      await tester.pumpWidget(
        host(
          ViewModelBuilder<CounterModel>.nonReactive(
            viewModelBuilder: () => model = CounterModel(),
            builder: (context, viewModel, child) => const CountLabel(reactive: false),
          ),
        ),
      );

      model.increment();
      await tester.pump();
      expect(find.text('widget 0'), findsOneWidget);
    });
  });

  group('getParentViewModel', () {
    testWidgets('finds the model of the nearest builder', (tester) async {
      late CounterModel model;
      late CounterModel found;
      await tester.pumpWidget(
        host(
          ViewModelBuilder<CounterModel>.reactive(
            viewModelBuilder: () => model = CounterModel(),
            builder: (context, viewModel, child) => Builder(
              builder: (inner) {
                found = getParentViewModel<CounterModel>(inner, listen: false);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(found, same(model));
    });

    testWidgets('throws when no builder is above', (tester) async {
      late Object error;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              try {
                getParentViewModel<CounterModel>(context);
              } catch (e) {
                error = e;
              }
              return const SizedBox();
            },
          ),
        ),
      );
      expect(error, isA<FlutterError>());
    });
  });
}
