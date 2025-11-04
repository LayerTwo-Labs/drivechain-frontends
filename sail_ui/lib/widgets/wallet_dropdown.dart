import 'package:flutter/material.dart';
import 'package:sail_ui/models/wallet_metadata.dart';
import 'package:sail_ui/sail_ui.dart';

/// Dropdown widget for wallet selection using SailDropdownButton
class WalletDropdown extends StatelessWidget {
  final WalletMetadata? currentWallet;
  final List<WalletMetadata> availableWallets;
  final Function(String walletId) onWalletSelected;
  final VoidCallback onCreateWallet;

  const WalletDropdown({
    super.key,
    required this.currentWallet,
    required this.availableWallets,
    required this.onWalletSelected,
    required this.onCreateWallet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailDropdownButton<String>(
      value: currentWallet?.id,
      items: availableWallets
          .map(
            (wallet) => SailDropdownItem<String>(
              value: wallet.id,
              child: Row(
                children: [
                  WalletBlobAvatar(
                    gradient: wallet.gradient,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  SailText.primary13(wallet.name),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (walletId) async {
        if (walletId != null) {
          onWalletSelected(walletId);
        }
      },
      menuChildren: [
        SailMenuItem(
          onSelected: () async {
            onCreateWallet();
          },
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 14,
                  color: theme.colors.text,
                ),
              ),
              const SizedBox(width: 12),
              SailText.primary13('Create new wallet'),
            ],
          ),
        ),
      ],
    );
  }
}
