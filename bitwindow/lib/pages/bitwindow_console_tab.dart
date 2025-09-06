import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/console/integrated_console_view.dart';

class BitwindowConsoleTab extends StatelessWidget {
  const BitwindowConsoleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Debug Console',
      subtitle: 'Execute commands and view responses',
      child: IntegratedConsoleView(),
    );
  }
}
