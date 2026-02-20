import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Dropdown selector for parent chain type (BTC, BCH, LTC, Signet, Regtest)
class ParentChainSelector extends StatelessWidget {
  final ParentChainType value;
  final ValueChanged<ParentChainType> onChanged;

  const ParentChainSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SailDropdownButton<ParentChainType>(
      value: value,
      items: ParentChainType.values.map((chain) {
        return SailDropdownItem<ParentChainType>(
          value: chain,
          label: chain.value,
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}
