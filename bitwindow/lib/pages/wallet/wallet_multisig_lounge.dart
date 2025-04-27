import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class MultisigLoungeTab extends StatelessWidget {
  const MultisigLoungeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Multisig Lounge',
      subtitle: 'Create and manage multi-signature wallets',
      child: Center(
        child: SailText.primary15(
          'Multisig functionality coming soon...',
          color: context.sailTheme.colors.textTertiary,
        ),
      ),
    );
  }
}
