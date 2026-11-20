import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Dropdown widget for wallet selection using SailDropdownButton
class WalletDropdown extends StatelessWidget {
  final WalletMetadata? currentWallet;
  final List<WalletMetadata> availableWallets;
  final Function(String walletId) onWalletSelected;
  final VoidCallback onCreateWallet;
  final Function(WalletMetadata wallet)? onEditWallet;

  /// Wallets that hold something the user still has to act on.
  final Set<String> walletsNeedingAttention;

  /// Replaces the menu while no wallet exists, and reads "No wallet". Null
  /// keeps "Create new wallet".
  final ({VoidCallback onGenerate, VoidCallback onPasteSeed, VoidCallback onImportDescriptor})? noWalletActions;

  const WalletDropdown({
    super.key,
    required this.currentWallet,
    required this.availableWallets,
    required this.onWalletSelected,
    required this.onCreateWallet,
    this.onEditWallet,
    this.walletsNeedingAttention = const {},
    this.noWalletActions,
  });

  @override
  Widget build(BuildContext context) {
    final empty = availableWallets.isEmpty ? noWalletActions : null;
    if (SailStyleValues.phoneLayout(context)) {
      return _PhoneWalletButton(dropdown: this);
    }

    return SizedBox(
      width: 200,
      child: SailDropdownButton<String>(
        key: ValueKey(
          'wallet_dropdown_${currentWallet?.id}_${currentWallet?.gradient.backgroundSvg}',
        ),
        value: currentWallet?.id,
        hint: empty == null ? null : 'No wallet',
        neutralHint: empty != null,
        hideCurrentlySelectedFromList: true,
        items: availableWallets
            .map(
              (wallet) => SailDropdownItem<String>(
                key: ValueKey(
                  'wallet_item_${wallet.id}_${wallet.gradient.backgroundSvg}',
                ),
                value: wallet.id,
                child: _WalletRow(
                  wallet: wallet,
                  attention: walletsNeedingAttention.contains(wallet.id),
                  onEdit: onEditWallet != null && wallet.id != currentWallet?.id
                      ? () async => onEditWallet!(wallet)
                      : null,
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
          if (onEditWallet != null && currentWallet != null)
            SailMenuItem(
              onSelected: () async => onEditWallet!(currentWallet!),
              child: Row(
                children: [
                  WalletBlobAvatar(gradient: currentWallet!.gradient, size: 24),
                  const SizedBox(width: 12),
                  SailText.primary13('Edit ${currentWallet!.name}'),
                ],
              ),
            ),
          if (empty == null)
            _MenuAction(icon: Icons.add, label: 'Create new wallet', onSelected: onCreateWallet)
          else ...[
            _MenuAction(icon: Icons.add, label: 'Generate wallet', onSelected: empty.onGenerate),
            _MenuAction(icon: Icons.content_paste, label: 'Paste seed phrase', onSelected: empty.onPasteSeed),
            _MenuAction(icon: Icons.download, label: 'Import descriptor', onSelected: empty.onImportDescriptor),
          ],
        ],
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onSelected;

  const _MenuAction({required this.icon, required this.label, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SailMenuItem(
      onSelected: () async => onSelected(),
      child: _ActionLabel(icon: icon, label: label),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.colors.border, width: 2),
          ),
          child: Icon(icon, size: 14, color: theme.colors.text),
        ),
        const SizedBox(width: 12),
        SailText.primary13(label),
      ],
    );
  }
}

class _WalletRow extends StatelessWidget {
  final WalletMetadata wallet;
  final bool attention;
  final Future<void> Function()? onEdit;

  const _WalletRow({required this.wallet, required this.attention, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Row(
      key: ValueKey('wallet_row_${wallet.id}_${wallet.gradient.backgroundSvg}'),
      children: [
        WalletBlobAvatar(
          key: ValueKey('wallet_avatar_${wallet.id}_${wallet.gradient.backgroundSvg}'),
          gradient: wallet.gradient,
          size: 24,
        ),
        const SizedBox(width: 12),
        SailText.primary13(wallet.name),
        if (attention) ...[
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colors.error,
              shape: BoxShape.circle,
            ),
          ),
        ],
        if (onEdit != null) ...[
          // A menu row lays out unbounded while the menu measures
          // its width, and a flex child throws there.
          const SizedBox(width: 12),
          SailTappable(
            onTap: onEdit!,
            child: SailText.primary12(
              'Edit',
              decoration: TextDecoration.underline,
              color: theme.colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// The phone form of [WalletDropdown]: a small button that opens the wallet menu as a sheet.
class _PhoneWalletButton extends StatelessWidget {
  final WalletDropdown dropdown;

  const _PhoneWalletButton({required this.dropdown});

  Future<void> _open(BuildContext context) async {
    final d = dropdown;
    final empty = d.availableWallets.isEmpty ? d.noWalletActions : null;
    final others = d.availableWallets.where((w) => w.id != d.currentWallet?.id).toList();
    final theme = SailTheme.of(context);

    Widget row(BuildContext sheet, {required Widget child, required VoidCallback onTap}) => SailTappable(
      onTap: () async {
        Navigator.of(sheet).pop();
        onTap();
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );

    await showThemedDialog<void>(
      context: context,
      builder: (sheet) => Dialog(
        backgroundColor: SailColorScheme.transparent,
        child: SailCard(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (others.isNotEmpty)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.background,
                      borderRadius: theme.chrome.radius,
                      border: Border.all(color: theme.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final wallet in others)
                          row(
                            sheet,
                            onTap: () => d.onWalletSelected(wallet.id),
                            child: _WalletRow(
                              wallet: wallet,
                              attention: d.walletsNeedingAttention.contains(wallet.id),
                              onEdit: d.onEditWallet == null
                                  ? null
                                  : () async {
                                      Navigator.of(sheet).pop();
                                      d.onEditWallet!(wallet);
                                    },
                            ),
                          ),
                      ],
                    ),
                  ),
                if (d.onEditWallet != null && d.currentWallet != null)
                  row(
                    sheet,
                    onTap: () => d.onEditWallet!(d.currentWallet!),
                    child: Row(
                      children: [
                        WalletBlobAvatar(gradient: d.currentWallet!.gradient, size: 24),
                        const SizedBox(width: 12),
                        SailText.primary13('Edit ${d.currentWallet!.name}'),
                      ],
                    ),
                  ),
                if (empty == null)
                  row(
                    sheet,
                    onTap: d.onCreateWallet,
                    child: const _ActionLabel(icon: Icons.add, label: 'Create new wallet'),
                  )
                else ...[
                  row(
                    sheet,
                    onTap: empty.onGenerate,
                    child: const _ActionLabel(icon: Icons.add, label: 'Generate wallet'),
                  ),
                  row(
                    sheet,
                    onTap: empty.onPasteSeed,
                    child: const _ActionLabel(icon: Icons.content_paste, label: 'Paste seed phrase'),
                  ),
                  row(
                    sheet,
                    onTap: empty.onImportDescriptor,
                    child: const _ActionLabel(icon: Icons.download, label: 'Import descriptor'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final current = dropdown.currentWallet;
    final noWallet = dropdown.availableWallets.isEmpty && dropdown.noWalletActions != null;
    return SailTappable(
      onTap: () async => _open(context),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: theme.chrome.radius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: noWallet || current == null
                    ? SailText.primary12('No wallet', color: theme.colors.textSecondary)
                    : SailText.primary12(current.name),
              ),
              SailSVG.fromAsset(SailSVGAsset.chevronDown, color: theme.colors.text, width: 13),
            ],
          ),
        ),
      ),
    );
  }
}
