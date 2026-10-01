import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

/// The Markets tab holds its own stack, so a market page opens inside the
/// home shell and keeps the top navigation.
@RoutePage()
class MarketsTabPage extends StatelessWidget {
  const MarketsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
