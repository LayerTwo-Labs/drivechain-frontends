import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/console/integrated_console_view.dart';

@RoutePage()
class ConsolePage extends StatefulWidget {
  const ConsolePage({super.key});

  @override
  State<ConsolePage> createState() => _ConsolePageState();
}

class _ConsolePageState extends State<ConsolePage> {
  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: Column(
        children: [
          Expanded(
            child: IntegratedConsoleView(),
          ),
        ],
      ),
    );
  }
}
