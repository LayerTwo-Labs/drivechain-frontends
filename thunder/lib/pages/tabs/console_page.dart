import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:thunder/widgets/containers/dropdownactions/console.dart';

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
          const Expanded(child: ConsoleWindow()),
          const SailSpacing(SailStyleValues.padding40),
        ],
      ),
    );
  }
}
