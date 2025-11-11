import 'package:auto_route/auto_route.dart' hide AutoRouterX;
import 'package:bitwindow/providers/cheque_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:stacked/stacked.dart';

class ChequeDetailViewModel extends BaseViewModel {
  Logger get log => GetIt.I.get<Logger>();
  final ChequeProvider _chequeProvider = GetIt.I.get<ChequeProvider>();
  final TransactionProvider _transactionProvider = GetIt.I.get<TransactionProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();
  final int chequeId;

  Cheque? _cheque;
  bool _isLoading = false;
  @override
  String? modelError;

  Cheque? get cheque => _cheque;
  bool get isLoading => _isLoading;

  ChequeDetailViewModel(this.chequeId) {
    _loadCheque();
    _chequeProvider.addListener(_onChequeProviderChanged);
  }

  void _onChequeProviderChanged() {
    // Reload when provider updates (e.g., from polling)
    _loadCheque();
  }

  Future<void> _loadCheque() async {
    _isLoading = true;
    notifyListeners();

    _cheque = await _chequeProvider.getCheque(chequeId);
    if (_cheque == null) {
      modelError = 'Check not found';
    } else if (!_cheque!.hasFundedTxid()) {
      // Start polling if not yet funded
      _chequeProvider.startPolling(chequeId);
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _chequeProvider.removeListener(_onChequeProviderChanged);
    super.dispose();
  }

  void copyAddress(BuildContext context) {
    if (_cheque != null) {
      Clipboard.setData(ClipboardData(text: _cheque!.address));
      showSnackBar(context, 'Address copied to clipboard');
    }
  }

  void copyTxid(BuildContext context, String txid) {
    Clipboard.setData(ClipboardData(text: txid));
    showSnackBar(context, 'Transaction ID copied to clipboard');
  }

  Future<void> fundWithWallet(BuildContext context) async {
    if (_cheque == null) return;

    final bitwindowRPC = GetIt.I.get<BitwindowRPC>();

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      final amountSats = _cheque!.expectedAmountSats.toInt();

      // Send bitcoin to the cheque address using the enforcer wallet
      final txid = await bitwindowRPC.wallet.sendTransaction(
        walletId,
        {_cheque!.address: amountSats},
        feeSatPerVbyte: 10, // Default fee rate
      );

      if (!context.mounted) return;

      showSnackBar(
        context,
        'Transaction sent! TXID: ${txid.substring(0, 10)}...',
      );

      // Navigate back to wallet page
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      showSnackBar(
        context,
        'Failed to fund cheque: $e',
      );
    }
  }

  Future<void> sweepCheque(BuildContext context) async {
    if (_cheque == null || !_cheque!.hasFundedTxid()) return;

    // Check if wallet is locked before attempting sweep
    if (!_chequeProvider.isWalletUnlocked) {
      if (!context.mounted) return;
      await _showUnlockDialog(context);
      // After unlock dialog closes, check again if unlocked
      if (!_chequeProvider.isWalletUnlocked) {
        return;
      }
    }

    final destinationAddress = _transactionProvider.address;
    if (destinationAddress.isEmpty) {
      if (context.mounted) {
        showSnackBar(context, 'No receive address available');
      }
      return;
    }

    // Get the private key WIF - this requires the cheque to have it
    if (!_cheque!.hasPrivateKeyWif() || _cheque!.privateKeyWif.isEmpty) {
      if (context.mounted) {
        showSnackBar(context, 'Private key not available - wallet may be locked');
      }
      return;
    }

    try {
      final txid = await _chequeProvider.sweepCheque(
        _cheque!.privateKeyWif,
        destinationAddress,
        10, // Default fee rate of 10 sat/vbyte
      );

      if (txid == null) {
        if (!context.mounted) return;

        // Check if wallet became locked during operation
        if (!_chequeProvider.isWalletUnlocked) {
          await _showUnlockDialog(context);
          return;
        }

        showSnackBar(
          context,
          'Failed to sweep cheque: ${_chequeProvider.modelError ?? "Unknown error"}',
        );
        return;
      }

      if (!context.mounted) return;

      showSnackBar(
        context,
        'Check swept! TXID: ${txid.substring(0, 10)}...',
      );

      // Navigate back to wallet page
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;

      showSnackBar(
        context,
        'Failed to sweep cheque: $e',
      );
    }
  }

