import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

// Padding plus chevron that SailDropdownButton draws around its selection.
const double _dropdownChrome = 45;

/// Picks the wallet that funds a transaction. It never changes the active one.
class WalletPicker extends StatelessWidget {
  final String? selectedWalletId;
  final ValueChanged<String> onChanged;

  /// Lists only wallets that can carry a raw output, which the enforcer cannot.
  final bool rawOutputs;

  const WalletPicker({
    super.key,
    required this.selectedWalletId,
    required this.onChanged,
    this.rawOutputs = false,
  });

  @override
  Widget build(BuildContext context) {
    final walletReader = GetIt.I<WalletReaderProvider>();

    return ListenableBuilder(
      listenable: walletReader,
      builder: (context, _) {
        final wallets = walletReader.fundingWallets(rawOutputs: rawOutputs);
        if (wallets.isEmpty) {
          return const SizedBox.shrink();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // The trigger sizes to its content, so cap the wallet row to the
            // slot minus the chrome drawn around it.
            final rowWidth = constraints.hasBoundedWidth
                ? max(0.0, constraints.maxWidth - _dropdownChrome)
                : double.infinity;

            return SizedBox(
              width: double.infinity,
              child: SailDropdownButton<String>(
                value: selectedWalletId,
                hint: 'Select a wallet',
                items: wallets
                    .map(
                      (wallet) => SailDropdownItem<String>(
                        value: wallet.id,
                        label: wallet.name,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: rowWidth),
                          child: SailRow(
                            spacing: SailStyleValues.padding08,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              WalletBlobAvatar(gradient: wallet.gradient, size: 20),
                              Flexible(child: SailText.primary13(wallet.name)),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (walletId) {
                  if (walletId != null) {
                    onChanged(walletId);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// A [WalletPicker] under a form label, for a send-style form row.
class FromWalletField extends StatelessWidget {
  final String? selectedWalletId;
  final ValueChanged<String> onChanged;
  final String label;

  const FromWalletField({
    super.key,
    required this.selectedWalletId,
    required this.onChanged,
    this.label = 'From Wallet',
  });

  @override
  Widget build(BuildContext context) {
    if (GetIt.I<WalletReaderProvider>().fundingWallets().isEmpty) {
      return const SizedBox.shrink();
    }

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13(label, bold: true),
        WalletPicker(selectedWalletId: selectedWalletId, onChanged: onChanged),
      ],
    );
  }
}
