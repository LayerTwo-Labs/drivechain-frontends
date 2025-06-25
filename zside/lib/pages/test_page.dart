import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SailTestPage extends StatelessWidget {
  final Widget child;
  const SailTestPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(child: child);
  }
}
