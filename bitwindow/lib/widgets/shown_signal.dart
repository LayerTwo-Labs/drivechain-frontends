import 'package:flutter/widgets.dart';

/// Calls [onShown] with the TickerMode of its place, so a hidden tab can stop
/// the polls of the widgets below it.
class ShownSignal extends StatefulWidget {
  final ValueChanged<bool> onShown;
  final Widget child;

  const ShownSignal({super.key, required this.onShown, required this.child});

  @override
  State<ShownSignal> createState() => _ShownSignalState();
}

class _ShownSignalState extends State<ShownSignal> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onShown(TickerMode.valuesOf(context).enabled);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
