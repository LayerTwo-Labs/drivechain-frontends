import 'package:flutter/material.dart';

/// A positioned bar at the bottom of a Stack for action buttons.
/// Use this inside a Stack to place buttons at the bottom of a page.
class BottomActionBar extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final double maxWidth;

  const BottomActionBar({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Center(
          child: SizedBox(
            width: maxWidth,
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