  Future<void> _showUnlockDialog(BuildContext context) async {
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
                SailText.secondary13('Enter your wallet password to sweep cheques'),
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

@RoutePage()
class ChequeDetailPage extends StatelessWidget {
  final int chequeId;

  const ChequeDetailPage({
    super.key,
    @PathParam('id') required this.chequeId,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChequeDetailViewModel>.reactive(
      viewModelBuilder: () => ChequeDetailViewModel(chequeId),
      builder: (context, model, child) {
        final amountBTC = model.cheque != null
            ? (model.cheque!.expectedAmountSats.toInt() / 100000000).toStringAsFixed(8)
            : '0.00000000';

        return Scaffold(
          backgroundColor: SailTheme.of(context).colors.background,
          appBar: AppBar(
            backgroundColor: SailTheme.of(context).colors.background,
            foregroundColor: SailTheme.of(context).colors.text,
            title: SailText.primary20('Check for $amountBTC BTC'),
          ),
          body: Builder(
            builder: (context) {
              if (model.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (model.modelError != null || model.cheque == null) {
                return Center(
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SailText.primary15(model.modelError ?? 'Check not found'),
                      SailButton(
                        label: 'Go Back',
                        onPressed: () async => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }

              final cheque = model.cheque!;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(SailStyleValues.padding40),
                      child: SailColumn(
                        spacing: SailStyleValues.padding20,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer circle
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cheque.hasFundedTxid()
                                            ? context.sailTheme.colors.success.withValues(alpha: 0.2)
                                            : context.sailTheme.colors.orange.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    // Middle circle
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cheque.hasFundedTxid()
                                            ? context.sailTheme.colors.success.withValues(alpha: 0.5)
                                            : context.sailTheme.colors.orange.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    // Inner circle
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cheque.hasFundedTxid()
                                            ? context.sailTheme.colors.success
                                            : context.sailTheme.colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: SailStyleValues.padding12),
                              SailText.primary13(
                                cheque.hasFundedTxid() ? 'Funded' : 'Awaiting funding',
                              ),
                            ],
                          ),

                          // QR Code
                          if (!cheque.hasFundedTxid())
                            Container(
                              padding: const EdgeInsets.all(SailStyleValues.padding20),
                              decoration: BoxDecoration(
                                color: context.sailTheme.colors.backgroundSecondary,
                                borderRadius: SailStyleValues.borderRadiusSmall,
                              ),
                              child: QrImageView(
                                data: cheque.address,
                                version: QrVersions.auto,
                                size: 200,
                                backgroundColor: context.sailTheme.colors.backgroundSecondary,
                              ),
                            ),

                          // Address with copy button
                          if (!cheque.hasFundedTxid())
                            SailRow(
                              spacing: SailStyleValues.padding08,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: SailText.primary13(
                                    cheque.address,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                CopyButton(text: cheque.address),
                              ],
                            ),

                          // Private key section (only shown when funded)
                          if (cheque.hasFundedTxid() && cheque.hasPrivateKeyWif() && cheque.privateKeyWif.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(SailStyleValues.padding16),
                              decoration: BoxDecoration(
                                color: context.sailTheme.colors.backgroundSecondary,
                                borderRadius: SailStyleValues.borderRadiusSmall,
                                border: Border.all(
                                  color: context.sailTheme.colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: SailColumn(
                                spacing: SailStyleValues.padding08,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SailSVG.icon(SailSVGAsset.iconWarning, width: 16),
                                      const SizedBox(width: SailStyleValues.padding08),
                                      SailText.primary13(
                                        'Private Key (WIF)',
                                        bold: true,
                                      ),
                                    ],
                                  ),
                                  SailText.secondary12(
                                    'Share this private key with the recipient. They can import it into most Bitcoin wallets to access the funds.',
                                  ),
                                  SailRow(
                                    spacing: SailStyleValues.padding08,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: SelectableText(
                                          cheque.privateKeyWif,
                                          style: TextStyle(
                                            fontFamily: 'IBMPlexMono',
                                            fontSize: 12,
                                            color: context.sailTheme.colors.text,
                                          ),
                                        ),
                                      ),
                                      CopyButton(text: cheque.privateKeyWif),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          // Fund button (only if not funded)
                          if (!cheque.hasFundedTxid())
                            SizedBox(
                              width: 400,
                              height: 64,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.sailTheme.colors.primary,
                                      context.sailTheme.colors.primary,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () => model.fundWithWallet(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: SailText.primary15(
                                    'Fund with Wallet',
                                    color: Colors.white,
                                    bold: true,
                                  ),
                                ),
                              ),
                            ),

                          // Sweep button (only if funded)
                          if (cheque.hasFundedTxid())
                            SizedBox(
                              width: 400,
                              height: 64,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.sailTheme.colors.success,
                                      context.sailTheme.colors.success,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () => model.sweepCheque(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: SailText.primary15(
                                    'Sweep Cheque to Wallet',
                                    color: Colors.white,
                                    bold: true,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
