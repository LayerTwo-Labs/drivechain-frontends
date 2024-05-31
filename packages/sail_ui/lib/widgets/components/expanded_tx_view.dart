import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ExpandedTXView extends StatelessWidget {
  final Map<String, dynamic> decodedTX;
  final double width;

  const ExpandedTXView({
    super.key,
    required this.decodedTX,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding08,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: decodedTX.keys.where((key) => key != 'walletconflicts').map((key) {
        return SingleValueContainer(
          label: key,
          value: decodedTX[key],
          width: width,
        );
      }).toList(),
    );
  }
}
