import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/pages/sidechains/bmm_tab.dart';
import 'package:sail_ui/sail_ui.dart';

/// BmmPage drives blind merged mining. It bids on every new mainchain tip and
/// connects the blocks miners take.
@RoutePage()
class BmmPage extends StatelessWidget {
  const BmmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const QtPage(child: BMMTab());
  }
}
