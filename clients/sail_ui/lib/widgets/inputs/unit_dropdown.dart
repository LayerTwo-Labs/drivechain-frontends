import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

enum Unit {
  BTC,
  mBTC,
  uBTC,
  sats,
}

class UnitDropdown extends StatelessWidget {
  final Unit value;
  final Function(Unit) onChanged;
  final bool enabled;

  const UnitDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SailDropdownButton(
      items: [
        SailDropdownItem(
          value: Unit.BTC,
          child: SailText.primary12('BTC'),
        ),
        SailDropdownItem(
          value: Unit.sats,
          child: SailText.primary12('SAT'),
        ),
      ],
      onChanged: onChanged,
      value: value,
      enabled: enabled,
    );
  }
}
