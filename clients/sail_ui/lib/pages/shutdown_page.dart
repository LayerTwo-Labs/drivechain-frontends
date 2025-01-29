import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class ShuttingDownPage extends StatelessWidget {
  const ShuttingDownPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return QtPage(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colors.primary,
              strokeWidth: 4,
            ),
            const SizedBox(height: 32),
            SailText.primary24(
              'Shutting down safely...',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}
