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

/// Opens the seed entry page. It closes when the wallet exists.
Future<void> openPasteSeed(BuildContext context) async {
  await Navigator.of(context).push<SeedBackup>(
    sailRoute(
      builder: (_) => const WalletBackupPage(mode: SeedEntryMode.importExisting, onCreate: createWalletFromSeed),
    ),
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
    if (SailStyleValues.phoneLayout(context)) {
      return const _PhoneNoWalletCard();
    }
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
                    'Make a new wallet, or restore one from its seed phrase or a descriptor.',
                    textAlign: TextAlign.center,
                  ),
                  SetupActionButton(
                    label: 'Generate wallet',
                    primary: true,
                    onPressed: () async => openGenerateWallet(context),
                  ),
                  SetupActionButton(
                    label: 'Paste seed phrase',
                    onPressed: () async => openPasteSeed(context),
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

class _PhoneNoWalletCard extends StatelessWidget {
  const _PhoneNoWalletCard();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SailCard(
        padding: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SailStyleValues.padding16,
            SailStyleValues.padding16,
            SailStyleValues.padding16,
            SailStyleValues.padding08,
          ),
          child: SailColumn(
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary15('You need a wallet to send and receive', bold: true),
              SailText.secondary13('Make a new wallet, or restore one from its seed phrase or a descriptor.'),
              const SizedBox(height: SailStyleValues.padding04),
              SailStatList(
                panel: false,
                children: [
                  _ActionRow(
                    icon: SailSVGAsset.plus,
                    label: 'Generate wallet',
                    onTap: () async => openGenerateWallet(context),
                  ),
                  _ActionRow(
                    icon: SailSVGAsset.clipboardPaste,
                    label: 'Paste seed phrase',
                    onTap: () async => openPasteSeed(context),
                  ),
                  _ActionRow(
                    icon: SailSVGAsset.upload,
                    label: 'Import descriptor',
                    onTap: () async => showImportDescriptorDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final SailSVGAsset icon;
  final String label;
  final Future<void> Function() onTap;

  const _ActionRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return SailTappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding12),
        child: SailRow(
          spacing: SailStyleValues.padding10,
          children: [
            SailSVG.icon(icon, width: 14, height: 14, color: theme.colors.textTertiary),
            Expanded(child: SailText.primary13(label)),
          ],
        ),
      ),
    );
  }
}
