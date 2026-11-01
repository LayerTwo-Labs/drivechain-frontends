import 'package:bitwindow/pages/welcome/wallet_backup_page.dart';
import 'package:bitwindow/pages/welcome/wallet_creation.dart';
import 'package:bitwindow/widgets/import_descriptor_dialog.dart';
import 'package:bitwindow/widgets/setup_action_button.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Opens the create wallet flow. It closes when the wallet exists.
Future<void> openGenerateWallet(BuildContext context) async {
  await Navigator.of(context).push<SeedBackup>(
    sailRoute(builder: (_) => const WalletBackupPage(onCreate: createWalletFromSeed)),
  );
}

/// Shows [child], or the no wallet card while the backend reports no wallet.
class NoWalletGate extends StatelessWidget {
  final Widget child;

  const NoWalletGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final reader = GetIt.I.get<WalletReaderProvider>();
    return ListenableBuilder(
      listenable: reader,
      builder: (context, _) => reader.hasNoWallet ? const NoWalletCard() : child,
    );
  }
}

class NoWalletCard extends StatelessWidget {
  const NoWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SailStyleValues.padding32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SailCard(
            padding: false,
            child: Padding(
              padding: const EdgeInsets.all(SailStyleValues.padding32),
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SailText.primary20('You need a wallet to send and receive', bold: true, textAlign: TextAlign.center),
                  SailText.secondary13(
                    'Make a new wallet, or import your existing wallet with a descriptor or seed.',
                    textAlign: TextAlign.center,
                  ),
                  SetupActionButton(
                    label: 'Generate wallet',
                    primary: true,
                    onPressed: () async => openGenerateWallet(context),
                  ),
                  SetupActionButton(
                    label: 'Import descriptor',
                    onPressed: () async => showImportDescriptorDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
