import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/check_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CreateCheckPage extends StatefulWidget {
  const CreateCheckPage({super.key});

  @override
  State<CreateCheckPage> createState() => _CreateCheckPageState();
}

class _CreateCheckPageState extends State<CreateCheckPage> {
  final CheckProvider _checkProvider = GetIt.I.get<CheckProvider>();
  final WalletReaderProvider _walletReader = GetIt.I.get<WalletReaderProvider>();
  final TextEditingController _amountController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SailTheme.of(context).colors.background,
      appBar: AppBar(
        backgroundColor: SailTheme.of(context).colors.background,
        foregroundColor: SailTheme.of(context).colors.text,
        title: SailText.primary20('Create Check'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(SailStyleValues.padding20),
              child: SailColumn(
                spacing: SailStyleValues.padding32,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SailText.primary24('How much should the check be for?'),
                  SailTextField(
                    controller: _amountController,
                    hintText: '0.00000000',
                    suffix: 'BTC',
                    textFieldType: TextFieldType.bitcoin,
                  ),
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SailButton(
                        label: 'Cancel',
                        variant: ButtonVariant.ghost,
                        onPressed: () async => context.router.maybePop(),
                      ),
                      SailButton(
                        label: 'Create',
                        loading: _isCreating,
                        onPressed: () async => _createCheck(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createCheck() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      showSnackBar(context, 'Please enter an amount');
      return;
    }

    final btcAmount = double.tryParse(amountText);
    if (btcAmount == null || btcAmount <= 0) {
      showSnackBar(context, 'Please enter a valid amount');
      return;
    }

    final sats = (btcAmount * 100000000).toInt();

    setState(() {
      _isCreating = true;
    });

    try {
      final check = await _checkProvider.createCheck(sats);
      if (!mounted) return;
      await context.router.replace(CheckDetailRoute(checkId: check.id.toInt()));
    } catch (e) {
      if (!mounted) return;

      if (e.toString().toLowerCase().contains('wallet is locked')) {
        final isEncrypted = await _walletReader.isWalletEncrypted();
        if (!mounted) return;
        if (isEncrypted) {
          await _showUnlockDialog();
          if (!mounted) return;
          if (_walletReader.isWalletUnlocked) {
            await _createCheck();
          }
        } else {
          showSnackBar(context, 'Backend wallet not initialized. Please restart the app.');
        }
      } else {
        showSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _showUnlockDialog() async {
    final passwordController = TextEditingController();
    bool isUnlocking = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SailTheme.of(context).colors.background,
          title: SailText.primary15('Unlock Wallet'),
          content: SizedBox(
            width: 400,
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              mainAxisSize: MainAxisSize.min,
              children: [
                SailText.secondary13('Enter your wallet password to create checks'),
                SailTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          actions: [
            SailButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () async => Navigator.of(context).pop(),
            ),
            SailButton(
              label: 'Unlock',
              loading: isUnlocking,
              onPressed: () async {
                setState(() => isUnlocking = true);
                final success = await _walletReader.unlockWallet(passwordController.text);

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                } else {
                  setState(() => isUnlocking = false);
                  if (context.mounted) {
                    showSnackBar(context, 'Incorrect password');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );

    passwordController.dispose();
  }
}
