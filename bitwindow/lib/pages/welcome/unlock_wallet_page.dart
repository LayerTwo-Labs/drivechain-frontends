import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/encryption_provider.dart';
import 'package:bitwindow/providers/wallet_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class UnlockWalletPage extends StatefulWidget {
  const UnlockWalletPage({super.key});

  @override
  State<UnlockWalletPage> createState() => _UnlockWalletPageState();
}

class _UnlockWalletPageState extends State<UnlockWalletPage> {
  final TextEditingController _passwordController = TextEditingController();
  final EncryptionProvider _encryptionProvider = GetIt.I.get<EncryptionProvider>();
  final Logger _logger = GetIt.I.get<Logger>();
  String? _errorMessage;
  bool _isUnlocking = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SailTheme.of(context).colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: SailTheme.of(context).colors.background,
        foregroundColor: SailTheme.of(context).colors.text,
      ),
      body: SafeArea(
        child: _buildUnlockScreen(),
      ),
    );
  }

  Widget _buildUnlockScreen() {
    final theme = SailTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: SizedBox(
          width: 800,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const BootTitle(
                title: 'Unlock Your Wallet',
                subtitle: 'Your wallet is encrypted. Please enter your password to unlock it and continue.',
              ),
              const Spacer(),
              // Password input
              SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SailTextField(
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      obscureText: true,
                      textFieldType: TextFieldType.text,
                      size: TextFieldSize.regular,
                      enabled: !_isUnlocking,
                      onSubmitted: (_) => _handleUnlock(),
                      autofocus: true,
                      maxLines: 1,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      SailText.secondary12(
                        _errorMessage!,
                        color: theme.colors.error,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Spacer(),
              const Spacer(),
              // Unlock button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 48,
                    child: SailButton(
                      label: 'Unlock Wallet',
                      variant: ButtonVariant.primary,
                      loading: _isUnlocking,
                      onPressed: _handleUnlock,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUnlock() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    setState(() {
      _isUnlocking = true;
      _errorMessage = null;
    });

    try {
      final success = await _encryptionProvider.unlockWallet(_passwordController.text);

      if (!mounted) return;

      if (success) {
        // Unlock successful, sync starter files so binaries can use the wallet
        try {
          final walletProvider = GetIt.I.get<WalletProvider>();
          await walletProvider.syncStarterFiles();
          _logger.i('Synced starter files after wallet unlock');
        } catch (e) {
          _logger.e('Failed to sync starter files after unlock: $e');
        }

        // Navigate to main app
        await GetIt.I.get<AppRouter>().replaceAll([const RootRoute()]);
      } else {
        setState(() {
          _errorMessage = 'Incorrect password. Please try again.';
          _isUnlocking = false;
          _passwordController.clear();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error unlocking wallet: $e';
        _isUnlocking = false;
      });
    }
  }
}

class BootTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const BootTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        SailText.primary40(
          title,
          bold: true,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SailText.primary15(
          subtitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
