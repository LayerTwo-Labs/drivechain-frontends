import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class ConsoleTabPage extends StatefulWidget {
  const ConsoleTabPage({super.key});

  @override
  State<ConsoleTabPage> createState() => _ConsoleTabPageState();
}

class _ConsoleTabPageState extends State<ConsoleTabPage> {
  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: SailColumn(
        children: [
          const Expanded(
            child: IntegratedConsoleView(),
          ),
        ],
      ),
    );
  }
}
