import 'package:flutter/material.dart';

class SailAppBarBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SailAppBarBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onPressed,
      ),
    );
  }
}
