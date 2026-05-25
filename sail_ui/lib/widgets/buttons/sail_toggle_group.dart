import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailToggleGroupItem<T> {
  final T value;
  final String label;

  const SailToggleGroupItem({required this.value, required this.label});
}

class SailToggleGroup<T> extends StatelessWidget {
  final List<SailToggleGroupItem<T>> items;

  /// Currently selected value(s).
  ///
  /// When [singleChoice] is true, only items whose value matches the first
  /// entry are highlighted. When false, every item present in [values] is on.
  final List<T> values;
  final ValueChanged<List<T>> onChanged;

  /// Radio (single) vs checkbox (multi) semantics.
  final bool singleChoice;

  /// Required when [singleChoice] is true; if true, the user can deselect
  /// the only-selected item leaving an empty selection.
  final bool allowEmptySingle;

  final double spacing;

  const SailToggleGroup({
    super.key,
    required this.items,
    required this.values,
    required this.onChanged,
    this.singleChoice = false,
    this.allowEmptySingle = false,
    this.spacing = SailStyleValues.padding08,
  });

  void _handle(T value, bool nowOn) {
    if (singleChoice) {
      if (nowOn) {
        onChanged([value]);
      } else if (allowEmptySingle) {
        onChanged(const []);
      }
      // else: ignore the toggle-off in single mode
    } else {
      final next = List<T>.from(values);
      if (nowOn) {
        if (!next.contains(value)) next.add(value);
      } else {
        next.remove(value);
      }
      onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i != 0) SizedBox(width: spacing),
          SailToggle(
            label: items[i].label,
            value: values.contains(items[i].value),
            onChanged: (v) => _handle(items[i].value, v),
          ),
        ],
      ],
    );
  }
}
