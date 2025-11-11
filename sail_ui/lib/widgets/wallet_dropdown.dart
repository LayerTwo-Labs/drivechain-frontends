import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Dropdown widget for wallet selection using SailDropdownButton
class WalletDropdown extends StatelessWidget {
  final WalletMetadata? currentWallet;
  final List<WalletMetadata> availableWallets;
  final Function(String walletId) onWalletSelected;
  final VoidCallback onCreateWallet;
  final Function(String walletId, String newBackgroundSvg)? onBackgroundChanged;

  const WalletDropdown({
    super.key,
    required this.currentWallet,
    required this.availableWallets,
    required this.onWalletSelected,
    required this.onCreateWallet,
    this.onBackgroundChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SizedBox(
      width: 200,
      child: SailDropdownButton<String>(
        key: ValueKey('wallet_dropdown_${currentWallet?.id}_${currentWallet?.gradient.backgroundSvg}'),
        value: currentWallet?.id,
        hideCurrentlySelectedFromList: true,
        items: availableWallets
            .map(
              (wallet) => SailDropdownItem<String>(
                key: ValueKey('wallet_item_${wallet.id}_${wallet.gradient.backgroundSvg}'),
                value: wallet.id,
                child: Row(
                  key: ValueKey('wallet_row_${wallet.id}_${wallet.gradient.backgroundSvg}'),
                  children: [
                    WalletBlobAvatar(
                      key: ValueKey('wallet_avatar_${wallet.id}_${wallet.gradient.backgroundSvg}'),
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
          if (walletId != null && walletId != currentWallet?.id) {
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
      ),
    );
  }
}
