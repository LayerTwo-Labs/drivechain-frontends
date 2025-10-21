import 'package:auto_route/auto_route.dart';
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
  final Logger _logger = GetIt.I.get<Logger>();
  String? _errorMessage;
  bool _isUnlocking = false;
  String? _pendingPassword;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    super.dispose();
  }

  /// Automatically attempt decryption on each keystroke
  void _onPasswordChanged() {
    final password = _passwordController.text;
    if (password.isEmpty || _isUnlocking) return;

    // Store the password we're attempting to decrypt with
    _pendingPassword = password;

    // Try decryption in background without blocking UI
    _tryAutoDecrypt(password);
  }

  /// Attempt automatic decryption in background
  Future<void> _tryAutoDecrypt(String password) async {
    try {
      final walletReader = GetIt.I.get<WalletReaderProvider>();

      // Try to unlock wallet (runs PBKDF2 in background isolate)
      final success = await walletReader.unlockWallet(password);

      if (!mounted) {
        return;
      }
      if (_pendingPassword != password) {
        return;
      }

      if (success) {
        if (mounted) {
          context.router.pop();
        }
      } else {
        _logger.d('_tryAutoDecrypt: Wrong password (length ${password.length})');
      }
    } catch (e, stack) {
      // Silently fail - user can still manually submit
      _logger.e('Auto-decrypt error: $e\n$stack');
    }
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
                title: 'Decrypt Your Wallet',
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
                  SailButton(
                    label: 'Decrypt Wallet',
                    variant: ButtonVariant.primary,
                    loading: _isUnlocking,
                    onPressed: _handleUnlock,
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
      final walletReader = GetIt.I.get<WalletReaderProvider>();
      final success = await walletReader.unlockWallet(_passwordController.text);

      if (!mounted) return;

      if (success) {
        if (mounted) {
          context.router.pop();
        }
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
