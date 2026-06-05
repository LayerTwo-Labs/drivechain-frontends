import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Top-right toast stack listening to [NotificationProvider]. Place as a direct
/// child of a [Stack] in each app's root layout.
class NotificationToastOverlay extends StatelessWidget {
  const NotificationToastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!GetIt.I.isRegistered<NotificationProvider>()) {
      return const SizedBox.shrink();
    }
    final provider = GetIt.I.get<NotificationProvider>();

    return Positioned(
      top: 24,
      right: 24,
      child: AnimatedBuilder(
        animation: provider,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: provider.notifications,
          );
        },
      ),
    );
  }
}
