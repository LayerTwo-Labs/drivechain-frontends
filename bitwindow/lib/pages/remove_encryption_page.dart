import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class RemoveEncryptionPage extends StatefulWidget {
  const RemoveEncryptionPage({super.key});

  @override
  State<RemoveEncryptionPage> createState() => _RemoveEncryptionPageState();
}

class _RemoveEncryptionPageState extends State<RemoveEncryptionPage> {
  final _passwordController = TextEditingController();
  bool _isRemoving = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _removeEncryption() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    setState(() {
      _isRemoving = true;
      _errorMessage = null;
    });

    try {
      final walletReader = GetIt.I.get<WalletReaderProvider>();
      await walletReader.removeEncryption(_passwordController.text);

      if (!mounted) return;

      await GetIt.I.get<AppRouter>().replace(SuccessRoute(title: 'Encryption Removed'));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Incorrect password')
            ? 'Incorrect password'
            : 'Error removing encryption: $e';
        _isRemoving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        foregroundColor: theme.colors.text,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SailText.primary24('REMOVE ENCRYPTION', bold: true),
                const SizedBox(height: SailStyleValues.padding32),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(SailStyleValues.padding12),
                    decoration: BoxDecoration(
                      color: theme.colors.error.withValues(alpha: 0.1),
                      borderRadius: SailStyleValues.borderRadiusSmall,
                      border: Border.all(color: theme.colors.error),
                    ),
                    child: SailText.secondary13(_errorMessage!),
                  ),
                  const SizedBox(height: SailStyleValues.padding16),
                ],
                SailTextField(
                  controller: _passwordController,
                  label: 'Current Password',
                  hintText: 'Enter your current password',
                  obscureText: _obscurePassword,
                  enabled: !_isRemoving,
                  autofocus: true,
                  maxLines: 1,
                  onSubmitted: (_) => _removeEncryption(),
                  suffixWidget: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: theme.colors.text,
                    ),
                  ),
                ),
                const SizedBox(height: SailStyleValues.padding32),
                SailButton(
                  label: 'REMOVE ENCRYPTION',
                  variant: ButtonVariant.destructive,
                  loading: _isRemoving,
                  onPressed: () async => _removeEncryption(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
