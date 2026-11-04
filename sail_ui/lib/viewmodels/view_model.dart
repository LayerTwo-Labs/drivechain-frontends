import 'package:flutter/widgets.dart';

/// A [ChangeNotifier] with busy and error state per key, that stops notifying after dispose.
class BaseViewModel extends ChangeNotifier {
  bool disposed = false;
  bool _onModelReadyCalled = false;
  final Map<int, bool> _busyStates = {};
  final Map<int, dynamic> _errorStates = {};

  bool get onModelReadyCalled => _onModelReadyCalled;

  void setOnModelReadyCalled(bool value) {
    _onModelReadyCalled = value;
  }

  bool busy(Object? object) => _busyStates[object.hashCode] ?? false;

  bool get isBusy => busy(this);

  bool get anyObjectsBusy => _busyStates.values.any((busy) => busy);

  void setBusyForObject(Object? object, bool value) {
    _busyStates[object.hashCode] = value;
    notifyListeners();
  }

  void setBusy(bool value) => setBusyForObject(this, value);

  dynamic error(Object object) => _errorStates[object.hashCode];

  bool get hasError => error(this) != null;

  dynamic get modelError => error(this);

  bool hasErrorForKey(Object key) => error(key) != null;

  void clearErrors() => _errorStates.clear();

  void setErrorForObject(Object object, dynamic value) {
    _errorStates[object.hashCode] = value;
    notifyListeners();
  }

  void setError(dynamic error) => setErrorForObject(this, error);

  void rebuildUi() => notifyListeners();

  @override
  void notifyListeners() {
    if (!disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

/// Builds a view model once, puts it in the tree for [ViewModelWidget] and
/// [getParentViewModel], and disposes it with the widget.
class ViewModelBuilder<T extends ChangeNotifier> extends StatefulWidget {
  final T Function() viewModelBuilder;
  final Widget Function(BuildContext context, T viewModel, Widget? child) builder;
  final Widget? staticChild;
  final void Function(T viewModel)? onViewModelReady;
  final void Function(T viewModel)? onDispose;
  final bool disposeViewModel;
  final bool fireOnViewModelReadyOnce;
  final bool _reactive;

  /// Rebuilds [builder] each time the view model notifies.
  const ViewModelBuilder.reactive({
    required this.viewModelBuilder,
    required this.builder,
    this.staticChild,
    this.onViewModelReady,
    this.onDispose,
    this.disposeViewModel = true,
    this.fireOnViewModelReadyOnce = false,
    super.key,
  }) : _reactive = true;

  /// Builds [builder] only when the parent rebuilds.
  const ViewModelBuilder.nonReactive({
    required this.viewModelBuilder,
    required this.builder,
    this.onViewModelReady,
    this.onDispose,
    this.disposeViewModel = true,
    this.fireOnViewModelReadyOnce = false,
    super.key,
  }) : _reactive = false,
       staticChild = null;

  @override
  State<ViewModelBuilder<T>> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends ChangeNotifier> extends State<ViewModelBuilder<T>> {
  late final T _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModelBuilder();
    final onReady = widget.onViewModelReady;
    if (onReady == null) {
      return;
    }
    if (!widget.fireOnViewModelReadyOnce) {
      onReady(_viewModel);
      return;
    }
    final model = _viewModel as BaseViewModel;
    if (!model.onModelReadyCalled) {
      onReady(_viewModel);
      model.setOnModelReadyCalled(true);
    }
  }

  @override
  void dispose() {
    if (widget.disposeViewModel) {
      _viewModel.dispose();
    }
    widget.onDispose?.call(_viewModel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ViewModelScope<T>(
      model: _viewModel,
      child: widget._reactive
          ? Builder(
              builder: (context) => widget.builder(context, _lookUp<T>(context, listen: true), widget.staticChild),
            )
          : widget.builder(context, _viewModel, widget.staticChild),
    );
  }
}

class _ViewModelScope<T> extends InheritedNotifier<ChangeNotifier> {
  final T model;

  const _ViewModelScope({required this.model, required super.child}) : super(notifier: model as ChangeNotifier);
}

T _lookUp<T>(BuildContext context, {required bool listen}) {
  final scope = listen
      ? context.dependOnInheritedWidgetOfExactType<_ViewModelScope<T>>()
      : context.getInheritedWidgetOfExactType<_ViewModelScope<T>>();
  if (scope == null) {
    throw FlutterError('No ViewModelBuilder<$T> above ${context.widget.runtimeType}.');
  }
  return scope.model;
}

/// The view model of the nearest [ViewModelBuilder] of type [T].
T getParentViewModel<T>(BuildContext context, {bool listen = true}) => _lookUp<T>(context, listen: listen);

/// A widget that builds from the view model of the nearest [ViewModelBuilder] of type [T].
abstract class ViewModelWidget<T> extends Widget {
  final bool reactive;

  const ViewModelWidget({super.key, this.reactive = true});

  @protected
  Widget build(BuildContext context, T viewModel);

  @override
  ComponentElement createElement() => _ViewModelElement<T>(this);
}

class _ViewModelElement<T> extends ComponentElement {
  _ViewModelElement(ViewModelWidget<T> super.widget);

  @override
  ViewModelWidget<T> get widget => super.widget as ViewModelWidget<T>;

  @override
  Widget build() => widget.build(this, _lookUp<T>(this, listen: widget.reactive));

  @override
  void update(ViewModelWidget<T> newWidget) {
    super.update(newWidget);
    rebuild(force: true);
  }
}
