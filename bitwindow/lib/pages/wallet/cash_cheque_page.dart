import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/cheque_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class CashChequePage extends StatefulWidget {
  const CashChequePage({super.key});

  @override
  State<CashChequePage> createState() => _CashChequePageState();
}

class _CashChequePageState extends State<CashChequePage> {
  final ChequeProvider _chequeProvider = GetIt.I.get<ChequeProvider>();
  final BitwindowRPC _bitwindowRPC = GetIt.I.get<BitwindowRPC>();
  final TextEditingController _wifController = TextEditingController();
  bool _isCashing = false;

  @override
  void dispose() {
    _wifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SailTheme.of(context).colors.background,
      appBar: AppBar(
        backgroundColor: SailTheme.of(context).colors.background,
        foregroundColor: SailTheme.of(context).colors.text,
        title: SailText.primary20('Cash Cheque'),
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
                  SailText.primary24('Enter the private key (WIF)'),
                  SailText.secondary13(
                    'Paste the private key from the cheque you received. The funds will be swept to your wallet.',
                    textAlign: TextAlign.center,
                  ),
                  SailTextField(
                    controller: _wifController,
                    hintText: 'Private key (WIF format)',
                    textFieldType: TextFieldType.text,
                    maxLines: 3,
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
                        label: 'Cash Cheque',
                        loading: _isCashing,
                        onPressed: () async => _cashCheque(),
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

  Future<void> _cashCheque() async {
    final wif = _wifController.text.trim();
    if (wif.isEmpty) {
      showSnackBar(context, 'Please enter a private key');
      return;
    }

    // Check if wallet is locked before attempting to import cheque
    if (!_chequeProvider.isWalletUnlocked) {
      if (!mounted) return;
      await _showUnlockDialog();
      // After unlock dialog closes, check again if unlocked
      if (!_chequeProvider.isWalletUnlocked) {
        return;
      }
    }

    setState(() {
      _isCashing = true;
    });

    try {
      // Get user's receive address
      final destinationAddress = await _bitwindowRPC.wallet.getNewAddress();

      // Sweep the cheque to the user's wallet
      final result = await _bitwindowRPC.wallet.sweepCheque(
        wif,
        destinationAddress,
        10, // Default fee rate of 10 sat/vbyte
      );

      setState(() {
        _isCashing = false;
      });

      if (!mounted) return;

      // Navigate to success page
      await context.router.replace(
        CashChequeSuccessRoute(
          txid: result.txid,
          amountSats: result.amountSats,
        ),
      );
    } catch (e) {
      setState(() {
        _isCashing = false;
      });

      if (mounted) {
        // Check if wallet became locked during operation
        if (e.toString().toLowerCase().contains('wallet is locked') && !_chequeProvider.isWalletUnlocked) {
          await _showUnlockDialog();
          return;
        }

        showSnackBar(context, 'Failed to cash cheque: $e');
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
                SailText.secondary13('Enter your wallet password to cash cheques'),
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
                final success = await _chequeProvider.unlockWallet(passwordController.text);

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                } else {
                  setState(() => isUnlocking = false);
                  if (context.mounted) {
                    showSnackBar(context, _chequeProvider.modelError ?? 'Failed to unlock wallet');
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
