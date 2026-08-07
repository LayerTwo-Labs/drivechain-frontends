import 'package:bitwindow/dialogs/change_password_dialog.dart';
import 'package:bitwindow/dialogs/encrypt_wallet_dialog.dart';
import 'package:bitwindow/main.dart' show rebootBitwindowBackend;
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart' as sail_routes;
import 'package:sail_ui/sail_ui.dart';

class SettingsWallet extends StatefulWidget {
  const SettingsWallet({super.key});

  @override
  State<SettingsWallet> createState() => _SettingsWalletState();
}

class _SettingsWalletState extends State<SettingsWallet> {
  final WalletReaderProvider _walletReader = GetIt.I.get<WalletReaderProvider>();
  final WalletWriterProvider _walletWriter = GetIt.I.get<WalletWriterProvider>();
  bool _isEncrypted = false;
  bool _isCheckingEncryption = true;

  @override
  void initState() {
    super.initState();
    _checkEncryptionStatus();
    _walletReader.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _walletReader.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    _checkEncryptionStatus();
    setState(() {});
  }

  Future<void> _checkEncryptionStatus() async {
    final encrypted = await _walletReader.isWalletEncrypted();
    if (mounted) {
      setState(() {
        _isEncrypted = encrypted;
        _isCheckingEncryption = false;
      });
    }
  }

  Future<void> _editWallet(WalletMetadata wallet) async {
    await showThemedDialog(
      context: context,
      builder: (context) => WalletManagementDialog(
        existingWallet: wallet,
        onSave: (name, gradient) async {
          await _walletWriter.updateWalletMetadata(wallet.id, name, gradient);
        },
        onDelete: () async {
          await _walletReader.removeWalletFromList(wallet.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailSettingsBody(
      children: [
        SailSettingsGroup(
          title: 'Wallets',
          children: [
            if (_walletReader.availableWallets.isEmpty)
              SailSettingsRow(
                label: 'No wallets',
                description: 'Create one to get started',
              )
            else
              ..._walletReader.availableWallets.map((wallet) {
                final isActive = wallet.id == _walletReader.activeWalletId;
                return SailSettingsRow(
                  leading: WalletBlobAvatar(gradient: wallet.gradient, size: 24),
                  label: wallet.name,
                  description: isActive ? 'Active wallet' : null,
                  trailing: SailButton(
                    label: 'Edit',
                    small: true,
                    variant: ButtonVariant.secondary,
                    onPressed: () async => _editWallet(wallet),
                  ),
                );
              }),
            SailSettingsRow(
              label: 'New wallet',
              description: 'Add another wallet to this node',
              trailing: SailButton(
                label: 'Create',
                small: true,
                onPressed: () async {
                  await GetIt.I.get<AppRouter>().push(CreateAnotherWalletRoute());
                },
              ),
            ),
          ],
        ),
        SailSettingsGroup(
          title: 'Encryption',
          children: [
            if (_isCheckingEncryption)
              SailSettingsRow(
                label: 'Wallet encryption',
                trailing: SizedBox(width: 20, height: 20, child: LoadingIndicator(color: theme.colors.primary)),
              )
            else if (!_isEncrypted)
              SailSettingsRow(
                label: 'Wallet encryption',
                description: 'Protect your wallet with a password',
                trailing: SailButton(
                  label: 'Encrypt',
                  small: true,
                  onPressed: () async {
                    final result = await EncryptWalletDialog.show(context);
                    if (result == true) {
                      await _checkEncryptionStatus();
                      if (context.mounted) {
                        showSailToast(context, 'Wallet encrypted', variant: SailToastVariant.success);
                      }
                    }
                  },
                ),
              )
            else ...[
              SailSettingsRow(
                label: 'Wallet encryption',
                description: 'This wallet is encrypted',
                descriptionColor: theme.colors.success,
                trailing: SailButton(
                  label: 'Change password',
                  small: true,
                  variant: ButtonVariant.secondary,
                  skipLoading: true,
                  onPressed: () async {
                    final result = await ChangePasswordDialog.show(context);
                    if (result == true && context.mounted) {
                      showSailToast(context, 'Password changed', variant: SailToastVariant.success);
                    }
                  },
                ),
              ),
              SailSettingsRow(
                label: 'Remove encryption',
                description: 'Store the wallet unencrypted again',
                destructive: true,
                trailing: SailButton(
                  label: 'Remove',
                  small: true,
                  variant: ButtonVariant.destructive,
                  skipLoading: true,
                  onPressed: () async {
                    await GetIt.I.get<AppRouter>().push(RemoveEncryptionRoute());
                    await _checkEncryptionStatus();
                  },
                ),
              ),
            ],
          ],
        ),
        SailSettingsGroup(
          title: 'Backup',
          children: [
            SailSettingsRow(
              label: 'Create backup',
              description: 'Writes a ZIP of all wallet files and multisig data',
              trailing: SailButton(
                label: 'Back up',
                small: true,
                onPressed: () async {
                  await GetIt.I.get<AppRouter>().push(sail_routes.BackupWalletRoute(appName: 'bitwindow'));
                },
              ),
            ),
            SailSettingsRow(
              label: 'Restore from backup',
              description: 'Reads a local backup file back into this node',
              trailing: SailButton(
                label: 'Restore',
                small: true,
                variant: ButtonVariant.secondary,
                onPressed: () async {
                  await GetIt.I.get<AppRouter>().push(
                    sail_routes.RestoreWalletRoute(
                      bootBinaries: (log) async => rebootBitwindowBackend(log),
                      binariesToStop: [BitcoinCore(), Enforcer(), BitWindow()],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
