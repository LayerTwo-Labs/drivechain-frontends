import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/console/integrated_console_view.dart';

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
        spacing: SailStyleValues.padding10,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Expanded(
            child: IntegratedConsoleView(),
          ),
          const SailSpacing(SailStyleValues.padding40),
        ],
      ),
    );
  }
}
