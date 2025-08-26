import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

enum Category { sidechain, mainchain }

class ActionTile extends StatelessWidget {
  final String title;
  final Category category;
  final SailSVGAsset? icon;
  final Future<void> Function() onTap;

  const ActionTile({super.key, required this.title, required this.category, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SailButton(label: title, variant: ButtonVariant.outline, onPressed: onTap, icon: icon);
  }
}
